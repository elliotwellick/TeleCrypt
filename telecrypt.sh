#!/bin/bash

readonly RATE_LIMIT_INTERVAL=5
readonly CONFIG_FILE="telegram-cloud.config"

get_sensitive_info() {
    local sensitive_info
    read -s -p "$1: " sensitive_info
    echo "$sensitive_info"
}

encrypt_file() {
    local file_path="$1"
    local encrypted_file_path="$file_path.gpg"

    gpg --batch --yes --passphrase-file <(echo "$ENCRYPTION_KEY") --output "$encrypted_file_path" --symmetric "$file_path"

    if [ $? -ne 0 ]; then
        echo "Error encrypting the file."
        return 1
    fi

    echo "File encrypted and saved as $encrypted_file_path"
    return 0
}

upload_file() {
    local file_path="$1"

    if [ -z "$file_path" ]; then
        echo "Please provide the file path to upload."
        return 1
    fi

    if [ ! -f "$file_path" ]; then
        echo "File not found. Please provide a valid file path to upload."
        return 1
    fi

    local encrypted_file_path="$file_path.gpg"
    encrypt_file "$file_path"   # Encrypt the file before uploading

    if [ $? -ne 0 ]; then
        return 1
    fi

    if [ -z "$CHAT_ID" ]; then
        echo "Chat ID not set. Use 'set_chat_id' command to set the chat ID."
        return 1
    fi

    echo "Uploading file to Telegram cloud storage..."

    local current_time=$(date +%s)
    local time_diff=$((current_time - last_request_time))
    if [ "$time_diff" -lt "$RATE_LIMIT_INTERVAL" ]; then
        sleep "$((RATE_LIMIT_INTERVAL - time_diff))"
    fi

    local response=$(curl -s -F "chat_id=$CHAT_ID" -F "document=@$encrypted_file_path" "https://api.telegram.org/bot$BOT_TOKEN/sendDocument")

    echo "Upload response: $response"  # Add debugging output

    if [ -z "$response" ] || ! echo "$response" | grep -q '"ok":true'; then
        echo "Error uploading file. Please try again later."
        rm "$encrypted_file_path"  # Wipe the GPG file after an error
        return 1
    fi

    local file_id=$(echo "$response" | grep -o '"file_id":"[^"]*' | cut -d':' -f2 | tr -d '"')
    echo "File uploaded to Telegram cloud storage. File ID: $file_id"
    rm "$encrypted_file_path"  # Wipe the GPG file after uploading

    last_request_time=$(date +%s)
    return 0
}


initialize() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    else
        echo "Config file '$CONFIG_FILE' not found. Creating a new configuration..."
        BOT_TOKEN=$(get_sensitive_info "Enter your Telegram bot token")
        ENCRYPTION_KEY=$(get_sensitive_info "Enter your encryption key")
        CHAT_ID=""
        echo "BOT_TOKEN='$BOT_TOKEN'" > "$CONFIG_FILE"
        echo "ENCRYPTION_KEY='$ENCRYPTION_KEY'" >> "$CONFIG_FILE"
        echo "CHAT_ID='$CHAT_ID'" >> "$CONFIG_FILE"
        chmod 600 "$CONFIG_FILE"
    fi
}

main() {
    initialize

    if [ -z "$BOT_TOKEN" ] || [ -z "$ENCRYPTION_KEY" ]; then
        echo "Error: Missing or invalid configuration. Please check '$CONFIG_FILE'."
        exit 1
    fi

    case "$1" in
        upload)
            upload_file "$2"
            ;;
        download)
            download_file "$2"
            ;;
        list)
            list_files
            ;;
        set_chat_id)
            if [ -z "$2" ]; then
                echo "Please provide the chat ID to set."
                exit 1
            fi
            CHAT_ID="$2"
            echo "CHAT_ID='$CHAT_ID'" >> "$CONFIG_FILE"
            echo "Chat ID set to: $CHAT_ID"
            ;;
        help)
            echo "Usage: ./telecrypt.sh [upload <file_path> | download <file_id> | list | set_chat_id <chat_id> | help]"
            ;;
        *)
            echo "Invalid command. Use 'help' for usage instructions."
            exit 1
            ;;
    esac
}

main "$@"
