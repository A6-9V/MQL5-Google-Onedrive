# Service Worker Inspector

A comprehensive debugging and monitoring tool for the MQL5 Trading Automation Progressive Web App.

## Quick Access

🔗 **URL:** `/sw-inspector.html` or click "Service Worker" → "Inspect Views" on the dashboard

## Features

### 📊 Real-Time Status Monitoring
- Service worker registration status
- Current state (installing, waiting, active)
- Scope and script URL
- Update availability detection

### 💾 Cache Storage Management
- View all caches and their contents
- See number of cached items per cache
- Refresh cache information
- Clear all caches with confirmation

### 🔄 Update Management
- Check for service worker updates
- Force apply waiting updates
- Skip waiting and reload
- Unregister service worker

### 📝 Activity Logging
- Real-time event logging
- Timestamped entries
- Track all service worker operations
- Clear log functionality

### 📱 PWA Installation
- Check if app is installable
- Show installation prompt
- Detect current display mode
- Track installation status

## Screenshots

### Main Interface
The inspector provides a clean, card-based interface with distinct sections for:
1. Service Worker Status
2. Cache Storage
3. Activity Log
4. PWA Installation

### Status Indicators
- 🟢 **Active** - Service worker is running
- 🔴 **Not Registered** - No service worker found
- 🟠 **Installing** - Service worker being installed

## Usage

### For End Users

1. **Access the Inspector:**
   - Visit `/sw-inspector.html`
   - Or click the "Service Worker" card on the main dashboard
   - Or click "Inspect Views" button

2. **Check Service Worker Status:**
   - View the status badge (Active/Inactive)
   - See the current state and scope
   - Check if updates are available

3. **Manage Offline Storage:**
   - Click "Refresh Cache Info" to see cached items
   - Clear caches if experiencing issues
   - Monitor storage usage

4. **Update the App:**
   - Click "Check for Updates" to manually check
   - Use "Force Update" if an update is available
   - App will reload with new version

5. **Install as PWA:**
   - Check if the app is installable
   - Click "Install App" when available
   - App will be added to your home screen

### For Developers

#### Debugging Service Worker Issues

1. **Registration Failures:**
   ```
   Status: Not Registered
   → Check console for errors
   → Ensure HTTPS or localhost
   → Verify service-worker.js path
   ```

2. **Update Not Applying:**
   ```
   Update Available: Yes
   → Click "Force Update"
   → Or unregister and refresh
   ```

3. **Cache Issues:**
   ```
   → Click "Refresh Cache Info"
   → Check cached items count
   → Clear caches if needed
   ```

4. **Offline Mode Not Working:**
   ```
   → Check cache list
   → Verify resources are cached
   → Check activity log for errors
   ```

#### Using the Activity Log

The activity log shows all service worker events:
- Page loaded
- Service worker registered
- Cache information refreshed
- Updates checked/forced
- Caches cleared
- Errors encountered

Each entry has a timestamp for debugging timing issues.

#### Cache Management

**View Caches:**
```javascript
// Caches are displayed as:
mql5-automation-v1: 6 items
mql5-runtime-v1: 15 items
```

**Clear Caches:**
- Use "Clear All Caches" button
- Confirms before clearing
- Logs the action
- Updates cache display

#### Forcing Updates

When a new service worker is available:
1. Inspector shows "Update Available: Yes"
2. Click "Force Update"
3. Service worker sends SKIP_WAITING message
4. Page reloads with new version

## API Reference

### Service Worker Messages

The inspector communicates with the service worker using messages:

#### Check Cache Stats
```javascript
navigator.serviceWorker.controller.postMessage({
  type: 'CACHE_STATS'
});
```

#### Clear Cache
```javascript
navigator.serviceWorker.controller.postMessage({
  type: 'CLEAR_CACHE'
});
```

#### Skip Waiting
```javascript
registration.waiting.postMessage({
  type: 'SKIP_WAITING'
});
```

### Event Listeners

The inspector listens for:
- `beforeinstallprompt` - PWA installation prompt
- `appinstalled` - PWA successfully installed
- `controllerchange` - Service worker controller changed
- `online` - Connection restored
- `offline` - Connection lost

## Troubleshooting

### Inspector Not Loading

**Problem:** Inspector page doesn't load  
**Solutions:**
- Check if file exists at `/sw-inspector.html`
- Clear browser cache
- Try direct URL: `https://yourdomain.com/sw-inspector.html`

### "Not Registered" Status

**Problem:** Service worker shows as not registered  
**Solutions:**
- Ensure HTTPS connection (or localhost)
- Check browser console for errors
- Verify service-worker.js is accessible
- Try hard refresh (Ctrl+Shift+R)

### Updates Not Showing

**Problem:** New version deployed but no update shown  
**Solutions:**
- Click "Check for Updates"
- Verify cache version was incremented
- Check service-worker.js is updated
- Try "Unregister" then refresh

### Cache Not Clearing

**Problem:** Clear cache button doesn't work  
**Solutions:**
- Check browser console for errors
- Try clearing browser data manually
- Unregister service worker and refresh
- Use browser DevTools Application tab

## Browser DevTools Integration

The inspector complements browser DevTools:

### Chrome DevTools
1. Open DevTools (F12)
2. Go to "Application" tab
3. Select "Service Workers" in sidebar
4. See registration, update, and unregister options
5. Use "Offline" checkbox to test offline mode

### Firefox DevTools
1. Open DevTools (F12)
2. Go to "Application" tab
3. Select "Service Workers"
4. View status and debug

### Safari DevTools
1. Enable Developer menu
2. Go to "Develop" → "Service Workers"
3. View registrations

## Best Practices

### Regular Checks
- Check status after deploying updates
- Monitor cache size periodically
- Review activity log for errors

### Update Process
1. Deploy new version
2. Visit inspector
3. Check for update
4. Force update if available
5. Verify new version works

### Cache Management
- Don't clear cache unnecessarily
- Check cache size before clearing
- Understand what's being cached
- Clear if experiencing issues

### Troubleshooting Workflow
1. Check inspector status first
2. Review activity log
3. Check cache information
4. Try force update
5. Clear caches if needed
6. Unregister as last resort

## Technical Details

### Technologies Used
- **Service Worker API** - Background processing
- **Cache Storage API** - Offline storage
- **Fetch API** - Network requests
- **Notification API** - Push notifications (future)

### Browser Requirements
- Chrome 40+
- Firefox 44+
- Safari 11.1+
- Edge 17+

### Security
- HTTPS required (except localhost)
- Same-origin policy enforced
- Secure context required
- No sensitive data cached

## Support

### Getting Help
1. Check this documentation
2. Review PWA_GUIDE.md
3. Check browser console
4. Use browser DevTools

### Reporting Issues
If you encounter issues:
1. Note the error in activity log
2. Check browser console
3. Take screenshot of inspector
4. Note browser and version
5. Report with reproduction steps

---

**Version:** 1.0.0  
**Last Updated:** February 1, 2026  
**Browser Compatibility:** Modern browsers with Service Worker support
