#!/usr/bin/env python3
"""Compare rainbow coloring with the disabled path and an optional old checkout."""
import argparse
import json
from pathlib import Path
import statistics
import subprocess
import tempfile
import time

ROOT = Path(__file__).resolve().parents[1]
SOURCES = {
    "typical": "\n".join(
        f'fn f{i}() {{\n    let value = {i};\n    println!("value", value);\n}}'
        for i in range(250)
    ),
    "dense": "\n".join(
        f'fn f{i}() {{ let x = [1, 2]; println!("{{}}", x[0]); }}'
        for i in range(1000)
    ),
    "no-delimiters": "\n".join(f"let value{i} = {i};" for i in range(1000)),
}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--baseline", type=Path, help="An old checkout containing codly.typ")
    parser.add_argument("--repeats", type=int, default=3)
    parser.add_argument("--case", choices=SOURCES, action="append", dest="cases")
    args = parser.parse_args()
    if args.repeats < 1:
        parser.error("--repeats must be positive")
    variants = [("disabled", ROOT, False), ("enabled", ROOT, True)]
    if args.baseline:
        variants.insert(0, ("baseline", args.baseline.resolve(), False))
    with tempfile.TemporaryDirectory(prefix="codly-rainbow-bench-") as directory:
        temporary = Path(directory)
        for case in args.cases or SOURCES:
            paths = {}
            for name, root, enabled in variants:
                path = temporary / f"{name}.typ"
                path.write_text(
                    f'#import {json.dumps(str(root / "codly.typ"), ensure_ascii=False)} as codly\n'
                    '#set page(width: 400pt, height: 600pt, margin: 10pt)\n'
                    f'#codly.new(raw({json.dumps(SOURCES[case])}, lang: "rs", block: true)'
                    + (", rainbow: true" if enabled else "") + ")\n"
                )
                paths[name] = path
            times = {name: [] for name in paths}
            for _ in range(args.repeats):
                for name, path in paths.items():
                    start = time.perf_counter()
                    subprocess.run(
                        ["typst", "compile", "--root", "/", str(path), str(temporary / "out.pdf")],
                        check=True, stdout=subprocess.DEVNULL,
                    )
                    times[name].append(time.perf_counter() - start)
            print(json.dumps({
                "case": case,
                "median_seconds": {name: round(statistics.median(runs), 3) for name, runs in times.items()},
                "runs_seconds": {name: [round(t, 3) for t in runs] for name, runs in times.items()},
            }), flush=True)


if __name__ == "__main__":
    main()
