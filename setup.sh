#!/usr/bin/env bash
# bizops setup — generates skills from templates + config directly into ~/.claude/skills/
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$SCRIPT_DIR/config.yaml"
TEMPLATES_DIR="$SCRIPT_DIR/templates"
CLAUDE_SKILLS="$HOME/.claude/skills"
BIN_DIR="$SCRIPT_DIR/bin"
XLSX_BIN="$BIN_DIR/xlsx2text"

# ─── Check config exists ───────────────────────────────────────────
if [ ! -f "$CONFIG" ]; then
  echo "Error: config.yaml not found."
  echo "Copy config.example.yaml to config.yaml and fill in your company details."
  echo "  cp config.example.yaml config.yaml"
  exit 1
fi

# ─── Read config values ────────────────────────────────────────────
read_config() {
  grep "^$1:" "$CONFIG" | sed "s/^$1:[[:space:]]*//" | tr -d '"' | tr -d "'"
}

COMPANY=$(read_config "company")
INDUSTRY=$(read_config "industry")
DESCRIPTION=$(read_config "description")
INDUSTRY_LOWER=$(echo "$INDUSTRY" | tr '[:upper:]' '[:lower:]')
CONTEXT_PATH=$(eval echo "$(read_config "context_path")")
COMPETITORS=$(read_config "competitors" | sed 's/&/\\\&/g')

if [ -z "$CONTEXT_PATH" ]; then
  CONTEXT_PATH="$HOME/bizops-context"
fi

if [ -z "$COMPANY" ] || [ -z "$INDUSTRY" ]; then
  echo "Error: config.yaml is missing required fields (company, industry)."
  exit 1
fi

echo "Configuring for: $COMPANY ($INDUSTRY)"
echo ""

# ─── Bun + Excel support ───────────────────────────────────────────
EXCEL_SUPPORT=false

if [ ! -f "$XLSX_BIN" ]; then
  # Ensure bun is available
  if ! command -v bun &>/dev/null; then
    echo "Installing Bun for Excel support..."
    if curl -fsSL https://bun.sh/install | bash 2>/dev/null; then
      export PATH="$HOME/.bun/bin:$PATH"
      echo "  Bun installed."
    else
      echo "  Bun install failed — Excel (.xlsx) files not supported."
      echo "  Drop a CSV export into $CONTEXT_PATH instead. Re-run setup.sh to retry."
    fi
  fi

  if command -v bun &>/dev/null; then
    echo "Building Excel reader..."
    cd "$BIN_DIR"
    bun install --quiet 2>/dev/null
    bun build --compile xlsx2text.ts --outfile xlsx2text 2>/dev/null
    cd "$SCRIPT_DIR"
    echo "  done"
    EXCEL_SUPPORT=true
  fi
else
  EXCEL_SUPPORT=true
fi

if [ "$EXCEL_SUPPORT" = false ]; then
  XLSX_BIN=""
fi

# ─── Create context folder ─────────────────────────────────────────
mkdir -p "$CONTEXT_PATH"

# ─── Generate skills directly into ~/.claude/skills/ ──────────────
mkdir -p "$CLAUDE_SKILLS"
echo ""
echo "Installing skills..."

for tmpl_dir in "$TEMPLATES_DIR"/*/; do
  skill_name="$(basename "$tmpl_dir")"
  tmpl_file="$tmpl_dir/SKILL.md.tmpl"

  if [ ! -f "$tmpl_file" ]; then
    continue
  fi

  out_dir="$CLAUDE_SKILLS/$skill_name"
  if [ -L "$out_dir" ] || [ -e "$out_dir" ]; then
    rm -rf "$out_dir"
  fi
  mkdir -p "$out_dir"

  sed \
    -e "s|{{COMPANY}}|$COMPANY|g" \
    -e "s|{{INDUSTRY}}|$INDUSTRY|g" \
    -e "s|{{INDUSTRY_LOWER}}|$INDUSTRY_LOWER|g" \
    -e "s|{{DESCRIPTION}}|$DESCRIPTION|g" \
    -e "s|{{CONTEXT_PATH}}|$CONTEXT_PATH|g" \
    -e "s|{{XLSX_BIN}}|$XLSX_BIN|g" \
    -e "s|{{COMPETITORS}}|$COMPETITORS|g" \
    "$tmpl_file" > "$out_dir/SKILL.md"

  echo "  installed: /$skill_name"
done

echo ""
echo "Done. Restart Claude Code to activate skills:"
echo "  /prep-brief        Chief of Staff — executive briefs"
echo "  /meeting-debrief   Chief of Staff — meeting notes to actions"
echo "  /growth-analysis   Growth Analyst — CAC/LTV, viral loops, A/B tests"
echo "  /gtm-draft         PMM — Go-to-Market briefs"
echo "  /journey-map       UX Researcher — customer journey maps"
echo "  /wbs               Project Coordinator — work breakdown structures"
echo "  /risk-register     Risk Officer — risk identification and mitigation"
echo "  /okr-draft         Strategy Lead — OKR drafting and alignment"
echo "  /market-watch      CI Analyst — deep competitor intelligence"
echo "  /daily-pulse       Morning briefing — overnight market developments"
echo ""
echo "Context folder : $CONTEXT_PATH"
echo "Excel support  : $([ "$EXCEL_SUPPORT" = true ] && echo 'yes (.xlsx/.xls)' || echo 'no — drop CSV files instead')"
echo "Configured for : $COMPANY | $INDUSTRY"
