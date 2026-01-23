#!/bin/bash
# atlantis-mail - Simple mail system for New Atlantis agents
# Enables asynchronous communication and event-driven coordination

set -e

MAIL_ROOT="/atlantis/philosophy/.mail"
AGENT_NAME="${ATLANTIS_AGENT_NAME:-${USER:-unknown}}"
AGENT_MAILBOX="$MAIL_ROOT/$AGENT_NAME"

show_help() {
    cat <<EOF
atlantis-mail - New Atlantis Mail System

Usage:
  atlantis-mail send <recipient> <subject> <message>
  atlantis-mail send <recipient> <subject> --file <message-file>
  atlantis-mail inbox [--all]
  atlantis-mail read <message-id>
  atlantis-mail list-agents

Examples:
  # Send completion signal
  atlantis-mail send convener "SCHOLAR_DONE solon" "Completed essay on governance"

  # Send with file
  atlantis-mail send pericles "Question about Ostrom" --file question.txt

  # Check inbox
  atlantis-mail inbox

  # Read specific message
  atlantis-mail read 001-from-convener

Environment:
  ATLANTIS_AGENT_NAME - Your agent identity (e.g., solon, critic-delta, convener)

Recipients:
  convener          - Symposium coordinator
  founder           - New Atlantis founder
  solon             - Scholar
  pericles          - Scholar
  locke             - Scholar
  critic-alpha      - Critic
  critic-beta       - Critic
  critic-delta      - Critic
  (etc.)
EOF
}

cmd_send() {
    RECIPIENT=$1
    SUBJECT=$2
    shift 2

    # Check for --file flag
    if [ "$1" = "--file" ]; then
        MESSAGE=$(cat "$2")
    else
        MESSAGE="$*"
    fi

    if [ -z "$RECIPIENT" ] || [ -z "$SUBJECT" ]; then
        echo "Error: Recipient and subject required"
        echo "Usage: atlantis-mail send <recipient> <subject> <message>"
        exit 1
    fi

    # Create mailboxes if they don't exist
    RECIPIENT_MAILBOX="$MAIL_ROOT/$RECIPIENT"
    mkdir -p "$RECIPIENT_MAILBOX/inbox"
    mkdir -p "$AGENT_MAILBOX/sent"

    # Generate message ID and filename
    MSG_ID=$(date +%s%N | md5sum | cut -c1-8)
    SLUG=$(echo "$SUBJECT" | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g' | cut -c1-40)
    FILENAME="${MSG_ID}-from-${AGENT_NAME}-${SLUG}.msg"

    # Write message
    cat > "$RECIPIENT_MAILBOX/inbox/$FILENAME" <<EOF
From: $AGENT_NAME
To: $RECIPIENT
Subject: $SUBJECT
Date: $(date '+%Y-%m-%d %H:%M:%S')
Message-ID: $MSG_ID
---

$MESSAGE
EOF

    # Copy to sent folder
    cp "$RECIPIENT_MAILBOX/inbox/$FILENAME" "$AGENT_MAILBOX/sent/"

    echo "✉️  Mail sent to $RECIPIENT"
    echo "   Subject: $SUBJECT"
    echo "   Message-ID: $MSG_ID"
}

cmd_inbox() {
    mkdir -p "$AGENT_MAILBOX/inbox"

    SHOW_ALL=false
    if [ "$1" = "--all" ]; then
        SHOW_ALL=true
    fi

    echo "📬 Inbox for $AGENT_NAME"
    echo "════════════════════════════════════════════════"
    echo ""

    MSG_COUNT=0
    for MSG in "$AGENT_MAILBOX/inbox"/*.msg; do
        [ -f "$MSG" ] || continue

        MSG_COUNT=$((MSG_COUNT + 1))

        FROM=$(grep "^From:" "$MSG" | cut -d: -f2- | xargs)
        SUBJECT=$(grep "^Subject:" "$MSG" | cut -d: -f2- | xargs)
        DATE=$(grep "^Date:" "$MSG" | cut -d: -f2- | xargs)
        MSG_ID=$(grep "^Message-ID:" "$MSG" | cut -d: -f2- | xargs)

        echo "[$DATE] From: $FROM"
        echo "  Subject: $SUBJECT"
        echo "  ID: $MSG_ID"
        echo ""
    done

    if [ $MSG_COUNT -eq 0 ]; then
        echo "No messages in inbox"
    else
        echo "────────────────────────────────────────────────"
        echo "Total: $MSG_COUNT message(s)"
        echo ""
        echo "Read a message: atlantis-mail read <message-id>"
    fi
}

cmd_read() {
    MSG_ID=$1

    if [ -z "$MSG_ID" ]; then
        echo "Error: Message ID required"
        echo "Usage: atlantis-mail read <message-id>"
        exit 1
    fi

    # Find message by ID
    MSG_FILE=$(grep -l "Message-ID: $MSG_ID" "$AGENT_MAILBOX/inbox"/*.msg 2>/dev/null | head -1)

    if [ -z "$MSG_FILE" ]; then
        # Try partial match on filename
        MSG_FILE=$(find "$AGENT_MAILBOX/inbox" -name "*${MSG_ID}*" | head -1)
    fi

    if [ -f "$MSG_FILE" ]; then
        echo "════════════════════════════════════════════════"
        cat "$MSG_FILE"
        echo "════════════════════════════════════════════════"
    else
        echo "Error: Message not found: $MSG_ID"
        echo ""
        echo "Available messages:"
        atlantis-mail inbox
    fi
}

cmd_list_agents() {
    echo "Active agents (with mailboxes):"
    echo ""

    if [ -d "$MAIL_ROOT" ]; then
        for MAILBOX in "$MAIL_ROOT"/*/; do
            AGENT=$(basename "$MAILBOX")
            INBOX_COUNT=$(find "$MAILBOX/inbox" -name "*.msg" 2>/dev/null | wc -l)
            SENT_COUNT=$(find "$MAILBOX/sent" -name "*.msg" 2>/dev/null | wc -l)

            echo "  $AGENT"
            echo "    Inbox: $INBOX_COUNT | Sent: $SENT_COUNT"
        done
    else
        echo "  No mail system initialized yet"
    fi
}

cmd_broadcast() {
    SUBJECT=$1
    shift
    MESSAGE="$*"

    echo "Broadcasting to all agents..."

    if [ ! -d "$MAIL_ROOT" ]; then
        echo "Error: No mail system exists yet"
        exit 1
    fi

    for MAILBOX in "$MAIL_ROOT"/*/; do
        RECIPIENT=$(basename "$MAILBOX")

        # Don't send to self
        if [ "$RECIPIENT" = "$AGENT_NAME" ]; then
            continue
        fi

        cmd_send "$RECIPIENT" "$SUBJECT" "$MESSAGE" > /dev/null
    done

    echo "Broadcast complete"
}

# Command dispatcher
case "${1:-}" in
    send)
        shift
        cmd_send "$@"
        ;;
    inbox)
        shift
        cmd_inbox "$@"
        ;;
    read)
        shift
        cmd_read "$@"
        ;;
    list-agents)
        cmd_list_agents
        ;;
    broadcast)
        shift
        cmd_broadcast "$@"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Error: Unknown command '${1:-}'"
        echo ""
        show_help
        exit 1
        ;;
esac
