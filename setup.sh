#!/bin/bash

# 0. Constants
PYTHON_SCRIPT="/workspace/poc_jci_Crane/dataset/generate_dataset_json/custom_dataset.py"
ZIP_BASE_DIR="/workspace/poc_jci_Crane/data"
ZIP_FILES=("nail_dataset_v5_train.zip" "nail_dataset_v5_test.zip" "hard_test_case.zip")

# 1. Install packages from requirements.txt if it exists
REQ_FILE="./requirements.txt"

if [ -f "$REQ_FILE" ]; then
    echo "[1] requirements.txt found. Installing packages..."
    pip install -r "$REQ_FILE"
    if [ $? -ne 0 ]; then
        echo "[!] Package installation failed. Exiting."
        exit 1
    fi
else
    echo "[1] requirements.txt not found. Skipping pip install."
fi

# 2. Download ViT-B SAM checkpoint (.pth) file to ~/.cache/sam
echo "[2] Checking Hugging Face model file in ~/.cache..."

HF_URL="https://huggingface.co/xingren23/comfyflow-models/resolve/976de8449674de379b02c144d0b3cfa2b61482f2/sams/sam_vit_b_01ec64.pth"
HF_CACHE_DIR="$HOME/.cache/sam"
HF_FILE_NAME="sam_vit_b_01ec64.pth"
HF_DEST_PATH="$HF_CACHE_DIR/$HF_FILE_NAME"

mkdir -p "$HF_CACHE_DIR"

if [ -f "$HF_DEST_PATH" ]; then
    echo "[2] Model file already exists at $HF_DEST_PATH. Skipping download."
else
    echo "[2] Downloading model file..."
    curl -L "$HF_URL" -o "$HF_DEST_PATH"
    if [ -f "$HF_DEST_PATH" ]; then
        echo "[2] Model file successfully saved to $HF_DEST_PATH"
    else
        echo "[!] Failed to download Hugging Face model file. Exiting."
        exit 1
    fi
fi

# 3. Download and extract VisA tar file
echo "[3] Checking VisA tar file..."

VISA_URL="https://amazon-visual-anomaly.s3.us-west-2.amazonaws.com/VisA_20220922.tar"
VISA_TAR_NAME="VisA_20220922.tar"
VISA_DOWNLOAD_DIR="/workspace/poc_jci_Crane/data"
VISA_TAR_PATH="$VISA_DOWNLOAD_DIR/$VISA_TAR_NAME"
VISA_EXTRACT_DIR="$VISA_DOWNLOAD_DIR/visa"

# Create extraction target directory
mkdir -p "$VISA_EXTRACT_DIR"

# Download only if tar does not already exist
if [ -f "$VISA_TAR_PATH" ]; then
    echo "[3] VisA tar file already exists at $VISA_TAR_PATH. Skipping download."
else
    echo "[3] Downloading VisA tar file to $VISA_TAR_PATH..."
    curl -L "$VISA_URL" -o "$VISA_TAR_PATH"
    if [ ! -f "$VISA_TAR_PATH" ]; then
        echo "[!] Failed to download VisA tar file. Exiting."
        exit 1
    fi
fi

# Extract only if visa folder does not already exist
if [ -d "$VISA_EXTRACT_DIR" ]; then
    echo "[3] VisA extraction directory already exists at $VISA_EXTRACT_DIR. Skipping extraction."
else
    echo "[3] Extracting VisA tar file to $VISA_EXTRACT_DIR..."
    mkdir -p "$VISA_EXTRACT_DIR"
    tar -xvf "$VISA_TAR_PATH" -C "$VISA_EXTRACT_DIR"
    echo "[3] Extraction complete."
    # Optionally delete tar after extraction
    # rm "$VISA_TAR_PATH"
fi

# Optional: remove tar file after extraction
# rm "$VISA_TAR_PATH"

echo "[3] VisA tar file extracted into $VISA_EXTRACT_DIR."

echo "[3] Running Python script to generate meta.json for VisA dataset..."
python3 /workspace/poc_jci_Crane/dataset/generate_dataset_json/visa.py


# 4. Unzip datasets and run Python meta generator
echo "[4] Unzipping datasets and generating meta.json..."

for zip_file in "${ZIP_FILES[@]}"; do
    zip_path="$ZIP_BASE_DIR/$zip_file"
    folder_name="${zip_file%.zip}"
    unzip_dir="$ZIP_BASE_DIR/$folder_name"

    if [ ! -d "$unzip_dir" ]; then
        if [ -f "$zip_path" ]; then
            echo "[4] Extracting $zip_file..."
            unzip -q "$zip_path" -d "$ZIP_BASE_DIR"
        else
            echo "[!] File not found: $zip_path. Skipping."
            continue
        fi
    else
        echo "[4] Directory $unzip_dir already exists. Skipping extraction."
    fi

    # Run Python script
    echo "[4] Running Python script for: $unzip_dir"
    python3 "$PYTHON_SCRIPT" --target "$unzip_dir"
done

echo "[✓] All tasks completed successfully."
