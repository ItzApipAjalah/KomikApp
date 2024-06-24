import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'chapter_detail.dart'; // Import halaman detail chapter
import 'package:shared_preferences/shared_preferences.dart';
import 'package:startapp_sdk/startapp.dart';

class ComicDetail extends StatefulWidget {
  final String endpoint;

  ComicDetail({required this.endpoint});

  @override
  _ComicDetailState createState() => _ComicDetailState();
}

class _ComicDetailState extends State<ComicDetail> {
  Map<String, dynamic>? _comicData;
  bool _isLoading = true;
  var startAppSdk = StartAppSdk();
  StartAppBannerAd? bannerAd;

  @override
  void initState() {
    super.initState();
    fetchComicDetail();
    loadBannerAd();
  }

  loadBannerAd() {
    // TODO make sure to comment out this line before release
    startAppSdk.setTestAdsEnabled(false);

    // TODO use one of the following types: BANNER, MREC, COVER
    startAppSdk.loadBannerAd(StartAppBannerType.BANNER).then((value) {
      setState(() {
        bannerAd = value;
      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");
    });
  }

  Future<void> fetchComicDetail() async {
    final response = await http.get(
        Uri.parse('https://api.amwp.website/komiku/comic/${widget.endpoint}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _comicData = data['data'];
        _isLoading = false;
      });
    } else {
      // Handle error
      throw Exception('Failed to load comic details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_comicData?['title'] ?? 'Loading...'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (bannerAd != null)
                    Center(child: StartAppBanner(bannerAd!)),
                  SizedBox(height: 20),
                  Center(
                    child: Image.network(
                      _comicData!['thumbnail'],
                      fit: BoxFit.cover,
                      height: 300,
                    ),
                  ),
                  if (bannerAd != null)
                    Center(child: StartAppBanner(bannerAd!)),
                  SizedBox(height: 20),
                  Text(
                    _comicData!['title'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    _comicData!['description'],
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Text('Status: ${_comicData!['status']}'),
                  Text('Type: ${_comicData!['type']}'),
                  Text('Released: ${_comicData!['released']}'),
                  Text('Last Updated: ${_comicData!['updated_at']}'),
                  SizedBox(height: 20),
                  Text(
                    'Genres',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 8.0,
                    children: _comicData!['genres']
                        .map<Widget>(
                            (genre) => Chip(label: Text(genre['title'])))
                        .toList(),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Chapters',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ..._comicData!['chapterList'].map<Widget>((chapter) {
                    return ListTile(
                      title: Text(chapter['title']),
                      subtitle: Text('Updated at: ${chapter['updated_at']}'),
                      onTap: () {
                        _addToHistory({
                          'title': chapter['title'],
                          'comicTitle': _comicData!['title'],
                          'thumbnail': _comicData!['thumbnail'],
                          'endpoint': chapter['endpoint']
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ChapterDetail(endpoint: chapter['endpoint']),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
    );
  }

  void _addToHistory(Map<String, dynamic> chapterData) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('history') ?? [];

    bool isDuplicate = history.any((item) {
      Map<String, dynamic> existingChapter = json.decode(item);
      return existingChapter['title'] == chapterData['title'];
    });

    if (!isDuplicate) {
      history.add(json.encode(chapterData));
      await prefs.setStringList('history', history);
    }
  }
}
