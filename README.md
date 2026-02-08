# DWC Watch Availability Tracker

Automated GitHub Actions bot that monitors the availability of the DWC Terra watch and sends Telegram notifications when the status changes.

## Features

- 🔄 Checks watch availability every 30 minutes
- 📱 Sends Telegram notifications when status changes
- 💾 Tracks status history to avoid duplicate notifications
- ⚡ Efficient bash implementation with minimal dependencies

## Setup Instructions

### 1. Create a Telegram Bot

1. Open Telegram and search for `@BotFather`
2. Send `/newbot` and follow the instructions
3. Copy the bot token (looks like `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`)

### 2. Get Your Telegram Chat ID

1. Send a message to your new bot
2. Visit: `https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getUpdates`
3. Find your `chat_id` in the response

### 3. Configure GitHub Secrets

1. Go to your repository on GitHub
2. Navigate to Settings → Secrets and variables → Actions
3. Click "New repository secret" and add:
   - `TELEGRAM_BOT_TOKEN`: Your bot token from BotFather
   - `TELEGRAM_CHAT_ID`: Your chat ID from step 2

### 4. Enable GitHub Actions

1. Go to the Actions tab in your repository
2. Enable workflows if prompted
3. The bot will automatically run every 30 minutes
4. You can also trigger it manually using "Run workflow"

## Watch URL

Currently monitoring: https://delhiwatchcompany.com/products/dwc-terra

## How It Works

1. The GitHub Action runs every 30 minutes (configurable in `.github/workflows/check-watch.yml`)
2. The bash script fetches the watch page and checks for availability keywords
3. If the status changes from "SOLD_OUT" to "AVAILABLE", you get a Telegram notification
4. The state is persisted between runs using GitHub Actions artifacts

## Testing Locally

```bash
# Set environment variables
export TELEGRAM_BOT_TOKEN="your_token_here"
export TELEGRAM_CHAT_ID="your_chat_id_here"

# Make the script executable
chmod +x check_watch.sh

# Run the checker
./check_watch.sh
```

## Customization

### Change Check Frequency

Edit the cron schedule in `.github/workflows/check-watch.yml`:

```yaml
schedule:
  - cron: '*/30 * * * *'  # Every 30 minutes
```

Examples:
- `*/15 * * * *` - Every 15 minutes
- `0 * * * *` - Every hour
- `0 */6 * * *` - Every 6 hours

### Monitor a Different Watch

Edit the `WATCH_URL` in `check_watch.sh`:

```bash
WATCH_URL="https://delhiwatchcompany.com/products/your-watch"
```

## Troubleshooting

- **Not receiving notifications**: Check that your Telegram bot token and chat ID are correct in GitHub Secrets
- **False positives**: The script looks for keywords like "add to cart" or "sold out". If the website changes, you may need to update the detection logic
- **Workflow not running**: Ensure GitHub Actions are enabled in your repository settings

## License

MIT
