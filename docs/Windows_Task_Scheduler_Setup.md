# Windows Task Scheduler Setup

This guide shows how to set up automatic startup using Windows Task Scheduler for MQL5 trading automation.

## Method 1: Automated Setup (Easiest)

Open PowerShell as Administrator and run:

```powershell
cd C:\path\to\MQL5-Google-Onedrive
powershell -ExecutionPolicy Bypass -File scripts\startup.ps1 -CreateScheduledTask
```

This automatically creates a scheduled task named `MQL5_Trading_Automation_Startup`.

## Method 2: Manual Setup

### Step 1: Open Task Scheduler

Press `Win + R`, type `taskschd.msc`, and press Enter.

### Step 2: Create New Task

1. In the right panel, click **"Create Task..."** (not "Create Basic Task")

### Step 3: General Settings

- **Name:** `MQL5 Trading Automation`
- **Description:** `Automatically start MT5 terminal and trading scripts`
- Check ☑ **"Run with highest privileges"**
- **Configure for:** Windows 10 (or your version)
- **Security options:** 
  - Select "Run whether user is logged on or not"
  - Check "Do not store password"

### Step 4: Triggers

1. Go to **Triggers** tab
2. Click **New...**
3. Settings:
   - **Begin the task:** `At startup`
   - **Delay task for:** `30 seconds` (recommended to let system initialize)
   - Check ☑ **Enabled**
4. Click **OK**

### Step 5: Actions

1. Go to **Actions** tab
2. Click **New...**
3. Settings:
   - **Action:** `Start a program`
   - **Program/script:** `powershell.exe`
   - **Add arguments:**
     ```
     -ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\path\to\MQL5-Google-Onedrive\scripts\startup.ps1" -NoWait
     ```
   - **Start in:** `C:\path\to\MQL5-Google-Onedrive`
4. Click **OK**

### Step 6: Conditions

1. Go to **Conditions** tab
2. **Power:**
   - Uncheck ☐ "Start the task only if the computer is on AC power"
   - Uncheck ☐ "Stop if the computer switches to battery power"
3. **Network:**
   - Check ☑ "Start only if the following network connection is available"
   - Select "Any connection"

### Step 7: Settings

1. Go to **Settings** tab
2. Configure:
   - Check ☑ "Allow task to be run on demand"
   - Check ☑ "Run task as soon as possible after a scheduled start is missed"
   - Check ☑ "If the task fails, restart every:" `5 minutes`
   - Set "Attempt to restart up to:" `3 times`
   - Uncheck ☐ "Stop the task if it runs longer than"
3. Click **OK**

### Step 8: Save and Test

1. Click **OK** to save the task
2. You may be prompted to enter your password
3. To test immediately:
   - Right-click the task in the list
   - Select **Run**
   - Check the **Last Run Result** column (should show "Success" or 0x0)

## Verification

### Check if Task is Running

```powershell
Get-ScheduledTask -TaskName "MQL5*" | Get-ScheduledTaskInfo
```

### View Task History

1. In Task Scheduler, select your task
2. Click the **History** tab at the bottom
3. Enable history if disabled: Actions → Enable All Tasks History

### Test the Task

```powershell
# Start the task manually
Start-ScheduledTask -TaskName "MQL5_Trading_Automation_Startup"

# Check status
Get-ScheduledTask -TaskName "MQL5_Trading_Automation_Startup" | Select-Object State, LastRunTime, LastTaskResult
```

## Troubleshooting

### Task Doesn't Run at Startup

1. Check if task is **Enabled**
2. Verify **Trigger** is set to "At startup"
3. Ensure "Run whether user is logged on or not" is selected
4. Check Task History for error details

### Task Runs But Nothing Happens

1. Check logs in `logs/` directory
2. Run PowerShell script manually to see errors:
   ```powershell
   cd C:\path\to\MQL5-Google-Onedrive
   .\scripts\startup.ps1 -Verbose
   ```
3. Verify MT5 path in `config/startup_config.json`

### Permission Errors

Run Task Scheduler as Administrator:
```powershell
Start-Process taskschd.msc -Verb RunAs
```

### Task Doesn't Start MT5

1. Test MT5 path in PowerShell:
   ```powershell
   Test-Path "C:\Program Files\Exness Terminal\terminal64.exe"
   ```
2. Update path in `config/startup_config.json` if different

## Alternative: Startup Folder

For simpler setup (runs after login only):

1. Create a shortcut to `startup.ps1`:
   - Right-click `scripts\startup.ps1` → Create shortcut
   - Right-click shortcut → Properties
   - Target: `powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\path\to\MQL5-Google-Onedrive\scripts\startup.ps1" -NoWait`

2. Move shortcut to Startup folder:
   ```powershell
   # Open Startup folder
   explorer shell:startup
   
   # Copy shortcut here
   ```

## Removing the Task

### Using PowerShell

```powershell
Unregister-ScheduledTask -TaskName "MQL5_Trading_Automation_Startup" -Confirm:$false
```

### Using Task Scheduler GUI

1. Open Task Scheduler
2. Find your task in the list
3. Right-click → **Delete**

## Security Notes

- The task runs with your user privileges
- Credentials are encrypted by Windows
- Scripts are executed with `ExecutionPolicy Bypass` for this task only
- Consider using a dedicated trading account on your PC
- Never share your scheduled task export with others (contains credentials)

## Advanced: Export/Import Task

Export task to XML (for backup or transfer):
```powershell
Export-ScheduledTask -TaskName "MQL5_Trading_Automation_Startup" -TaskPath "\" | Out-File -FilePath "C:\path\to\backup\task.xml"
```

Import task on another machine:
```powershell
Register-ScheduledTask -Xml (Get-Content "C:\path\to\backup\task.xml" | Out-String) -TaskName "MQL5_Trading_Automation_Startup"
```

## Additional Resources

- [Microsoft Docs - Task Scheduler](https://docs.microsoft.com/en-us/windows/win32/taskschd/task-scheduler-start-page)
- [PowerShell Task Scheduler Cmdlets](https://docs.microsoft.com/en-us/powershell/module/scheduledtasks/)
