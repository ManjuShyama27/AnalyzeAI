import 'package:analyzeai/bookSummarizer.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<List<dynamic>> analyzers = [
    [
      'Book Summarizer',
      'Upload Books or Text to generate concise summary',
      Icons.bookmark_add,
      '/bookSummarizer',
    ],
    [
      'Math/Riddles Solver',
      'Solve Complex math problems/riddles step by step',
      Icons.calculate,
      '/mathSolver',
    ],
    [
      'Object Identifier',
      'Upload images to identify objects and get detailed information',
      Icons.remove_red_eye,
      '/objectIdentifier',
    ],
    [
      'Recipe Suggester',
      'Get recipe ideas from food images or ingredients list',
      Icons.food_bank,
      '/recipeSuggester',
    ],
    [
      'Study Card Generator',
      'Create flashcards and study questions from your pdf notes',
      Icons.card_membership,
      '/studyCardGenerator',
    ],
    [
      'Image StoryTeller',
      'Turn any image into a creative story with AI',
      Icons.video_camera_back,
      '/imageStoryTeller',
    ],
    [
      'Audio/Video Minutes',
      'Extract minutes and keypoints from recordings',
      Icons.audio_file,
      '/audioVideoMinutes',
    ],
    // [
    //   'Data Analyzer',
    //   'Analyze and assess data',
    //   Icons.table_chart,
    //   '/dataAnalyzer',
    // ],
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Analyze AI',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height - 20,
                child: GridView.count(
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                  crossAxisCount: 2,
                  children: List.generate(analyzers.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        // Navigator.of(context).push(
                        //   MaterialPageRoute(
                        //     builder: (context) => BookSummarizer(),
                        //   ),
                        // );
                        Navigator.pushNamed(context, analyzers[index][3]);
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          side: BorderSide(color: Colors.deepOrangeAccent),
                        ),
                        elevation: 1,
                        shadowColor: Colors.grey,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(analyzers[index][2]),
                              Text(
                                analyzers[index][0],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                analyzers[index][1],
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.blueGrey,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
