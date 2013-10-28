#!/bin/bash -ue

cd

REPO=git://github.com/ocaml/opam-repository.git
URL=http://opam.ocaml.org/
BIN=~/local/bin

WWW=~/www

WWW_NEW=~/www-new

WWW_BAK=~/www-bak

TEST=""
while [ $# -gt 0 ]; do
    case $1 in
        --test)
            TEST=1
            WWW_NEW=~/www-test;;
        *)
            echo "Bad argument $1. Known option: --test."
            exit 2;;
    esac
    shift
done

git clone --local $WWW $WWW_NEW

if [ -z "$TEST" ]; then
    trap "rm -rf $WWW_NEW" ERR
fi

cd $WWW_NEW
git fetch $REPO master
git reset FETCH_HEAD --hard

mkdir -p archives
cp -al $WWW/archives/* archives/
cp $WWW/index.tar.gz $WWW/urls.txt .

umask 002
date > $WWW_NEW/lastlog.txt
echo >> $WWW_NEW/lastlog.txt
echo "============= opam-admin make ============" >> $WWW_NEW/lastlog.txt
$BIN/opam-admin make |& tee -a $WWW_NEW/lastlog.txt

CONTENT=$(mktemp -d /tmp/opam2web-content.XXXX)
cp -r ~/git/opam2web/content/* $CONTENT
git clone https://github.com/OCamlPro/opam.wiki.git $CONTENT/doc
trap "rm -rf /tmp/${CONTENT#/tmp/}" EXIT

echo >> $WWW_NEW/lastlog.txt
echo "================ opam2web ================" >> $WWW_NEW/lastlog.txt
$BIN/opam2web \
    --content $CONTENT \
    --statistics ~/var/log/access.log.1 \
    --statistics ~/var/log/access.log \
    --prefix "$URL" \
    path:. \
    |& tee -a $WWW_NEW/lastlog.txt

cp -r -L ~/git/opam2web/ext $WWW_NEW

cd

if [ -z "$TEST" ]; then
    rm -rf $WWW_BAK
    mv $WWW $WWW_BAK
    mv $WWW_NEW $WWW
fi
