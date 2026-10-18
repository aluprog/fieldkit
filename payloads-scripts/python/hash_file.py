#!/usr/bin/env python3
"""Print a SHA-256 checksum for a local file."""
import hashlib, pathlib, sys
def main():
    if len(sys.argv) != 2:
        print(f"Usage: {pathlib.Path(sys.argv[0]).name} FILE", file=sys.stderr); return 2
    p = pathlib.Path(sys.argv[1])
    if not p.is_file():
        print(f"Not a regular file: {p}", file=sys.stderr); return 1
    h = hashlib.sha256()
    with p.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""): h.update(chunk)
    print(f"{h.hexdigest()}  {p}"); return 0
if __name__ == "__main__": raise SystemExit(main())
