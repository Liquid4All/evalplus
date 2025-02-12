#!/bin/bash

set -euo pipefail

usage() {
    echo "Usage: $0 --model-name <MODEL_NAME> --model-url <MODEL_URL> --model-api-token <MODEL_API_TOKEN> --dataset <DATASET> [--base-only]"
    echo "  --model-name       Model name. E.g. lfm-3b."
    echo "  --model-url        Inference server URL. E.g. 'https://inferece-1.liquid.ai'."
    echo "  --model-api-token  API token for authentication."
    echo "  --dataset          Dataset to use: humaneval or mbpp."
    echo "  --base-only        (Optional) Run only the base version of the evaluation."
    exit 1
}

if [ "$#" -eq 0 ]; then
    usage
fi

BASE_ONLY=""

while [ "$#" -gt 0 ]; do
    case "$1" in
        --model-name)
            MODEL_NAME="$2"
            shift 2
            ;;
        --model-url)
            MODEL_URL="$2"
            shift 2
            ;;
        --model-api-token)
            MODEL_API_TOKEN="$3"
            shift 2
            ;;
        --dataset)
            DATASET="$2"
            shift 2
            ;;
        --base-only)
            BASE_ONLY="--base-only"
            shift
            ;;
        --help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

if [ -z "$MODEL_NAME" ] || [ -z "$MODEL_URL" ] || [ -z "$MODEL_API_TOKEN" ] || [ -z "$DATASET" ]; then
    echo "Error: All arguments are required."
    usage
fi

if [[ "$DATASET" != "humaneval" && "$DATASET" != "mbpp" ]]; then
    echo "Invalid dataset. Please choose 'humaneval' or 'mbpp'."
    exit 1
fi

export OPENAI_API_KEY="$MODEL_API_TOKEN"

OUTPUT_DIR=$(pwd)/evalplus_results

mkdir -p "$OUTPUT_DIR"

docker run --rm -v "$OUTPUT_DIR":/app ganler/evalplus:latest \
    evalplus.evaluate $BASE_ONLY \
    --model "$MODEL_NAME" \
    --dataset "$DATASET" \
    --backend openai \
    --base-url "$MODEL_URL" \
    --greedy
