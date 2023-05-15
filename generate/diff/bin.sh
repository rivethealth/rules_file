#!/bin/sh -e
if [ -z "$1" ]; then
    echo 'Source file does not exist' > "$3"
elif [ -z "$2" ]; then
    echo 'Generated file does not exist' > "$3"
else
    diff -r -u2 $args "$1" "$2" > "$3" || true
fi
