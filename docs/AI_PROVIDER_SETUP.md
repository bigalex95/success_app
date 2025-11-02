# AI Assistant Configuration Guide

This app supports multiple AI providers that you can easily switch between by editing the `.env` file.

## Supported Providers

### 1. Ollama (Local) - **Default**

- **Pros**: Free, private, runs offline, no API costs
- **Cons**: Requires local resources, slower on weak hardware
- **Setup**:
  ```env
  SLM_PROVIDER=ollama
  OLLAMA_BASE_URL=http://localhost:11434
  OLLAMA_MODEL=mistral:7b-instruct
  ```
- **Requirements**:
  - Install Ollama: `curl -fsSL https://ollama.com/install.sh | sh`
  - Pull model: `ollama pull mistral:7b-instruct`

### 2. Gemini (Google AI) - **Recommended for Production**

- **Pros**: Fast, intelligent, scalable, free tier available
- **Cons**: Requires internet, API key needed
- **Setup**:
  ```env
  SLM_PROVIDER=gemini
  GEMINI_API_KEY=your_api_key_here
  GEMINI_MODEL=gemini-1.5-flash
  ```
- **Get API Key**: https://aistudio.google.com/app/apikey
- **Available Models** (November 2025):
  - `gemini-2.5-flash` ⭐ **RECOMMENDED** - Latest, fastest, 10 RPM
  - `gemini-2.0-flash` - Stable, 15 RPM, 1M TPM
  - `gemini-2.0-flash-exp` - Experimental, 15 RPM
  - `gemini-2.5-pro` - Most capable, 2 RPM (rate limited)
- **Note**: Live API models (ending in `-live`) require WebSocket and are not supported yet

### 3. OpenAI/Other APIs

- **Setup**:
  ```env
  SLM_PROVIDER=api
  API_BASE_URL=https://api.openai.com
  API_KEY=your_openai_key
  ```

## Quick Switch Examples

### Use Local Ollama:

```env
SLM_PROVIDER=ollama
```

### Use Gemini API:

```env
SLM_PROVIDER=gemini
GEMINI_API_KEY=AIzaSy...
```

## After Changing Provider

1. Save the `.env` file
2. Hot restart your app (press `R` in terminal or restart)
3. Test with: "hi" (should respond naturally)

## Troubleshooting

### Ollama Issues:

- Check if running: `ollama list`
- Start service: `ollama serve`

### Gemini Issues:

- Verify API key is valid
- Check quota: https://console.cloud.google.com/

### General:

- Check console for error messages
- Verify `.env` is in project root
- Ensure no typos in provider name
