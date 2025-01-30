#!/bin/bash

# Set package name and download URL
PKG_NAME="gnu-elpa-keyring-update"
ELPA_URL="https://elpa.gnu.org/packages"
TAR_FILE="${PKG_NAME}-latest.tar"
SIG_FILE="${TAR_FILE}.sig"
INSTALL_DIR="$HOME/.emacs.d/elpa"

# Ensure dependencies are installed
command -v wget >/dev/null 2>&1 || { echo "Error: wget is not installed." >&2; exit 1; }
command -v gpg >/dev/null 2>&1 || { echo "Error: gpg is not installed." >&2; exit 1; }

# Create a temporary directory
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR" || { echo "Failed to enter temporary directory"; exit 1; }

echo "Downloading $PKG_NAME package..."
wget "$ELPA_URL/$TAR_FILE" -O "$TAR_FILE"
wget "$ELPA_URL/$SIG_FILE" -O "$SIG_FILE"

# Verify GPG signature
echo "Verifying package signature..."
gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys 645357D2883A0966
if gpg --verify "$SIG_FILE" "$TAR_FILE"; then
    echo "Signature verification successful!"
else
    echo "ERROR: GPG verification failed! Aborting installation." >&2
    exit 1
fi

# Extract the package
echo "Extracting package..."
tar -xf "$TAR_FILE"

# Find the extracted directory
EXTRACTED_DIR=$(find . -maxdepth 1 -type d -name "${PKG_NAME}-*" | head -n 1)

if [[ -z "$EXTRACTED_DIR" ]]; then
    echo "ERROR: Failed to extract package." >&2
    exit 1
fi

# Move package to Emacs' package directory
echo "Installing $PKG_NAME into Emacs package directory..."
mkdir -p "$INSTALL_DIR"
mv "$EXTRACTED_DIR" "$INSTALL_DIR/"

# Run Emacs command to update the keyring
echo "Updating GNU ELPA keyring in Emacs..."
emacs --batch -l "$INSTALL_DIR/$PKG_NAME/gnu-elpa-keyring-update.el" --eval="(gnu-elpa-keyring-update)"

echo "Installation complete! 🎉"
echo "You can now install GNU ELPA packages without signature errors."

# Clean up temporary files
rm -rf "$TMP_DIR"

exit 0
