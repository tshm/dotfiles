---
name: omniroute-free-combos
description: Audit and refresh the free OmniRoute combos on SSH host oci. Use when asked to update, repair, test, or discover free models/providers for omp-*-free combos.
---

# OmniRoute Free Combos

Maintain the visible `omp-*-free` combos on `oci` using the live catalog and real zero-cost calls. Default endpoint: `http://127.0.0.1:20128` from the host.

## Workflow

1. Check `/api/mcp/status`. Require MCP online and enabled.
2. Start a fresh SSE session with `POST /api/mcp/sse`, JSON-RPC `initialize`, and retain the `mcp-session-id` response header. Use `tools/call` for every tool invocation.
3. Through MCP, call:
   - `omniroute_list_combos`
   - `omniroute_list_models_catalog`
   - `omniroute_check_quota`
4. Read `/api/combos` and `/api/models/catalog` only when MCP output is truncated. Limit scope to visible combo names matching `omp-*-free`; leave hidden/generated/static combos unchanged.
5. Build candidates conservatively:
   - OpenRouter: only model IDs ending in `:free`.
   - Groq: chat models proven by a valid free quota and a live request reporting `cost: 0`.
   - Other providers: require explicit free-tier evidence plus a live request reporting `cost: 0`; an active connection or missing price is not evidence.
   - Exclude audio models from chat combos. Never add text-only models to `omp-vision-free`.
6. Call `omniroute_route_request` with `budget: 0` for each new candidate before changing a combo. Reject failures and nonzero cost.
7. Match capabilities to roles:
   - `task`: coding, tool calling, then quality.
   - `reviewer` and `security`: reasoning and tool calling.
   - `plan`: reasoning and longest context.
   - `scout` and `sonic`: low latency and smaller models.
   - `vision`: `vision: true` only.
   Preserve the existing order and append proven fallbacks; do not reorder working models without evidence.
8. Remove entries only when the live catalog no longer contains them or a test proves a persistent access restriction such as `403 ... only be used from within ...`. Keep entries on transient timeout or `429` failures.
9. Update only when the model list changed. OmniRoute MCP currently creates combos but cannot replace an existing combo's model list: `omniroute_create_combo` rejects duplicate names. Preserve the combo name, description, strategy, config, visibility, and sort order, then `PUT /api/combos/{id}` with the revised model list. Do not create `-updated` duplicates or deactivate the original combo.
10. Through MCP, run `omniroute_test_combo` for every changed combo. Require every final model to succeed with `cost: 0`; otherwise restore that combo's pre-change payload.
11. Report the per-combo additions/removals and verification counts. Delete temporary files.

## Safety

- Never expose provider tokens, cookies, API keys, or full `/api/providers` responses.
- Never classify paid credits, trials, or unknown billing state as permanently free.
- Prefer fewer proven fallbacks over a large stale combo.
- A successful HTTP response is insufficient: verify model identity, success, and zero reported cost.
