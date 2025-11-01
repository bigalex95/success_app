# Supabase Setup Guide

This app uses **Supabase** as the database backend, which works across all platforms:
- ✅ Web
- ✅ Android
- ✅ iOS
- ✅ Linux
- ✅ Windows
- ✅ macOS

## Quick Setup (5 minutes)

### Step 1: Create a Supabase Account
1. Go to [https://app.supabase.com](https://app.supabase.com)
2. Sign up for a free account (no credit card required)
3. Create a new project
   - Choose a name (e.g., "success-app")
   - Choose a database password (save this!)
   - Select a region closest to you
   - Wait 2-3 minutes for setup to complete

### Step 2: Get Your API Keys
1. In your Supabase project dashboard, go to **Settings** → **API**
2. Copy the following:
   - **Project URL** (starts with `https://`)
   - **anon public** key (long string)

### Step 3: Configure the App with Environment Variables
1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```
2. Open `.env` file (in the project root)
3. Replace the placeholders with your actual values:
   ```env
   SUPABASE_URL=https://abcdefghijklmnop.supabase.co
   SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   USE_SUPABASE=true
   ```
   
   **Important:** 
   - The `.env` file is already in `.gitignore` - your secrets are safe!
   - Never commit `.env` to Git - only commit `.env.example`
   - The app will automatically load these values at startup

### Step 4: Set Up Database Tables
1. In Supabase dashboard, go to **SQL Editor**
2. Click **New Query**
3. Copy and paste the entire contents of `supabase_setup.sql`
4. Click **Run** (or press Ctrl+Enter)
5. You should see "Success. No rows returned"

### Step 5: Run the App
```bash
flutter pub get
flutter run
```

That's it! Your app is now connected to Supabase.

## Free Tier Limits

Supabase free tier includes:
- ✅ 500 MB database storage
- ✅ 2 GB bandwidth per month
- ✅ 500 MB file storage
- ✅ 50,000 monthly active users
- ✅ Real-time subscriptions

**This is more than enough for personal use and testing!**

## Troubleshooting

### "Supabase not initialized" error
- Make sure you've created a `.env` file from `.env.example`
- Make sure you've added your actual Supabase URL and key in the `.env` file
- Check that your Supabase project is active (not paused)

### "relation does not exist" error
- Make sure you ran the SQL setup script (`supabase_setup.sql`) in Supabase SQL Editor

### Connection issues
- Check your internet connection
- Verify the Supabase URL and key are correct
- Check Supabase dashboard to see if your project is active

## Next Steps

### For Production:
1. **Enable Authentication** (optional):
   - Go to Authentication → Settings in Supabase
   - Set up email/password or OAuth providers
   - Update app to require login

2. **Set up Row Level Security (RLS)**:
   - The SQL script includes basic RLS
   - For multi-user apps, add `user_id` column to tables
   - Update policies to restrict access per user

3. **Backup**:
   - Supabase automatically backs up your database
   - Export data from Settings → Database

### Multi-Platform Deployment:
Once configured, your app will work on:
- Web: `flutter run -d chrome`
- Android: Build APK or publish to Play Store
- iOS: Build and publish to App Store
- Linux: `flutter run -d linux`
- Windows: `flutter run -d windows`
- macOS: `flutter run -d macos`

All using the same Supabase backend! 🎉

