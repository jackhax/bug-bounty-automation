#!/usr/bin/env bash

# Usage: ./enum.sh domain.com [out_of_scope.txt] [-o output_file]

# Check if required arguments are provided
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <domain> [out_of_scope_file] [-o output_file]"
    exit 1
fi

TARGET=$1
OUT_OF_SCOPE=""
OUTPUT_FILE=""

# Parse optional arguments
if [[ $# -ge 2 && $2 != "-o" ]]; then
    OUT_OF_SCOPE=$2
fi

if [[ $# -ge 4 && $3 == "-o" ]]; then
    OUTPUT_FILE=$4
else
    OUTPUT_FILE="output/${TARGET}"
fi

# Convert output path to absolute path
OUTPUT_FILE="$(realpath "$OUTPUT_FILE")"

# Run subscraper to gather subdomains
python3 subscraper/subscraper.py -d "$TARGET" -o "${TARGET}_subdomains.txt"

# Ensure subscraper output exists
if [[ ! -s "${TARGET}_subdomains.txt" ]]; then
    echo "Error: No subdomains found or subscraper failed."
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$(dirname "$OUTPUT_FILE")"

# Filter out out-of-scope subdomains (if provided) and probe live hosts
if [[ -n "$OUT_OF_SCOPE" && -f "$OUT_OF_SCOPE" ]]; then
    cat "${TARGET}_subdomains.txt" | grep -v "$(cat "$OUT_OF_SCOPE")" | httprobe > "$OUTPUT_FILE"
else
    cat "${TARGET}_subdomains.txt" | httprobe > "$OUTPUT_FILE"
fi

# Clean up temporary file
rm "${TARGET}_subdomains.txt"

# Print the full path of the results
echo "Results saved to: $OUTPUT_FILE"
