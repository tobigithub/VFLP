#!/bin/bash
# ---------------------------------------------------------------------------
#
# Usage: . exchange-jobfile.sh template_file jobline_no [quiet]
#
# Description: Exchanges a jobfile in use with a new (template) jobfile.
#
# Option: quiet (optional)
#    Possible values: 
#        quiet: No information is displayed on the screen.
#
# Revision history:
# 2015-12-05  Created (version 1.2)
# 2015-12-12  Various improvements (version 1.10)
# 2015-12-16  Adaption to version 2.1
# 2016-07-16  Various improvements
#
# ---------------------------------------------------------------------------

# Displaying help if the first argument is -h
usage="Usage: . exchange-jobfile.sh template_file jobline_no [quiet]"
if [ "${1}" = "-h" ]; then
    echo "${usage}"
    return
fi

# Getting the batchsystem type
line=$(grep -m 1 "^batchsystem=" ../../workflow/control/all.ctrl)
batchsystem="${line/batchsystem=}"

# Getting the jobline number and the current job number
jobline_no=${2}
job_template=${1}
new_job_file=${2}.job
if [ "${batchsystem}" = "SLURM" ]; then
    line=$(cat ../../workflow/job-files/main/${new_job_file} | grep -m 1 "job-name")
    job_no=${line/"#SBATCH --job-name=j-"}
elif [ "${batchsystem}" = "MT" ]; then
    line=$(cat ../../workflow/job-files/main/${new_job_file} | grep -m 1 "\-N")
    job_no=${line/"#PBS -N j-"}
fi

# Copying the new job file
cp ../${job_template} ../../workflow/job-files/main/${new_job_file}
. copy-templates.sh subjobfiles

# Changing the job number 1.1 (of template/new job file) to current job number
sed -i "s/j-1.1/j-${job_no}/g" ../../workflow/job-files/main/${new_job_file}

# Changing the output filenames
sed -i "s/1.1_/${job_no}_/g" ../../workflow/job-files/main/${new_job_file}

# Displaying some information
if [[ ! "$*" = *"quiet"* ]]; then
    echo "The jobfiles were exchanged."
    echo
fi
