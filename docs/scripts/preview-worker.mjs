import fs from 'node:fs/promises';
import path from 'node:path';
import { parentPort, workerData } from 'node:worker_threads';
import { createEngine } from '../runtime/compiler.mjs';

const compile = await createEngine(workerData.engine);
parentPort.on('message', async example => {
  try {
    const svg = await compile(example.source);
    await fs.writeFile(path.join(workerData.outputDirectory, `${example.id}.svg`), svg);
  } catch (error) {
    throw new Error(`${example.chapter}: ${error.message}`, { cause: error });
  }
  parentPort.postMessage('done');
});
parentPort.postMessage('ready');
