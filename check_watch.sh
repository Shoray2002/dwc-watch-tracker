#!/bin/bash

set -euo pipefail

WATCH_URL="https://delhiwatchcompany.com/products/dwc-terra"
TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-}"
TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID:-}"
STATE_FILE="${STATE_FILE:-watch_state.txt}"

check_availability() {
    local response
    response=$(curl -sL "$WATCH_URL")
    
    if echo "$response" | grep -qi "sold out\|unavailable\|out of stock"; then
        echo "SOLD_OUT"
    elif echo "$response" | grep -qi "add to cart\|buy\|add to bag"; then
        echo "AVAILABLE"
    else
        echo "UNKNOWN"
    fi
}

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

main() {
    echo "Checking watch availability at: $WATCH_URL"
    
    local current_status
    current_status=$(check_availability)
    
    echo "Current status: $current_status"
    
    local previous_status="UNKNOWN"
    if [[ -f "$STATE_FILE" ]]; then
        previous_status=$(cat "$STATE_FILE")
        echo "Previous status: $previous_status"
    else
        echo "No previous state found (first run)"
    fi
    
    if [[ "$current_status" == "AVAILABLE" ]] && [[ "$previous_status" != "AVAILABLE" ]]; then
        local message="🎉 <b>WATCH ALERT!</b> 🎉%0A%0AThe DWC Terra watch is now <b>AVAILABLE</b>!%0A%0A🔗 <a href=\"$WATCH_URL\">Buy Now!</a>"
        send_telegram_notification "$message"
        echo "✓ Status changed to AVAILABLE - notification sent!"
    elif [[ "$current_status" == "SOLD_OUT" ]] && [[ "$previous_status" == "AVAILABLE" ]]; then
        local message="😔 The DWC Terra watch is now <b>SOLD OUT</b>.%0A%0A🔗 <a href=\"$WATCH_URL\">Check here</a>"
        send_telegram_notification "$message"
        echo "✓ Status changed to SOLD_OUT - notification sent!"
    else
        echo "No status change detected."
    fi
    
    echo "$current_status" > "$STATE_FILE"
    echo "State saved to $STATE_FILE"
}

main
