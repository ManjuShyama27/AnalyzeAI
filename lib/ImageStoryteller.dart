import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

class ImageStoryTeller extends StatefulWidget {
  const ImageStoryTeller({super.key});

  @override
  State<ImageStoryTeller> createState() => _ImageStoryTellerState();
}

class _ImageStoryTellerState extends State<ImageStoryTeller> {
  bool isLoading = false;
  String API_KEY = "AIzaSyCsbYA-HcMLJCxoOF49QccvXUx6o8eXMJk";
  dynamic response;
  File? image;
  var type = [
    "Adventure",
    "Romance",
    "Mystery",
    "Fantasy",
    "Horror",
    "Science Fiction",
  ];
  var tone = ["emotional", "funny", "serious"];
  var length = ["short paragraph", "3-minute read", "500 words"];
  var typeVal = "Adventure";
  var toneVal = "funny";
  var lengthVal = "500 words";

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
          "Image Story Teller",
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
              'Upload an image and let AI create a captivating story based on what it sees',
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
                  height: MediaQuery.of(context).size.height / 3.5,

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
                                      MediaQuery.of(context).size.height / 3.5,
                                ),
                              ],
                            ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton(
                  dropdownColor: Colors.deepOrange[100],
                  focusColor: Colors.deepOrange[100],
                  value: typeVal,
                  onChanged: (newValue) {
                    setState(() {
                      typeVal = newValue!;
                    });
                  },
                  items:
                      type.map((lang) {
                        return DropdownMenuItem(value: lang, child: Text(lang));
                      }).toList(),
                ),

                DropdownButton(
                  dropdownColor: Colors.deepOrange[100],
                  focusColor: Colors.deepOrange[100],
                  value: lengthVal,
                  onChanged: (newValue) {
                    setState(() {
                      lengthVal = newValue!;
                    });
                  },
                  items:
                      length.map((lang) {
                        return DropdownMenuItem(value: lang, child: Text(lang));
                      }).toList(),
                ),
                DropdownButton(
                  dropdownColor: Colors.deepOrange[100],
                  focusColor: Colors.deepOrange[100],
                  value: toneVal,
                  onChanged: (newValue) {
                    setState(() {
                      toneVal = newValue!;
                    });
                  },
                  items:
                      tone.map((lang) {
                        return DropdownMenuItem(value: lang, child: Text(lang));
                      }).toList(),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 300,
                height: 40,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent[200],
                    foregroundColor: Colors.white,
                  ),
                  label: Text('Generate Story', style: TextStyle(fontSize: 19)),
                  icon: Icon(Icons.book, color: Colors.white, size: 21),
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
                          '''You are a master storyteller. Look at the image and create a compelling story inspired by what you see. Include characters, setting, emotions, and a narrative arc. You can be imaginative — it's okay to create a fantasy or fictional story based on visual clues. Tailor the tone depending on the audience (e.g., kids, adults, dark, motivational, humorous).
 - Story Type:$typeVal 
 - Length: $lengthVal
 - Tone: $toneVal
Output format:
1. Title:
2. Genre:
3. Story:
4. Moral / Message (optional):
5. Characters Introduced:
6. Possible Continuation (optional):
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
              height: 340,
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
