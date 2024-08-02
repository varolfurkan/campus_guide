import 'package:campus_guide/bloc/admin_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationManagementScreen extends StatefulWidget {
  const NotificationManagementScreen({super.key});

  @override
  _NotificationManagementScreenState createState() => _NotificationManagementScreenState();
}

class _NotificationManagementScreenState extends State<NotificationManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  String? _notificationTitle;
  String? _notificationDescription;
  List<Map<String, dynamic>> _notifications = [];
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadAdminNotifications();
      context.read<AdminCubit>().getCurrentAdmin();
  }

  Future<void> _loadAdminNotifications() async {
    try {
      String? adminUid = BlocProvider.of<AdminCubit>(context).state.firebaseUser?.uid;
      if (adminUid != null) {
        List<Map<String, dynamic>> notifications = await BlocProvider.of<AdminCubit>(context).getAdminNotifications(adminUid);
        setState(() {
          _notifications = notifications;
          _isAdmin = true;
        });
      }
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }

  Future<void> _addNotification() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      try {
        String? adminUid = BlocProvider.of<AdminCubit>(context).state.firebaseUser?.uid;
        String? adminName = BlocProvider.of<AdminCubit>(context).state.adminName;

        if (adminUid != null && adminName != null) {
          Map<String, dynamic> newNotification = {
            'notification_title': _notificationTitle,
            'notification_description': _notificationDescription,
            'clubName': adminName,
            'adminUid': adminUid,
          };

          await BlocProvider.of<AdminCubit>(context).addNotification(newNotification);

          setState(() {
            _notifications.add(newNotification);
          });

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Duyuru başarıyla oluşturuldu')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Admin bilgileri eksik')));
        }
      } catch (e) {
        print('Error adding notification: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Duyuru oluşturulamadı: $e')));
      }
    }
  }


  Future<void> _deleteNotification(Map<String, dynamic> notification) async {
    try {
      String notificationId = notification['documentId'];

      await _firestore.collection('notifications').doc(notificationId).delete();

      setState(() {
        _notifications.remove(notification);
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Duyuru başarıyla silindi')));
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }


  Future<void> _editNotification(Map<String, dynamic> notification) async {
    // Implement notification edit functionality here
  }

  Widget _buildNotificationList() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        var notification = _notifications[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: const BorderSide(color: Color(0xFFFFC107), width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification['notification_title'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kulüp Adı: ${notification['clubName']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Duyuru Metni: ${notification['notification_description'] ?? 'Belirtilmedi'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => _editNotification(notification),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: const Color(0xFF007BFF),
                      ),
                      child: const Text('Düzenle'),
                    ),
                    ElevatedButton(
                      onPressed: () => _deleteNotification(notification),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.red,
                      ),
                      child: const Text('Sil'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
        title: const Text('Duyuru Yönetimi', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF007BFF),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadAdminNotifications,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Yeni Duyuru Ekle',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        labelText: 'Duyuru Metni Adı',
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
                          return 'Lütfen duyuru metni girin';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _notificationTitle = value;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Duyuru Açıklaması',
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
                          return 'Lütfen duyuru açıklaması girin';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _notificationDescription = value;
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _addNotification,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: const Color(0xFF007BFF),
                      ),
                      child: const Text('Duyuru Oluştur'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Mevcut Duyurular',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23)),
              const SizedBox(height: 10,),
              _buildNotificationList(),
            ],
          ),
        ),
      ),
    );
  }
}
