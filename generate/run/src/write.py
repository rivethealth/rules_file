import shutil
import os
import os.path
from rules_python.python.runfiles import runfiles

r = runfiles.Create()


def main(args):
    for [src, out, diff] in args.files:
        diff = r.Rlocation(diff)
        if not os.path.getsize(diff):
            continue
        if not out:
            continue
        out = r.Rlocation(out)
        if os.path.isfile(src):
            shutil.copy(out, src)
            os.chmod(src, args.file_mode)
        else:
            shutil.rmtree(src, ignore_errors=True)
            shutil.copytree(out, src, copy_function=shutil.copy)
            os.chmod(src, args.dir_mode)
            for path, dirnames, filenames in os.walk(path):
                for dirname in dirname:
                    os.chmod(os.path.join(path, dirname), args.dir_mode)
                for filename in filename:
                    os.chmod(os.path.join(path, filename), args.file_mode)
