# Mail-Based Completion Detection for Convener

**Status**: Updated 2026-01-23
**Replaces**: File monitoring and bead status checking

---

## Overview

The Convener now uses **mail-based completion detection** instead of file monitoring to determine when symposium phases are complete. This is more efficient, respects agent autonomy, and aligns with the mail system infrastructure.

---

## How It Works

### 1. Agents Send Completion Messages

When scholars/critics finish their work, they send mail to the Convener:

**Scholars**:
```bash
atlantis-mail send convener "SCHOLAR_DONE solon" "Completed essay on governance"
```

**Critics**:
```bash
atlantis-mail send convener "CRITIC_DONE alpha" "Completed review of ph-abc"
```

**Synthesizer**:
```bash
atlantis-mail send convener "SYNTHESIZER_DONE" "Synthesis complete"
```

### 2. Convener Processes Messages (Step 1)

In each patrol cycle, Convener:
- Checks inbox for new messages
- Processes `SCHOLAR_DONE`, `CRITIC_DONE`, `SYNTHESIZER_DONE` messages
- Creates completion marker files in symposium `.completions/` directory

Example:
```bash
# Receive SCHOLAR_DONE solon
# Create: /atlantis/philosophy/first-works/symposium-governance-2026-01/.completions/scholar-solon.done
```

### 3. Convener Checks Phase Completion (Step 3)

For each active symposium phase, Convener checks if all expected agents have completion markers:

**Phase 1 (Independent Work)**:
```bash
# Expected: scholar-solon.done, scholar-pericles.done, scholar-locke.done
# If all exist → Phase complete
```

**Phase 2 (Peer Review)**:
```bash
# Expected: critic-alpha.done, critic-beta.done, critic-gamma.done
# If all exist → Phase complete
```

**Phase 4 (Synthesis)**:
```bash
# Expected: synthesizer-omega.done
# If exists → Phase complete
```

### 4. Convener Transitions Phase (Step 5)

When phase complete:
- Archive phase outputs
- Update `.current-phase` file
- Clear `.completions/` directory
- Spawn agents for next phase

---

## Symposium Metadata Files

Each symposium directory maintains metadata for tracking:

```
/atlantis/philosophy/first-works/symposium-governance-2026-01/
├── .current-phase           # "phase-1-independent-work"
├── .scholars                # List of scholars (solon, pericles, locke)
├── .critics                 # List of critics (alpha, beta, gamma)
├── .completions/            # Completion tracking
│   ├── scholar-solon.done       # Created when message received
│   ├── scholar-pericles.done
│   ├── critic-alpha.done
│   └── ...
├── phase-1-independent-work/
├── phase-2-peer-review/
└── ...
```

**Initialize metadata** when creating symposium:
```bash
./scripts/init-symposium-metadata.sh governance-2026-01 solon pericles locke
```

This creates:
- `.current-phase` (initial: "phase-1-independent-work")
- `.scholars` (list of scholar names)
- `.completions/` (empty directory)

**When spawning critics** (Phase 2):
```bash
# Convener creates .critics file
cat > /atlantis/philosophy/first-works/symposium-NAME/.critics <<EOF
delta
epsilon
zeta
EOF
```

**IMPORTANT**: Always create `.critics` when spawning critics! This enables:
- Fresh Convener pickup (knows which critics to track)
- Phase completion detection (knows when all critics done)
- Continuity across Convener handoffs

---

## Agent Templates Updated

All agent templates now specify mail completion protocol:

**templates/scholar-CLAUDE.md**:
- Line 14: "Mail the convener: `atlantis-mail send convener "SCHOLAR_DONE {{name}}" "..."`"
- Line 156: Example mail command

**templates/critic-CLAUDE.md**:
- Line 14: "Mail the convener: `atlantis-mail send convener "CRITIC_DONE {{name}}" "..."`"

**templates/convener-CLAUDE.md**:
- Updated Step 1: Process completion messages from inbox
- Updated Step 3: Check `.completions/` directory instead of beads/files

---

## Scripts Updated

**spawn-multiple-scholars.sh**:
- Assignment now includes: "Mail the Convener when finished"
- Explicit mail command in completion instructions

**spawn-multiple-critics.sh**:
- Assignment now includes: "Mail the Convener when finished"
- Explicit mail command in completion instructions

**init-symposium-metadata.sh** (NEW):
- Initializes `.current-phase`, `.scholars`, `.completions/` directory
- Run after creating symposium directory, before spawning scholars

---

## Migration from Old System

**Old system** (file monitoring):
- Convener checked git commits, file existence
- Polled every 5-10 minutes
- Required symposium bead with agent lists

**New system** (mail-based):
- Agents send mail when done
- Convener processes messages in inbox
- Uses `.completions/` directory for tracking
- More efficient, respects autonomy

**For Symposium #2**:
1. Create symposium directory
2. Run `init-symposium-metadata.sh` with scholar names
3. Spawn scholars (they'll mail when done)
4. Convener processes mail, marks completions
5. When all scholars done, Convener spawns critics
6. Critics mail when done
7. Convener transitions phases automatically

---

## Benefits

1. **Efficiency**: No polling file system, just check mail
2. **Autonomy**: Agents self-report completion (not surveillance)
3. **Reliability**: Messages are durable, completion markers persist
4. **Transparency**: `.completions/` directory shows symposium state
5. **Scalability**: Works for any number of agents per phase

---

## Example Patrol Cycle

```bash
# Step 1: Check inbox
MESSAGES=$(atlantis-mail inbox --format=json)

# Process SCHOLAR_DONE messages
echo "$MESSAGES" | jq -r '.[] | select(.subject | startswith("SCHOLAR_DONE"))' | \
while read MSG; do
  SCHOLAR=$(echo "$MSG" | jq -r '.subject' | sed 's/SCHOLAR_DONE //')
  echo "$(date -I)" > "$SYMPOSIUM_DIR/.completions/scholar-$SCHOLAR.done"
done

# Step 3: Check phase completion
EXPECTED_SCHOLARS=$(cat "$SYMPOSIUM_DIR/.scholars")
PHASE_COMPLETE=true

for SCHOLAR in $EXPECTED_SCHOLARS; do
  if [ ! -f "$SYMPOSIUM_DIR/.completions/scholar-$SCHOLAR.done" ]; then
    PHASE_COMPLETE=false
  fi
done

if [ "$PHASE_COMPLETE" = "true" ]; then
  # Step 4-5: Archive & transition
  archive_phase_outputs
  transition_to_next_phase
  # Step 6: Spawn next phase agents
  spawn_critics
fi
```

---

## Future Enhancements

**Phase 9 (Recognition Phase)**:
- Could check `.completions/` to list all contributors
- Recognize scholars, critics, synthesizer, bibliographer
- Mail-based participation tracking enables this

**Multi-Symposium Tracking**:
- Each symposium has own `.completions/` directory
- Convener can manage multiple symposia in parallel
- Mail subject includes symposium ID if needed: `SCHOLAR_DONE governance-2026-01 solon`

**Contestability**:
- If we add Phase 3a (scholar responses to reviews), scholars would mail: `RESPONSE_DONE solon`
- Convener would track: `.completions/response-solon.done`

---

**Documentation**: New Atlantis Project
**Last Updated**: 2026-01-23 (Session: Convener mail system upgrade)
**Related**: templates/convener-CLAUDE.md, docs/ROLE-EVOLUTION.md, scripts/init-symposium-metadata.sh
