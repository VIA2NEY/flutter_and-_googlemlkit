import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gallery_picker/gallery_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';


class ImageLabelingPage extends StatefulWidget {
  const ImageLabelingPage({super.key});

  @override
  State<ImageLabelingPage> createState() => _ImageLabelingPageState();
}

class _ImageLabelingPageState extends State<ImageLabelingPage> {
  File? selectedMedia;
  List<ImageLabel>? _labels;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image Labeling"),
      ),
      body: _buildUi(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          List<MediaFile>? media = await GalleryPicker.pickMedia(
            context: context,
            singleMedia: true,
          );

          if (media != null && media.isNotEmpty) {
            var data = await media.first.getFile();

            setState(() {
              selectedMedia = data;
              _labels = null; // Reset labels when a new image is picked
            });

            await _labelImage(data);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildUi() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _imageView(),
        _labelResultView(),
      ],
    );
  }

  Widget _imageView() {
    if (selectedMedia == null) {
      return const Center(
        child: Text("Pick an image for labeling"),
      );
    }
    return Center(
      child: Image.file(
        selectedMedia!,
        width: 200,
      ),
    );
  }

  Widget _labelResultView() {
    if (_labels == null) {
      return const Center(
        child: Text("No labels detected"),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: _labels?.length ?? 0,
        itemBuilder: (context, index) {
          final label = _labels![index];
          return ListTile(
            title: Text(label.label),
            subtitle: Text('Confidence: ${label.confidence.toStringAsFixed(2)}'),
          );
        },
      ),
    );
  }

  Future<void> _labelImage(File image) async {
    final inputImage = InputImage.fromFile(image);
    final imageLabeler = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.5));
    final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);

    setState(() {
      _labels = labels;
    });

    imageLabeler.close();
  }
  


}

