#!/bin/bash -e
arg="$1"

if [ -z "$BUILD_WORKSPACE_DIRECTORY" ]; then
    cd "$(bazel info workspace)"
else
    cd "$BUILD_WORKSPACE_DIRECTORY"
fi

exit=0

function format {
    if [ "$arg" = write ]; then
        if ! cmp -s "$1" "$2"; then
            echo "$1"
            cp "$2" "$1"
        fi
    elif ! diff --color=always -u0 "$1" "$2"; then
        exit=1
    fi
}

%{files}

exit "$exit"
