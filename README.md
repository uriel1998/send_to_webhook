# Maubot Webhook Sender Script

This script sends a simple JSON payload to a Maubot webhook handler, allowing shell scripts or other command-line tools to post notifications into Matrix rooms via Maubot.

It is intended to work with the **maubot-webhook** plugin:

* Maubot core: [https://github.com/maubot/maubot](https://github.com/maubot/maubot)
* Webhook plugin: [https://github.com/jkhsjdhjs/maubot-webhook](https://github.com/jkhsjdhjs/maubot-webhook)

## Purpose

The script constructs a JSON payload containing a `title` and `body`, then POSTs it to a Maubot webhook endpoint using HTTP basic authentication. It is designed for:

* System notifications
* Scriptable alerts
* CLI-driven status messages
* Piping content from other commands into Matrix

## Requirements

* Bash
* `curl`
* `jq`
* A running Maubot instance
* The `maubot-webhook` plugin enabled and configured

## Configuration

The script expects configuration values to be provided via an environment file:

```
maubot_vars.env
```

This file is sourced at runtime and must define at least:

```bash
MATRIXSERVER="https://matrix.example.org"
MAUBOT_STATUS_WEBHOOK_INSTANCE="instance_name"
```

## Usage

### Command-line arguments

```bash
./send_to_webhook.sh --title "Title text" --body "Message body text"
```

* `--title`
  Sets the message title.
  Defaults to `Notification!` if omitted.

* `--body`
  Sets the message body.
  Consumes the remainder of the command line.

### STDIN mode

If no arguments are provided, the script reads the entire JSON body from standard input:

```bash
echo "Message text" | ./send_to_webhook.sh
```

This is useful for piping output from other commands.

### Loud mode

```bash
./send_to_webhook.sh --loud --title "Test" --body "Verbose output enabled"
```

When `--loud` is enabled, informational messages are printed to stdout.

## JSON Payload Format

The script generates JSON using `jq` to ensure proper escaping:

```json
{
  "title": "Notification!",
  "body": "Message text"
}
```

This payload is POSTed to:

```
${MATRIXSERVER}/_matrix/maubot/plugin/${MAUBOT_STATUS_WEBHOOK_INSTANCE}/send
```

Maubot's configuration should be similar to this:

```
path: /send
method: POST
room: '!RoomIDtoPostIn'
message: |-
    {{ json.title }} : {{ json.body }}
message_format: markdown
message_type: m.notice
auth_type:
auth_token:
force_json: false
ignore_empty_messages: false
```

## Behavior Notes

* JSON is constructed using `jq -n --arg` to avoid shell escaping issues.
* Defaults are applied only if values are not explicitly provided.
* The script is suitable for non-interactive use (cron jobs, monitoring hooks, etc.).

## Security Notes

* Credentials are currently embedded in the script via `curl -u`.
  Consider moving these to environment variables or a `.netrc` file.
* Ensure the script and `maubot_vars.env` have appropriate file permissions.
 
