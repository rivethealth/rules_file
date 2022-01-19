#!/bin/sh -e
cd file/test/bazel
unset RUNFILES_DIR
unset TEST_TMPDIR
bazel info output_path
bazel build basic:example
