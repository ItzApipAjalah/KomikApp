import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../widgets/chapter_detail.dart'; // Import halaman detail chapter

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('history') ?? [];
    setState(() {
      _history = history
          .map((item) => json.decode(item) as Map<String, dynamic>)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reading History'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              await _clearHistory();
              // Refresh the screen
              _loadHistory();
            },
          ),
        ],
      ),
      body: _history.isEmpty
          ? Center(child: Text('No reading history.'))
          : ListView.builder(
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final chapter = _history[index];
                return ListTile(
                  leading: Image.network(
                    chapter['thumbnail'],
                    fit: BoxFit.cover,
                    width: 50,
                    height: 50,
                  ),
                  title: Text(chapter['title']),
                  subtitle: Text(chapter['comicTitle']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChapterDetail(endpoint: chapter['endpoint']),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      await _removeFromHistory(index);
                    },
                  ),
                );
              },
            ),
    );
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      _history = [];
    });
  }

  Future<void> _removeFromHistory(int index) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('history') ?? [];
    history.removeAt(index);
    await prefs.setStringList('history', history);
    _loadHistory();
  }
}
