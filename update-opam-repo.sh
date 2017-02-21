#!/bin/bash -ue

# Make sure piping through tee doesn't lose error exit status of the command
set -o pipefail

cd

REPO=git://github.com/ocaml/opam-repository.git
BRANCH=master
URL=https://opam.ocaml.org/
BIN=~/local/bin
DOC=~/local/share/doc

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

# Dispatch all non-standard versions
cat <<EOF >>repo
redirect: [
  "${URL}1.1" { opam-version < "1.2" }
]
EOF

# Older, no longer in use repositories, just put in inconditional redirects to
# top-level
make_redirect() {
    mkdir $1
    cd $1
    echo "redirect: [ \"${URL}\" ]" > repo
    tar czf index.tar.gz repo
    md5=$(md5sum repo | cut -d' ' -f1)
    echo -e "repo\t$md5\t420" > urls.txt
    cd ..
}
make_redirect 1.3
make_redirect 2.0~dev

# Compat repos, in subdirectories. Redirect to main if version doesn't match.
echo "============= copy 1.1 repo ==========" >> $WWW_NEW/lastlog.txt
# Updates to the 1.1 mirror disabled, copy unchanged (redirect is included)
mkdir $WWW_NEW/1.1
cp -al $WWW/1.1/* $WWW_NEW/1.1/

echo "============= generate 2.0 repo ==========" >> $WWW_NEW/lastlog.txt
$BIN/opam2 admin upgrade --mirror="$URL" |& tee -a $WWW_NEW/lastlog.txt
cp -al $WWW/2.0/cache 2.0/ || cp -al $WWW/2.0~dev/cache 2.0/ || true
cd 2.0
$BIN/opam2 admin cache --link=archives |& tee -a $WWW_NEW/lastlog.txt
$BIN/opam2 admin index --full-urls-txt |& tee -a $WWW_NEW/lastlog.txt
cd ..

# Needs to be last to include changes to the 'repo' file
echo "============= Generate 1.2 archives and index ============" >> $WWW_NEW/lastlog.txt
$BIN/opam-admin make |& tee -a $WWW_NEW/lastlog.txt


CONTENT=$(mktemp -d /tmp/opam2web-content.XXXX)
cp -r ~/git/opam2web/content/* $CONTENT
mkdir -p $CONTENT/doc/1.1
git clone git://github.com/ocaml/opam.wiki.git $CONTENT/doc/1.1 --depth 1
git clone git://github.com/ocaml/opam.git $CONTENT/opam-tmp -b 1.2 --depth 1
cp $CONTENT/opam-tmp/doc/pages/* $CONTENT/doc/
mkdir -p $CONTENT/doc/2.0
cd $CONTENT/opam-tmp && git fetch origin master && git checkout master && cp doc/pages/* $CONTENT/doc/2.0
cd $WWW_NEW
ln -sf $CONTENT/doc $CONTENT/doc/1.2

git clone git://github.com/ocaml/platform-blog.git $CONTENT/blog --depth 1
trap "rm -rf /tmp/${CONTENT#/tmp/}" EXIT

cp -r -L ~/local/share/opam2web $WWW_NEW/ext

echo >> $WWW_NEW/lastlog.txt
echo "================ opam2web ================" >> $WWW_NEW/lastlog.txt
APACHELOGS=(~/var/log/ocamlpro/access.log ~/var/log/access*.log)
$BIN/opam2web \
    --content $CONTENT \
    ${APACHELOGS[*]/#/--statistics=} \
    --statistics ~/var/log/ocamlpro/access.log \
    --statistics ~/var/log/access.log \
    --root $URL \
    path:. \
    |& tee -a $WWW_NEW/lastlog.txt

# Serve up-to-date bytecode compat scripts to be used by Travis
cp $BIN/repo_compat_1_1.byte* .
# Add symlink to bulk builds
ln -s /logs/builds
# And install html manual
mkdir ./doc/manual
cp $DOC/dev-manual.* ./doc/manual
mkdir -p ./doc/1.2/api/
cp -r $DOC/1.2/api/* ./doc/1.2/api/
mkdir -p ./doc/1.3/api/
cp -r $DOC/1.3/api/* ./doc/1.3/api/
mkdir -p ./doc/2.0/api/
cp -r $DOC/2.0/api/* ./doc/2.0/api/
mkdir -p ./doc/2.0/man/
cp -r $DOC/2.0/man/* ./doc/2.0/man/

cd

echo "SUCCESS" >> $WWW_NEW/lastlog.txt
date >> $WWW_NEW/lastlog.txt

if [ -z "$TEST" ]; then
    rm -rf $WWW_BAK
    mv $WWW $WWW_BAK
    mv $WWW_NEW $WWW
fi
