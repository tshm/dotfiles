# MarkItDown reference

## Installation

MarkItDown requires Python 3.10 or newer.

### Full install

```bash
python -m pip install 'markitdown[all]'
```

### Targeted installs

Install only the extras needed for the formats in scope:

```bash
python -m pip install 'markitdown[pdf,docx,pptx]'
```

Available extras from the official README:

- `all`
- `pptx`
- `docx`
- `xlsx`
- `xls`
- `pdf`
- `outlook`
- `az-doc-intel`
- `audio-transcription`
- `youtube-transcription`

## Supported inputs

Common supported inputs include:

- PDF
- PowerPoint
- Word
- Excel
- Images
- Audio
- HTML
- CSV, JSON, and XML
- ZIP archives
- EPUB
- YouTube URLs

The output is optimized for LLM consumption, not high-fidelity publishing.

## CLI patterns

### Basic conversion

```bash
markitdown input.pdf -o output.md
```

### Stdout pipeline

```bash
markitdown input.pdf > output.md
```

### List and enable plugins

```bash
markitdown --list-plugins
markitdown --use-plugins input.pdf -o output.md
```

### Azure Document Intelligence for PDFs

```bash
markitdown input.pdf -d -e "<document_intelligence_endpoint>" -o output.md
```

## Python API

### Basic usage

```python
from markitdown import MarkItDown

md = MarkItDown()
result = md.convert("document.pdf")
print(result.text_content)
```

### Stream conversion

```python
from markitdown import MarkItDown

md = MarkItDown()
with open("document.pdf", "rb") as stream:
    result = md.convert_stream(stream, file_extension=".pdf")
print(result.text_content)
```

### LLM-backed image descriptions

```python
from markitdown import MarkItDown
from openai import OpenAI

client = OpenAI()
md = MarkItDown(
    llm_client=client,
    llm_model="gpt-4o",
)
result = md.convert("presentation.pptx")
print(result.text_content)
```

## OCR and plugins

The `markitdown-ocr` plugin adds OCR for embedded images in PDF, DOCX, PPTX, and XLSX files.

```bash
python -m pip install markitdown-ocr
python -m pip install openai
```

Then enable plugins in the CLI with `--use-plugins`, or in Python with `MarkItDown(enable_plugins=True, ...)`.

## Caveats

- Scanned or visually complex documents may need OCR or Azure Document Intelligence.
- Optional extras control which converters are available. Missing extras can explain unsupported-format failures.
- Plugin execution is opt-in and should stay opt-in unless the user explicitly needs it.
- MarkItDown is excellent for extraction and normalization, but not for preserving page geometry or recreating the original visual layout.
