import fs from 'node:fs/promises';
import path from 'node:path';
import { availableParallelism } from 'node:os';
import { Worker } from 'node:worker_threads';

export function previewConcurrency(exampleCount, requested = process.env.CODLY_DOCS_WORKERS, cpus = availableParallelism()) {
  if (requested !== undefined && (!/^[1-9]\d*$/.test(String(requested)) || !Number.isSafeInteger(Number(requested)))) {
    throw new Error('CODLY_DOCS_WORKERS must be a positive integer.');
  }
  return Math.min(exampleCount, requested === undefined ? Math.min(cpus, 4) : Number(requested));
}

export async function renderPreviews({ examples, engine, outputDirectory, workers }) {
  const unique = [...new Map(examples.map(example => [example.id, example])).values()];
  if (!unique.length) return;
  const count = previewConcurrency(unique.length, workers);
  outputDirectory = path.resolve(outputDirectory);
  await fs.mkdir(outputDirectory, { recursive: true });
  const pool = [];
  let next = 0, idle = 0;
  try {
    await new Promise((resolve, reject) => {
      for (let index = 0; index < count; index++) {
        const worker = new Worker(new URL('./preview-worker.mjs', import.meta.url), {
          workerData: { engine, outputDirectory },
        });
        pool.push(worker);
        worker.on('message', () => {
          if (next < unique.length) worker.postMessage(unique[next++]);
          else if (++idle === count) resolve();
        });
        worker.on('error', reject);
        worker.on('exit', code => reject(new Error(`Preview worker exited unexpectedly (${code}).`)));
      }
    });
  } finally {
    await Promise.all(pool.map(worker => worker.terminate()));
  }
}
