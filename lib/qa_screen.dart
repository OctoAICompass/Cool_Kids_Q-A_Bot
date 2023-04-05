import 'package:just_audio/just_audio.dart';
import 'package:kids_qa_bot/aws_service.dart';
import 'package:kids_qa_bot/pallete.dart';
import 'package:kids_qa_bot/settings.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:logging/logging.dart';

import 'openai_service.dart';

class QAScreen extends StatefulWidget {
  const QAScreen({super.key});

  @override
  State<QAScreen> createState() => _QAScreenState();
}

class _QAScreenState extends State<QAScreen> {
  final stt.SpeechToText _stt = stt.SpeechToText();
  String _question = 'Octonauts, what is your question?';
  String _answer = "Waiting for OctoAI bot's response";
  final Logger logger = Logger('MyLogger');
  bool _isListening = false;
  final OpenAIService openAIService = OpenAIService();
  final AWSService awsService = AWSService();
  Language selectedLanguage = Language.english;
  String _inputLocale = 'en-US';

  @override
  void initState() {
    super.initState();
    initSTT();
  }

  @override
  void dispose() {
    _stt.stop();
    super.dispose();
  }

  Future<void> initSTT() async {
    await _stt.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    setState(() {
      _isListening = true;
    });
    await _stt.listen(onResult: onSpeechResult, localeId: _inputLocale);
  }

  Future<void> stopListening() async {
    await _stt.stop();
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _question = result.recognizedWords;
    });
  }

  Future<void> generateResponseVoice() async {
    setState(() {
      _isListening = false;
    });
    print(_question);
    print("start generating answer from chatGPT");
    final result = await openAIService.chatGPTAPI(_question, selectedLanguage);
    print(result);
    setState(() {
      _answer = result;
    });

    print("start TTS");
    final audioUrl = await awsService.getTTSAudio(result, selectedLanguage);
    final player = AudioPlayer();
    await player.setUrl(audioUrl);
    player.play();
    await _stt.stop();
  }

  void micButtonPressed() async {
    if (await _stt.hasPermission && !_isListening) {
      await startListening();
    } else if (_isListening) {
      // await stopListening();
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
        // leading: const Icon(Icons.menu),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(padding: EdgeInsets.zero, children: <Widget>[
          DrawerHeader(
              decoration:
                  const BoxDecoration(color: Pallete.firstSuggestionBoxColor),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: const Text(
                  'Pick your language:',
                  style: TextStyle(fontSize: 25, fontFamily: 'Cera Pro'),
                ),
              )),
          ListTile(
            title: const Text('English'),
            onTap: () {
              setState(() {
                selectedLanguage = Language.english;
                _inputLocale = 'en-US';
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('中文'),
            onTap: () {
              setState(() {
                selectedLanguage = Language.chinese;
                _inputLocale = 'zh-CN';
              });
              Navigator.pop(context);
            },
          )
        ]),
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
                      image: AssetImage('assets/images/inkling.png'),
                    ),
                  ),
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
