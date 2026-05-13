import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_parser/http_parser.dart';

void main() async {
  await dotenv.load(fileName: "assets/.env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Somali STT',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  bool _isProcessing = false;
  String _text = "App is ready. Tap the mic.";
  String _apiKey = '';

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
    if (_apiKey.isNotEmpty) _text = "✅ Groq API Ready. Tap mic.";
  }

  void _initRecorder() async {
    await _recorder.openRecorder();
  }

  Future<void> _startRecording() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/recording.wav';

      await _recorder.startRecorder(
        toFile: path,
        codec: Codec.pcm16WAV,
        sampleRate: 16000,
        numChannels: 1,
      );
      
      setState(() {
        _isRecording = true;
        _text = "🔴 Recording... (5 seconds)";
      });

      await Future.delayed(const Duration(seconds: 5));

      final recordedPath = await _recorder.stopRecorder();
      setState(() {
        _isRecording = false;
        _isProcessing = true;
        _text = "🔄 Sending to Groq API...";
      });

      if (recordedPath != null) {
        await _sendToGroq(recordedPath);
      } else {
        setState(() => _text = "Error: Could not save recording.");
      }
    } catch (e) {
      setState(() => _text = "Error: ${e.toString()}");
      _isRecording = false;
      _isProcessing = false;
    }
  }

  Future<void> _sendToGroq(String filePath) async {
    try {
      File audioFile = File(filePath);
      
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.groq.com/openai/v1/audio/transcriptions'),
      );
      
      request.headers['Authorization'] = 'Bearer $_apiKey';
      
      // Add the audio file
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          filePath,
          contentType: MediaType('audio', 'wav'),
        ),
      );
      
      // Add other fields
      request.fields['model'] = 'whisper-large-v3-turbo';
      request.fields['language'] = 'so';
      request.fields['response_format'] = 'json';
      
      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _text = "🎤 Somali: ${data['text']}";
          _isProcessing = false;
        });
      } else {
        setState(() {
          _text = "API Error ${response.statusCode}";
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        _text = "Network Error: ${e.toString()}";
        _isProcessing = false;
      });
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Somali STT'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isRecording ? Icons.mic : Icons.mic_none,
                size: 80,
                color: _isRecording ? Colors.red : Colors.green,
              ),
              const SizedBox(height: 30),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    _text,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_apiKey.isNotEmpty)
                const Text("✅ Groq API Ready", style: TextStyle(color: Colors.green)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (_isRecording || _isProcessing) ? null : _startRecording,
        backgroundColor: _isRecording ? Colors.red : Colors.green,
        child: Icon(_isRecording ? Icons.stop : Icons.mic),
      ),
    );
  }
}
