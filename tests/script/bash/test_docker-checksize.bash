#!/bin/bash

# Test documentation generation of script.
echo "Tests"
./script/bash/docker-checksize.bash help

# Run the script and capture output
OUTPUT=$(./script/bash/docker-checksize.bash 2>&1)
EXIT_CODE=$?

# Check if script ran (exit code 0 means success or expected warning)
if [ $EXIT_CODE -eq 0 ]; then
    # Check if output contains expected warnings (these are acceptable)
    if echo "$OUTPUT" | grep -q "WARNING:"; then
        echo "Script executed with expected warnings (permissions or docker not found)"
        echo "$OUTPUT"
    else
        echo "Script executed successfully"
        echo "$OUTPUT"
    fi
else
    echo "Test failed: Script returned exit code $EXIT_CODE"
    echo "$OUTPUT"
    exit 1
fi
