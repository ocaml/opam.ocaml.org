#!/bin/bash -ue

# Make sure piping through tee doesn't lose error exit status of the command
set -o pipefail

cd

REPO=git://github.com/ocaml/opam-repository.git
BRANCH=master
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
            WWW_NEW=~/www-test
            if [ $# -gt 1 ]; then shift; BRANCH="$1"; fi
            ;;
        *)
            echo "Bad argument $1. Known option: --test [branch]."
            exit 2;;
    esac
    shift
done

git clone --local $WWW $WWW_NEW

if [ -z "$TEST" ]; then
    trap "rm -rf $WWW_NEW" ERR
fi

cd $WWW_NEW
git fetch $REPO $BRANCH
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
git clone https://github.com/ocaml/opam.wiki.git $CONTENT/doc
trap "rm -rf /tmp/${CONTENT#/tmp/}" EXIT

echo >> $WWW_NEW/lastlog.txt
echo "================ opam2web ================" >> $WWW_NEW/lastlog.txt
$BIN/opam2web \
    --content $CONTENT \
    --statistics ~/var/log/ocamlpro/access.log \
    --statistics ~/var/log/access.log \
    path:. \
    |& tee -a $WWW_NEW/lastlog.txt

echo >> $WWW_NEW/lastlog.txt
echo "================ opam2web (1.0) ================" >> $WWW_NEW/lastlog.txt
mkdir -p "1.0" && cd "1.0"
$BIN/opam2web \
    --content $CONTENT \
    --statistics ~/var/log/ocamlpro/access.log \
    path:.. \
    |& tee -a $WWW_NEW/lastlog.txt

cp -r -L ~/git/opam2web/ext $WWW_NEW

cd

echo "SUCCESS" >> $WWW_NEW/lastlog.txt
date >> $WWW_NEW/lastlog.txt

if [ -z "$TEST" ]; then
    rm -rf $WWW_BAK
    mv $WWW $WWW_BAK
    mv $WWW_NEW $WWW
fi
