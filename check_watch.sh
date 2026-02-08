#!/bin/bash

set -euo pipefail

WATCH_URL="https://delhiwatchcompany.com/products/dwc-terra"
JSON_URL="https://delhiwatchcompany.com/products/dwc-terra.js"
TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-}"
TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID:-}"

send_telegram_notification() {
    local message="$1"
    
    if [[ -z "$TELEGRAM_BOT_TOKEN" ]] || [[ -z "$TELEGRAM_CHAT_ID" ]]; then
        echo "Telegram credentials not configured. Skipping notification."
        return 0
    fi
    
    local telegram_url="https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage"
    
    curl -s -X POST "$telegram_url" \
        -d "chat_id=${TELEGRAM_CHAT_ID}" \
        -d "text=${message}" \
        -d "parse_mode=HTML" \
        -d "disable_web_page_preview=false" > /dev/null
    
    echo "Telegram notification sent!"
}

parse_json_available() {
    local json="$1"
    
    if command -v jq &> /dev/null; then
        echo "$json" | jq -r '.available'
    else
        echo "$json" | grep -o '"available":[^,]*' | head -1 | cut -d':' -f2 | tr -d ' '
    fi
}

main() {
    echo "Checking watch availability at: $JSON_URL"
    
    local response
    response=$(curl -sL "$JSON_URL" 2>/dev/null)
    
    if [[ -z "$response" ]]; then
        echo "Error: Failed to fetch product data"
        exit 1
    fi
    
    local available
    available=$(parse_json_available "$response")
    
    echo "Debug: available=$available"
    
    if [[ "$available" == "true" ]]; then
        echo "Status: AVAILABLE ✓"
        local message="🎉 <b>WATCH ALERT!</b> 🎉%0A%0AThe DWC Terra watch is <b>AVAILABLE</b>!%0A%0A🔗 <a href=\"$WATCH_URL\">Buy Now!</a>"
        send_telegram_notification "$message"
        echo "✓ Notification sent - watch is available!"
    elif [[ "$available" == "false" ]]; then
        echo "Status: SOLD OUT ❌"
    else
        echo "Status: UNKNOWN ❓"
        echo "Could not parse availability from response"
        exit 1
    fi
}

main
