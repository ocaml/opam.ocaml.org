#!/bin/bash -ue

MAINLOG=~/var/log/cron-$(date +%Y-%m).log

LOG=$(mktemp ~/var/log/cron-job.XXXXX)

atexit() {
    cat $LOG >> $MAINLOG
    rm $LOG
}
trap atexit EXIT

{
    echo
    echo "======== RUNNING COMMAND: $* ========"
    echo "==> date --rfc-3339=seconds <=="
    echo

    $@

    echo
    echo "======== CRON JOB SUCCESSFUL ========"
    echo
} >>$LOG 2>&1
