# Logs Directory

This directory contains log files from the automation scripts.

## Log Files

- `startup_YYYYMMDD_HHMMSS.log` - Python orchestrator logs
- `startup_ps_YYYYMMDD_HHMMSS.log` - PowerShell script logs
- Other custom script logs

## Log Retention

Logs are kept indefinitely by default. You may want to:

1. Periodically archive or delete old logs
2. Use log rotation tools
3. Configure retention in `startup_config.json` (future feature)

## Privacy Note

Log files may contain:
- System paths
- Execution timestamps
- Process IDs
- Error messages

Do not share logs publicly if they contain sensitive information.
