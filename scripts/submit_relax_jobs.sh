#!/bin/bash
#SBATCH --job-name=relax_preprocess
#SBATCH --output=../logs/relax_job_%A_%a.out # Log file for stdout, %A = job ID, %a = task ID
#SBATCH --error=../logs/relax_job_%A_%a.err  # Log file for stderr
#SBATCH --time=02:00:00                     # Time limit (HH:MM:SS)
#SBATCH --partition=cpu-short               # Partition to run on
#SBATCH --nodes=1                           # Ensure all cores are on one machine
#SBATCH --ntasks=1                          # Number of tasks (usually 1 for non-MPI jobs)
#SBATCH --cpus-per-task=4                   # Number of CPU cores per task (adjust if needed)
#SBATCH --mem=16G                           # Memory per node (total memory request)
#SBATCH --array=1-4                         # Job array indices (one for each input file)

# --- Job Setup ---
echo "======================================================="
echo "SLURM_JOB_ID: $SLURM_JOB_ID"
echo "SLURM_ARRAY_JOB_ID: $SLURM_ARRAY_JOB_ID"
echo "SLURM_ARRAY_TASK_ID: $SLURM_ARRAY_TASK_ID"
echo "Running on host: $(hostname)"
echo "Job started: $(date)"
echo "======================================================="

# --- Environment Setup ---
echo "Loading MATLAB module..."
module load MATLAB/2023b

# Define project base directory relative to this script's location
# SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
# PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
# Use absolute path to avoid issues with SLURM working directory
PROJECT_DIR="/home/s3648540/data_pi-michielvanelkm/Parsa/Chakra/EEG"
echo "Project Directory: $PROJECT_DIR"

# Define key directories and files
INPUT_DATA_DIR="$PROJECT_DIR/data/raw_set"
OUTPUT_DIR="$PROJECT_DIR/data/preprocessed"
CONFIG_FILE="$PROJECT_DIR/scripts/config_relax.m"
RUNNER_SCRIPT="$PROJECT_DIR/scripts/run_relax_job"
LOG_FILE="$PROJECT_DIR/logs/relax_job_${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}.err" # Reuse stderr log for MATLAB function arg

# --- Input File Selection ---
# Create an array of input filenames (ensure order matches desired processing)
INPUT_FILES=(
    "$INPUT_DATA_DIR/SRS_vs_YRS.set"
    "$INPUT_DATA_DIR/YRS_vs_Ajna.set"
    "$INPUT_DATA_DIR/YRS_vs_Anahata.set"
    "$INPUT_DATA_DIR/YRS_vs_Manipura.set"
)

# Select the input file based on the SLURM array task ID
# SLURM_ARRAY_TASK_ID is 1-based, bash arrays are 0-based
INDEX=$(($SLURM_ARRAY_TASK_ID - 1))
CURRENT_INPUT_FILE="${INPUT_FILES[$INDEX]}"

echo "Processing Input File: $CURRENT_INPUT_FILE"
echo "Output Directory: $OUTPUT_DIR"
echo "Config File: $CONFIG_FILE"

# Check if input file exists
if [ ! -f "$CURRENT_INPUT_FILE" ]; then
    echo "ERROR: Input file not found: $CURRENT_INPUT_FILE" >&2
    exit 1
fi

# --- Create Output and Log Directories if they don't exist ---
mkdir -p "$OUTPUT_DIR"
mkdir -p "$PROJECT_DIR/logs"

# --- Construct MATLAB Command ---
# Use -batch to run non-interactively
# Pass arguments to the run_relax_job function
# Ensure setup_paths is run within the MATLAB environment (run_relax_job should handle this if setup_paths.m is present)
# Run setup_paths first, then run the job function
SETUP_SCRIPT_PATH="$PROJECT_DIR/scripts/setup_paths.m"
MATLAB_CMD="run('$SETUP_SCRIPT_PATH'); run_relax_job('$CURRENT_INPUT_FILE', '$OUTPUT_DIR', '$CONFIG_FILE', '$LOG_FILE')"

# --- Execute MATLAB Script ---
echo "Executing MATLAB command:"
echo "matlab -nodisplay -nosplash -batch \"${MATLAB_CMD}\""
echo "-------------------------------------------------------"

matlab -nodisplay -nosplash -batch "${MATLAB_CMD}"
MATLAB_EXIT_CODE=$?

echo "-------------------------------------------------------"
echo "MATLAB script finished with exit code: $MATLAB_EXIT_CODE"

# --- Job Finish --- 
echo "======================================================="
echo "Job finished: $(date)"
echo "======================================================="

exit $MATLAB_EXIT_CODE 