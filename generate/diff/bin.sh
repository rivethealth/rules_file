#!/bin/sh -e
diff -r -u2 --color "$1" "$2" > "$3" || true
