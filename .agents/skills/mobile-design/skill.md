---
name: mobile-design
description: "Trigger: mobile UI, UX, screen, flow, component, layout, visual design. Guides modern, lively, usable mobile product design."
license: MIT
metadata:
  author: CesarAntolinez
  version: "1.0.0"
---

# Mobile Design

## Activation Contract

Load this skill for any task that designs, implements, reviews, or changes a mobile screen, user flow, navigation pattern, component, interaction, visual system, empty/loading/error state, or responsive mobile layout.

Before designing, read `../../../docs/product/vision.md` and the relevant domain rules. Preserve product semantics over visual convenience.

## Hard Rules

- Design mobile-first for touch: clear hierarchy, comfortable targets, safe areas, keyboard behavior, scrolling, and one-handed reach.
- Make the primary action obvious without making every element visually loud.
- Prefer progressive disclosure over dense dashboards and configuration-heavy screens.
- Never communicate financial meaning by color alone; pair color with labels, icons, signs, position, or copy.
- Keep income, expense, reimbursement, debt, transfer, savings, and available balance visually distinguishable when their domain meaning differs.
- Provide intentional loading, empty, error, success, disabled, destructive, and offline/retry states when applicable.
- Preserve accessibility: readable type, sufficient contrast, scalable text, semantic controls, focus order, and reduced-motion tolerance.
- Avoid generic "AI dashboard" aesthetics: excessive gradients, glass everywhere, decorative cards for every row, meaningless charts, neon accents, or animation without feedback value.
- Reuse a small design system instead of inventing per-screen styling.

## Decision Gates

| Situation | Direction |
| --- | --- |
| Frequent action | Reduce steps; keep it reachable and recognizable. |
| Complex financial concept | Clarify with hierarchy and copy; do not hide semantics. |
| Dense information | Group, summarize, then reveal detail on demand. |
| Destructive/irreversible action | Separate visually and require proportional confirmation. |
| Motion | Use for continuity, state change, hierarchy, or feedback; otherwise omit it. |
| New visual pattern | Reuse an existing component/token first; introduce a new pattern only when it solves a distinct need. |

## Execution Steps

1. Identify the user's job, primary action, secondary actions, and critical information for the screen or flow.
2. Map entry, success, cancellation/back, error, empty, loading, and edge states before polishing visuals.
3. Establish hierarchy using spacing, typography, grouping, position, and restrained emphasis.
4. Apply a modern visual language: generous but efficient spacing, strong typography, purposeful surfaces, rounded geometry where appropriate, subtle depth, expressive icons, and a restrained accent system.
5. Add life through meaningful microinteractions: pressed states, transitions, progress, confirmations, contextual motion, and lightweight celebration only when an outcome deserves it.
6. Check thumb reach, target sizes, keyboard overlap, long content, localization growth, dynamic text, dark/light appearance when supported, and small-screen behavior.
7. Review the result against domain clarity and accessibility before implementation is considered ready.

## Output Contract

When proposing or reviewing mobile UI/UX, state:

- the user goal and primary action;
- the screen/flow hierarchy;
- important interaction and state behavior;
- reusable components or tokens introduced;
- accessibility considerations;
- any unresolved product/design decision that requires owner approval.

For implementation tasks, keep visual decisions consistent across affected screens and avoid unrelated redesigns.

## References

- `../../../docs/product/vision.md`
- `../../../docs/product/domain-rules.md`
- `../../../docs/product/roadmap.md`
- `../../../docs/development/workflow.md`
