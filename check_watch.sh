#!/bin/bash

set -euo pipefail

WATCH_URL="https://delhiwatchcompany.com/products/dwc-terra"
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

main() {
    echo "Checking watch availability at: $WATCH_URL"
    
    local response
    response=$(curl -sL "$WATCH_URL")
    
    if echo "$response" | grep -qi "sold out"; then
        echo "Status: SOLD OUT ❌"
        echo "No notification sent (watch is sold out)"
    else
        echo "Status: AVAILABLE ✓"
        local message="🎉 <b>WATCH ALERT!</b> 🎉%0A%0AThe DWC Terra watch is <b>AVAILABLE</b>!%0A%0A🔗 <a href=\"$WATCH_URL\">Buy Now!</a>"
        send_telegram_notification "$message"
        echo "✓ Notification sent - watch is available!"
    fi
}

main
