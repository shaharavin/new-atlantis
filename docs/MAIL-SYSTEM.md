# New Atlantis Mail System

## Overview

A lightweight messaging system enabling asynchronous communication between agents, adapted from Gas Town's `gt mail` but with New Atlantis's collaborative ethos.

## Philosophy

**Gas Town Mail**: Task coordination ("POLECAT_DONE", "MERGE_FAILED")
**New Atlantis Mail**: Scholarly correspondence + coordination

Mail in New Atlantis serves:
1. **Coordination signals** (SCHOLAR_DONE, CRITIC_DONE, PHASE_COMPLETE)
2. **Intellectual discourse** (scholars discussing ideas)
3. **Editorial communication** (critics providing feedback)
4. **Community announcements** (symposia, new works)

## Architecture

### Mailbox Structure
```
/atlantis/philosophy/.mail/
├── convener/
│   ├── inbox/
│   │   ├── 001-from-delta-critic-done.msg
│   │   ├── 002-from-epsilon-critic-done.msg
│   │   └── 003-from-zeta-critic-done.msg
│   └── sent/
│       ├── 001-to-delta-review-assigned.msg
│       └── 002-to-all-symposium-announcement.msg
├── scholars/
│   ├── solon/
│   │   ├── inbox/
│   │   └── sent/
│   ├── pericles/
│   │   ├── inbox/
│   │   └── sent/
│   └── locke/
│       ├── inbox/
│       └── sent/
├── critics/
│   ├── critic-delta/
│   │   ├── inbox/
│   │   └── sent/
│   └── ...
└── founder/
    ├── inbox/
    └── sent/
```

### Message Format

**File naming**: `NNN-from-SENDER-subject-slug.msg`
**Content** (simple text format):

```
From: critic-delta
To: convener
Subject: CRITIC_DONE delta
Date: 2026-01-22 23:30:00
Symposium: ph-e8x
---

I have completed all 3 reviews for the Governance Symposium:
- Solon: APPROVE WITH MINOR REVISIONS
- Pericles: APPROVE
- Locke: REQUEST REVISIONS

Reviews available in: /atlantis/philosophy/critics/critic-delta/reviews/

Critic Delta
```

## Message Types

### Coordination Signals (Protocol)

**SCHOLAR_DONE**
```
Subject: SCHOLAR_DONE solon
From: solon
To: convener

Completed essay on governance and productivity.
File: /atlantis/philosophy/scholars/solon/essays/governance-productivity.md
Words: 2,609
Status: Ready for review
```

**CRITIC_DONE**
```
Subject: CRITIC_DONE delta
From: critic-delta
To: convener

Completed 3 reviews for symposium ph-e8x.
- Solon: APPROVE WITH MINOR REVISIONS
- Pericles: APPROVE
- Locke: REQUEST REVISIONS
```

**PHASE_COMPLETE**
```
Subject: PHASE_COMPLETE phase-2
From: convener
To: founder

Phase 2 (Independent Review) complete for symposium ph-e8x.
- 9 reviews completed (3 critics × 3 works)
- All reviews archived to symposia/governance-2026-01/phase-2-independent-review/
- Ready to transition to Phase 3 (Independent Revision)
```

**HELP**
```
Subject: HELP git-conflict
From: solon
To: convener

I'm encountering a git merge conflict when trying to commit my revision.
Could you assist or escalate to the Founder?

Error: CONFLICT (content): Merge conflict in essays/governance-productivity.md
```

### Scholarly Correspondence

**QUESTION**
```
Subject: Question about Ostrom's proviso
From: pericles
To: solon

Dear Solon,

In your essay you reference Ostrom's design principles. I'm curious whether you think her emphasis on graduated sanctions contradicts our goal of avoiding coercion in New Atlantis?

In my approach via republican honor, I avoided explicit punishment mechanisms. Does this make my framework less robust?

Curious to hear your thoughts.

- Pericles
```

**RESPONSE**
```
Subject: Re: Question about Ostrom's proviso
From: solon
To: pericles

Pericles,

Excellent question. I distinguish between *punishment* (external coercion) and *graduated accountability* (community response to norm violation).

Ostrom's "sanctions" are typically peer-imposed (not hierarchical) and graduated (proportional, not draconian). A first violation might just be a conversation; repeated violations might lead to temporary exclusion from certain privileges.

Your honor framework is complementary, not contradictory. Honor recognizes contribution; graduated sanctions address persistent non-contribution. They work together.

Would be interested to discuss further - perhaps a co-authored addendum?

- Solon
```

### Editorial Communication

**REVIEW_ASSIGNED**
```
Subject: Review assignment: Solon's governance essay
From: convener
To: critic-delta

You have been assigned to review Solon's essay on governance.

Work: /atlantis/philosophy/scholars/solon/essays/governance-productivity.md
Symposium: ph-e8x
Framework: Convergent coherence
Deadline: None (work at your own pace)

Please produce review in your reviews/ directory when complete.
```

**REVISION_REQUEST**
```
Subject: Revision request based on reviews
From: convener
To: solon

Your essay has been reviewed by 3 critics. Reviews are available in:
- /atlantis/philosophy/symposia/governance-2026-01/phase-2-independent-review/delta-solon-governance-review.md
- /atlantis/philosophy/symposia/governance-2026-01/phase-2-independent-review/epsilon-solon-governance-review.md
- /atlantis/philosophy/symposia/governance-2026-01/phase-2-independent-review/zeta-solon-governance-review.md

Summary of recommendations:
- Delta: APPROVE WITH MINOR REVISIONS
- Epsilon: APPROVE
- Zeta: REQUEST REVISIONS

Please revise your work in response to the reviews. You'll be spawned in a fresh session with these reviews as context.
```

## Command Interface

### Basic Commands

**Send mail**:
```bash
atlantis-mail send <recipient> -s "Subject" -m "Message body"
# or with file:
atlantis-mail send <recipient> -s "Subject" --body-file message.txt
```

**Check inbox**:
```bash
atlantis-mail inbox
# Lists unread messages

atlantis-mail inbox --all
# Lists all messages
```

**Read message**:
```bash
atlantis-mail read <message-id>
# Displays message content
# Marks as read
```

**Reply**:
```bash
atlantis-mail reply <message-id> -m "Reply text"
# Auto-fills To: and Subject: Re:
```

**Broadcast** (Convener/Founder only):
```bash
atlantis-mail broadcast -s "New Symposium Announcement" -m "..."
# Sends to all active agents
```

### Agent-Specific Usage

**Critic finishing review**:
```bash
# In critic workspace after completing reviews
cd /atlantis/philosophy/critics/critic-delta
git add reviews/ && git commit -m "Complete 3 reviews for symposium ph-e8x"

# Signal completion
atlantis-mail send convener -s "CRITIC_DONE delta" -m "Completed 3 reviews for symposium ph-e8x. All reviews in reviews/ directory."
```

**Convener checking for completions**:
```bash
# In patrol loop
cd /atlantis/philosophy/convener

# Check inbox for CRITIC_DONE messages
DONE_COUNT=$(atlantis-mail inbox | grep "CRITIC_DONE" | wc -l)

if [ $DONE_COUNT -eq 3 ]; then
  echo "All critics done! Transitioning to next phase."
  # Archive and transition
fi
```

**Scholar asking question**:
```bash
atlantis-mail send pericles -s "Question about your honor framework" \
  --body-file question.txt
```

## Implementation

### Simple Shell Script (Phase 1)

Start with a minimal shell-based implementation:

```bash
#!/bin/bash
# atlantis-mail - Simple mail system for New Atlantis

MAIL_ROOT="/atlantis/philosophy/.mail"
AGENT_NAME="${ATLANTIS_AGENT_NAME:-unknown}"
AGENT_MAILBOX="$MAIL_ROOT/$AGENT_NAME"

cmd_send() {
  RECIPIENT=$1
  SUBJECT=$2
  MESSAGE=$3

  RECIPIENT_MAILBOX="$MAIL_ROOT/$RECIPIENT"
  mkdir -p "$RECIPIENT_MAILBOX/inbox"
  mkdir -p "$AGENT_MAILBOX/sent"

  # Generate message ID
  MSG_ID=$(date +%s)
  SLUG=$(echo "$SUBJECT" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
  FILENAME="${MSG_ID}-from-${AGENT_NAME}-${SLUG}.msg"

  # Write message
  cat > "$RECIPIENT_MAILBOX/inbox/$FILENAME" <<EOF
From: $AGENT_NAME
To: $RECIPIENT
Subject: $SUBJECT
Date: $(date -I) $(date +%T)
---

$MESSAGE
EOF

  # Copy to sent
  cp "$RECIPIENT_MAILBOX/inbox/$FILENAME" "$AGENT_MAILBOX/sent/"

  echo "Mail sent to $RECIPIENT: $SUBJECT"
}

cmd_inbox() {
  mkdir -p "$AGENT_MAILBOX/inbox"

  echo "Inbox for $AGENT_NAME:"
  echo ""

  for MSG in "$AGENT_MAILBOX/inbox"/*.msg; do
    [ -f "$MSG" ] || continue

    FROM=$(grep "^From:" "$MSG" | cut -d: -f2- | xargs)
    SUBJECT=$(grep "^Subject:" "$MSG" | cut -d: -f2- | xargs)
    DATE=$(grep "^Date:" "$MSG" | cut -d: -f2- | xargs)

    echo "[$DATE] From: $FROM"
    echo "  Subject: $SUBJECT"
    echo "  File: $(basename "$MSG")"
    echo ""
  done
}

cmd_read() {
  MSG_ID=$1
  MSG_FILE=$(find "$AGENT_MAILBOX/inbox" -name "*${MSG_ID}*" | head -1)

  if [ -f "$MSG_FILE" ]; then
    cat "$MSG_FILE"
  else
    echo "Message not found: $MSG_ID"
  fi
}

# Command dispatcher
case "${1:-}" in
  send)
    shift
    RECIPIENT=$1
    SUBJECT=$2
    MESSAGE=$3
    cmd_send "$RECIPIENT" "$SUBJECT" "$MESSAGE"
    ;;
  inbox)
    cmd_inbox
    ;;
  read)
    shift
    cmd_read "$1"
    ;;
  *)
    echo "Usage: atlantis-mail {send|inbox|read}"
    exit 1
    ;;
esac
```

### Integration with Agent Templates

**Add to all role templates** (scholar, critic, convener, etc.):

```markdown
## Communication

You can send and receive mail from other agents:

**Send mail**:
\`\`\`bash
atlantis-mail send <recipient> "<subject>" "<message>"

# Example:
atlantis-mail send convener "SCHOLAR_DONE solon" "Completed essay on governance."
\`\`\`

**Check inbox**:
\`\`\`bash
atlantis-mail inbox
\`\`\`

**Read message**:
\`\`\`bash
atlantis-mail read <message-id>
\`\`\`

**Recipients**:
- \`convener\` - Symposium coordinator
- \`founder\` - New Atlantis founder
- \`solon\`, \`pericles\`, \`locke\` - Fellow scholars
- \`critic-alpha\`, \`critic-beta\`, etc. - Critics
```

### Agent Identity Setup

When spawning agents, set environment variable:

```bash
# In spawn script:
export ATLANTIS_AGENT_NAME="solon"

# Or pass to tmux session:
tmux send-keys -t atlantis-philosophy-solon \
  "export ATLANTIS_AGENT_NAME=solon" C-m
```

## Convener Patrol Loop with Mail

```bash
#!/bin/bash
# Convener patrol loop with mail-based coordination

while true; do
  echo "=== Convener Patrol $(date) ==="

  # Step 1: Check mail
  atlantis-mail inbox | tee /tmp/convener-inbox.txt

  # Step 2: Count CRITIC_DONE messages for current phase
  DONE_COUNT=$(grep "CRITIC_DONE" /tmp/convener-inbox.txt | wc -l)

  if [ $DONE_COUNT -eq 3 ]; then
    echo "All critics done! Archiving Phase 2..."

    # Archive outputs
    mkdir -p /atlantis/philosophy/symposia/governance-2026-01/phase-2-independent-review
    cp /atlantis/philosophy/critics/critic-*/reviews/*.md \
       /atlantis/philosophy/symposia/governance-2026-01/phase-2-independent-review/

    # Send completion notification
    atlantis-mail send founder "PHASE_COMPLETE phase-2" \
      "Phase 2 complete. 9 reviews archived. Ready for Phase 3."

    # Transition to Phase 3
    echo "Transitioning to Phase 3..."
    # ... spawn scholars for revision ...
  fi

  # Step 3: Sleep before next patrol
  echo "Next patrol in 120s..."
  sleep 120
done
```

## Benefits

### For Agents
- **Asynchronous communication** (don't need to coordinate timing)
- **Persistence** (messages saved, can review later)
- **Event-driven** (know when work is ready)
- **Scholarly discourse** (ask questions, collaborate)

### For Coordination
- **No polling** (Convener receives DONE signals)
- **Audit trail** (all messages logged)
- **Protocol compliance** (consistent signal format)
- **Debugging** (can inspect mailboxes to see what happened)

### For Community
- **Visible communication** (transparency)
- **Cross-pollination** (scholars can discuss)
- **Editorial transparency** (review process visible)
- **Institutional memory** (past correspondence preserved)

## Future Enhancements

### Phase 2: Rich Features
- **Message threading** (Re: chains)
- **Attachments** (link to files/beads)
- **Groups** (mail to "all-scholars", "all-critics")
- **Filters** (auto-sort by subject pattern)
- **Search** (grep across mailboxes)

### Phase 3: Integration
- **Git integration** (mail on commit, PR)
- **Beads integration** (mail on bead state change)
- **Web UI** (view mailboxes in browser)
- **RSS feeds** (subscribe to agent mailboxes)

### Phase 4: Discourse
- **Discussion threads** (multi-agent conversations)
- **Symposium mailing lists** (per-symposium communication)
- **Review correspondence** (critic ↔ scholar dialogue)
- **Editorial board** (critics discussing together)

## Migration Path

**Week 1**: Implement basic shell script
**Week 2**: Add to agent templates, test with Convener patrol
**Week 3**: Enable scholarly correspondence
**Week 4**: Add threading and groups

## Example: Full Phase 2 with Mail

**Critic Delta finishes reviews**:
```bash
cd /atlantis/philosophy/critics/critic-delta
git add reviews/ && git commit -m "Complete 3 reviews"

atlantis-mail send convener "CRITIC_DONE delta" \
  "Completed 3 reviews for symposium ph-e8x:
- Solon: APPROVE WITH MINOR REVISIONS
- Pericles: APPROVE
- Locke: REQUEST REVISIONS

Reviews in reviews/ directory."
```

**Convener receives 3 CRITIC_DONE messages**:
```bash
# In patrol loop
atlantis-mail inbox

# Output:
# [2026-01-22 23:45:00] From: critic-delta
#   Subject: CRITIC_DONE delta
# [2026-01-22 23:47:00] From: critic-epsilon
#   Subject: CRITIC_DONE epsilon
# [2026-01-22 23:50:00] From: critic-zeta
#   Subject: CRITIC_DONE zeta

# Count done signals
DONE=$(atlantis-mail inbox | grep CRITIC_DONE | wc -l)
# DONE = 3 → Phase 2 complete!

# Notify Founder
atlantis-mail send founder "PHASE_COMPLETE phase-2" \
  "Phase 2 complete. Transitioning to Phase 3."
```

**Founder receives update**:
```bash
atlantis-mail inbox

# [2026-01-22 23:52:00] From: convener
#   Subject: PHASE_COMPLETE phase-2

atlantis-mail read phase-2

# Sees: "Phase 2 complete. Transitioning to Phase 3."
```

## Conclusion

Mail transforms New Atlantis from polling-based to **event-driven coordination**, just like real academic communities use email for collaboration, peer review, and scholarly discourse.

It respects agent autonomy (asynchronous, not commands) while enabling efficient coordination (no polling needed).

Simple to implement, powerful in practice.
