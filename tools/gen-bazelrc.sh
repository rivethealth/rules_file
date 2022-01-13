#!/bin/bash -e
RUNFILES_DIR="$0.runfiles"

cd "$BUILD_WORKSPACE_DIRECTORY"

function escape_pattern {
  <<< "$1" sed 's/[\/&]/\\&/g'
}

packages="$( \
    (find . -name BUILD -o -name BUILD.bazel) \
    | sed -e 's:/[^/]*$::' -e 's:^\./::' -e 's:^:@rules_format_files//files/:' -e 's:/.$::' \
)"

sed -e "s/%{deleted_packages}/$(escape_pattern "$packages")/g" "$RUNFILES_DIR/rules_format/tools/deleted.bazelrc.template" > tools/deleted.bazelrc
