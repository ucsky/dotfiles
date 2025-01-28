#!/bin/bash

# Define the Emacs configuration file to test
CONFIG_FILE="$HOME/.dotfiles/config/emacs/emacs"

# Log file for Emacs output
LOG_FILE="emacs-test.log"

# Exit immediately if any command fails
set -e

echo "Testing Emacs configuration..."

# Check if Emacs is installed
if ! command -v emacs &> /dev/null; then
    echo "Error: Emacs is not installed. Please install Emacs first."
    exit 1
fi

# Run Emacs in batch mode to load the configuration
emacs --batch \
    -l "$CONFIG_FILE" \
    --eval "(progn (message \"Configuration loaded successfully.\") (kill-emacs 0))" \
    > "$LOG_FILE" 2>&1

# Check the exit code of Emacs
if [ $? -eq 0 ]; then
    echo "Emacs configuration loaded successfully."
    echo "Logs can be found in $LOG_FILE"
else
    echo "Error: Failed to load Emacs configuration."
    echo "Check the logs in $LOG_FILE for more details."
    exit 1
fi

# Optional: Test specific features in the configuration
echo "Running feature tests..."

# Test if use-package is available
emacs --batch \
    -l "$CONFIG_FILE" \
    --eval "(progn (require 'use-package) (message \"use-package loaded successfully.\") (kill-emacs 0))" \
    >> "$LOG_FILE" 2>&1

# Test TRAMP configuration
emacs --batch \
    -l "$CONFIG_FILE" \
    --eval "(progn (require 'tramp) (message \"TRAMP loaded successfully.\") (kill-emacs 0))" \
    >> "$LOG_FILE" 2>&1

# Test Python mode configuration
emacs --batch \
    -l "$CONFIG_FILE" \
    --eval "(progn (require 'python-mode) (message \"Python mode loaded successfully.\") (kill-emacs 0))" \
    >> "$LOG_FILE" 2>&1

# Test AUCTeX for LaTeX
emacs --batch \
    -l "$CONFIG_FILE" \
    --eval "(progn (require 'tex) (message \"AUCTeX loaded successfully.\") (kill-emacs 0))" \
    >> "$LOG_FILE" 2>&1

# Final success message
echo "All tests passed successfully!"
