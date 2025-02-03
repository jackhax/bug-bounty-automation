#!/usr/bin/env bash

# Usage: ./enum.sh domain.com out_of_scope.txt [-o output_file]

# Check if required arguments are provided
if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <domain> <out_of_scope_file> [-o output_file]"
    exit 1
fi

TARGET=$1
OUT_OF_SCOPE=$2
OUTPUT_FILE=""

# Parse optional -o flag for output file
if [[ $# -eq 4 && $3 == "-o" ]]; then
    OUTPUT_FILE=$4
else
    OUTPUT_FILE="output/${TARGET}"
fi

OUTPUT_FILE="$(realpath "$OUTPUT_FILE")"

# Run subscraper to gather subdomains
python3 subscraper/subscraper.py -d "$TARGET" -o "${TARGET}_subdomains.txt"

# Ensure subscraper output exists
if [[ ! -s "${TARGET}_subdomains.txt" ]]; then
    echo "Error: No subdomains found or subscraper failed."
    exit 1
fi

# Filter out out-of-scope subdomains and probe live hosts
cat "${TARGET}_subdomains.txt" | grep -v "$(cat "$OUT_OF_SCOPE")" | httprobe > "$OUTPUT_FILE"

# Clean up temporary file
rm "${TARGET}_subdomains.txt"

echo "Results saved to: $OUTPUT_FILE"
