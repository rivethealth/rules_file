import argparse
import black
import contextlib
import io
import pathlib
import setproctitle
import sys
from bazelwatcher2 import worker

setproctitle.setproctitle("black-worker")

parser = argparse.ArgumentParser(prog="black-worker")
parser.add_argument("--black-option", action="append", default=[], dest="black_options")
parser.add_argument("src", type=pathlib.Path)
parser.add_argument("dest", type=pathlib.Path)


@contextlib.contextmanager
def _detach_wrapper(wrapper):
    try:
        yield wrapper
    finally:
        wrapper.detach()


@contextlib.contextmanager
def _modify_std(stdin=None, stdout=None, stderr=None):
    if stdin is not None:
        real_stdin = sys.stdin
        sys.stdin = stdin
    if stdout is not None:
        real_stdout = sys.stdout
        sys.stdout = stdout
    if stderr is not None:
        real_stderr = sys.stderr
        sys.stderr = stderr
    try:
        yield
    finally:
        if stdin is not None:
            sys.stdin = real_stdin
        if stdout is not None:
            sys.stdout = real_stdout
        if stderr is not None:
            sys.stderr = real_stderr


def _run(args):
    args = parser.parse_args(args)

    output = io.BytesIO()
    stderr = io.TextIOWrapper(output, write_through=True)
    with args.src.open() as stdin, args.dest.open("w") as stdout, _modify_std(
        stdin=stdin, stdout=stdout, stderr=stderr
    ):
        try:
            black.main(
                args.black_options + ["-q", "--stdin-filename", str(args.src), "-"]
            )
        except SystemExit as e:
            exit_code = e.code
        else:
            exit_code = 0

    return worker.WorkResult(exit_code=exit_code, output=output.getvalue())


def _worker_factory(_):
    return lambda args, _: _run(args)


worker.main(_worker_factory)
