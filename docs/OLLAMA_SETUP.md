# Ollama Setup Guide for Success App

This guide will help you install and configure Ollama to use with the Success Habit Tracking App.

## 1. Installation on Linux

### Option A: Using the Official Install Script (Recommended)

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

This script will:
- Download and install Ollama
- Set up the Ollama service
- Add Ollama to your PATH

### Option B: Manual Installation

1. Download the Linux package from [ollama.com/download](https://ollama.com/download)
2. Extract and install:
   ```bash
   # For .deb package (Debian/Ubuntu)
   sudo dpkg -i ollama*.deb
   
   # For .rpm package (Fedora/RHEL)
   sudo rpm -i ollama*.rpm
   ```

### Option C: Using Snap

```bash
sudo snap install ollama
```

## 2. Verify Installation

Check if Ollama is installed and running:

```bash
ollama --version
```

You should see output like: `ollama version is 0.x.x`

## 3. Start Ollama Service

Ollama runs as a service. Start it with:

```bash
# Start the service
ollama serve

# Or if installed via systemd (most installations):
sudo systemctl start ollama
sudo systemctl enable ollama  # Enable auto-start on boot
```

**Note:** If you run `ollama serve` in the foreground, keep the terminal open. The service runs on `http://localhost:11434` by default.

## 4. Download a Model

The app is configured to use `llama3.2` by default. Download it:

```bash
# Download the default model (llama3.2)
ollama pull llama3.2

# Or download a smaller/faster variant:
ollama pull llama3.2:1b    # 1 billion parameters (fastest)
ollama pull llama3.2:3b    # 3 billion parameters (balanced)
ollama pull llama3.2       # Default size (usually 3b or larger)
```

### Other Recommended Models

You can also try other models that work well for chat:

```bash
# Lightweight options
ollama pull phi3:mini        # Very small, fast
ollama pull gemma2:2b         # Google's Gemma 2B

# Balanced options
ollama pull llama3.1:8b       # Llama 3.1 with 8B parameters
ollama pull mistral:7b       # Mistral 7B

# High quality (slower, requires more RAM)
ollama pull llama3.1:70b     # Large model (requires 40GB+ RAM)
```

After downloading, verify the model:

```bash
ollama list
```

## 5. Test Ollama

Test that Ollama is working:

```bash
# Test with a simple query
ollama run llama3.2 "Say hello"

# Or test the API directly
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2",
  "prompt": "Hello, how are you?",
  "stream": false
}'
```

## 6. Configure the App

The app's configuration is in `lib/core/config/app_config.dart`. The default settings should work:

```dart
static const String ollamaBaseUrl = 'http://localhost:11434';
static const String ollamaModel = 'llama3.2';
```

### Change the Model

If you want to use a different model:

1. Edit `lib/core/config/app_config.dart`
2. Change `ollamaModel` to your preferred model:
   ```dart
   static const String ollamaModel = 'phi3:mini';  // or any model you downloaded
   ```

### Change the Server URL

If Ollama is running on a different machine or port:

```dart
static const String ollamaBaseUrl = 'http://your-server-ip:11434';
```

## 7. Testing with the App

1. Make sure Ollama is running:
   ```bash
   curl http://localhost:11434/api/tags
   ```
   This should return a JSON list of available models.

2. Run your Flutter app:
   ```bash
   flutter run
   ```

3. Navigate to the "Assistant" tab in the app
4. Try asking a question like "How can I build better habits?"

## 8. Troubleshooting

### Ollama service not running
```bash
# Check status
sudo systemctl status ollama

# Start it
sudo systemctl start ollama

# Check logs
sudo journalctl -u ollama -f
```

### Model not found
- Make sure you've downloaded the model: `ollama pull llama3.2`
- Verify models: `ollama list`
- Check the model name matches exactly in `app_config.dart`

### Connection refused
- Ensure Ollama is running: `ollama serve` or `sudo systemctl status ollama`
- Check if port 11434 is accessible: `curl http://localhost:11434/api/tags`
- Check firewall settings if using remote server

### Out of memory
- Try a smaller model (e.g., `llama3.2:1b` or `phi3:mini`)
- Close other applications
- Check available RAM: `free -h`

### Performance Tips
- Use smaller models (1b-3b) for faster responses
- Enable GPU acceleration if you have an NVIDIA GPU (Ollama auto-detects CUDA)
- For better quality, use larger models (7b-8b) but expect slower responses

## 9. Running Ollama on a Remote Server (Optional)

If you want to run Ollama on a different machine:

1. Start Ollama with host binding:
   ```bash
   OLLAMA_HOST=0.0.0.0:11434 ollama serve
   ```

2. Update `app_config.dart`:
   ```dart
   static const String ollamaBaseUrl = 'http://your-server-ip:11434';
   ```

3. Configure firewall to allow port 11434

**Security Note:** Exposing Ollama to the network makes it accessible to anyone. Consider adding authentication or using a VPN/tunnel.

## Quick Start Summary

```bash
# 1. Install
curl -fsSL https://ollama.com/install.sh | sh

# 2. Start service
ollama serve &
# OR
sudo systemctl start ollama

# 3. Download model
ollama pull llama3.2

# 4. Test
ollama run llama3.2 "Hello"

# 5. Run your Flutter app
flutter run
```

That's it! Your app should now be able to communicate with Ollama.

