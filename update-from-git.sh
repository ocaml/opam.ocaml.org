#!/bin/bash -ue

echo
echo -n "===== Running $0 $* ====="
date
echo

repo=$1
shift
if [ $# -ne 0 ] || [ ! -d "~/git/$repo" ]; then
    echo "Bad arguments. Syntax: $0 <repo>"
    exit 2
fi

cd ~/git/$repo

git fetch
git clean -fdx
git checkout master
git reset origin/master --hard

./configure -prefix ~/local
make
make install
