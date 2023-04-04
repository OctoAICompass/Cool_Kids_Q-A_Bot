import 'package:kids_qa_bot/pallete.dart';
import 'package:kids_qa_bot/qa_screen.dart';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OctoAI Q&A Bot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true)
          .copyWith(scaffoldBackgroundColor: Pallete.whiteColor),
      home: const QAScreen(),
    );
  }
}
