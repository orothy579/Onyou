import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class GalleryPage extends StatefulWidget {
  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  late List<String> imageUrls;

  @override
  void initState() {
    super.initState();
    imageUrls = []; // Initialize empty list
    _loadImages();
  }

  Future<void> _loadImages() async {
    // Fetch image URLs from Firebase Storage
    // This is just a sample path, your paths may differ.
    final ListResult result = await FirebaseStorage.instance.ref('images/').listAll();

    List<String> urls = [];
    for (var ref in result.items) {
      String url = await ref.getDownloadURL();
      urls.add(url);
    }

    setState(() {
      imageUrls = urls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gallery')),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Image.network(imageUrls[index]);
        },
      ),
    );
  }
}
