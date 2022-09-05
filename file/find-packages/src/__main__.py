import argparse
import pathlib
import os
from os import path

parser = argparse.ArgumentParser(prog="find-packages")
parser.add_argument("root", type=pathlib.Path)
parser.add_argument("roots", nargs="*")
parser.add_argument("--prefix", default="")
args = parser.parse_args()


def packages(root):
    for root, _, files in os.walk(args.root / root):
        if "BUILD" in files or "BUILD.bazel" in files:
            yield pathlib.Path(root).relative_to(args.root)


for root in args.roots:
    for package in sorted(packages(root), key=str):
        print(
            args.prefix
            if str(package) == "."
            else f"{args.prefix}/{package}"
            if args.prefix
            else package
        )
