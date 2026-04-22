.DEFAULT_GOAL := help

SKILLS_DIR := $(HOME)/.claude/skills
SKILLS     := cost-optimization brainofbrains elasticjudge

.PHONY: help install-all install-cost install-brains install-judge check update-all clean

help: ## Show this help message
	@echo "AI Performance Skills — root-level tooling"
	@echo ""
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-18s %s\n", $$1, $$2}'

install-all: ## Copy all three skills to ~/.claude/skills/
	@echo "Installing all three skills to $(SKILLS_DIR) ..."
	@mkdir -p "$(SKILLS_DIR)"
	cp -R cost-optimization brainofbrains elasticjudge "$(SKILLS_DIR)/"
	@echo "Done. Restart your Claude Code session to pick up the new skills."

install-cost: ## Copy only cost-optimization to ~/.claude/skills/
	@echo "Installing cost-optimization to $(SKILLS_DIR) ..."
	@mkdir -p "$(SKILLS_DIR)"
	cp -R cost-optimization "$(SKILLS_DIR)/"
	@echo "Done. Restart your Claude Code session to pick up the skill."

install-brains: ## Copy only brainofbrains to ~/.claude/skills/
	@echo "Installing brainofbrains to $(SKILLS_DIR) ..."
	@mkdir -p "$(SKILLS_DIR)"
	cp -R brainofbrains "$(SKILLS_DIR)/"
	@echo "Done. Restart your Claude Code session to pick up the skill."

install-judge: ## Copy only elasticjudge to ~/.claude/skills/
	@echo "Installing elasticjudge to $(SKILLS_DIR) ..."
	@mkdir -p "$(SKILLS_DIR)"
	cp -R elasticjudge "$(SKILLS_DIR)/"
	@echo "Done. Restart your Claude Code session to pick up the skill."

check: ## Syntax-check all scripts in all three skills (bash -n)
	@PASS=0; FAIL=0; \
	for skill in $(SKILLS); do \
		for script in $$skill/scripts/*.sh; do \
			if bash -n "$$script" 2>/dev/null; then \
				echo "PASS  $$script"; \
				PASS=$$((PASS+1)); \
			else \
				echo "FAIL  $$script"; \
				bash -n "$$script"; \
				FAIL=$$((FAIL+1)); \
			fi; \
		done; \
	done; \
	echo ""; \
	echo "Results: $$PASS passed, $$FAIL failed"; \
	[ "$$FAIL" -eq 0 ]

update-all: ## Run update.sh for all three installed skills
	@for skill in $(SKILLS); do \
		target="$(SKILLS_DIR)/$$skill"; \
		if [ -f "$$target/scripts/update.sh" ]; then \
			echo "Updating $$skill ..."; \
			bash "$$target/scripts/update.sh"; \
		else \
			echo "SKIP  $$skill — not installed at $$target (run make install-all first)"; \
		fi; \
	done

clean: ## Remove /tmp/aips scratch directory (prompts for confirmation)
	@echo "WARNING: This will permanently delete /tmp/aips."
	@printf "Type 'yes' to confirm: "; read answer; \
	if [ "$$answer" = "yes" ]; then \
		rm -rf /tmp/aips; \
		echo "Removed /tmp/aips."; \
	else \
		echo "Aborted."; \
	fi
