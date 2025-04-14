import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

class MathProblemSolver extends StatefulWidget {
  const MathProblemSolver({super.key});

  @override
  State<MathProblemSolver> createState() => _MathProblemSolverState();
}

class _MathProblemSolverState extends State<MathProblemSolver> {
  bool isLoading = false;
  String API_KEY = "YOUR_GEMINI_API_KEY";
  dynamic response;
  File? image;

  void picImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? img = await picker.pickImage(
      source: ImageSource.gallery, // alternatively, use ImageSource.gallery
      maxWidth: 400,
    );
    if (img == null) {
      return;
    } else {
      setState(() {
        image = File(img.path); // convert it to a Dart:io file
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
          "Math/Riddle Solver",
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
              'Solve Complex Math Problems or Riddles',
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
                  height: MediaQuery.of(context).size.height / 3.4,

                  child: GestureDetector(
                    onTap: () {
                      picImage();
                    },
                    child:
                        image == null
                            ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.upload,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                                Text(
                                  'Upload image',
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
                                Image.file(
                                  image!,
                                  width: MediaQuery.of(context).size.width - 40,
                                  height:
                                      MediaQuery.of(context).size.height / 3.4,
                                ),
                              ],
                            ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 300,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent[200],
                    foregroundColor: Colors.white,
                  ),
                  label: Text('Solve Problem', style: TextStyle(fontSize: 20)),
                  icon: Icon(Icons.calculate, color: Colors.white, size: 23),
                  onPressed: () async {
                    if (image == null) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Pick Image')));
                    } else {
                      setState(() {
                        isLoading = true;
                      });

                      final model = GenerativeModel(
                        model: 'gemini-1.5-flash',
                        apiKey: API_KEY,
                        systemInstruction: Content.system(
                          '''You are a brilliant mathematician and riddle master. Solve the following question or puzzle with clear, step-by-step logic and reasoning. If it’s a math problem, show all necessary calculations and formulas. If it’s a riddle, explain the logic behind the answer and any interesting insights.
Output format:
1. Problem Type: [Math / Riddle / Logic Puzzle / Word Puzzle]
2. Question:
3. Step-by-Step Solution:
4. Final Answer:
5. Explanation (for riddles):
6. Fun Fact or Related Trick (optional):
''',
                        ),
                      );

                      response = await model.generateContent([
                        Content.multi([
                          DataPart(
                            lookupMimeType(image!.path) ??
                                'application/octet-stream',
                            await image!.readAsBytes(),
                          ),
                        ]),
                      ]);
                      setState(() {
                        isLoading = false;
                      });
                      print(response.text);
                    }
                  },
                ),
              ),
            ),
            SizedBox(
              height: 345,
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
                        : Card(
                          color: const Color.fromARGB(255, 238, 224, 218),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15.0,
                              vertical: 10,
                            ),
                            child: Text(
                              response.text,
                              style: TextStyle(
                                fontSize: 14,
                                height: 2,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
