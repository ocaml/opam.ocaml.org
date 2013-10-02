#!/bin/bash -ue

repo=$1
shift
if [ $# -ne 0 ]; then
    echo "Bad arguments. Syntax: $0 <repo>"
    exit 2
elif [ ! -d ~/git/$repo ]; then
    echo "Directory ~/git/$repo does not exist. Clone a repo by hand first."
    exit 2
fi

cd ~/git/$repo

git fetch
git clean -fdx
git checkout master
git reset origin/master --hard

export PREFIX=~/local
if [ -x configure ]; then ./configure -prefix ~/local; fi
make
make install
