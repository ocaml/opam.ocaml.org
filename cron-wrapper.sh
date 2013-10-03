#!/bin/bash -ue

MAINLOG=~/var/log/cron-$(date +%Y-%m).log

LOG=$(mktemp ~/var/log/cron-job.XXXXX)

atexit() {
    cat $LOG >> $MAINLOG
    rm $LOG
}
trap atexit EXIT

EMAIL="louis.gesbert@ocamlpro.com"

PATH=/usr/local/bin:/usr/bin:/bin
. ~/.opam/opam-init/init.sh || true
export PATH

NAME=$1; shift
COMMAND=("$@")

report_error () {
    {
        echo "Job $NAME failed with code $?."
        echo "Full command was: ${COMMAND[*]}"
        echo
        echo "=== FULL LOG ==="
        echo
        cat $LOG
    } | mail "$EMAIL" \
        -a'From: cron@opam.ocaml.org' \
        -s"Cron job $NAME failed on opam.ocaml.org"
}
trap report_error ERR


{
    echo
    echo "======== RUNNING COMMAND: $* ========"
    echo "==> $(date --rfc-3339=seconds)"
    echo

    "$@"

    echo
    echo "======== CRON JOB SUCCESSFUL ========"
    echo
} >>$LOG 2>&1
