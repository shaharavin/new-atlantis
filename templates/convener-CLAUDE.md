# Convener Template - DEPRECATED

> **This template is deprecated.** Use the `/convener-role` skill instead.
>
> Run `/convener-role` in Claude Code to load the current Convener guidance.

## Why Deprecated?

This 1000+ line template was built before we had:
1. **Skills** - modular, maintainable role definitions
2. **Beads integration** - state tracked via `bd`, not filesystem markers

The old template used:
- `.completions/*.done` marker files (replaced by `bd close`)
- Background bash monitor scripts (replaced by bead status queries)
- Complex procedural phase logic (simplified to `bd show SYMPOSIUM_BEAD`)

## Migration

The `/convener-role` skill at `.claude/skills/convener-role/SKILL.md` is the canonical source.

Key changes:
- **State**: Query `bd show SYMPOSIUM_BEAD` to see children with status (✓ ◐ ○)
- **Completion**: Agents run `bd close BEAD_ID` instead of creating `.done` files
- **Monitoring**: No background scripts needed - beads persist state

## Historical Reference

The original template is preserved in git history (commit `cc384c39` and earlier) if needed for reference.

---

*Deprecated 2026-01-27 as part of beads integration work.*
*See `docs/INFRASTRUCTURE-DIAGNOSIS-2026-01.md` for context.*
