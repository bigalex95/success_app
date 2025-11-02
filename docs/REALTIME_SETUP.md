# Real-Time Synchronization Setup

Your app now has **real-time synchronization** enabled! Changes made in one app instance (Linux or Chrome) will automatically appear in the other without refreshing.

## How It Works

The app now uses **Supabase Real-time** to subscribe to database changes:

- When you complete a habit in Chrome, Linux app updates automatically
- When you create a new habit in Linux, Chrome app shows it immediately
- No manual refresh needed!

## Supabase Setup Required

To enable real-time, you need to enable it in your Supabase dashboard:

### Step 1: Enable Real-time for Tables

1. Go to https://app.supabase.com
2. Open your project
3. Go to **Database** → **Replication** (in left sidebar)
4. Find these tables and enable replication:
   - `habits` - Enable replication
   - `progress` - Enable replication

### Step 2: Verify Real-time is Enabled

1. Go to **Database** → **Tables**
2. Click on `habits` table
3. In the table settings, check if "Realtime" is enabled
4. Repeat for `progress` table

Alternatively, you can enable it via SQL:

```sql
-- Enable realtime for habits table
alter publication supabase_realtime add table habits;

-- Enable realtime for progress table
alter publication supabase_realtime add table progress;
```

## Testing Real-time Sync

1. **Open two instances**:

   - Run on Linux: `flutter run -d linux`
   - Run on Chrome: `flutter run -d chrome`

2. **Test habit creation**:

   - Create a new habit in Chrome
   - Watch it appear instantly in Linux app (no refresh needed!)

3. **Test habit completion**:

   - Mark a habit as completed in Linux
   - See the checkmark appear in Chrome immediately

4. **Test progress dashboard**:
   - Complete habits in one app
   - Watch stats update in the other app in real-time

## Code Changes Made

### 1. `supabase_service.dart`

- Added real-time subscription setup
- Created streams for habits and progress changes
- Automatically subscribes to database changes on initialization

### 2. `habits_list_page.dart`

- Changed from `ConsumerWidget` to `ConsumerStatefulWidget`
- Added listeners for real-time habit and progress changes
- Automatically refreshes data when changes are detected

### 3. `progress_dashboard.dart`

- Changed from `ConsumerWidget` to `ConsumerStatefulWidget`
- Added listeners for real-time progress changes
- Automatically refreshes stats when data changes

## Troubleshooting

### Changes not appearing automatically?

1. **Check Supabase real-time is enabled** (see Step 1 above)
2. **Check browser console** for connection errors
3. **Verify .env file** has correct Supabase credentials
4. **Restart the app** after enabling real-time in Supabase

### Still having issues?

Run this test command to check Supabase connection:

```bash
dart run tools/check_connections.dart
```

Look for these messages in the debug console:

- `Habits change detected: INSERT/UPDATE/DELETE`
- `Progress change detected: INSERT/UPDATE/DELETE`
- `[Realtime] Habits changed, refreshing data`
- `[Realtime] Progress changed, refreshing data`

## Performance Notes

- Real-time uses WebSockets for efficient communication
- Minimal bandwidth usage (only changes are transmitted)
- Works across all platforms: Web, Linux, Android, iOS, Windows, macOS
- Automatic reconnection if connection is lost

## Disabling Real-time

If you want to disable real-time and go back to manual refresh:

1. Comment out the `initState()` methods in:

   - `habits_list_page.dart`
   - `progress_dashboard.dart`

2. Or remove the real-time subscription in `supabase_service.dart`:
   - Comment out `_setupRealtimeSubscriptions()` call
