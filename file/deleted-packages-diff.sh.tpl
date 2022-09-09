#!/usr/bin/env bash
set -euo pipefail

if [ -z "${RUNFILES_DIR-}" ]; then
  if [ ! -z "${RUNFILES_MANIFEST_FILE-}" ]; then
    export RUNFILES_DIR="${RUNFILES_MANIFEST_FILE%.runfiles_manifest}.runfiles"
  else
    export RUNFILES_DIR="$0.runfiles"
  fi
fi

if ! (echo '# Generated by bazel run '%{label}; (%{commands}) | "$RUNFILES_DIR"/%{deleted_packages} %{args}) | diff -r -u2 --color "$BUILD_WORKSPACE_DIRECTORY"/%{output} /dev/stdin; then
  echo '*** Run bazel run '%{label}
  exit 1
fi
