import 'package:campus_guide/bloc/admin_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventManagementScreen extends StatefulWidget {
  const EventManagementScreen({super.key});

  @override
  _EventManagementScreenState createState() => _EventManagementScreenState();
}

class _EventManagementScreenState extends State<EventManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  String? _selectedClubId;
  String? _eventTitle;
  String? _eventDate;
  String? _eventLocation;
  String? _eventDescription;
  List<Map<String, dynamic>> _events = [];
  String _clubType = 'Genel';

  @override
  void initState() {
    super.initState();
    _loadEvents();
    context.read<AdminCubit>().getCurrentAdmin();
  }

  Future<void> _loadEvents() async {
    try {
      String? adminUid = BlocProvider.of<AdminCubit>(context).state.firebaseUser?.uid;
      if (adminUid != null) {
        DocumentSnapshot clubSnapshot = await _firestore.collection('student_clubs').doc(adminUid).get();
        if (clubSnapshot.exists) {
          setState(() {
            _events = List<Map<String, dynamic>>.from((clubSnapshot.data() as Map<String, dynamic>)['events'] ?? []);
            _selectedClubId = adminUid;
          });
        }
      }
    } catch (e) {
      print('Error loading events: $e');
    }
  }

  Future<void> _addEvent() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      try {
        String? adminName = BlocProvider.of<AdminCubit>(context).state.adminName;
        if (_selectedClubId != null && adminName != null) {
          Map<String, dynamic> newEvent = {
            'date': _eventDate,
            'location': _eventLocation,
            'description': _eventDescription,
            'type': _clubType,
            'clubName': adminName,
            'event_title': _eventTitle,
          };

          await _firestore.collection('student_clubs').doc(_selectedClubId).update({
            'events': FieldValue.arrayUnion([newEvent]),
          });

          setState(() {
            _events.add(newEvent);
          });

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Etkinlik başarıyla oluşturuldu')));
        }
      } catch (e) {
        print('Error adding event: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Etkinlik oluşturulamadı: $e')));
      }
    }
  }

  Future<void> _deleteEvent(Map<String, dynamic> event) async {
    try {
      if (_selectedClubId != null) {
        await _firestore.collection('student_clubs').doc(_selectedClubId).update({
          'events': FieldValue.arrayRemove([event]),
        });

        setState(() {
          _events.remove(event);
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Etkinlik başarıyla silindi')));
      }
    } catch (e) {
      print('Error deleting event: $e');
    }
  }

  Future<void> _editEvent(Map<String, dynamic> event) async {
    // Implement event edit functionality here
  }

  Widget _buildEventList() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _events.length,
      itemBuilder: (context, index) {
        var event = _events[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: const BorderSide(color: Color(0xFFFFC107), width: 2),
          ),
          child: ListTile(
            title: Text(event['event_title'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tarih: ${event['date']}',
                    style: const TextStyle(fontWeight: FontWeight.bold)
                ),
                Text('Konum: ${event['location'] ?? 'Belirtilmedi'}',
                    style: const TextStyle(fontWeight: FontWeight.bold)
                ),
              ],
            ),
            trailing: Wrap(
              spacing: 8.0,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editEvent(event),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteEvent(event),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(String label, Color color, bool isSelected) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(color: isSelected ? Colors.white : color),
      ),
      backgroundColor: isSelected ? color : Colors.transparent,
      shape: StadiumBorder(side: BorderSide(color: color)),
    );
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
        title: const Text('Etkinlik Yönetimi', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF007BFF),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadEvents,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Yeni Etkinlik Ekle',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _setClubType('Genel'),
                            child: _buildInfoChip('Genel', Colors.green, _clubType == 'Genel'),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => _setClubType('Özel'),
                            child: _buildInfoChip('Özel', Colors.red, _clubType == 'Özel'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Etkinlik Adı',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFFFC107), width: 2),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFFFC107), width: 2),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen etkinlik adı girin';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _eventTitle = value;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Etkinlik Tarihi',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFFFC107), width: 2),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFFFC107), width: 2),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen etkinlik tarihi girin';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _eventDate = value;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Etkinlik Konumu',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFFFC107), width: 2),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFFFC107), width: 2),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onSaved: (value) {
                        _eventLocation = value;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Etkinlik Tanımı',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFFFC107), width: 2),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFFFC107), width: 2),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onSaved: (value) {
                        _eventDescription = value;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _addEvent,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: const Color(0xFF007BFF),
                      ),
                      child: const Text('Etkinlik Oluştur'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Mevcut Etkinlikler',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 23)),
              const SizedBox(height: 10,),
              _buildEventList(),
            ],
          ),
        ),
      ),
    );
  }
  void _setClubType(String type) {
    setState(() {
      _clubType = type;
    });
  }
}
