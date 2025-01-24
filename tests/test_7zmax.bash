#!/bin/bash

# Define the test input and output
test_file="test_input_file.txt"
output_file="test_input_file.txt.7z"

# Create a sample file for testing
echo "This is a test file for compression." > "$test_file"

# Run the 7zmax script and capture the output
7zmax "$test_file"
exit_code=$?

# Check if the script ran successfully
if [ $exit_code -ne 0 ]; then
    echo "Test failed: 7zmax script returned an error."
    exit 1
fi

# Check if the output file was created
if [ ! -f "$output_file" ]; then
    echo "Test failed: Output file $output_file was not created."
    exit 1
fi

# Check if the output file is not empty
if [ ! -s "$output_file" ]; then
    echo "Test failed: Output file $output_file is empty."
    exit 1
fi

echo "All tests passed successfully!"

# Clean up test files
rm "$test_file" "$output_file"
