import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'comic_detail.dart'; // Import halaman detail

class LastUpdate extends StatefulWidget {
  @override
  _LastUpdateState createState() => _LastUpdateState();
}

class _LastUpdateState extends State<LastUpdate> {
  List<dynamic> _updates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLastUpdates();
  }

  Future<void> fetchLastUpdates() async {
    final response =
        await http.get(Uri.parse('https://api.amwp.website/komiku/updated'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _updates = data['datas'];
        _isLoading = false;
      });
    } else {
      // Handle error
      throw Exception('Failed to load updates');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Last Update',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        _isLoading
            ? Center(child: CircularProgressIndicator())
            : Container(
                height:
                    250, // Meningkatkan tinggi untuk menampilkan gambar dan teks dengan baik
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _updates.length,
                  itemBuilder: (context, index) {
                    final update = _updates[index];
                    final lastChapter = update['chapters'].first;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ComicDetail(endpoint: update['endpoint']),
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
                              aspectRatio: 3 / 4, // Menjaga rasio aspek gambar
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    8.0), // Membuat gambar dengan sudut melengkung
                                child: Image.network(
                                  update['thumbnail'],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              update['title'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${lastChapter['title']} - ${lastChapter['updated_at']}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
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
