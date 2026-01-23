# Coordination Efficiency in New Atlantis

## Token-Efficient Event-Driven Coordination

New Atlantis uses a **mail-based signaling system** to coordinate multi-agent discourse without expensive continuous polling.

## Architecture

### Agents Signal Completion

When scholars or critics finish their work, they:

1. Commit work to git
2. Close work bead (`bd close`)
3. **Mail the convener** with completion signal
4. Exit cleanly

```bash
export ATLANTIS_AGENT_NAME=solon
atlantis-mail send convener "SCHOLAR_DONE solon" "Completed essay on governance"
exit
```

### Convener Polls Inbox (Relaxed Interval)

The Convener runs a patrol loop that:

1. Checks inbox for SCHOLAR_DONE / CRITIC_DONE signals
2. Counts completed agents per phase
3. When phase complete → transitions to next phase
4. Spawns new agents for next phase
5. Sleeps 5 minutes before next cycle

**Why 5 minutes?** Academic discourse operates on slower timescales than production systems. Scholars typically work for 1-3 hours. Checking every 5 minutes is frequent enough while being token-efficient.

## Token Cost Comparison

### Continuous Polling (Gas Town style)
- Check every 30 seconds
- 120 checks/hour
- High token usage for simple status checks

### Mail-Based (New Atlantis style)
- Check inbox every 5 minutes
- 12 checks/hour (10x reduction)
- Inbox check is simple text file read (very low cost)
- Only "wakes up" when messages arrive

## Model Selection for Efficiency

### Scholars/Critics: Opus (Quality Work)
- Deep philosophical analysis requires best model
- Long-form writing benefits from Opus capabilities
- Cost justified by output quality

### Convener: Sonnet (Coordination)
- Coordination tasks are simpler than content creation
- Checking inbox, spawning agents, archiving outputs
- Sonnet is more than capable for these tasks
- **3-5x cost savings** compared to Opus

### Potential: Haiku for Simple Tasks
- Future: Could use Haiku for pure mechanical tasks
- Archive copying, file organization, simple checks
- Would need testing to ensure reliability

## Message Format

### Standard Signals

```
SCHOLAR_DONE <name>
  Subject: "SCHOLAR_DONE solon"
  Body: "Completed essay on [topic]"

CRITIC_DONE <name>
  Subject: "CRITIC_DONE critic-delta"
  Body: "Completed review of [work]"

NEW_SYMPOSIUM
  Subject: "NEW_SYMPOSIUM"
  Body: "Topic: [question]\nScholars: solon,pericles,locke"

ESCALATION
  Subject: "ESCALATION [agent-name]"
  Body: "Problem description"
```

### Mailbox Structure

```
/atlantis/philosophy/.mail/
├── convener/
│   ├── inbox/
│   │   ├── 001-from-solon-scholar-done.msg
│   │   ├── 002-from-critic-delta-critic-done.msg
│   │   └── ...
│   └── sent/
│       └── ...
├── solon/
│   ├── inbox/
│   └── sent/
└── ...
```

## Patrol Loop (Convener)

```bash
#!/bin/bash
# Convener patrol loop

PATROL_COUNT=0
export ATLANTIS_AGENT_NAME=convener

while true; do
  echo "=== Patrol Cycle $PATROL_COUNT ==="

  # Step 1: Check inbox
  atlantis-mail inbox

  # Step 2: Count completion signals
  SCHOLAR_DONE=$(atlantis-mail inbox | grep -c "SCHOLAR_DONE" || echo 0)
  CRITIC_DONE=$(atlantis-mail inbox | grep -c "CRITIC_DONE" || echo 0)

  # Step 3: Check if phase complete
  # (Implementation depends on current symposium state)

  # Step 4-6: If phase complete, archive and spawn next phase
  # ...

  # Step 7: Sleep (token-efficient interval)
  PATROL_COUNT=$((PATROL_COUNT + 1))

  if [ $PATROL_COUNT -ge 20 ]; then
    echo "Handing off to fresh Convener"
    atlantis-mail send founder "CONVENER_HANDOFF" "Completed $PATROL_COUNT patrols"
    exit
  fi

  echo "Sleeping 300s (5min) before next patrol"
  sleep 300
done
```

## Benefits

1. **Token Efficiency**: 90% reduction in polling overhead
2. **Event-Driven**: React to completion rather than continuously check
3. **Scalable**: Works with 3 agents or 30 agents
4. **Asynchronous**: Respects agents' autonomy and thinking time
5. **Clear Signals**: Explicit completion messages (not inferred from git activity)

## Trade-offs

- **Latency**: 5-minute delay before Convener notices completion
  - Acceptable for academic discourse (agents work for hours)
  - Not suitable for real-time systems

- **Reliability**: Depends on agents sending signals
  - If agent crashes before sending mail, Convener won't know
  - Future: Witness can detect stalled agents and escalate

## Future Enhancements

1. **Priority Mail**: Urgent messages checked more frequently
2. **Witness Integration**: Monitor agent health, send STALLED signals
3. **Broadcast**: Convener can send updates to all symposium participants
4. **Read Receipts**: Track which agents have read important messages

---

**Philosophy**: New Atlantis coordination respects autonomy and operates on academic timescales. We optimize for quality and cost-efficiency, not real-time response.
