# bizops

A Claude Code skill pack that turns AI into a structured business operations team.
10 specialist personas — each activated by a slash command — covering strategy, intelligence,
marketing, research, operations, and planning. Configure once for your company; all skills
adapt automatically.

---

## Prerequisites

- [Claude Code](https://claude.ai/code) installed and authenticated
- macOS or Linux — works natively
- Windows — requires [Git Bash](https://git-scm.com/downloads) or [WSL](https://learn.microsoft.com/en-us/windows/wsl/install). Does not work in Command Prompt or PowerShell.

---

## Install

**Step 1 — Clone**
```bash
git clone https://github.com/gladius/bizops.git
cd bizops
```

**Step 2 — Configure for your company**
```bash
cp config.example.yaml config.yaml
```
Edit `config.yaml`:
```yaml
company: Acme Corp
industry: SaaS
description: A B2B project management platform serving mid-market engineering teams.
context_path: ~/bizops-context
competitors: Asana, Monday.com, Notion
```

**Step 3 — Run setup**
```bash
bash setup.sh
```

Setup will:
- Generate all 10 skills configured for your company
- Create your context folder (`~/bizops-context` by default)
- Install [Bun](https://bun.sh) and build the Excel reader (one-time, no manual steps)

**Step 4 — Restart Claude Code**

Close and reopen Claude Code. All 10 skills are immediately available as slash commands.

**To update** after editing config or pulling new skill files:
```bash
bash setup.sh
```
Then restart Claude Code.

---

## Context folder — drop files, skills read them automatically

Every skill checks your context folder before starting. Drop any relevant files there
and they are incorporated automatically — no pasting, no extra prompting.

| Format | Support |
|--------|---------|
| `.pdf` | Native — Claude Code reads these directly |
| `.xlsx` / `.xls` | Built-in reader (compiled at setup, no manual installs) |
| `.csv` | Native |
| `.txt` / `.md` | Native |

Skills only read files relevant to the current task — not everything blindly.

**Example:** drop `q1-metrics.xlsx` into `~/bizops-context/`, run `/prep-brief`, and the brief includes your Q1 data without you mentioning it.

---

## Skills

### `/prep-brief` — Chief of Staff
Takes any sprawling document — meeting notes, proposals, data dumps — and condenses
it into a 1-page executive brief. Always leads with financial impact, resource
requirements, top risks, and a clear recommendation.

**Input:** Paste a document, provide a file path, or drop files in the context folder

---

### `/meeting-debrief` — Chief of Staff
Converts meeting transcripts or rough notes into a structured debrief: decisions made,
action items with owners and deadlines, open questions, and a suggested next agenda.

**Input:** Paste transcript or notes

---

### `/growth-analysis` — Growth Analyst
Two modes. Given your **own campaign data or product feature**: identifies viral loops,
calculates CAC/LTV ratios, finds conversion leaks, suggests 3 A/B tests.
Given a **competitor campaign**: decodes their growth mechanics and outputs tactics to steal or counter.

**Input:** Paste campaign data, metrics, or a competitor URL

---

### `/gtm-draft` — Product Marketing Manager
Takes raw technical specs or a feature list and generates a full Go-to-Market brief:
audience personas, messaging pillars with proof points, channel rollout plan by phase,
and a "what not to say" section.

**Input:** Paste product specs or a feature list

---

### `/journey-map` — UX Researcher
Maps the step-by-step customer experience through any process or flow. Flags drop-off
risks, friction points, cognitive load issues, and accessibility concerns at each step.

**Input:** Describe a customer flow or process

---

### `/wbs` — Project Coordinator
Breaks any strategic goal into a structured Work Breakdown Structure — phased tasks,
owners, durations, dependencies, single points of failure, and a critical path.

**Input:** State a project goal and target date

---

### `/risk-register` — Risk Officer
Given any project, initiative, or business decision, produces a structured risk register
across execution, market, people, financial, and external categories — each with
likelihood, impact, severity, mitigation, contingency, and owner. Flags the top 3 risks.

**Input:** Describe a project or initiative

---

### `/okr-draft` — Strategy Lead
Takes a strategy document or business goal and produces well-formed OKRs: inspiring
Objectives, measurable Key Results, suggested initiatives, and an alignment check
flagging gaps and conflicts.

**Input:** Paste a strategy doc or describe a goal

---

### `/market-watch` — Competitive Intelligence Analyst
Deep competitor research across 9 signal types: earnings & executive language,
regulatory filings, hiring signals, pricing, product & technology, independent
benchmarks, ad creative, marketing & messaging, and customer sentiment.
Each signal includes threat rating and recommended response.

**Input:** Competitor name, topic, or "broad sweep"

---

### `/daily-pulse` — Morning Briefing
Scans overnight developments across your configured competitors and broader industry.
Triages every item: Act today / Monitor / FYI. If nothing significant happened, says so.
Defaults to email format — designed to land before the first meeting.

**Input:** None required. Optionally specify a focus ("anything on pricing today")

**To schedule daily:** In a new Claude Code session, run `/schedule` and say
"run `/daily-pulse` every weekday at 8am."

---

## How skills chain together

```
/meeting-debrief surfaces a new initiative
    → /risk-register before committing
        → /wbs to plan execution
            → /okr-draft to set success criteria
```

```
/daily-pulse flags a competitor move
    → /market-watch for a full strategic read
        → /prep-brief the findings for leadership
```

```
/growth-analysis on a new product feature
    → /gtm-draft the launch brief
        → /journey-map the purchase flow for friction
```

---

## Output formats

All skills output to the terminal by default. After running a skill, ask Claude to reformat:

| Say this | What you get |
|----------|-------------|
| "format this as an email" | Forwardable email with subject line and body |
| "make this slide-ready" | Headline + bullets per section, deck-friendly |
| "save this to a file" | Written to a timestamped `.md` file |

---

## Project structure

```
bizops/
  setup.sh                — configures and installs all 10 skills
  config.example.yaml     — copy to config.yaml and fill in your details
  config.yaml             — your company config (gitignored, never committed)
  templates/              — skill source files (one SKILL.md.tmpl per skill)
  bin/
    xlsx2text.ts          — Excel reader source (TypeScript)
    package.json          — dependencies (SheetJS)
    xlsx2text             — compiled binary (gitignored, built by setup.sh)

~/.claude/skills/         — generated skills (written by setup.sh)
~/bizops-context/         — drop files here for skills to pick up automatically
```
