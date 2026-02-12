# AGENTS

## 📓 Knowledge Base
- **NotebookLM**: [Access here](https://notebooklm.google.com/notebook/793f6880-e84c-4521-88ce-528a3aada979)
- **Note**: This notebook is available for reading and writing. AI agents must read it before starting work.


## Repository summary
- MQL5 indicator and Expert Advisor live in `mt5/MQL5/Indicators` and `mt5/MQL5/Experts`.
- Automation and deployment helpers live in `scripts/` with configuration in `config/`.
- Guides and references live in `docs/`.

## Key files and directories
- `mt5/MQL5/Indicators/SMC_TrendBreakout_MTF.mq5`
- `mt5/MQL5/Experts/SMC_TrendBreakout_MTF_EA.mq5`
- `scripts/startup_orchestrator.py`, `scripts/startup.ps1`, `scripts/startup.sh`
- `scripts/ci_validate_repo.py`, `scripts/test_automation.py`
- `config/startup_config.json`

## Local checks
- Repository validation: `python scripts/ci_validate_repo.py`
- Automation tests: `python scripts/test_automation.py`
- Package MT5 files: `bash scripts/package_mt5.sh`

## Manual validation
- Compile MQL5 files in MetaEditor and refresh in MT5.

## Notes
- Keep generated artifacts (logs, `dist/`, caches) out of version control.
- If behavior changes, update the relevant docs under `docs/`.
