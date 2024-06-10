import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gallery_picker/gallery_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  File ? selectedMedia;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Text Recognition" ),
      ),

      body: _buildUi(),

      floatingActionButton: FloatingActionButton(
        onPressed: ()async{
          List <MediaFile>? media = await GalleryPicker.pickMedia(
            context: context,
            singleMedia: true,
          );

          if(media != null && media.isNotEmpty){
            var data = await media.first.getFile();

            setState(() {
              selectedMedia = data;
            });

          }
        },
        child: const Icon(
          Icons.add
        ),
      ),
    );
  }
Widget _buildUi (){
  return Column(
    mainAxisSize: MainAxisSize.max,
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      _imageView(),
      _extractTextView()
    ],
  );
}


Widget _imageView (){
  if (selectedMedia == null) {
    print('\n||||||||||La valeur du selectedMedia est : ${selectedMedia}');
    return const Center(
      child: Text(
        "Pick an image for text recognition"
      ),
    );
  }
  return Center(
    child: Image.file(
      selectedMedia!,
      width: 200,
    ),
  );

}

Widget _extractTextView (){
  if (selectedMedia == null) {
    return const Center(
      child: Text("No result"),
    );
  }

  return FutureBuilder(
    future: _extractText(selectedMedia!), 
    builder: (context, snapshot) {
      return Text(
        snapshot.data ?? "",
        style: const TextStyle(
          fontSize: 25
        ),
      );
    }
  );
}

Future<String?>_extractText(File file) async{
  final textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin
  );
  final InputImage inputImage = InputImage.fromFile(file);
  final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

  String text = recognizedText.text;
  textRecognizer.close();

  return text;
}

}
