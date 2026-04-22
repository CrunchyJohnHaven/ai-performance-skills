.DEFAULT_GOAL := help

SKILLS_DIR := $(HOME)/.claude/skills
SKILLS     := cost-optimization brainofbrains elasticjudge

.PHONY: help install-all install-cost install-brains install-judge check clean lint smoke-test update-all diagnose uninstall shellcheck

help: ## Show this help message
	@echo "AI Performance Skills — root-level tooling"
	@echo ""
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-18s %s\n", $$1, $$2}'

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

clean: ## Remove generated deliverables/ directory (prompts for confirmation)
	@echo "WARNING: This will permanently delete ./deliverables/."
	@printf "Type 'yes' to confirm: "; read answer; \
	if [ "$$answer" = "yes" ]; then \
		rm -rf deliverables; \
		echo "Removed deliverables/."; \
	else \
		echo "Aborted."; \
	fi

install-all: ## Copy all three skills to ~/.claude/skills/
	@echo "Installing all three skills to $(SKILLS_DIR) ..."
	@mkdir -p "$(SKILLS_DIR)"
	cp -R cost-optimization brainofbrains elasticjudge "$(SKILLS_DIR)/"
	find "$(SKILLS_DIR)" -name "*.sh" -exec chmod +x {} \;
	@echo "Done. Restart your Claude Code session to pick up the new skills."

install-brains: ## Copy only brainofbrains to ~/.claude/skills/
	@echo "Installing brainofbrains to $(SKILLS_DIR) ..."
	@mkdir -p "$(SKILLS_DIR)"
	cp -R brainofbrains "$(SKILLS_DIR)/"
	@echo "Done. Restart your Claude Code session to pick up the skill."

install-cost: ## Copy only cost-optimization to ~/.claude/skills/
	@echo "Installing cost-optimization to $(SKILLS_DIR) ..."
	@mkdir -p "$(SKILLS_DIR)"
	cp -R cost-optimization "$(SKILLS_DIR)/"
	@echo "Done. Restart your Claude Code session to pick up the skill."

install-judge: ## Copy only elasticjudge to ~/.claude/skills/
	@echo "Installing elasticjudge to $(SKILLS_DIR) ..."
	@mkdir -p "$(SKILLS_DIR)"
	cp -R elasticjudge "$(SKILLS_DIR)/"
	@echo "Done. Restart your Claude Code session to pick up the skill."

lint: check ## Alias for check (syntax-check all scripts)

diagnose: ## Run all three skill diagnostics and print a pass/fail summary
	bash scripts/diagnose.sh

shellcheck: ## Run ShellCheck -S warning on all scripts (requires shellcheck)
	@find . -name "*.sh" | sort | xargs shellcheck -S warning

smoke-test: ## Run the cost-optimization smoke test from repo root
	bash cost-optimization/scripts/smoke-test.sh

uninstall: ## Remove all skills from ~/.claude/skills/ (dry-run safe)
	bash scripts/uninstall.sh

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
