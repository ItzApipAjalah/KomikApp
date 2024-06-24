import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shimmer/shimmer.dart';

class ChapterDetail extends StatefulWidget {
  final String endpoint;

  ChapterDetail({required this.endpoint});

  @override
  _ChapterDetailState createState() => _ChapterDetailState();
}

class _ChapterDetailState extends State<ChapterDetail> {
  List<String> _chapterImages = [];
  String _title = 'Loading...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChapterDetail();
  }

  Future<void> fetchChapterDetail() async {
    final response = await http.get(Uri.parse(
        'https://api.amwp.website/komiku/chapter/${widget.endpoint}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _chapterImages = List<String>.from(data['data']['chapters']);
        _title = data['data']['title'];
        _isLoading = false;
      });
    } else {
      // Handle error
      throw Exception('Failed to load chapter details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _chapterImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ChapterImage(
                    imageUrl: _chapterImages[index],
                  ),
                );
              },
            ),
    );
  }
}

class ChapterImage extends StatelessWidget {
  final String imageUrl;

  ChapterImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadImage(context, imageUrl),
      builder: (context, AsyncSnapshot<Image> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Container(
              height: 300,
              color: Colors.grey[200],
              child: Center(child: Text('Failed to load image')),
            );
          } else {
            return snapshot.data!;
          }
        } else {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 300,
              color: Colors.grey[300],
            ),
          );
        }
      },
    );
  }

  Future<Image> _loadImage(BuildContext context, String url) async {
    try {
      final image = Image.network(url);
      await precacheImage(image.image, context);
      return image;
    } catch (e) {
      throw Exception('Failed to load image');
    }
  }
}
