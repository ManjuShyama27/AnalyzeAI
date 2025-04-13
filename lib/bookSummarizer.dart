import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mime/mime.dart';

class BookSummarizer extends StatefulWidget {
  const BookSummarizer({super.key});

  @override
  State<BookSummarizer> createState() => _BookSummarizerState();
}

class _BookSummarizerState extends State<BookSummarizer> {
  final TextEditingController prompt = TextEditingController();
  bool isLoading = false;
  String API_KEY = "AIzaSyCsbYA-HcMLJCxoOF49QccvXUx6o8eXMJk";
  dynamic response;
  File? image;
  PlatformFile? file;

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
          "Book Summarizer",
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
              'Upload a book file (PDF, EPUB, TXT) and generate a concise summary of its content.',
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
                                  'Upload a book file',
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
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 300,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent[200],
                    foregroundColor: Colors.white,
                  ),
                  label: Text('Summarize Book', style: TextStyle(fontSize: 20)),
                  icon: Icon(Icons.bookmark, color: Colors.white, size: 23),
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
                        systemInstruction: Content.system(
                          '''You are a professional book summarizer. Summarize the following book content clearly and concisely, preserving the main ideas, themes, and key takeaways. Maintain the tone and style of the book. If it's fiction, highlight the plot, characters, and emotional arc. If it's non-fiction, focus on the core arguments, lessons, and practical insights.

Text: """[Insert book content here]"""

Output format:
1. Title:
2. Author:
3. Genre:
4. Summary:
5. Key Takeaways / Lessons:
6. Ideal For (who should read this book):
7. Memorable Quotes (optional):
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
                      });
                      print(response.text);
                    }
                  },
                ),
              ),
            ),
            SizedBox(
              height: 410,
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
