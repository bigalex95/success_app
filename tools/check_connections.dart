import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Small script to check connectivity to Ollama and Supabase without starting the full app.
///
/// Usage (from project root):
///   OLLAMA_BASE_URL=http://localhost:11434 SUPABASE_URL=https://xxx.supabase.co SUPABASE_ANON_KEY=yourkey dart run tools/check_connections.dart
/// Or simply:
///   CHECK_VERBOSE=1 dart run tools/check_connections.dart
/// when you have a .env file in the project root.

const _defaultOllamaUrl = 'http://localhost:11434';
const _defaultOllamaModel = 'llama3.2';

bool get _isVerbose => Platform.environment['CHECK_VERBOSE'] == '1';

void _v(String msg) {
  if (_isVerbose) stdout.writeln(msg);
}

String _maskIfSecret(String key, String value) {
  final k = key.toLowerCase();
  if (k.contains('key') ||
      k.contains('secret') ||
      k.contains('token') ||
      k.contains('anon')) {
    return '(hidden)';
  }
  return value;
}

Future<String?> _readEnvVar(String key) async {
  // 1) Process environment
  final env = Platform.environment[key];
  if (env != null && env.isNotEmpty) return env;

  // 2) .env files
  final candidates = ['.env', '.env.local', '.env.example'];
  for (final name in candidates) {
    final envFile = File(name);
    if (!await envFile.exists()) continue;

    final lines = await envFile.readAsLines();
    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty || line.startsWith('#')) continue;

      if (line.startsWith('export ')) {
        line = line.substring(7).trim();
      }

      final idx = line.indexOf('=');
      if (idx <= 0) continue;
      final k = line.substring(0, idx).trim();
      var v = line.substring(idx + 1).trim();

      // Remove optional surrounding quotes
      if (v.length >= 2 && v.startsWith('"') && v.endsWith('"')) {
        v = v.substring(1, v.length - 1);
      } else if (v.length >= 2 && v.startsWith('\'') && v.endsWith('\'')) {
        v = v.substring(1, v.length - 1);
      }

      if (k == key) {
        _v('Loaded $key from $name: ${_maskIfSecret(key, v)}');
        return v;
      }
    }
  }
  return null;
}

String _normalizeBase(String baseUrl) {
  // Drop any trailing slash for consistent path joining
  if (baseUrl.endsWith('/')) return baseUrl.substring(0, baseUrl.length - 1);
  return baseUrl;
}

Uri _buildEndpoint(String baseUrl, String path) {
  // baseUrl is expected normalized (no trailing slash)
  final base = Uri.parse(baseUrl);
  final basePath = base.path.endsWith('/')
      ? base.path.substring(0, base.path.length - 1)
      : base.path;
  final finalPath = (basePath.isEmpty ? '' : basePath) + path;
  return base.replace(path: finalPath);
}

Future<bool> _ollamaGenerate(Uri target, String model,
    {Duration requestTimeout = const Duration(seconds: 20)}) async {
  final body = jsonEncode({
    'model': model,
    'prompt': 'Test connection from project check script',
    'stream': false,
    'options': {
      'num_predict': 8,
      'temperature': 0.0,
    },
  });

  final client = HttpClient();
  client.connectionTimeout = const Duration(seconds: 3);
  try {
    final request = await client.postUrl(target);
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set(HttpHeaders.connectionHeader, 'close');
    final bytes = utf8.encode(body);
    request.contentLength = bytes.length;
    request.add(bytes);
    final response = await request.close().timeout(requestTimeout);
    final status = response.statusCode;
    final respBody = await response.transform(utf8.decoder).join();
    if (_isVerbose) {
      _v('Ollama /api/generate -> HTTP $status');
    }
    if (status == 200) {
      try {
        final data = jsonDecode(respBody);
        if (data is Map &&
            (data['response'] != null || data['choices'] != null)) {
          stdout.writeln('Ollama: OK (200, response looks valid)');
          return true;
        }
      } catch (_) {
        stdout.writeln('Ollama: OK (200, non-JSON body)');
        return true;
      }
      stdout.writeln('Ollama: OK (200)');
      return true;
    } else {
      stdout.writeln('Ollama: /api/generate failed - HTTP $status');
      if (_isVerbose) stdout.writeln('Body: $respBody');
      return false;
    }
  } on TimeoutException {
    stdout.writeln('Ollama: /api/generate timed out');
    return false;
  } on SocketException catch (e) {
    stdout.writeln('Ollama: /api/generate socket error - ${e.message}');
    return false;
  } catch (e) {
    stdout.writeln('Ollama: /api/generate error - ${e.runtimeType}: $e');
    return false;
  } finally {
    client.close(force: true);
  }
}

Future<bool> _ollamaChat(Uri target, String model,
    {Duration requestTimeout = const Duration(seconds: 20)}) async {
  final body = jsonEncode({
    'model': model,
    'messages': [
      {'role': 'user', 'content': 'Hello from connection check'}
    ],
    'stream': false,
    'options': {
      'num_predict': 8,
      'temperature': 0.0,
    },
  });
  final client = HttpClient();
  client.connectionTimeout = const Duration(seconds: 3);
  try {
    final request = await client.postUrl(target);
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set(HttpHeaders.connectionHeader, 'close');
    final bytes = utf8.encode(body);
    request.contentLength = bytes.length;
    request.add(bytes);
    final response = await request.close().timeout(requestTimeout);
    final status = response.statusCode;
    final respBody = await response.transform(utf8.decoder).join();
    if (_isVerbose) {
      _v('Ollama /api/chat -> HTTP $status');
    }
    if (status == 200) {
      stdout.writeln('Ollama (chat): OK (200)');
      return true;
    } else {
      stdout.writeln('Ollama (chat): Failed - HTTP $status');
      if (_isVerbose) stdout.writeln('Body: $respBody');
      return false;
    }
  } on TimeoutException {
    stdout.writeln('Ollama (chat): timed out');
    return false;
  } on SocketException catch (e) {
    stdout.writeln('Ollama (chat): socket error - ${e.message}');
    return false;
  } catch (e) {
    stdout.writeln('Ollama (chat): error - ${e.runtimeType}: $e');
    return false;
  } finally {
    client.close(force: true);
  }
}

Future<bool> checkOllama(String baseUrl, String model) async {
  final normalized = _normalizeBase(baseUrl);

  // Optional quick probes
  try {
    final tagsUri = _buildEndpoint(normalized, '/api/tags');
    final resp = await http.get(tagsUri).timeout(const Duration(seconds: 4));
    if (resp.statusCode == 200) {
      _v('Ollama: /api/tags reachable (200)');
    } else {
      _v('Ollama: /api/tags HTTP ${resp.statusCode}');
    }
  } catch (e) {
    _v('Ollama: /api/tags probe error: $e');
  }
  try {
    final rootResp = await http
        .get(Uri.parse(normalized))
        .timeout(const Duration(seconds: 4));
    _v('Ollama: GET $normalized -> HTTP ${rootResp.statusCode}');
  } catch (e) {
    _v('Ollama: GET $normalized probe error: $e');
  }

  // Main generate attempt
  final genUri = _buildEndpoint(normalized, '/api/generate');
  if (await _ollamaGenerate(genUri, model)) return true;

  // If host is localhost, retry via 127.0.0.1
  final parsed = Uri.parse(normalized);
  if (parsed.host == 'localhost') {
    final alt = parsed.replace(host: '127.0.0.1');
    final altBase = alt.toString().endsWith('/')
        ? alt.toString().substring(0, alt.toString().length - 1)
        : alt.toString();
    stdout.writeln('Ollama: Retrying via 127.0.0.1 ...');
    final altGen = _buildEndpoint(altBase, '/api/generate');
    if (await _ollamaGenerate(altGen, model)) return true;
  }

  // Fallback to chat
  final chatUri = _buildEndpoint(normalized, '/api/chat');
  if (await _ollamaChat(chatUri, model)) return true;

  // Try chat via 127.0.0.1 if applicable
  if (parsed.host == 'localhost') {
    final alt = parsed.replace(host: '127.0.0.1');
    final altBase = alt.toString().endsWith('/')
        ? alt.toString().substring(0, alt.toString().length - 1)
        : alt.toString();
    final altChat = _buildEndpoint(altBase, '/api/chat');
    return await _ollamaChat(altChat, model);
  }

  return false;
}

Future<bool> checkSupabase(String supabaseUrl, String? anonKey) async {
  try {
    final normalized = _normalizeBase(supabaseUrl);

    // Basic reachability check to the Supabase host
    final hostUri = Uri.parse(normalized);
    final respHost =
        await http.get(hostUri).timeout(const Duration(seconds: 6));
    if (respHost.statusCode < 200 || respHost.statusCode >= 400) {
      stdout.writeln(
          'Supabase host reachable but returned HTTP ${respHost.statusCode}');
    } else {
      stdout.writeln('Supabase host reachable (HTTP ${respHost.statusCode})');
    }

    // If we have an anon key, try a minimal REST request to PostgREST endpoint to check auth/headers.
    if (anonKey != null && anonKey.isNotEmpty) {
      final restUri = _buildEndpoint(normalized, '/rest/v1');
      final headers = {
        'apikey': anonKey,
        'Authorization': 'Bearer $anonKey',
        'Accept': 'application/json',
      };
      final resp = await http
          .get(restUri, headers: headers)
          .timeout(const Duration(seconds: 6));
      if (resp.statusCode == 200 ||
          resp.statusCode == 401 ||
          resp.statusCode == 403 ||
          resp.statusCode == 404) {
        stdout.writeln(
            'Supabase REST endpoint reachable (HTTP ${resp.statusCode})');
        return true;
      } else {
        stdout
            .writeln('Supabase REST request failed (HTTP ${resp.statusCode})');
        if (_isVerbose) stdout.writeln('Body: ${resp.body}');
        return false;
      }
    } else {
      // No anon key provided; consider the host reachability sufficient for a basic test
      stdout.writeln(
          'No SUPABASE_ANON_KEY provided; host reachability checked only.');
      return respHost.statusCode >= 200 && respHost.statusCode < 400;
    }
  } on Exception catch (e) {
    stdout.writeln('Supabase: Error - ${e.runtimeType}: ${e.toString()}');
    return false;
  }
}

Future<void> main() async {
  stdout.writeln('Checking connections...');

  final envOllama = (await _readEnvVar('OLLAMA_BASE_URL')) ?? _defaultOllamaUrl;
  final envModel = (await _readEnvVar('OLLAMA_MODEL')) ?? _defaultOllamaModel;
  final supabaseUrl = await _readEnvVar('SUPABASE_URL');
  final supabaseAnon = await _readEnvVar('SUPABASE_ANON_KEY');

  stdout.writeln('Ollama base URL: $envOllama');
  stdout.writeln('Ollama model: $envModel');
  stdout.writeln('Supabase URL: ${supabaseUrl ?? "(not set)"}');
  stdout.writeln(
      'Supabase anon key: ${supabaseAnon != null ? "(set)" : "(not set)"}');
  stdout.writeln('');

  final results = <String, bool>{};

  stdout.writeln('-> Testing Ollama...');
  final okOllama = await checkOllama(envOllama, envModel);
  results['ollama'] = okOllama;

  stdout.writeln('');
  stdout.writeln('-> Testing Supabase...');
  if (supabaseUrl == null || supabaseUrl.isEmpty) {
    stdout.writeln(
        'Supabase: SUPABASE_URL is not set in the environment or .env file — skipping Supabase checks.');
    results['supabase'] = false;
  } else {
    final okSupabase = await checkSupabase(supabaseUrl, supabaseAnon);
    results['supabase'] = okSupabase;
  }

  stdout.writeln('\nSummary:');
  results.forEach(
      (k, v) => stdout.writeln(' - ${k.padRight(8)} : ${v ? 'OK' : 'FAIL'}'));

  final allOk = results.values.every((v) => v == true);
  if (!allOk) {
    stdout.writeln('\nOne or more checks failed. Exit code 1.');
    exit(1);
  } else {
    stdout.writeln('\nAll checks passed. Exit code 0.');
    exit(0);
  }
}
