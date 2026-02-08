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
    response=$(curl -sL "$WATCH_URL" 2>/dev/null)
    
    local has_sold_out=false
    local has_add_to_cart=false
    
    if echo "$response" | grep -qi "sold out\|unavailable\|out of stock"; then
        has_sold_out=true
    fi
    
    if echo "$response" | grep -qi "add to cart\|add to bag\|buy now\|purchase"; then
        has_add_to_cart=true
    fi
    
    echo "Debug: sold_out=$has_sold_out, add_to_cart=$has_add_to_cart"
    
    if [[ "$has_sold_out" == true ]]; then
        echo "Status: SOLD OUT ❌"
        echo "Reason: Found 'sold out' text on page"
    elif [[ "$has_add_to_cart" == true ]]; then
        echo "Status: AVAILABLE ✓"
        local message="🎉 <b>WATCH ALERT!</b> 🎉%0A%0AThe DWC Terra watch is <b>AVAILABLE</b>!%0A%0A🔗 <a href=\"$WATCH_URL\">Buy Now!</a>"
        send_telegram_notification "$message"
        echo "✓ Notification sent - watch is available!"
    else
        echo "Status: UNKNOWN ❓"
        echo "Could not determine status - page structure may have changed"
    fi
}

main
