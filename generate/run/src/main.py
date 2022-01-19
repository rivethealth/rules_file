__package__ = "generate.run.src"
import argparse


def octal_int(x):
    return int(x, 8)


parser = argparse.ArgumentParser(fromfile_prefix_chars="@")
subparsers = parser.add_subparsers(dest="command")

check_parser = subparsers.add_parser("check")
check_parser = check_parser.add_argument("diffs", nargs="*")

write_parser = subparsers.add_parser("write")
write_parser.add_argument("--file-mode", required=True, type=octal_int)
write_parser.add_argument("--dir-mode", required=True, type=octal_int)
write_parser.add_argument(
    "--file",
    action="append",
    help="Tuple of src, out, diff",
    default=[],
    dest="files",
    nargs=3,
)

args = parser.parse_args()

if args.command == "check":
    from .check import main

    main(args)
elif args.command == "write":
    from .write import main

    main(args)
