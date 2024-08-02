import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DigitalLibraryScreen extends StatefulWidget {
  @override
  _DigitalLibraryScreenState createState() => _DigitalLibraryScreenState();
}

class _DigitalLibraryScreenState extends State<DigitalLibraryScreen> {
  final TextEditingController _titleController = TextEditingController();
  String? _selectedCourse;
  File? _selectedFile;
  List<Map<String, dynamic>> uploadedNotes = [];
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadNote() async {
    if (_selectedFile != null && _titleController.text.isNotEmpty && _selectedCourse != null) {
      String fileName = _selectedFile!.path.split('/').last;
      String destination = 'notes/$fileName';

      try {
        final ref = FirebaseStorage.instance.ref(destination);
        await ref.putFile(_selectedFile!);
        String downloadUrl = await ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('notes').add({
          'title': _titleController.text,
          'course': _selectedCourse!,
          'url': downloadUrl,
          'timestamp': FieldValue.serverTimestamp(),
        });

        setState(() {
          _selectedFile = null;
        });

        _titleController.clear();
        _selectedCourse = null;

        _fetchNotes(); // Refresh notes list
      } catch (e) {
        print('Error: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tüm alanları doldurun ve bir dosya seçin.'),
        ),
      );
    }
  }

  Future<void> _fetchNotes() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('notes')
        .orderBy('timestamp', descending: true)
        .limit(3)
        .get();

    setState(() {
      uploadedNotes = snapshot.docs.map((doc) => {
        'title': doc['title'],
        'course': doc['course'],
        'url': doc['url'],
        'timestamp': doc['timestamp'],
        'document': doc, // Add the document snapshot to use later
      }).toList();
    });
  }

  Future<void> _loadMoreNotes() async {
    if (_loadingMore) return;

    setState(() {
      _loadingMore = true;
    });

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('notes')
        .orderBy('timestamp', descending: true)
        .startAfterDocument(uploadedNotes.last['document'] as DocumentSnapshot)
        .limit(3)
        .get();

    setState(() {
      uploadedNotes.addAll(snapshot.docs.map((doc) => {
        'title': doc['title'],
        'course': doc['course'],
        'url': doc['url'],
        'timestamp': doc['timestamp'],
        'document': doc, // Add the document snapshot to use later
      }).toList());
      _loadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Dijital Kütüphane', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF007BFF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF007BFF)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Not Yükle'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Not Başlığı',
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    value: _selectedCourse,
                    hint: const Text('Dersi Seç'),
                    items: <String>['Matematik', 'Fizik']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCourse = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: ElevatedButton(
                      onPressed: _pickFile,
                      child: const Text('Dosya Seç'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _selectedFile != null
                      ? Text('Seçilen Dosya: ${_selectedFile!.path.split('/').last}')
                      : const Text('Dosya seçilmedi'),
                  const SizedBox(height: 10),
                  Center(
                    child: ElevatedButton(
                      onPressed: _uploadNote,
                      child: const Text('Yükle'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Son Yüklenen Notlar'),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: uploadedNotes.length + 1,
                itemBuilder: (context, index) {
                  if (index == uploadedNotes.length) {
                    return _loadingMore
                        ? const Center(child: CircularProgressIndicator())
                        : TextButton(
                      onPressed: _loadMoreNotes,
                      child: const Text('Daha Fazla Göster'),
                    );
                  }

                  final note = uploadedNotes[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade300,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text('${note['title']!}.pdf'),
                    subtitle: Text(note['course']!),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(FontAwesomeIcons.heart),
                        const SizedBox(width: 10),
                        const Icon(FontAwesomeIcons.bookmark),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(FontAwesomeIcons.download),
                          onPressed: () {
                            // PDF indirme işlemi
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
