# Agentic Book Explainer

A portfolio-ready Jupyter notebook that demonstrates multi-agent AI workflows using
**CrewAI** and **LangGraph** side by side. Drop in any PDF or Markdown book and the
system explains it -- chunk by chunk -- in beginner-friendly language, then assembles
a final document with a study guide, quiz, and glossary.

---

## What It Does

1. Loads a PDF or Markdown source document.
2. Splits it into chapters or logical chunks.
3. Runs **two independent multi-agent pipelines** on every chunk:
   - CrewAI: sequential role-based agents.
   - LangGraph: stateful graph with a built-in review loop.
4. An **LLM-as-Judge** (Claude Sonnet) picks the better framework output.
5. Assembles a final Markdown document: full explanation + study guide + quiz + glossary.

---

## Architecture

### Six Agents, Built Two Ways

| Agent | What it does |
|------|--------------|
| **Supervisor** | Analyzes the chunk first; classifies complexity and strategy; briefs the team |
| **Concept Extractor** | Identifies key ideas, terms, and confusing passages |
| **Explainer** | Rewrites difficult material in plain English, step by step |
| **Example Adder** | Adds analogies, examples, and a "why this matters" paragraph |
| **Reviewer** | Checks grounding and accuracy; votes APPROVED or NEEDS REVISION |
| **Output Formatter** | Produces clean structured Markdown with citations |

### CrewAI Implementation

Sequential workflow. The Supervisor runs first and briefs the team.

```
Supervisor -> Concept Extractor -> Explainer -> Example Adder -> Reviewer -> Output Formatter
```

### LangGraph Implementation

Graph-based workflow. The Supervisor node sets state before any explanation work begins.

```
supervisor -> extract_concepts -> explain_chunk -> add_examples -> review_explanation
                                       ^                                   |
                                       |          NEEDS REVISION           |
                                       +-----------------------------------+
                                                   APPROVED
                                                      |
                                                format_output
```

The review node can send the explanation back for revision up to two times before
it automatically approves and moves forward.

### LLM-as-Judge

After both frameworks process a sample chunk, Claude Sonnet evaluates the outputs
across five dimensions: accuracy, clarity, completeness, structure, and overall quality.
The winning framework's full batch output is used for all downstream steps.

---

## Project Structure

```
CrewAI and LangGraph - PDF & md Book Explainer\
    agentic_book_explainer_v2.ipynb   <- the notebook (run this)
    README.md                          <- this file
    .gitignore                         <- excludes secrets, venv, logs, and generated files
    .env                               <- your API keys (never committed)
    .env.example                       <- template to copy from
    requirements.txt                   <- all Python dependencies
    input\
        a-practical-guide-to-building-agents.pdf   <- sample source document
        (add your own PDF or Markdown file here)
    output\
        {book-name}\                   <- per-book intermediate outputs (gitignored)
    logs\
        {book-name}\                   <- per-book trace logs (gitignored)
```

---

## Quick Start

### 1. Clone and create a virtual environment

```powershell
git clone <repo-url>
cd "CrewAI and LangGraph - PDF & md Book Explainer"
python -m venv .venv
.venv\Scripts\Activate.ps1
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

### 4. Add your source document

Place a PDF or Markdown file in the `input\` folder. The notebook scans that folder
automatically and shows a file picker -- no need to edit any code.

### 5. Run the notebook

Open `agentic_book_explainer_v2.ipynb` in VS Code and run all cells top to bottom.
The final document is saved to `output\{book-name}\{book-name}_book_explainer.md`.

---

## Output Format

Each explained section follows this structure:

```markdown
## Section Title

### Plain-English Explanation
...

### Step-by-Step Breakdown
1. ...
2. ...
3. ...

### Example or Analogy
...

### Why This Matters
...

### Review Notes
- Grounded in source: yes/no
- Missing context: ...
- Confidence: 0-100
```

The final assembled document also includes:

- Chapter-level summaries
- A consolidated glossary (LLM-deduplicated across all chunks)
- A study guide organized by chapter
- A chapter-by-chapter quiz with an answer key
- An accuracy and confidence report table

---

## Stages

| # | Stage | What it builds |
|---|-----------|----------------|
| 1 | Foundation | Notebook structure, env validation, folder setup |
| 2 | Document Ingestion | PDF and Markdown loaders, type detection |
| 3 | Schemas and Chunking | Pydantic models, heading/paragraph chunking |
| 4 | CrewAI Pipeline | Role-based agents, sequential workflow, trace logging |
| 5 | LangGraph Pipeline | Stateful graph, conditional review loop |
| 6 | LLM-as-Judge | Both frameworks run; Claude Sonnet selects the winner |
| 7 | Markdown Assembly | 7-section document built from winner output |
| 8 | Output | File link + confidence table display |

---

## Requirements

- Python 3.12
- Windows 11 (tested), macOS/Linux should work
- VS Code with Jupyter extension
- OpenAI API key (required)
- Anthropic API key (required for LLM-as-Judge with Claude Sonnet)

---

## Key Design Decisions

- **Self-contained notebook**: all logic lives in the notebook; no separate package folder needed.
- **Beginner-friendly**: Markdown cells explain every step before it runs.
- **No hard-coded secrets**: all API keys come from `.env`.
- **Per-book output directories**: every source document gets its own output and log subfolder.
- **Full-book processing**: all chunks are processed by default, not just a sample.
- **Observable**: every agent step is logged with a trace ID; traces are saved as JSON
  and displayed as a pandas DataFrame.
- **Fault-tolerant batch**: each framework runs in its own cell and caches results to disk;
  re-running after a failure loads the completed output instantly -- no tokens wasted.
- **Dual-framework first-class**: CrewAI and LangGraph are equal, independent pipelines
  that run the same content; the LLM-as-Judge picks the better result per run.
