#!/bin/bash
#BSUB -cwd
#BSUB -L /bin/bash
#BSUB -q default
#BSUB -n 4
#BSUB -o ./cluster_logs/lsf-$LSB_JOBNAME-$LSB_JOBID-$HOSTNAME.out
#BSUB -e ./cluster_logs/lsf-$LSB_JOBNAME-$LSB_JOBID-$HOSTNAME.err

# set umask to avoid locking each other out of directories
umask 002

COHORT=$1
mkdir -p cohorts/${COHORT}/
LOCKFILE=cohorts/${COHORT}/process_cohort.lock

# add lockfile to directory to prevent multiple simultaneous jobs
lockfile -r 0 ${LOCKFILE} || exit 1
trap "rm -f ${LOCKFILE}; exit" SIGINT SIGTERM ERR EXIT

# execute snakemake
snakemake \
    --printshellcmds \
    --config cohort=${COHORT} \
    --nolock \
    --local-cores 4 \
    --use-singularity --singularity-args '--nv ' \
    --profile workflow/profiles/lsf \
    --snakefile workflow/process_cohort.smk
