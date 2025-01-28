#!/bin/bash

# Exit on any error
set -e

# Paths
CONFIG_FILE="$HOME/.dotfiles/config/emacs/emacs"
LOG_FILE="emacs-test.log"

# Function to print messages with formatting
print_message() {
    echo -e "\n[INFO] $1\n"
}

# Function to test a specific feature or module
test_feature() {
    local feature="$1"
    local message="$2"
    emacs --batch \
        -l "$CONFIG_FILE" \
        --eval "(progn (require '$feature) (message \"$message\") (kill-emacs 0))" \
        >> "$LOG_FILE" 2>&1 || {
        echo "[ERROR] Failed to load $feature. Check $LOG_FILE for details."
        exit 1
    }
    print_message "$message"
}

# Function to check if Emacs is installed
check_emacs_installed() {
    if ! command -v emacs &> /dev/null; then
        echo "[ERROR] Emacs is not installed. Please install it before running this script."
        exit 1
    fi
}

# Main function to test the configuration
test_emacs_config() {
    print_message "Testing Emacs configuration..."

    # Test loading the configuration
    emacs --batch \
        -l "$CONFIG_FILE" \
        --eval "(progn (message \"Configuration loaded successfully.\") (kill-emacs 0))" \
        > "$LOG_FILE" 2>&1 || {
        echo "[ERROR] Failed to load Emacs configuration. Check $LOG_FILE for details."
        exit 1
    }
    print_message "Configuration loaded successfully."

    # Test individual features
    test_feature "use-package" "use-package loaded successfully."
    test_feature "tramp" "TRAMP loaded successfully."
    test_feature "python-mode" "Python mode loaded successfully."
    test_feature "tex" "AUCTeX loaded successfully."
}

# Run the script
check_emacs_installed
test_emacs_config

# Final success message
print_message "All tests passed successfully! Logs available in $LOG_FILE."
