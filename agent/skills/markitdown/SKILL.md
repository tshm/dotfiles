---
name: markitdown
description: Convert PDFs, Office documents, images, audio, HTML, EPUB, structured data, ZIP archives, and supported URLs into LLM-friendly Markdown with Microsoft's MarkItDown. Use when the user wants file-to-Markdown conversion, batch conversion, OCR/transcription-backed extraction, or to integrate MarkItDown's CLI or Python API into a workflow.
---

# MarkItDown

## Overview

Use MarkItDown when the deliverable is clean Markdown instead of layout-faithful reproduction. Prefer it for converting documents into text that will be summarized, chunked, indexed, diffed, or passed into LLM or RAG pipelines.

## Workflow

1. Decide whether the task is a one-off conversion or code integration.
2. Prefer the CLI for one file, shell pipelines, or quick batch loops.
3. Prefer the Python API when the user wants conversion inside an app, notebook, script, or automated pipeline.
4. Spot-check the generated Markdown for headings, tables, lists, and missing text before using it downstream.
5. If the document is scanned, image-heavy, or a complex PDF, read `references/api_reference.md` before choosing OCR, plugins, or Azure Document Intelligence.

## Quick start

### CLI conversion

```bash
# Write Markdown to stdout
markitdown input.pdf > output.md

# Or write directly to a file
markitdown input.pdf -o output.md

# Enable installed plugins when needed
markitdown --use-plugins input.pdf -o output.md
```

### Python API

```python
from markitdown import MarkItDown

md = MarkItDown()
result = md.convert("input.pdf")
print(result.text_content)
```

### Stream input

```python
from markitdown import MarkItDown

md = MarkItDown()
with open("input.pdf", "rb") as stream:
    result = md.convert_stream(stream, file_extension=".pdf")
print(result.text_content)
```

## Tool selection

- Use MarkItDown when the user explicitly wants Markdown output.
- Do not use MarkItDown when the task requires pixel-faithful reproduction, spreadsheet formulas, or direct editing of the original file format.
- Install only the extras required for the formats in scope when a smaller dependency set matters; otherwise `markitdown[all]` is the simplest default.
- Plugins are disabled by default. Enable them only when you need trusted installed plugins.

## Advanced features

For installation choices, supported formats, Azure Document Intelligence, OCR/plugin notes, and LLM-backed image descriptions, read `references/api_reference.md`.
