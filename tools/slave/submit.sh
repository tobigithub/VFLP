#!/bin/bash
# ---------------------------------------------------------------------------
#
# Usage: . submit.sh jobfile partition/queue [quiet]

# Description: Submits a new job.
#
# Option: quiet (optional)
#    Possible values: 
#        quiet: No information is displayed on the screen.
#
# Revision history
# 2015-12-05  Created (version 1.2)
# 2015-12-12  Various improvements (version 1.10)
# 2015-12-16  Adaption to version 2.1
# 2016-07-16  Various improvements
#
# ---------------------------------------------------------------------------

# Displaying help if the first argument is -h
usage="# Usage: . submit.sh jobfile partition/queue [quiet]"
if [ "${1}" = "-h" ]; then
    echo "${usage}"
    return
fi

# Variables 
partition="${2}"

# Getting the batchsystem type
line=$(grep -m 1 "^batchsystem=" ../../workflow/control/all.ctrl)
batchsystem="${line/batchsystem=}"

# Submitting the job
if [ "${batchsystem}" = "SLURM" ]; then
    cd ..
    if [ -n "${2}" ]; then
        sbatch --signal=10@300 -p ${partition} ${1}
    else 
        sbatch --signal=10@300 ${1}
    fi
    cd slave
elif [ "${batchsystem}" = "MT" ]; then
    cd ..
    if [ -n "${2}" ]; then
        msub -l signal=10@300 -q ${partition} ${1}
    else 
        msub -l signal=10@300 ${1}
    fi
    cd slave
fi

# Displaying some information
if [ ! "$*" = *"quiet"* ]; then
    echo
    echo "The job was submitted."
    echo
fi
