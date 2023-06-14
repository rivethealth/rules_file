import os.path
from rules_python.python.runfiles import runfiles
import sys

r = runfiles.Create()


def main(args):
    difference = False
    for diff in args.diffs:
        diff = r.Rlocation(diff)
        if not os.path.getsize(diff):
            continue
        if not difference:
            print("Differences detected")
            difference = True
        with open(diff, "r") as f:
            print(f.read())
    if difference:
        sys.exit(1)
