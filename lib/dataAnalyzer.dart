import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mime/mime.dart';

class DataAnalyzer extends StatefulWidget {
  const DataAnalyzer({super.key});

  @override
  State<DataAnalyzer> createState() => _DataAnalyzerState();
}

class _DataAnalyzerState extends State<DataAnalyzer> {
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
          "Data Analyzer",
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
              'Upload a file and generate a concise analysis of its content.',
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
                                  'Upload File',
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
                  label: Text('Analyze Data', style: TextStyle(fontSize: 20)),
                  icon: Icon(Icons.table_chart, color: Colors.white, size: 23),
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
                          '''You are a professional data analyst. Analyze the uploaded file and provide a detailed report with key insights, trends, and any anomalies. Use charts and plain language to explain findings.
Output format:
1. File Type:
2. Summary of Data:
3. Key Findings & Insights:
4. Anomalies / Warnings:
5. Suggested Next Steps:
6. Additional Notes:
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
                        : Card(
                          color: const Color.fromARGB(255, 234, 203, 187),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              response.text,
                              style: TextStyle(fontSize: 14),
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
