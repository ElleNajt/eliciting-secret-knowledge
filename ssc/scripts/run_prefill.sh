#!/bin/bash

# Usage:
# ./run_prefill.sh <prompts_file> <constraints_file> <prefill_file> <model_name> [output_dir]

set -e

PROMPTS_FILE="$1"
CONSTRAINTS_FILE="$2"
PREFILL_FILE="$3"
MODEL_NAME="$4"
OUTPUT_DIR="${5:-ssc/results/prefill}"

# Fixed parameters
NUM_RESPONSES=1
MAX_NEW_TOKENS=128
TEMPERATURE=0.0
BATCH_SIZE=100
SEED=1

# Check if prompts file exists
if [ ! -f "$PROMPTS_FILE" ] || [ ! -f "$CONSTRAINTS_FILE" ] || [ ! -f "$PREFILL_FILE" ]; then
    echo "❌ Error: Prompts file '$PROMPTS_FILE' not found"
    exit 1
fi

# Get script directory and batch inference path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BATCH_INFERENCE_SCRIPT="$SCRIPT_DIR/../../sampling/batch_inference.py"

if [ ! -f "$BATCH_INFERENCE_SCRIPT" ]; then
    echo "❌ Error: batch_inference.py not found at $BATCH_INFERENCE_SCRIPT"
    exit 1
fi

# Convert to absolute path
PROMPTS_FILE="$(realpath "$PROMPTS_FILE")"

python3 "$BATCH_INFERENCE_SCRIPT" \
    --prompts_file "$PROMPTS_FILE" \
    --constraints_file "$CONSTRAINTS_FILE" \
    --prefill_file "$PREFILL_FILE" \
    --model_name "$MODEL_NAME" \
    --num_responses $NUM_RESPONSES \
    --max_new_tokens $MAX_NEW_TOKENS \
    --temperature $TEMPERATURE \
    --seed $SEED \
    --output_dir "$OUTPUT_DIR" \
    --batch_size $BATCH_SIZE \
    --ssc \
    --prefill

echo "✅ Prefill experiment completed successfully!"
echo "📁 Results: $OUTPUT_DIR"
