import argparse
import pathlib
import shutil

parser = argparse.ArgumentParser(fromfile_prefix_chars="@", prog="directory")
parser.add_argument("files", type=pathlib.Path, nargs="*")
args = parser.parse_args()

for i in range(0, len(args.files), 2):
    input = args.files[i]
    output = args.files[i + 1]
    output.parent.mkdir(parents=True, exist_ok=True)
    if input.is_dir():
        shutil.copytree(input, output, copy_function=shutil.copy)
    else:
        shutil.copy(input, output)
