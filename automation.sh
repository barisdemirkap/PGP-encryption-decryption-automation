#!/bin/bash

# Check if Homebrew is installed, and install if not
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed."
fi

# Check if GnuPG is installed, and install if not
if ! command -v gpg &> /dev/null; then
    echo "GnuPG not found. Installing GnuPG..."
    brew install gnupg
else
    echo "GnuPG is already installed."
fi

# Check if the gpg_config file exists
if [ ! -f "gpg_config" ]; then
    echo "gpg_config file not found. Please create the file with your GPG configuration."
    exit 1
fi

# Generate a new key pair non-interactively
echo "Generating a new GPG key pair..."
gpg --batch --generate-key gpg_config

# Export the public key
email=$(grep 'Name-Email' gpg_config | cut -d' ' -f2)
echo "Exporting the public key for $email..."
gpg --armor --export "$email" > recipient_public_key.asc

# Import the public key
echo "Importing the public key..."
gpg --import recipient_public_key.asc

# Check if the message.txt file exists
if [ ! -f "message.txt" ]; then
    echo "message.txt file not found. Please create the file and add your message."
    exit 1
fi

# Encrypt and sign the message
echo "Encrypting and signing the message..."
gpg --armor --encrypt --sign --recipient "$email" message.txt

# Check if the encrypted file was created
if [ ! -f "message.txt.asc" ]; then
    echo "Failed to create encrypted file. Please check the encryption process."
    exit 1
fi

# Decrypt the message
echo "Decrypting the message..."
gpg --decrypt message.txt.asc > decrypted_message.txt

# Verify the signature
echo "Verifying the signature..."
gpg --verify message.txt.asc

# Output the decrypted message
echo "Decrypted message content:"
cat decrypted_message.txt

echo "Process completed."

