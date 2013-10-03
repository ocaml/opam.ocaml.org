#!/bin/bash -ue

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
echo

PATH=/usr/local/bin:/usr/bin:/bin
. ~/.opam/opam-init/init.sh || true
export PATH

NAME="$1"; shift
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

"${COMMAND[@]}"

echo
echo "======== CRON JOB SUCCESSFUL ========"
