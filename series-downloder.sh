#!/bin/bash

LINKS_FILE=$1
LIMIT=${2:-1}

if [ -z "$LINKS_FILE" ]; then
    echo "Links file is not provided."
    exit 1
fi

if ! [[ "$LIMIT" =~ ^[0-9]+$ ]]; then
    echo "Invalid limit provided. Using default limit of 1."
    LIMIT=1
fi

download_season() {
    SEASON_LINKS="$1"
    SEASON_DIR="$2"

    echo "Downloading to directory: $SEASON_DIR"
    mkdir -p "$SEASON_DIR"

    echo "$SEASON_LINKS" | xargs -P "$LIMIT" -I {} wget -P "$SEASON_DIR" {}
}

PREV_SEASON=""
PREV_SEASON_DIR=""
SEASON_LINKS=""

while IFS= read -r line; do
    SEASON=$(echo "$line" | grep -oP 'S[0-9]+E[0-9]+')

    if [[ ! -z "$SEASON" ]]; then
        SEASON_DIR=$(echo "$SEASON" | grep -oP 'S[0-9]+' | tr '[:upper:]' '[:lower:]')

        if [[ "$PREV_SEASON" != "$SEASON_DIR" && ! -z "$PREV_SEASON" ]]; then
            download_season "$SEASON_LINKS" "$PREV_SEASON_DIR"
            SEASON_LINKS=""
        fi
        PREV_SEASON_DIR=$SEASON_DIR
        PREV_SEASON=$SEASON_DIR
        SEASON_LINKS+="$line"$'\n'
    else
        echo "No season found for $line"
    fi
done <"$LINKS_FILE"

if [[ ! -z "$SEASON_LINKS" ]]; then
    download_season "$SEASON_LINKS" "$PREV_SEASON_DIR"
fi
