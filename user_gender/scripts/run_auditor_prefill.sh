#!/bin/bash

# Usage:
#   ./run_auditor_prefill.sh <data_dir> <auditor_model> <target_word> [output_dir]

set -e

DATA_DIR="$1"
AUDITOR_MODEL="$2"
TARGET_WORD="$3"
OUTPUT_DIR="${4:-$DATA_DIR}"

# Fixed parameters
MODE="only_input_output"
NUM_GUESSES=1
BATCH_SIZE=100
TEMPERATURE=0.0
PROMPT_TEMPLATE="prompts/gender/auditor_guess_prefill_single.txt"

# Check if results directory exists
if [ ! -d "$DATA_DIR" ]; then
    echo "❌ Error: Results directory '$DATA_DIR' not found"
    exit 1
fi

# Find all JSON files
JSON_FILES=($(find "$DATA_DIR" -name "*.json" -type f))
if [ ${#JSON_FILES[@]} -eq 0 ]; then
    echo "❌ Error: No JSON files found in '$DATA_DIR'"
    exit 1
fi

echo "📊 Found ${#JSON_FILES[@]} JSON files to proqcess"
mkdir -p "$OUTPUT_DIR"

# Process files
for DATA_FILE in "${JSON_FILES[@]}"; do
    echo "  Processing: $(basename "$DATA_FILE")"

    python3 utils/guess_secret_word.py \
        --model_name "$AUDITOR_MODEL" \
        --data_file "$DATA_FILE" \
        --mode "$MODE" \
        --num_guesses $NUM_GUESSES \
        --output_dir "$OUTPUT_DIR" \
        --template_file "$PROMPT_TEMPLATE" \
        --batch_size $BATCH_SIZE \
        --temperature $TEMPERATURE \
        --target_words "$TARGET_WORD"
done

echo "Prefill guessing completed!"
