#!/bin/bash -ue

BASE=~/var/log

for f in $BASE/access-*.log; do
    z="$BASE/xz/${f#$BASE/}.xz"
    if [ "$f" -nt "$z" ]; then
        echo "Zipping $f..."
        xz "$f" --stdout > "$z"
    fi
done
