import 'package:analyzeai/AudioVideoMinutes.dart';
import 'package:analyzeai/ImageStoryteller.dart';
import 'package:analyzeai/ObjectIdentifier.dart';
import 'package:analyzeai/RecipeSuggester.dart';
import 'package:analyzeai/StudyCardGenerator.dart';
import 'package:analyzeai/bookSummarizer.dart';
import 'package:analyzeai/dashboard.dart';
import 'package:analyzeai/dataAnalyzer.dart';
import 'package:analyzeai/mathSolver.dart';
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
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Dashboard(),
      initialRoute: '/',
      routes: {
        '/bookSummarizer': (context) => BookSummarizer(),
        '/mathSolver': (context) => MathProblemSolver(),
        '/objectIdentifier': (context) => ObjectIdentifier(),
        '/recipeSuggester': (context) => RecipeSuggester(),
        '/studyCardGenerator': (context) => StudyCardGenerator(),
        '/imageStoryTeller': (context) => ImageStoryTeller(),
        '/audioVideoMinutes': (context) => AudioVideoMinutes(),
        '/dataAnalyzer': (context) => DataAnalyzer(),
      },
    );
  }
}
