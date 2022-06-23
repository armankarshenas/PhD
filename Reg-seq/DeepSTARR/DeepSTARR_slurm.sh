#!/bin/bash
# Job name:
#SBATCH --job-name=DeepSTARR_arch_v1
#
# Account:
#SBATCH --account=ac_mhmm
#
# Partition:
#SBATCH --partition=savio2_gpu
#
# Number of nodes:
#SBATCH --nodes=1
#
# Number of tasks (one for each GPU desired for use case) (example):
#SBATCH --ntasks=1
#
# Processors per task:
# Always at least twice the number of GPUs (savio2_gpu and GTX2080TI in savio3_gpu)
# Four times the number for TITAN and V100 in savio3_gpu
# Eight times the number for A40 in savio3_gpu
#SBATCH --cpus-per-task=2
#
#Number of GPUs, this can be in the format of "gpu:[1-4]", or "gpu:K80:[1-4] with the type included
#SBATCH --gres=gpu:1
#
# Wall clock limit:
#SBATCH --time=00:00:30
#
# Output files
#SBATCH --output=outputlog.output
#SBATCH --error=errorlog.err
#
# Email notifications
#SBATCH --mail-type=ALL
#SBATCH --mail-user=arman_karshenas@berkeley.edu
## Command(s) to run (example):
conda activate DeepSTARR
python DeepSTAAR.py
