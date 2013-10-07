#!/bin/bash -ue

HOME="/home/opam"
PATH="$HOME/local/bin:/usr/local/bin:/usr/bin:/bin"
OCAMLRUNPARAM=b
export HOME
export PATH
export OCAMLRUNPARAM

umask 0022

EMAIL="opam-commits@lists.ocaml.org"

MAINLOG=~/var/log/cron-$(date +%Y-%m).log

LOG=$(mktemp ~/var/log/cron-job.XXXXX)

atexit() {
    cat $LOG >> $MAINLOG
    echo "}}}" >> $MAINLOG
    echo >> $MAINLOG
    rm $LOG
}
trap atexit EXIT

exec >$LOG 2>&1

echo
echo "======== RUNNING COMMAND: $* ========"
echo "{{{"
echo "==> $(date --rfc-3339=seconds)"

NAME="$1"; shift
COMMAND="$*"

report_error () {
    echo
    echo "======== CRON JOB $NAME FAILED ========"
    echo "==> $(date --rfc-3339=seconds)"
    echo "==> Full command was: $COMMAND"
    {
        echo
        echo "=== FULL LOG ==="
        echo
        cat $LOG
    } | mail "$EMAIL" \
        -a'From: cron@opam.ocaml.org' \
        -s"Cron job $NAME failed on opam.ocaml.org"
    exit 1
}
trap report_error ERR

echo "==> Load opam env"

eval $(opam config env)

echo "==> Running $COMMAND"
echo

"$@"

echo
echo "======== CRON JOB $NAME SUCCESSFUL ========"
