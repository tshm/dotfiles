# Graft — repo context graph

This repo is indexed in `graft/`: small linked markdown nodes that explain each system and carry exact file:line spans, kept in sync with the code through git.

## Purpose

Graft provides fast, accurate context discovery without grepping source files or LLM search. Use it before opening any file.

## Workflows

For ANY task here — understanding how something works, finding where code lives, or scoping a change — get context from the graph before grepping or opening source files.

### Get oriented (first time)

```
graft map
```

Token-budgeted orientation: directory clusters, hubs, hotspots. No LLM, no key.

### Answer a question

```
graft ask "<your question>" --source
```

Ranked nodes with relevant code spans inlined (each hit's ≤8-line crux by default; `--full` for whole definitions when the crux isn't enough). The top node IS the answer — cite its `covers:` file:line spans and edit straight from `--source`.

### Find every occurrence or caller

```
graft grep "<literal>"
```

Exhaustive over indexed files, grouped by enclosing symbol. Fall back to raw `grep -rn` only for unindexed files.

For exhaustive tasks ("every occurrence / every caller of this pattern"), ranked results are top-N, not complete — use `graft grep` instead of `graft ask`.

### Skim an API surface

```
graft skeleton <file>
```

Every definition's signature + span, ~10× cheaper than reading the file.

### Trace callers and dependencies

```
graft callers <symbol>
```

Precomputed, exact edges — who calls this. Add `--direction out` for what it calls, or `--depth N` to walk transitively for the full blast radius. For structural questions, skip ranking and use this directly.

### Browse the index

```
graft/INDEX.md
```

Lists every node; follow the links.

## Multi-project repos

Monorepos and folders of multiple repos rank fairly across sub-projects — hits carry `[scope/]` labels naming which one they're from. Narrow with:

```
graft ask "<task>" --in <scope>/
```

once you know where you're working.

## When to open source files

If a returned span is truncated ("+N more lines"), open the file at that exact range before finalizing. Only open source files when a node genuinely lacks a needed detail, and then at the exact file:line the node points to — never re-read whole files.

## Maintenance

After big code changes, refresh the graph:

```
graft build
```

Deterministic, no API key, $0.
