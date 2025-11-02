# Environment Variables Setup

This app uses environment variables to securely store API keys and configuration. This prevents sensitive data from being committed to Git.

## Quick Start

1. **Copy the example file:**
   ```bash
   cp .env.example .env
   ```

2. **Edit `.env` with your actual keys:**
   ```env
   SUPABASE_URL=your_actual_url_here
   SUPABASE_ANON_KEY=your_actual_key_here
   ```

3. **Run the app:**
   ```bash
   flutter pub get
   flutter run
   ```

## Security Notes

✅ **`.env` is in `.gitignore`** - Your secrets won't be committed to Git  
✅ **`.env.example` is committed** - This is the template for other developers  
✅ **Never commit `.env`** - Always keep it local  

⚠️ **Production Security Warning:**
- The `.env` file is bundled in the app as an asset (for development convenience)
- For production apps, consider using:
  - Build-time environment variables (CI/CD secrets)
  - Platform-specific secure storage
  - Server-side configuration
  - Or remove `.env` from `pubspec.yaml` assets and load from filesystem only

## Environment Variables

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `SUPABASE_URL` | Your Supabase project URL | Yes | - |
| `SUPABASE_ANON_KEY` | Your Supabase anon/public key | Yes | - |
| `USE_SUPABASE` | Enable/disable Supabase | No | `true` |
| `OLLAMA_BASE_URL` | Local Ollama server URL | No | `http://localhost:11434` |
| `OLLAMA_MODEL` | Ollama model to use | No | `llama3.2` |
| `API_BASE_URL` | External API URL (future use) | No | - |
| `API_KEY` | External API key (future use) | No | - |

## For Team Development

When working in a team:

1. **New developers:** Copy `.env.example` to `.env` and add their keys
2. **Never share `.env` files** - Use secure channels (e.g., password managers, encrypted messages)
3. **Production:** Use your hosting platform's environment variable settings (e.g., GitHub Secrets, Vercel, etc.)

## Troubleshooting

### "Could not load .env file" warning
- Make sure `.env` exists in the project root (same folder as `pubspec.yaml`)
- Check file permissions - it should be readable

### "Supabase URL not configured" error
- Make sure `SUPABASE_URL` is set in `.env`
- Make sure the value is not `YOUR_SUPABASE_URL` or empty
- Restart the app after editing `.env`

### App still uses old values
- Restart the app completely (hot reload doesn't reload `.env`)
- Make sure there are no typos in variable names
- Check that `.env` is in the project root, not in a subdirectory

