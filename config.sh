#!/bin/bash

### Analysis parameters ###
MER=1                     # Length of the end motif

### SLURM parameters ###
# Main workflow job
MAIN_PARTITION="debug"         # Partition name; modify based on the local cluster configuration
MAIN_CPUS=1                    # Number of CPUs used
MAIN_MEMORY="1G"               # Memory used
MAIN_TIME="7-00:00"            # Maximum runtime

# Sample-level jobs
SAMPLE_PARTITION="debug"         
SAMPLE_CPUS=5                    
SAMPLE_MEMORY="10G"               
SAMPLE_TIME="7-00:00"            
