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

case $repo in
    "opam")
        make prepare
        ./configure -prefix ~/local
        make compile
        make install libinstall
        ;;
    "opam2web")
        export PREFIX=~/local
        make
        make install
        ;;
    *)
        echo "$repo fetched, don't know how to build"
esac
