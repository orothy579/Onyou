import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
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

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로드가 완료되었습니다! 기다려 주셔서 감사합니다!'))
    );
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
                try {
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
                Navigator.pop(context);
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
      appBar: AppBar(title: Text('Gallery'), automaticallyImplyLeading: false,),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
        padding: const EdgeInsets.all(4.0), // 전체 그리드에 패딩 추가
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 한 열당 사진 3개
          crossAxisSpacing: 4.0, // 수평 간격
          mainAxisSpacing: 4.0, // 수직 간격
          childAspectRatio: 1.0, // 자식의 너비-높이 비율을 1:1로 (정사각형)
        ),
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _showImageDialog(imageUrls[index]),
            child: Padding(
              padding: const EdgeInsets.all(2.0), // 각 사진에 패딩 추가
              child: Image.network(
                imageUrls[index],
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress){
                  if(loadingProgress == null) return child;
                  else{
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded/(loadingProgress.expectedTotalBytes ?? 1) : null,
                      ),
                    );
                  }
              },
                fit: BoxFit.cover, // 이미지가 정사각형 안에 꽉 차게
              ),
            ),
          );
        },
      ),
    );
  }
}
