# ROADMAP v2 -- PDF Book Explainer
## CrewAI and LangGraph Dual-Framework Agentic Workflow

All v2 files use the `_v2` suffix:
- `agentic_book_explainer_v2.ipynb` -- main notebook
- `config_v2.json` -- pipeline configuration (auto-generated on first run)
- `output\{stem}\{stem}_book_explainer.md` -- final Markdown study document
- `output\{stem}\workload_v2.json` -- serialized pipeline state for inspection
- `logs\{stem}\` -- execution logs
- `documentation\ROADMAP_v2.md` -- this file

---

## Design Decisions (locked)

| Decision | Choice | Rationale |
|---|---|---|
| Output format | Markdown | Reader-facing, renderable, diffable |
| Config format | JSON | Machine-readable, editable without code changes |
| Framework A | CrewAI | Role-based agent orchestration, sequential crew |
| Framework B | LangGraph | Explicit state machine, conditional retry edges |
| Comparison | LLM-as-Judge | Independent evaluation picks the better output |
| Confidence | Table in Section 7 | Never embedded in prose |
| Quiz format | MCQ only | 10 per chapter |
| Output packaging | One combined file | Single study document per PDF |
| Notebook format | Jupyter Notebook | Always, no exceptions |

---

## Output Schema (7 sections)

| # | Section | Agent responsible |
|---|---|---|
| 1 | Source Reference | PDF Intake Agent |
| 2 | Document Overview | Markdown Assembly Agent (LLM call) |
| 3 | Chapter Study Notes + 10 MCQs | Summarization, Study Notes, Quiz Agents |
| 4 | Glossary | Glossary Agent |
| 5 | Consolidated Study Guide | Study Guide Agent |
| 6 | Final Review Questions | Assembled from quiz outputs |
| 7 | Accuracy / Confidence Report | Confidence Scoring + Verification Agents |

---

## Pipeline Architecture

```
Stage 1  Environment & Config         [shared setup]
Stage 2  PDF Intake & Parsing         [PDF Intake Agent + PDF Parsing Agent]
Stage 3  Chapter Segmentation         [Chapter Segmentation Agent]
Stage 4  CrewAI Content Pipeline      [5 specialist agents per chapter + glossary + study guide]
Stage 5  LangGraph Content Pipeline   [5-node state graph per chapter + glossary + study guide]
Stage 6  LLM-as-Judge                 [independent comparison, winner selection]
Stage 7  Markdown Assembly            [7-section document built from winner output]
Stage 8  Output                       [FileLink + confidence table display]
```

### Agent Inventory

| # | Agent | Framework(s) | Runs |
|---|---|---|---|
| 1 | PDF Intake Agent | Shared | Once |
| 2 | PDF Parsing Agent | Shared | Once |
| 3 | Chapter Segmentation Agent | Shared | Once |
| 4 | Summarization Agent | CrewAI + LangGraph | Per chapter |
| 5 | Study Notes Agent | CrewAI + LangGraph | Per chapter |
| 6 | Quiz Agent | CrewAI + LangGraph | Per chapter |
| 7 | Confidence Scoring Agent | CrewAI + LangGraph | Per chapter |
| 8 | Verification Agent | CrewAI + LangGraph | Per chapter |
| 9 | Glossary Agent | CrewAI + LangGraph | Once (post-chapters) |
| 10 | Markdown Assembly Agent | Shared | Once |

---

## Session Log

### 2026-06-25 -- v2 Rebuild

**Reason for rebuild:** v1 accumulated tech debt from 10 stage-by-stage additions without a
locked output schema. Confidence scores were embedded in prose text, Review Notes contaminated
the final document, agent boundaries were blurry, and the output structure did not match the
user's vision.

**v2 design principles:**
- Schema first: 7-section output structure locked before any code was written
- Confidence as data: scores live in JSON and Section 7 table only
- Dual-framework first-class: CrewAI and LangGraph are equal, independent pipelines
- Shared ingestion: PDF parsing and chapter segmentation run once and feed both frameworks
- Clean handoff: WORKLOAD dict is the single source of truth across all stages

**Deliverables generated:**
- `agentic_book_explainer_v2.ipynb` (40 cells, 8 stages)
- `documentation\ROADMAP_v2.md` (this file)
- `config_v2.json` (auto-generated on first notebook run)

**Status:** Ready for first run. Open `agentic_book_explainer_v2.ipynb`, set `PDF_SOURCE`,
set `LLM_PROVIDER` env var, and run all cells.

---

## Known Limitations / Future Work

| Item | Notes |
|---|---|
| Scanned PDFs | Text extraction will be poor; OCR integration not yet implemented |
| Very long chapters | Raw text is truncated at 4000 chars per agent call to fit context windows |
| Glossary deduplication | Duplicate terms from different chapters are not merged |
| Final Review Questions | Currently pulls first 2 MCQs from each chapter; a dedicated final-questions agent would be better |
| Streaming output | Batch processing is synchronous; async/streaming would improve UX for long PDFs |
