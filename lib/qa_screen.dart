import 'package:kids_qa_bot/pallete.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart' as tts;
import 'package:logging/logging.dart';

import 'openai_service.dart';

class QAScreen extends StatefulWidget {
  const QAScreen({super.key});

  @override
  State<QAScreen> createState() => _QAScreenState();
}

class _QAScreenState extends State<QAScreen> {
  final stt.SpeechToText _stt = stt.SpeechToText();
  bool _isListening = false;
  String _question = 'Octonauts, what is your question?';
  String _answer = "Waiting for OctoAI bot's response";
  final tts.FlutterTts _tts = tts.FlutterTts();
  final Logger logger = Logger('MyLogger');
  final OpenAIService openAIService = OpenAIService();

  @override
  void initState() {
    super.initState();
    initSTT();
  }

  @override
  void dispose() {
    super.dispose();
    _stt.stop();
  }

  Future<void> initSTT() async {
    await _stt.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await _stt.listen(onResult: onSpeechResult);
    setState(() {
      _answer = "Waiting for OctoAI bot's response";
      _isListening = true;
    });
  }

  Future<void> stopListening() async {
    await _stt.stop();
    setState(() {
      _isListening = false;
    });
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _question = result.recognizedWords;
    });
  }

  Future<void> generateResponseVoice() async {
    final result = await openAIService.chatGPTAPI(_question);
    setState(() => _answer = result);

    await _tts.setLanguage('en-US');
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);
    await _tts.speak(result);
  }

  void micButtonPressed() async {
    if (await _stt.hasPermission && _stt.isNotListening) {
      await startListening();
    } else if (_stt.isListening) {
      await stopListening();
      await generateResponseVoice();
    } else {
      await initSTT();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fun Kids Q&A Bot'),
        leading: const Icon(Icons.menu),
        centerTitle: true,
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
          onPressed: micButtonPressed,
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Assistant profile
            Stack(
              children: [
                Center(
                  child: Container(
                    height: 120,
                    width: 120,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                      color: Pallete.assistantCircleColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Container(
                  height: 123,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: AssetImage(
                              'assets/images/virtualAssistant.png'))),
                )
              ],
            ),
            // Question bubble
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              margin: const EdgeInsets.only(left: 40, right: 40, top: 30),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Pallete.borderColor,
                ),
                borderRadius:
                    BorderRadius.circular(20).copyWith(topLeft: Radius.zero),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  _question,
                  style: const TextStyle(
                      color: Pallete.mainFontColor,
                      fontSize: 25,
                      fontFamily: 'Cera Pro'),
                ),
              ),
            ),
            // Answer bubble
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              margin: const EdgeInsets.only(left: 40, right: 40, top: 30),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Pallete.borderColor,
                ),
                borderRadius: BorderRadius.circular(20)
                    .copyWith(bottomRight: Radius.zero),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  _answer,
                  style: const TextStyle(
                      color: Pallete.mainFontColor,
                      fontSize: 25,
                      fontFamily: 'Cera Pro'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
