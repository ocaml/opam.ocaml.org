#!/bin/bash -ue

repo=$1
shift
BRANCH=master
if [ $# -gt 0 ]; then
    BRANCH=$1
    shift
fi
if [ $# -ne 0 ]; then
    echo "Bad arguments. Syntax: $0 <repo> [branch]"
    echo "Default branch is master"
    exit 2
elif [ ! -d ~/git/$repo ]; then
    echo "Directory ~/git/$repo does not exist. Clone a repo by hand first."
    exit 2
fi

cd ~/git/$repo

git fetch
git clean -fdx
git checkout master
git reset origin/$BRANCH --hard

case $repo in
    "opam")
        ./configure -prefix ~/local
        make
        make install libinstall
        ;;
    "opamfu")
        make uninstall || true
        make build
        make install
        ;;
    "opam2web")
        export PREFIX=~/local
        ocamlfind remove opam2web || true
        make
        make install
        mkdir -p ~/local/share/opam2web
        cp -r -L ext/* ~/local/share/opam2web
        ;;
    *)
        echo "$repo fetched, don't know how to build"
esac
