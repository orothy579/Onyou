import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:image_downloader/image_downloader.dart';

class GalleryPage extends StatefulWidget {
  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  late List<String> imageUrls;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    imageUrls = [];
    _loadImages();
  }

  Future<void> _loadImages() async {
    final ListResult result = await FirebaseStorage.instance.ref('story/').listAll();

    List<String> urls = [];
    for (var ref in result.items) {
      String url = await ref.getDownloadURL();
      urls.add(url);
    }

    setState(() {
      imageUrls = urls;
      isLoading = false;
    });
  }

  _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Image.network(imageUrl),
          actions: [
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  // Download the image using the image_downloader package
                  await ImageDownloader.downloadImage(imageUrl);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Image downloaded!')),
                  );
                } catch (error) {
                  print(error);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to download image.')),
                  );
                }
              },
              child: Text("Save"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gallery')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _showImageDialog(imageUrls[index]),
            child: Image.network(imageUrls[index]),
          );
        },
      ),
    );
  }
}
