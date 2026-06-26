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
    agentic_book_explainer.ipynb    <- the notebook (run this)
    README.md                       <- this file
    .gitignore                      <- excludes secrets, venv, logs, and generated files
    .env                            <- your API keys (never committed)
    .env.example                    <- template to copy from
    requirements.txt                <- all Python dependencies
    input\
        (add your PDF or Markdown file here)
    output\
        completed\                  <- final explainer documents land here
        {book-name}\                <- per-book intermediate outputs (gitignored)
    logs\
        {book-name}\                <- per-book trace logs (gitignored)
    documentation\
        ROADMAP.md                  <- stage history and decisions
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
OPENAI_MODEL=gpt-5.5
OPENAI_EMBEDDING_MODEL=text-embedding-3-small
```

Optional -- needed only for the LLM-as-Judge step and alternative providers:

```
ANTHROPIC_API_KEY=your-key-here
GOOGLE_API_KEY=your-key-here
DEEPSEEK_API_KEY=your-key-here
GROQ_API_KEY=your-key-here
```

### 4. Add your source document

Place a PDF or Markdown file in the `input\` folder. The notebook scans that folder
automatically and shows a file picker -- no need to edit any code.

### 5. Run the notebook

Open `agentic_book_explainer.ipynb` in VS Code and run all cells top to bottom.
The final document is saved to `output\completed\{book-name}-final.md`.

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
- Source citations linking back to the original chunk
- A consolidated glossary (LLM-deduplicated across all chunks)
- A study guide organized by chapter
- A chapter-by-chapter quiz with an answer key

---

## Stages

| # | Stage | What it builds |
|---|-----------|----------------|
| 1 | Foundation | Notebook structure, env validation, folder setup |
| 2 | Document Ingestion | PDF and Markdown loaders, type detection |
| 3 | Schemas and Chunking | Pydantic models, heading/paragraph chunking |
| 4 | CrewAI Explainer | 6 role-based agents (Supervisor first), sequential workflow, trace logging |
| 5 | LangGraph Explainer | Stateful graph, 6 nodes (Supervisor entry point), conditional review loop |
| 6 | Batch Processing | Both frameworks run in separate cached cells; LLM-as-Judge selects the winner |
| 7 | Reliability | Retry logic, exponential backoff, fallback messages |
| 8 | Citations | Chunk title enrichment, chapter summaries, source citations |
| 9 | Scoring and Providers | Confidence scores, multi-provider support, LLM-as-Judge |
| 10 | Learning Outputs | Glossary, study guide, quiz with answer key, final document |

---

## Requirements

- Python 3.12
- Windows 11 (tested), macOS/Linux should work
- VS Code with Jupyter extension
- OpenAI API key (required)
- Anthropic API key (optional, enables LLM-as-Judge with Claude Sonnet)

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
- **Cost-conscious model configuration**: a single `MODEL_CONFIG` cell assigns a specific model
  (`gpt-5-nano`, `gpt-5-mini`, etc.) to each agent role. Set `USE_PRODUCTION_MODEL = True` to
  promote all agents to `gpt-5.5` for a final run. Token usage is logged per agent and displayed
  in a summary table.

---

## Glossary

Terms are tagged to show scope: **[General]** broadly used in AI and software,
**[CrewAI]** specific to the CrewAI framework, **[LangGraph]** specific to the
LangGraph framework, **[Project]** defined for this notebook, **[Python]** a Python
library or language feature.

**Agent** [General] -- An AI system that receives instructions, takes actions, and
produces outputs. In this notebook, agents are specialized for a single role.

**Agent** [CrewAI] -- A CrewAI object with a `role`, `goal`, `backstory`, and `llm`.
Given a task and run as part of a `Crew`.

**Agentic AI** [General] -- An AI architecture where LLMs act as autonomous agents
that plan, reason, and take sequences of actions to accomplish a goal.

**asyncio** [Python] -- Python's built-in async library. Used because CrewAI and
LangGraph use async patterns internally. `nest_asyncio` patches the Jupyter event
loop so they work inside a notebook.

**Backstory** [CrewAI] -- A natural-language string describing a CrewAI Agent's
experience and point of view. Included in the agent's system prompt.

**Batch processing** [Project] -- Running the full pipeline across every document
chunk, not just one selected chunk. Implemented in Stage 6.

**BRIEF** [Project] -- One of three Supervisor outputs. A single focus sentence passed
to every downstream agent. Stored as `supervisor_brief` in `ExplainerState`.

**call_llm** [Project] -- A shared helper function used by all LangGraph nodes. Takes
a `system_prompt`, `user_prompt`, and `agent_role`; creates a per-agent `ChatOpenAI`
instance from `MODEL_CONFIG`, logs token usage to `TOKEN_LOG`, and returns a plain string.

**ChatOpenAI** [Python] -- The LangChain wrapper around OpenAI's chat API. Allows the
model to be swapped by changing `OPENAI_MODEL` in `.env`.

**Chunk / Chunking** [General] -- Splitting a long document into smaller logical
sections so each fits within an LLM's context window.

**Compiled graph** [LangGraph] -- The result of `graph.compile()`. Locks in nodes and
edges; returns a `.invoke()`-able object.

**COMPLEXITY** [Project] -- One of three Supervisor outputs. Classifies the chunk as
`simple`, `technical`, `narrative`, or `conceptual`. Stored as `complexity` in state.

**ConceptSet** [Project] -- A Pydantic model holding the Concept Extractor's output:
lists of key concepts, key terms, and flagged passages for one chunk.

**Concept Extractor** [Project] -- Second agent/node in the per-chunk pipeline.
Identifies key concepts, terms, and confusing passages, primed by the Supervisor brief.

**Conditional edge** [LangGraph] -- An edge that calls a router function at runtime to
decide which node to run next. Used after `review_explanation` to route to revision
or approval.

**Confidence score** [Project] -- A 0-100 value assigned by the Output Formatter
indicating how well the explanation is grounded in the source. Stored in
`ExplanationOutput.confidence_score`.

**Context (task context)** [CrewAI] -- The `context` parameter on a `Task`. A list of
earlier tasks whose outputs are injected into this task's prompt.

**Context window** [General] -- Maximum tokens an LLM can process in one call. Chunking
is necessary when a document exceeds this limit.

**Crew** [CrewAI] -- The top-level CrewAI object that binds agents and tasks together.
`crew.kickoff()` / `crew.kickoff_async()` starts the run.

**CrewAI** [CrewAI] -- Open-source framework for role-based multi-agent workflows.
Agents have a role, goal, and backstory; tasks run in a defined sequence.

**Document Loader Agent** [Project] -- First agent in the pipeline. Detects PDF or
Markdown, extracts text, returns a `DocumentMetadata` object.

**DocumentChunk** [Project] -- Pydantic model for one document section: `chunk_id`,
`title`, `text`, `source_file`, `position`.

**DocumentMetadata** [Project] -- Pydantic model for document-level facts: file path,
type, name, character count, page count, chunk count.

**dotenv / .env** [Python] -- `python-dotenv` loads a `.env` file as environment
variables so API keys are never hard-coded.

**Edge** [LangGraph] -- A directed connection between two nodes. Fixed edges go to one
destination; conditional edges call a router to choose.

**Embedding** [General] -- A numeric vector representation of text. Configured via
`OPENAI_EMBEDDING_MODEL`; not used in the core pipeline.

**Entry point** [LangGraph] -- The first node executed when a graph is invoked. Set
with `graph.set_entry_point()`. In this notebook, `supervisor` is the entry point.

**Example Adder** [Project] -- Fourth agent/node. Adds analogies, examples, and a
"why this matters" paragraph to the Explainer's output.

**ExplainerState** [LangGraph] [Project] -- The `TypedDict` shared across all
LangGraph nodes. Holds `chunk`, `concepts`, `explanation`, `complexity`, `strategy`,
`supervisor_brief`, `approved`, `revision_count`, `formatted_output`, `trace_events`.

**ExplanationOutput** [Project] -- Pydantic model for the final chunk result: title,
explanation, key terms, steps, example, why-it-matters, review notes, confidence
score, grounded flag.

**Explainer Agent** [Project] -- Third agent/node. Rewrites the chunk in plain English
guided by the Supervisor's strategy and the Concept Extractor's output.

**File picker** [Project] -- An `ipywidgets.Select` widget (Stage 2) that scans
`input\` for `.pdf` and `.md` files; no code editing needed to change the source.

**format_output** [LangGraph] [Project] -- Final LangGraph node. Assembles the full
structured Markdown output with citations and a confidence score.

**Goal** [CrewAI] -- Short string on a CrewAI Agent describing what it is trying to
accomplish. Included in its prompt.

**Grounding / Source grounding** [General] -- Keeping an AI explanation anchored to
the source text, not adding unsupported facts. The Reviewer checks for this.

**Hallucination** [General] -- When an LLM generates plausible-sounding text not
supported by the source. The Review Agent and confidence score defend against it.

**ipywidgets** [Python] -- Library for interactive HTML widgets in Jupyter. Used for
the file picker.

**Kickoff** [CrewAI] -- Method that starts a Crew. `kickoff()` is synchronous;
`kickoff_async()` is asynchronous. Wrapped in `kickoff_crew_sync` for batch runs.

**LangChain** [Python] -- Framework for LLM applications. Used here for `ChatOpenAI`
and message types. LangGraph is a separate package built on LangChain concepts.

**LangGraph** [LangGraph] -- Open-source framework (LangChain team) for stateful,
graph-based multi-agent workflows. Workflows are directed graphs of nodes and edges.

**LLM (Large Language Model)** [General] -- A neural network trained on large text
corpora that can generate, summarize, and explain text. Primary model: `gpt-5.5`.
LLM-as-Judge model: Claude Sonnet (Anthropic).

**LLM-as-Judge** [Project] -- Stage 9 feature. Claude Sonnet evaluates CrewAI vs
LangGraph outputs across accuracy, clarity, completeness, structure, and overall
quality, then selects the winning framework for the full batch.

**Markdown** [General] -- Plain-text formatting language that renders as HTML. All
agent outputs and notebook explanation cells are in Markdown.

**Multi-agent workflow** [General] -- A system where multiple AI agents with
specialized roles collaborate to complete a task.

**nest_asyncio** [Python] -- Patches Python's event loop so async code can run inside
Jupyter. Required for CrewAI and LangGraph to work in a notebook.

**Node** [LangGraph] -- A plain Python function registered in a `StateGraph`. Receives
full state, does one job, returns a dict of updated fields.

**OpenAI** [General] -- Primary LLM provider. Development uses `gpt-5-nano` (fast agents)
and `gpt-5-mini` (reviewer and formatter) per `MODEL_CONFIG`. Production uses `gpt-5.5`
(set `USE_PRODUCTION_MODEL = True`). `text-embedding-3-small` is the configured embedding model.

**Output Formatter** [Project] -- Final agent/node. Assembles pipeline outputs into
structured Markdown with citations and confidence score.

**pandas / DataFrame** [Python] -- Data analysis library. Used to display trace logs
in a readable table after each run.

**Per-book output** [Project] -- Each source document gets its own subfolder under
`output\` and `logs\`. Managed by `book_output_path()`, `book_log_path()`,
`book_final_path()`.

**Process.sequential** [CrewAI] -- Crew execution mode where tasks run one at a time
in listed order; each output is passed to the next via CrewAI context.

**Prompt** [General] -- Input text sent to an LLM. Each call has a system prompt
(agent role) and a user prompt (specific content or instruction).

**Pydantic** [Python] -- Data validation library using type annotations. Used for all
project data models with automatic field validation.

**Review loop** [LangGraph] [Project] -- The conditional path where `review_explanation`
can route back to `explain_chunk` for revision. Runs at most twice before
auto-approving.

**Reviewer** [Project] -- Fifth agent/node. Checks grounding, flags unsupported claims,
and votes APPROVED or NEEDS REVISION.

**Role** [CrewAI] -- Job-title string on a CrewAI Agent. Included in its prompt and
shown in logs.

**route_review** [LangGraph] [Project] -- Router function for the conditional edge
after `review_explanation`. Returns `'explain_chunk'` or `'format_output'`.

**Sequential workflow** [General] -- Steps run one after another in a fixed order.
CrewAI uses a sequential workflow; LangGraph adds a conditional review loop.

**StateGraph** [LangGraph] -- LangGraph class for defining a graph workflow. Nodes are
added with `add_node`, edges with `add_edge` / `add_conditional_edges`; compiled with
`compile()`.

**STRATEGY** [Project] -- One of three Supervisor outputs. Recommends `standard`,
`detailed`, or `simplified` as the explanation approach. Stored as `strategy` in state.

**Structure Agent** [Project] -- Second agent in the document pipeline. Splits
extracted text into `DocumentChunk` objects based on headings or paragraph breaks.

**Supervisor Agent** [Project] -- First agent/node in the per-chunk pipeline in both
frameworks. Outputs COMPLEXITY, STRATEGY, and BRIEF before any explanation work begins.
In LangGraph, it is the graph entry point.

**System prompt** [General] -- Part of an LLM call that sets the model's role and
constraints. Each agent in the pipeline has its own system prompt.

**Task** [CrewAI] -- CrewAI object that gives one agent a specific instruction.
Has a `description`, expected output, assigned `agent`, and optional `context` list.

**Temperature** [General] -- LLM parameter controlling output randomness. `0.0` is
deterministic; higher values increase creativity. All agents use `temperature=0` in
both development and production mode to maximize faithfulness to the source material.

**Token** [General] -- Basic unit an LLM processes; roughly 3/4 of an English word.
API costs and context window limits are measured in tokens.

**TraceEvent** [Project] -- Pydantic model recording one workflow step: `trace_id`,
`run_timestamp`, `agent_name`, `step_name`, `status`, `duration_ms`, `notes`. Saved
as JSON to `logs\` and shown as a DataFrame.

**Trace ID** [Project] -- First 8 characters of a UUID, assigned to each workflow run.
All `TraceEvent` objects for a run share the same trace ID.

**TypedDict** [Python] [LangGraph] -- Python typing construct for a dictionary with
known keys and typed values. LangGraph uses it as the graph state type. Does not
validate at runtime -- it is a type hint only.

**User prompt** [General] -- Part of an LLM call containing the specific content to
process, as opposed to the system prompt which sets the agent's role.

**Verbose** [CrewAI] -- Boolean flag on a CrewAI Agent. When `True`, prints detailed
execution logs. Set to `False` here to keep notebook output readable.

**Virtual environment (.venv)** [Python] -- Isolated Python installation for this
project. Created with `python -m venv .venv`; activated with
`.venv\Scripts\Activate.ps1`. Prevents package conflicts.
