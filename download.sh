#!/bin/bash

# Install wget if not present
if ! command -v wget &> /dev/null; then
    echo "Installing wget..."
    apt-get update && apt-get install -y wget
fi

echo "Creating directories..."
mkdir -p temp/
mkdir -p data/
mkdir -p modules/CE_detection/ckpts
mkdir -p modules/KP_detection/ckpts
mkdir -p modules/Grouping_legend_mapping/ckpts

# Function to download from Google Drive
download_from_gdrive() {
    FILE_ID=$1
    DESTINATION=$2
    CONFIRM=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate "https://docs.google.com/uc?export=download&id=$FILE_ID" -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')
    wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$CONFIRM&id=$FILE_ID" -O $DESTINATION
    rm -rf /tmp/cookies.txt
}

echo "Downloading model weights..."
echo "This might take a while..."

# Download model weights
echo "Downloading checkpoint110.pth..."
download_from_gdrive "1z6nLrIfjPRghJkLzPIWBLs5KPPaxgnfx" "modules/CE_detection/ckpts/checkpoint110.pth"

echo "Downloading ckpt_30.t7..."
download_from_gdrive "1N49INpPKXWbAk7DCk8dRJX9MUnUa184d" "modules/Grouping_legend_mapping/ckpts/ckpt_30.t7"

echo "Downloading mlp_ckpt.t7..."
download_from_gdrive "1FtA-gJoU6Nf1nUTkMX2g_909l1rn96N0" "modules/Grouping_legend_mapping/ckpts/mlp_ckpt.t7"

echo "Downloading ckpt_L.t7..."
download_from_gdrive "1LFSCjf1gnK346iZQRCUPL_yLPmfP2Zyl" "modules/KP_detection/ckpts/ckpt_L.t7"

echo "Downloading ckpt_L+D.t7..."
download_from_gdrive "1QyPykDBusW9LW0YejuTJfgfPr4qICtq8" "modules/KP_detection/ckpts/ckpt_L+D.t7"

while getopts "T:V:L:" flag
do
    case "${flag}" in
        T) TRAIN=${OPTARG};;
        V) VAL=${OPTARG};;
        L) TEST=${OPTARG};;
    esac
done

if [ "$TRAIN" = "True" ] || [ "$VAL" = "True" ] || [ "$TEST" = "True" ]
then 
   mkdir -p data/
   echo "Downloading data files..."
fi

if [ "$TRAIN" = "True" ]
then
   echo "Downloading training data..."
   mkdir -p data/train
   download_from_gdrive "1-2A0TXTY2cL7390NSvVXrt9skIuUKkR" "temp/train.zip"
   unzip temp/train.zip -d data/train/
fi

if [ "$VAL" = "True" ]
then
   echo "Downloading validation data..."
   mkdir -p data/val
   download_from_gdrive "1wr1pezZ3teMiS3k4TCNcNvH7TigtiGMF" "temp/val.zip"
   unzip temp/val.zip -d data/val/
fi

if [ "$TEST" = "True" ]
then
   echo "Downloading test data..."
   mkdir -p data/test
   download_from_gdrive "1nDSGrYqUrwBg-8YkcvWLmGU5mtyfA1uz" "temp/test.zip"
   unzip temp/test.zip -d data/test/
fi

echo "Cleaning up..."
rm -rf temp/

echo "Download complete!"