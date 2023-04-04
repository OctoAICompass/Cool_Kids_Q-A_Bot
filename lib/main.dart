import 'dart:convert';
import 'config.dart';
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart' as tts;
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cool Q&A Bot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SpeechScreen(),
    );
  }
}

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({super.key});

  @override
  State<SpeechScreen> createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = 'Press the button and start speaking';
  String _result = "Waiting for Q&A bot's response";
  final tts.FlutterTts _tts = tts.FlutterTts();
  final Logger logger = Logger('MyLogger');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fun Kids Q&A Bot'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Theme.of(context).primaryColor,
        endRadius: 75.0,
        duration: const Duration(milliseconds: 2000),
        repeatPauseDuration: const Duration(milliseconds: 100),
        repeat: true,
        child: FloatingActionButton(
          onPressed: _listen,
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _text,
                style: const TextStyle(
                  fontSize: 32.0,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Divider(
                height: 20,
                thickness: 2,
                color: Colors.grey[400],
              ),
              Text(
                _result,
                style: const TextStyle(
                  fontSize: 32.0,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => logger.info('onStatus: $val'),
        onError: (val) => logger.info('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();

      String result = await _generateResponse(
          '$_text, can you answer that in 20 words, in a scientific and easy to understand way for preschool children?');
      setState(() => _result = result);

      await _tts.setLanguage('en-US');
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.5);
      await _tts.speak(result);
    }
  }

  Future<String> _generateResponse(String text) async {
    String model = 'text-davinci-003';
    String prompt = text;
    String url = 'https://api.openai.com/v1/engines/$model/completions';
    String data =
        json.encode({'prompt': prompt, 'temperature': 0.7, 'max_tokens': 1024});

    var response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $OPEN_AI_API_KEY'
      },
      body: data,
    );

    if (response.statusCode == 200) {
      var jsonResult = json.decode(response.body);
      var choices = jsonResult['choices'];
      if (choices != null && choices.isNotEmpty) {
        var text = choices.first['text'].toString().trim();
        return text;
      }
    } else {
      logger.warning(response.statusCode);
      logger.warning(response.body);
    }

    // Return null if something went wrong
    return 'Something went wrong';
  }
}
