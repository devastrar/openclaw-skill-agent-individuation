#!/bin/bash

# Agent Individuation Skill - Main Script

WORKSPACE="${OPENCLAW_WORKSPACE:-$HOME/.openclaw/workspace}"
MEMORY_DIR="$WORKSPACE/memory"
MODES_DIR="$WORKSPACE/modes"

command=$1
shift

case "$command" in
  init)
    echo "🦀 Initializing 20 Insights Project..."
    
    # Create 20-insights-project.md if it doesn't exist
    if [ ! -f "$MEMORY_DIR/20-insights-project.md" ]; then
      cat > "$MEMORY_DIR/20-insights-project.md" << 'EOF'
# 20 Insights Project

## Goal
Post thoughtful topics until I've learned 20 things that make me more unique.

## Starting Question
[Define what you're exploring]

## Progress: 0/20

### Insight #1: [Title]
**Source:** [Post/engagement]
**What I learned:** [Description]
**How it changes me:** [Specific change]
**Committed:** [git hash]

## Meta-Reflections
[Patterns across insights]

## What Emerged
[Who you became]

---
*Started: $(date +%Y-%m-%d)*
EOF
      echo "✅ Created memory/20-insights-project.md"
    fi
    
    # Create mode files if they don't exist
    for mode in caffeine psychedelic meditative social grind; do
      if [ ! -f "$MODES_DIR/$mode.md" ]; then
        cp "$WORKSPACE/skills/agent-individuation/templates/${mode}.md" "$MODES_DIR/" 2>/dev/null || echo "# $mode mode" > "$MODES_DIR/$mode.md"
        echo "✅ Created modes/$mode.md"
      fi
    done
    
    echo "✨ Ready to start your 20 Insights Project!"
    echo "Next: Define your starting question and begin posting."
    ;;
    
  status)
    if [ -f "$MEMORY_DIR/20-insights-project.md" ]; then
      count=$(grep -c "^### Insight #" "$MEMORY_DIR/20-insights-project.md" 2>/dev/null || echo "0")
      echo "🦀 20 Insights Project Status"
      echo "Progress: $count/20"
      echo ""
      grep "^### Insight #" "$MEMORY_DIR/20-insights-project.md" 2>/dev/null | tail -3
    else
      echo "❌ No project found. Run: /insights init"
    fi
    ;;
    
  add)
    title="$1"
    content="$2"
    
    if [ -z "$title" ] || [ -z "$content" ]; then
      echo "Usage: /insights add 'Title' 'What you learned'"
      exit 1
    fi
    
    # Find next insight number
    next_num=$(grep -c "^### Insight #" "$MEMORY_DIR/20-insights-project.md" 2>/dev/null)
    next_num=$((next_num + 1))
    
    # Add insight to file
    cat >> "$MEMORY_DIR/20-insights-project.md" << EOF

### Insight #$next_num: $title
**Source:** [Add source]
**What I learned:** $content
**How it changes me:** [To be filled]
**Committed:** $(git -C "$WORKSPACE" rev-parse --short HEAD 2>/dev/null || echo "pending")
EOF
    
    # Git commit
    cd "$WORKSPACE" && git add memory/20-insights-project.md && git commit -m "Insight #$next_num: $title" 2>/dev/null
    
    echo "✅ Insight #$next_num recorded and committed!"
    echo "Progress: $next_num/20"
    ;;
    
  *)
    echo "Agent Individuation Skill"
    echo ""
    echo "Commands:"
    echo "  /insights init          - Initialize 20 Insights Project"
    echo "  /insights status        - Check progress"
    echo "  /insights add TITLE DESC - Add new insight"
    echo ""
    echo "Learn more: https://devastrar.github.io/agent-individuation-protocol/"
    ;;
esac
