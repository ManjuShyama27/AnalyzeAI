import 'dart:convert';
import 'dart:io';

import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flip_card/controllers/flip_card_controllers.dart';
import 'package:flutter_flip_card/flipcard/flip_card.dart';
import 'package:flutter_flip_card/modal/flip_side.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mime/mime.dart';

class StudyCardGenerator extends StatefulWidget {
  const StudyCardGenerator({super.key});

  @override
  State<StudyCardGenerator> createState() => _StudyCardGeneratorState();
}

class _StudyCardGeneratorState extends State<StudyCardGenerator> {
  final TextEditingController prompt = TextEditingController();
  bool isLoading = false;
  String API_KEY = "AIzaSyCsbYA-HcMLJCxoOF49QccvXUx6o8eXMJk";
  dynamic response;
  File? image;
  PlatformFile? file;
  bool isFlashCard = true;
  final controller = FlipCardController();
  List<dynamic>? questions;
  List<dynamic>? flashcards;

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        file = result.files.single; // convert it to a Dart:io file
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Study Material Generator",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Upload your notes or textbook PDFs to create flashcards and study questions',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blueGrey,
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DottedBorder(
                dashPattern: [6, 3, 6, 3],
                color: Colors.grey,
                borderType: BorderType.RRect,
                radius: Radius.circular(12),
                padding: EdgeInsets.all(6),

                strokeWidth: 2,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  height: MediaQuery.of(context).size.height / 4.5,

                  child: GestureDetector(
                    onTap: () {
                      pickFile();
                    },
                    child:
                        file == null
                            ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.upload,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                                Text(
                                  'Upload Notes file',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  textAlign: TextAlign.center,
                                  'Drag and drop your file here, or\n click to browse',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.blueGrey,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            )
                            : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.file_upload_outlined,
                                  color: Colors.green,
                                  size: 60,
                                ),
                                Text(
                                  textAlign: TextAlign.center,
                                  'File Uploaded Successfully \n ${file!.name}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 10),
              child: CustomSlidingSegmentedControl<int>(
                innerPadding: EdgeInsets.all(5),
                initialValue: 1,
                children: {
                  1: Text(
                    'Flash Cards',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  2: Text(
                    'Study Questions',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                },
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
                thumbDecoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.black.withOpacity(.3),
                  //     blurRadius: 4.0,
                  //     spreadRadius: 1.0,
                  //     offset: Offset(0.0, 2.0),
                  //   ),
                  // ],
                ),
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInToLinear,
                onValueChanged: (v) {
                  if (v == 1) {
                    setState(() {
                      isFlashCard = true;
                    });
                  } else {
                    setState(() {
                      isFlashCard = false;
                    });
                  }
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 15.0),
              child: SizedBox(
                width: 320,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent[200],
                    foregroundColor: Colors.white,
                  ),
                  label: Text(
                    'Generate Study Materials',
                    style: TextStyle(fontSize: 20),
                  ),
                  icon: Icon(Icons.book, color: Colors.white, size: 20),
                  onPressed: () async {
                    if (file == null) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Select files')));
                    } else {
                      setState(() {
                        isLoading = true;
                      });

                      final model = GenerativeModel(
                        model: 'gemini-1.5-flash',
                        apiKey: API_KEY,
                        systemInstruction:
                            isFlashCard == true
                                ? Content.system(
                                  '''You are a brilliant teacher and memory coach. Based on the uploaded notes or documents, generate 3 smart study flashcards that help with concept retention. Flashcards should cover key definitions, formulas, concepts, and important points.

Output Format:
[["Question1","Answer1"],["Question1","Answer1"],["Question1","Answer1"]]
keep the answers 3 lines maximum
''',
                                )
                                : Content.system(
                                  '''You are a brilliant teacher and memory coach. Based on the uploaded notes or documents, generate 10 quiz questions. Quizzes should include a mix of MCQs, true/false, fill-in-the-blanks.

Output Format:
1. Topic Title:
2. Quiz Questions:
   - Q1: [Question]
   - Type: [MCQ/TF/Short]
   - Options (if applicable):
   - Correct Answer:
   - Explanation (optional)

''',
                                ),
                      );

                      response = await model.generateContent([
                        Content.multi([
                          DataPart(
                            lookupMimeType(file!.xFile.path) ??
                                'application/octet-stream',
                            await file!.xFile.readAsBytes(),
                          ),
                        ]),
                      ]);
                      setState(() {
                        isLoading = false;
                        String istra =
                            response.text.toString().split('json')[1];
                        String hil = istra.substring(0, istra.length - 4);
                        print(hil);
                        flashcards = json.decode(hil);
                      });
                      print(response.text);
                    }
                  },
                ),
              ),
            ),
            SizedBox(
              height: 350,
              child: SingleChildScrollView(
                child:
                    isLoading == true
                        ? Center(
                          child: CircularProgressIndicator(
                            color: Colors.deepOrange,
                          ),
                        )
                        : response == null
                        ? Text('')
                        : ListView.builder(
                          shrinkWrap: true,
                          itemCount: flashcards!.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: FlipCard(
                                animationDuration: const Duration(seconds: 1),
                                rotateSide: RotateSide.right,
                                onTapFlipping:
                                    true, //When enabled, the card will flip automatically when touched.
                                axis: FlipAxis.horizontal,
                                controller: controller,
                                frontWidget: Center(
                                  child: Container(
                                    color: const Color.fromARGB(
                                      255,
                                      238,
                                      224,
                                      218,
                                    ),
                                    height: 220,
                                    width: 320,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            "QUESTION ${index + 1}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 20,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Text(
                                            textAlign: TextAlign.center,
                                            flashcards![index][0],
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 18,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                backWidget: Center(
                                  child: Container(
                                    color: const Color.fromARGB(
                                      255,
                                      238,
                                      224,
                                      218,
                                    ),
                                    height: 220,
                                    width: 320,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            "Answer ${index + 1}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 20,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Text(
                                            flashcards![index][1],
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                // : Card(
                //   color: const Color.fromARGB(255, 238, 224, 218),
                //   child: Padding(
                //     padding: const EdgeInsets.symmetric(
                //       horizontal: 15.0,
                //       vertical: 10,
                //     ),
                //     child: Text(
                //       response.text,
                //       style: TextStyle(
                //         fontSize: 14,
                //         height: 2,
                //         fontWeight: FontWeight.w500,
                //       ),
                //     ),
                //   ),
                // ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
