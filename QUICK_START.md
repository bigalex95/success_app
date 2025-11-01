# Quick Start: Ollama Setup

## Installation Steps

Run these commands in your terminal:

### 1. Install Ollama

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

Or download manually from: https://ollama.com/download

### 2. Start Ollama Service

```bash
# Option A: Run in foreground (keep terminal open)
ollama serve

# Option B: Run as system service (recommended)
sudo systemctl start ollama
sudo systemctl enable ollama  # Auto-start on boot
```

### 3. Download the Model

The app uses `llama3.2` by default. Download it:

```bash
ollama pull llama3.2
```

**Note:** For faster performance on older hardware, use:
```bash
ollama pull llama3.2:1b    # Very small and fast
ollama pull llama3.2:3b     # Balanced
```

### 4. Verify Installation

```bash
# Check Ollama version
ollama --version

# List downloaded models
ollama list

# Test the model
ollama run llama3.2 "Say hello"
```

### 5. Test API Connection

```bash
curl http://localhost:11434/api/tags
```

This should return a JSON list of available models.

## App Configuration

The app is already configured to use:
- **URL:** `http://localhost:11434`
- **Model:** `llama3.2`

If you want to change the model, edit `lib/core/config/app_config.dart`:

```dart
static const String ollamaModel = 'llama3.2';  // Change to your preferred model
```

## Running the App

Once Ollama is running and a model is downloaded:

```bash
flutter pub get
flutter run
```

Navigate to the **Assistant** tab and start chatting!

## Troubleshooting

**Service not starting?**
```bash
sudo systemctl status ollama
sudo journalctl -u ollama -f
```

**Model not found?**
- Make sure you ran: `ollama pull llama3.2`
- Check available models: `ollama list`
- Verify model name in `app_config.dart` matches exactly

**Out of memory?**
- Try smaller model: `ollama pull llama3.2:1b`
- Update `app_config.dart` with the smaller model name

