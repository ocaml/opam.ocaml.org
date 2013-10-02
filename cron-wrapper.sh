#!/bin/bash -ue

MAINLOG=/tmp/cron-$(date +%Y-%m).log

LOG=$(mktemp /tmp/cron-job.XXXXX)

EMAIL="louis.gesbert@ocamlpro.com"

NAME=$1; shift

atexit() {
    cat $LOG >> $MAINLOG
    rm $LOG
}
trap atexit EXIT

report_error () {
    {
        echo "Job $NAME failed with code $?."
        echo "Full command was: $*"
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
