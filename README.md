# Agentic Book Explainer
Directed by Brock Frary using Claude Code<p>
Published:  2026-06-26 | Updated: 2026-06-26

---

| File | Link |
|---|---|
| Jupyter Notebook (full run) | [Open notebook](https://github.com/VoxSecuritatis/pdf-book-explainer/blob/master/agentic_book_explainer-full_run.ipynb) |
| Source (Input) PDF file | [Open PDF](https://github.com/VoxSecuritatis/pdf-book-explainer/blob/master/sample/input/a-practical-guide-to-building-agents.pdf) |
| Generated (Output) markdown summary/explainer | [Open markdown explainer](https://github.com/VoxSecuritatis/pdf-book-explainer/blob/master/sample/output/a-practical-guide-to-building-agents/a-practical-guide-to-building-agents_book_explainer.md) |

---

A Jupyter notebook that demonstrates multi-agent AI workflows using
**CrewAI** and **LangGraph** side by side. Drop in any PDF book and the system
processes it chapter by chapter, then assembles a final Markdown document with a
study guide, multiple-choice quiz, glossary, and confidence scoring.

---

## What It Does

1. Loads a PDF source document and extracts text with PyMuPDF.
2. Detects chapter/section boundaries using an LLM.
3. Runs **two independent multi-agent pipelines** on every chapter:
   - CrewAI: sequential role-based agents.
   - LangGraph: stateful graph with a conditional retry edge.
4. An **LLM-as-Judge** (Claude Sonnet) compares both outputs and picks the better one.
5. Assembles a 7-section Markdown study document from the winning framework's output.

---

## Architecture

### Five Agents Per Chapter, Built Two Ways

| Agent | What it does |
|------|--------------|
| **Summarization Agent** | Produces chapter summary, key concepts, important details, practical examples, common misunderstandings |
| **Study Notes Agent** | Writes learner-friendly Markdown study notes |
| **Quiz Agent** | Creates 10 multiple-choice questions with answer key and explanations |
| **Confidence Scoring Agent** | Scores summary, notes, and quiz against the source (0.0-1.0) |
| **Verification Agent** | Flags unsupported claims or quiz errors |

Two additional agents run once after all chapters:

| Agent | What it does |
|------|--------------|
| **Glossary Agent** | Extracts technical terms and writes plain-English definitions |
| **Study Guide Agent** | Synthesizes all chapter summaries into a consolidated study guide |

### CrewAI Implementation

Sequential workflow using `Process.sequential`. Each task passes its output as context to the next.

```
Summarizer -> Study Notes -> Quiz -> Confidence Scoring -> Verifier
```

Then, once per document:
```
Glossary Agent   (independent crew)
Study Guide Agent (independent crew)
```

### LangGraph Implementation

Explicit state machine using `StateGraph` and `TypedDict`. A conditional retry edge
re-runs the summarize node if confidence falls below threshold.

```
summarize -> study_notes -> quiz -> confidence -> verify
    ^                                   |
    |     confidence < 0.8 + retries    |
    +----(increment_retry)--------------|
                                        |
                               (confidence ok or retry limit hit)
                                        |
                                      END
```

### LLM-as-Judge

After both frameworks process all chapters, Claude Sonnet evaluates a sample of each
output across three dimensions: content quality, coverage, and study utility. The
winning framework's full output is used for Markdown assembly.

---

## Project Structure

```
CrewAI and LangGraph - PDF & md Book Explainer\
    agentic_book_explainer.ipynb           <- the notebook (run this)
    agentic_book_explainer-full_run.ipynb  <- notebook exported with all cell outputs
    README.md                              <- this file
    .gitignore                             <- excludes secrets, venv, logs, and generated files
    .env                                   <- your API keys (never committed)
    .env.example                           <- template to copy from
    requirements.txt                       <- all Python dependencies
    input\
        (add your own PDF here)
    output\
        {book-name}\                       <- generated study document per book
    logs\
        {book-name}\                       <- per-book trace logs (gitignored)
    sample\
        input\
            a-practical-guide-to-building-agents.pdf   <- sample source document
        output\
            a-practical-guide-to-building-agents\      <- sample run output
```

---

## Quick Start

### 1. Clone and create a virtual environment

```powershell
git clone https://github.com/VoxSecuritatis/pdf-book-explainer.git
cd "pdf-book-explainer"
python -m venv .venv

```

### 2. Install dependencies

```powershell
pip install -r requirements.txt
```

### 3. Configure your API keys

Copy `.env.example` to `.env` and fill in your keys:

```
OPENAI_API_KEY=your-key-here
ANTHROPIC_API_KEY=your-key-here
```

Both keys are required. OpenAI runs all content agents; Anthropic runs the LLM-as-Judge.

### 4. Set your source document

The notebook defaults to the included sample PDF. To use your own document:

1. Place your PDF in the `input\` folder.
2. In the notebook's **Stage 1 Paths cell**, change `PDF_SOURCE` to point to your file:
   ```python
   PDF_SOURCE = INPUT_DIR / 'your-file.pdf'
   ```

### 5. Run the notebook

Open `agentic_book_explainer.ipynb` in VS Code and run all cells top to bottom.
The final document is saved to `output\{book-name}\{book-name}_book_explainer.md`.

---

## Output Format

The final assembled Markdown document has 7 sections:

| # | Section | Contents |
|---|---------|----------|
| 1 | Source Reference | Title, file name, authors, pages, framework used, extraction confidence |
| 2 | Document Overview | Plain-English summary, intended audience, key themes |
| 3 | Chapter-by-Chapter Study Notes | Per chapter: summary, key concepts, important details, study notes, 10 MCQs, confidence score |
| 4 | Glossary | Alphabetical table of technical terms with definitions and confidence scores |
| 5 | Consolidated Study Guide | Cross-chapter synthesis: what to memorize, understand, and review |
| 6 | Final Review Questions | 2 MCQs pulled from each chapter for cross-chapter practice |
| 7 | Accuracy / Confidence Report | Per-element scoring table, judge rationale, verification flags |

---

## Stages

| # | Stage | What it builds |
|---|-----------|----------------|
| 1 | Foundation | Notebook structure, env validation, LLM setup, path helpers |
| 2 | PDF Intake & Parsing | PyMuPDF text extraction, heading detection, metadata |
| 3 | Chapter Segmentation | LLM-identified chapter boundaries, per-chapter text slices |
| 4 | CrewAI Pipeline | 5 specialist agents per chapter + glossary + study guide crews |
| 5 | LangGraph Pipeline | 5-node state graph per chapter with conditional retry edge |
| 6 | LLM-as-Judge | Claude Sonnet compares frameworks and selects the winner |
| 7 | Markdown Assembly | 7-section document built from winner output |
| 8 | Output | File link + per-chapter confidence table |

---

## Requirements

- Python 3.12
- Windows 11 (tested), macOS/Linux should work
- VS Code with Jupyter extension
- OpenAI API key (required -- runs all CrewAI and LangGraph agents)
- Anthropic API key (required -- runs the LLM-as-Judge with Claude Sonnet)

---

## Key Design Decisions

- **Self-contained notebook**: all logic lives in one `.ipynb` file; no separate package needed.
- **Schema-first output**: the 7-section structure was locked before any code was written.
- **Confidence as data**: scores live in JSON only; never embedded in prose.
- **Dual-framework first-class**: CrewAI and LangGraph run the same content independently; neither is a fallback for the other.
- **No hard-coded secrets**: all API keys come from `.env`.
- **Per-book output directories**: every source document gets its own `output\{name}\` subfolder.
- **Fault-tolerant**: `retry_with_fallback` wraps every LLM call with exponential backoff.
- **WORKLOAD dict**: single shared state object serialized to `workload_v2.json` after each stage; re-running Stage 7 alone regenerates the document without repeating any LLM calls.

---

© 2026 Brock Frary. All rights reserved.
