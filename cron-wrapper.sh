#!/bin/bash -u

MAINLOG=~/var/log/cron-$(date +%Y-%m).log

LOG=$(mktemp ~/var/log/cron-job.XXXXX)

EMAIL="louis.gesbert@ocamlpro.com"

atexit() {
    cat $LOG >> $MAINLOG
    echo >> $MAINLOG
    rm $LOG
}
trap atexit EXIT

exec >$LOG 2>&1

echo
echo "======== RUNNING COMMAND: $* ========"
echo "==> $(date --rfc-3339=seconds)"

NAME="$1"; shift
COMMAND="$*"

report_error () {
    echo
    echo "======== CRON JOB FAILED ========"
    {
        echo "Job $NAME FAILED."
        echo "Full command was: $COMMAND"
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

PATH=~/local/bin:/usr/local/bin:/usr/bin:/bin
export PATH
eval $(opam config env)

echo "==> Running $COMMAND"
echo

"$@"

echo
echo "======== CRON JOB SUCCESSFUL ========"
