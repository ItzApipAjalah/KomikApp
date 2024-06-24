import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'comic_detail.dart'; // Import halaman detail

class Manga extends StatefulWidget {
  @override
  _MangaState createState() => _MangaState();
}

class _MangaState extends State<Manga> {
  List<dynamic> _mangaComics = [];
  bool _isLoading = true;
  int _selectedPage = 1; // Halaman yang dipilih, default ke halaman pertama
  int _totalPages = 2; // Total halaman yang tersedia, sesuai dengan respons API

  @override
  void initState() {
    super.initState();
    fetchMangaComics(_selectedPage);
  }

  Future<void> fetchMangaComics(int page) async {
    final response = await http
        .get(Uri.parse('https://api.amwp.website/komiku/manga?page=$page'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _mangaComics = data['datas'];
        _isLoading = false;
      });
    } else {
      // Handle error
      throw Exception('Failed to load manga comics');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: [
            Text('Manga',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(width: 10),
            DropdownButton<int>(
              value: _selectedPage,
              items: List.generate(
                  _totalPages,
                  (index) => DropdownMenuItem<int>(
                      value: index + 1, child: Text('Page ${index + 1}'))),
              onChanged: (int? newValue) {
                setState(() {
                  _selectedPage = newValue!;
                  _isLoading =
                      true; // Set isLoading ke true saat memilih halaman baru
                });
                fetchMangaComics(
                    _selectedPage); // Panggil kembali fungsi fetch dengan halaman baru
              },
            ),
          ],
        ),
        SizedBox(height: 10),
        _isLoading
            ? Center(child: CircularProgressIndicator())
            : Container(
                height: 250,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _mangaComics.length,
                  itemBuilder: (context, index) {
                    final comic = _mangaComics[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ComicDetail(endpoint: comic['endpoint']),
                          ),
                        );
                      },
                      child: Container(
                        width: 150,
                        margin: EdgeInsets.only(right: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AspectRatio(
                              aspectRatio: 3 / 4,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  comic['thumbnail'],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              comic['title'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              comic['newest_chapter'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }
}
