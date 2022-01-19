import os
import os.path
import shutil
import stat
from rules_python.python.runfiles import runfiles

r = runfiles.Create()


def main(args):
    for [src, out, diff] in args.files:
        # check diff
        diff = r.Rlocation(diff)
        if not os.path.getsize(diff):
            continue

        print(src)

        # remove src
        try:
            src_stat = os.stat(src)
        except FileNotFoundError:
            pass
        else:
            if stat.S_ISDIR(src_stat.st_mode):
                shutil.rmtree(src)
            else:
                os.remove(src)

        if not out:
            continue

        # copy out to src
        dir = os.path.dirname(src)
        if dir:
            os.makedirs(os.path.dirname(src), exist_ok=True)
        out = r.Rlocation(out)
        out_stat = os.stat(out)
        if stat.S_ISDIR(out_stat.st_mode):
            shutil.copytree(out, src, copy_function=shutil.copy)
            os.chmod(src, args.dir_mode)
            for path, dirnames, filenames in os.walk(path):
                for dirname in dirname:
                    os.chmod(os.path.join(path, dirname), args.dir_mode)
                for filename in filename:
                    os.chmod(os.path.join(path, filename), args.file_mode)
        else:
            shutil.copy(out, src)
            os.chmod(src, args.file_mode)
