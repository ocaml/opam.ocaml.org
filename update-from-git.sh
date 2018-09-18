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
git reset origin/$BRANCH --hard || git reset refs/tags/$BRANCH --hard

case $repo in
    "opam")
        ./configure -prefix ~/local
        make
        make install libinstall
	cp admin-scripts/*.ml ~/local/bin
        make -C doc/dev-manual dev-manual.html
        make -C doc html
        mkdir -p ~/local/share/doc/$BRANCH
        cp doc/dev-manual/dev-manual.{html,css,pdf} ~/local/share/doc
        rm -rf ~/local/share/doc/$BRANCH/api
        cp -r doc/html ~/local/share/doc/$BRANCH/api
        ;;
    "opam2")
        ./configure -prefix ~/local
        make
        make -C doc html man-html
        mkdir -p ~/local/share/doc/2.0/api
        rm -rf ~/local/share/doc/2.0/api/*
        cp -r doc/html/* ~/local/share/doc/2.0/api/
        mkdir -p ~/local/share/doc/2.0/man
        rm -rf ~/local/share/doc/2.0/man/*
        cp -r doc/man-html/* ~/local/share/doc/2.0/man/
        cp opam ~/local/bin/opam2
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
    "opam2web2")
        export PREFIX=~/local
        make
        mkdir -p ~/local/share/opam2web2
        cp -b opam2web ~/local/bin/opam2web2
        cp -r -L ext/* ~/local/share/opam2web2
        ;;
    *)
        echo "$repo fetched, don't know how to build"
esac
