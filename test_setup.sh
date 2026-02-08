#!/bin/bash

echo "Testing Telegram bot with your token..."
echo ""

export TELEGRAM_BOT_TOKEN="8350053486:AAGqLgCUI-nHTkFHO5OQUdkBLaxEccIFaS0"

echo "Step 1: Getting your chat ID..."
echo "Please send a message to your bot first, then press Enter"
read -r

RESPONSE=$(curl -s "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getUpdates")
CHAT_ID=$(echo "$RESPONSE" | grep -o '"chat":{"id":[0-9-]*' | head -1 | grep -o '[0-9-]*$')

if [[ -z "$CHAT_ID" ]]; then
    echo "❌ Could not find chat ID. Make sure you sent a message to your bot!"
    echo ""
    echo "Bot link: https://t.me/$(curl -s "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getMe" | grep -o '"username":"[^"]*"' | cut -d'"' -f4)"
    exit 1
fi

echo "✓ Found chat ID: $CHAT_ID"
echo ""

export TELEGRAM_CHAT_ID="$CHAT_ID"

echo "Step 2: Sending test notification..."
TEST_MESSAGE="🧪 <b>Test Notification</b>%0A%0AYour DWC Terra watch tracker is working! You'll be notified whenever the watch availability changes.%0A%0A✓ Status changes are monitored%0A✓ Notifications are enabled"

curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    -d "chat_id=${CHAT_ID}" \
    -d "text=${TEST_MESSAGE}" \
    -d "parse_mode=HTML" > /dev/null

echo "✓ Test notification sent! Check your Telegram."
echo ""
echo "Step 3: Running the watch checker..."
echo ""

./check_watch.sh

echo ""
echo "================================================"
echo "✓ Setup complete!"
echo ""
echo "To use with GitHub Actions, add these secrets:"
echo "  TELEGRAM_BOT_TOKEN: 8350053486:AAGqLgCUI-nHTkFHO5OQUdkBLaxEccIFaS0"
echo "  TELEGRAM_CHAT_ID: $CHAT_ID"
echo "================================================"
