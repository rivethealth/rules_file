#!/bin/bash

# --- begin runfiles.bash initialization v2 ---
# Copy-pasted from the Bazel Bash runfiles library v2.
set -uo pipefail; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v2 ---

set -e

if [ "${1-}" = check ]; then
    if "$(rlocation rules_file/generate/run/bin)" check @"$(rlocation %{check_args})"; then
      exit
    else
      code="$?"
      echo 'To correct, run bazel run '%{label}
      exit "$code"
    fi
fi

if ! [ -z "${BUILD_WORKSPACE_DIRECTORY-}" ]; then
  cd "$BUILD_WORKSPACE_DIRECTORY"
fi

exec "$(rlocation rules_file/generate/run/bin)" write --file-mode=%{file_mode} --dir-mode=%{dir_mode} @"$(rlocation %{write_args})"
