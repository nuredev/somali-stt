import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
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
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;
  String _text = "Tap the mic and speak Somali";

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    setState(() => _text = "Initializing speech recognition...");
    bool available = await _speech.initialize(
      onStatus: (status) {
        print("Status: $status");
        if (status == "notListening") {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        print("Error: ${error.errorMsg}");
        setState(() {
          _text = "Speech Error: ${error.errorMsg}";
          _speechAvailable = false;
        });
      },
    );
    
    _speechAvailable = available;
    if (available) {
      setState(() => _text = "✅ Ready! Tap mic and speak Somali");
    } else {
      setState(() => _text = "❌ Speech recognition not available on this device");
    }
  }

  void _listen() async {
    if (!_speechAvailable) {
      setState(() => _text = "Speech recognition not available. Check Settings → Privacy → Speech Recognition");
      return;
    }

    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
    } else {
      setState(() {
        _isListening = true;
        _text = "🔴 Listening... Speak Somali";
      });
      _speech.listen(
        onResult: (result) => setState(() {
          _text = result.recognizedWords;
        }),
        listenFor: Duration(seconds: 10),
        pauseFor: Duration(seconds: 5),
        localeId: "so_SO",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Somali STT', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                size: 80,
                color: _isListening ? Colors.red : Colors.green,
              ),
              const SizedBox(height: 30),
              Text(
                _text,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _listen,
        backgroundColor: _isListening ? Colors.red : Colors.green,
        child: Icon(_isListening ? Icons.stop : Icons.mic, size: 35),
      ),
    );
  }
}
