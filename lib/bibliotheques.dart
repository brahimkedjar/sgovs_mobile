import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class FileItem {
  final int id;
  final String name;
  final String link;
  final String dateSaved;

  FileItem({
    required this.id,
    required this.name,
    required this.link,
    required this.dateSaved,
  });
}

class ParticipantLibraryPage extends StatefulWidget {
  @override
  _ParticipantLibraryPageState createState() => _ParticipantLibraryPageState();
}

class _ParticipantLibraryPageState extends State<ParticipantLibraryPage> {
  List<FileItem> _files = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getParticipantFiles();
  }

  Future<void> _getParticipantFiles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('participant_id') ?? 0;
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'http://regestrationrenion.atwebpages.com/fetch_files.php?participant_id=${userId}'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          _files = responseData
              .map((file) => FileItem(
                    id: int.parse(file['id']),
                    name: file['name'],
                    link: file['link'],
                    dateSaved: file['date_saved'],
                  ))
              .toList();
        });
      } else {
        throw Exception('Failed to load files');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openFileLink(String link) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: TextButton(onPressed: () { launch(link); },
          child: const Text("Download Link")),
          content: Text(
            link,
            style: const TextStyle(
              color: Colors.blue,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
           
          ],
        );
      },
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Participant Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final String? result = await showSearch(
                context: context,
                delegate: _SearchDelegate(_files),
              );
              if (result != null) {
                // Handle search result if needed
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _files.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            launch(_files[index].link);
                          },
                          child: Text(
                            _files[index].name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.file_download),
                        onPressed: () {
                          launch(_files[index].link);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    // Handle list item tap if needed
                  },
                );
              },
            ),
    );
  }
}

class _SearchDelegate extends SearchDelegate<String> {
  final List<FileItem> files;

  _SearchDelegate(this.files);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSuggestions(query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSuggestions(query);
  }

  Widget _buildSuggestions(String query) {
    final List<FileItem> suggestionList = query.isEmpty
        ? files
        : files
            .where(
                (file) => file.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestionList[index].name),
          onTap: () {
            close(context, suggestionList[index].name);
          },
        );
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ParticipantLibraryPage(),
  ));
}
