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
	cp admin-scripts/*.ml ~/local/bin
        make -C doc/dev-manual dev-manual.html
        mkdir -p ~/local/share/doc
        cp doc/dev-manual/dev-manual.{html,css,pdf} ~/local/share/doc
        [ "4.01.0" = "$(opam config var ocaml-version)" ]
        make -C admin-scripts to_1_1
        mv admin-scripts/to_1_1 ~/local/bin/repo_compat_1_1.byte4.01
        for ocamlv in 3.12.1 4.00.1 4.02.0; do
            make clean
            opam config exec --switch $ocamlv -- ./configure -prefix ~/.opam/$ocamlv
            opam config exec --switch $ocamlv -- make all libinstall
            cd admin-scripts
            opam config exec --switch $ocamlv -- make to_1_1
            mv to_1_1 ~/local/bin/repo_compat_1_1.byte${ocamlv%.*}
            cd ..
        done
        ;;
    "opam2")
        ./configure -prefix ~/local
        make
        make -C doc html pages
        mkdir -p ~/local/share/doc/2.0
        cp -r doc/html ~/local/share/doc/2.0/api
        cp -r doc/pages ~/local/share/doc/2.0/manual
        make -C admin-scripts 1_2_to_2_0
        mv admin-scripts/1_2_to_2_0 ~/local/bin/repo_1_2_to_2_0
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
