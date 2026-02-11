---
name: analyze-web-performance
description: Diagnose frontend performance bottlenecks using browser tools and reproducible metrics
---

# Analyze web performance

## Trigger

Pages feel slow, interactions jank, or load times regress.

## Workflow

1. Capture a reproducible scenario and baseline metrics.
2. Profile main-thread work, rendering, and network timing.
3. Identify high-cost operations and root causes.
4. Propose smallest high-impact fixes.
5. Re-measure and report before/after evidence.

## Performance Profiling

Use `browser_profile_start` and `browser_profile_stop` for CPU profiling with call stacks and timing data. Profile data is written to `~/.cursor/browser-logs/`: `cpu-profile-{timestamp}.json` (raw Chrome DevTools format) and `cpu-profile-{timestamp}-summary.md` (human-readable). When diagnosing performance, read the raw `.json` and cross-check with the summary. Verify `profile.samples.length`, `profile.nodes[].hitCount`, and `profile.nodes[].callFrame.functionName` before making optimization recommendations.

## MCP

Lock before interactions. Unlock when done. See canonical browser docs for full lock/unlock sequence.

## Output

- Performance bottleneck summary
- Prioritized fix list
- Before/after metric comparison
