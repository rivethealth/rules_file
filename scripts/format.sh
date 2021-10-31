#!/bin/bash -ex
cd "$(dirname "$0")/.."

if [ "$1" = check ]; then
    ARG=
else
    ARG=write
fi

packages="$(\
    find . -not \( -path ./tests -prune \) \( -name BUILD -o -name BUILD.bazel \) \
    | sed -e 's:/[^/]*$::' -e 's:^\./::' -e 's:^:@rules_format_files//files/:' -e 's:/.$::' \
    | tr '\n' , \
    | sed 's/,$//' \
)"

bazel run "--deleted_packages=$packages" @rules_format//:buildifier_format -- $ARG
