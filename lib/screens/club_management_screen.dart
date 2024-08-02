import 'dart:io';
import 'package:campus_guide/bloc/admin_bloc.dart';
import 'package:campus_guide/models/clubs_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class ClubManagementScreen extends StatefulWidget {
  const ClubManagementScreen({super.key});

  @override
  State<ClubManagementScreen> createState() => _ClubManagementScreenState();
}

class _ClubManagementScreenState extends State<ClubManagementScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contactInfoController = TextEditingController();
  final List<Map<String, String>> _managementList = [];
  String _clubType = 'Genel';
  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminCubit()..getCurrentAdmin(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: const Text('Kulüp Yönetimi', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF007BFF),
          centerTitle: true,
        ),
        body: BlocBuilder<AdminCubit, AdminState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.error != null) {
              return Center(child: Text('Hata: ${state.error}'));
            }

            if (!state.isAdmin) {
              return const Center(child: Text('Yönetici yetkisi bulunamadı.'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNewClubSection(context, state),
                  const SizedBox(height: 20),
                  _buildMyClubsSection(context, state.clubs ?? []),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNewClubSection(BuildContext context, AdminState state) {
    if (state.clubs != null && state.clubs!.isNotEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFFFFC107)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _selectImage,
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey,
                  backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
                  child: _selectedImage == null
                      ? const Icon(Icons.add_a_photo, color: Colors.white)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text('Yeni Kulüp Oluştur', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
            const SizedBox(height: 10),
            _buildCustomButton(context, 'Kulüp Açıklamasını Ekle', _descriptionController, labelText: 'Kulüp Açıklaması'),
            _buildCustomButton(context, 'Yönetici Bilgilerini ekle', null, isManagement: true, labelText: 'Yönetici Bilgileri'),
            _buildCustomButton(context, 'İletişim Bilgilerini ekle', _contactInfoController, labelText: 'İletişim Bilgileri'),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () => _createClub(context),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: const Color(0xFF007BFF),
                ),
                child: const Text('Kulüp Oluştur'),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildMyClubsSection(BuildContext context, List<Club> clubs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: clubs.map((club) => _buildClubCard(context, club)).toList(),
    );
  }

  Widget _buildClubCard(BuildContext context, Club club) {
    return Column(
      children: [
        Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Color(0xFFFFC107)),
          ),
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Image.network(club.img, height: 70, width: 70),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(club.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildInfoChip(club.type, club.type == 'Özel' ? Colors.red : Colors.green, false),
                            const SizedBox(width: 10),
                            _buildInfoChip('${club.members} Üye', Colors.orange, false),
                            const SizedBox(width: 10),
                            _buildInfoChip('${club.events.length} Etkinlik', Colors.blue, false),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const Text("Kulüp Açıklaması:", style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF007BFF)),),
                    const SizedBox(height: 10),
                    Text(club.description),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Düzenle işlemi burada yapılacak
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: const Color(0xFF007BFF),
                          ),
                          child: const Text('Düzenle'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Silme işlemi burada yapılacak
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: Colors.red,
                          ),
                          child: const Text('Sil'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        _buildManagementCard(context, club),
        _buildContactInfoCard(context, club),
      ],
    );
  }

  Widget _buildManagementCard(BuildContext context, Club club) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFFFFC107)),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kulüp Yönetim Bilgileri', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF007BFF)),),
            const SizedBox(height: 10),
            Text(club.management.isNotEmpty ? '${club.management[0]['role']}: ${club.management[0]['name']}' : 'Bilgi Yok'),
            Text(club.management.length > 1 ? '${club.management[1]['role']}: ${club.management[1]['name']}' : 'Bilgi Yok'),
            Text(club.management.length > 2 ? '${club.management[2]['role']}: ${club.management[2]['name']}' : 'Bilgi Yok'),
            Text(club.management.length > 3 ? '${club.management[3]['role']}: ${club.management[3]['name']}' : 'Bilgi Yok'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Düzenle işlemi burada yapılacak
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: const Color(0xFF007BFF),
                  ),
                  child: const Text('Düzenle'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoCard(BuildContext context, Club club) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFFFFC107)),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('İletişim Bilgileri', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF007BFF)),),
            const SizedBox(height: 10),
            Text(club.contactInfo),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Düzenle işlemi burada yapılacak
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: const Color(0xFF007BFF),
                  ),
                  child: const Text('Düzenle'),
                ),
              ],
            ),
          ],
        ),
      ),
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

  Widget _buildCustomButton(BuildContext context, String label, TextEditingController? controller, {bool isManagement = false, String labelText = ''}) {
    String buttonText;

    if (isManagement && _managementList.isNotEmpty) {
      buttonText = _managementList.map((e) => '${e['role']}: ${e['name']}').join(', ');
    } else {
      buttonText = controller != null && controller.text.isNotEmpty ? controller.text : label;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ElevatedButton(
        onPressed: () {
          if (isManagement) {
            _addManagementRole();
          } else {
            _showInputDialog(context, labelText, controller);
          }
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black, backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFFFC107)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Align(
          alignment: Alignment.center,
          child: Text(buttonText, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }



  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _setClubType(String type) {
    setState(() {
      _clubType = type;
    });
  }

  void _showInputDialog(BuildContext context, String label, TextEditingController? controller) {
    final tempController = TextEditingController(text: controller?.text);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(label),
          content: TextField(
            controller: tempController,
            decoration: const InputDecoration(hintText: "Metin girin"),
            maxLines: null,
          ),
          actions: [
            TextButton(
              child: const Text("Tamam"),
              onPressed: () {
                setState(() {
                  if (controller != null) {
                    controller.text = tempController.text;
                  }
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  void _addManagementRole() {
    TextEditingController presidentController = TextEditingController();
    TextEditingController vicePresidentController = TextEditingController();
    TextEditingController secretaryController = TextEditingController();
    TextEditingController coordinatorController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Yönetici Bilgisi Ekle"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: presidentController,
                  decoration: const InputDecoration(hintText: "Başkan"),
                ),
                TextField(
                  controller: vicePresidentController,
                  decoration: const InputDecoration(hintText: "Başkan Yardımcısı"),
                ),
                TextField(
                  controller: secretaryController,
                  decoration: const InputDecoration(hintText: "Sekreter"),
                ),
                TextField(
                  controller: coordinatorController,
                  decoration: const InputDecoration(hintText: "Etkinlik Koordinatörü"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Tamam"),
              onPressed: () {
                setState(() {
                  _managementList.clear();
                  if (presidentController.text.isNotEmpty) {
                    _managementList.add({'role': 'Başkan', 'name': presidentController.text});
                  }
                  if (vicePresidentController.text.isNotEmpty) {
                    _managementList.add({'role': 'Başkan Yardımcısı', 'name': vicePresidentController.text});
                  }
                  if (secretaryController.text.isNotEmpty) {
                    _managementList.add({'role': 'Sekreter', 'name': secretaryController.text});
                  }
                  if (coordinatorController.text.isNotEmpty) {
                    _managementList.add({'role': 'Etkinlik Koordinatörü', 'name': coordinatorController.text});
                  }
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }



  Future<void> _createClub(BuildContext context) async {
    final adminCubit = context.read<AdminCubit>();

    if (_selectedImage != null) {
      String imageUrl = await _uploadImageToStorage(_selectedImage!);

      Club newClub = Club(
        id: '',
        title: 'Yeni Kulüp',
        description: _descriptionController.text,
        img: imageUrl,
        events: [],
        members: 0,
        type: _clubType,
        management: _managementList,
        contactInfo: _contactInfoController.text,
      );

      await adminCubit.addClub(newClub);
      _resetForm();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Center(
            child: Text('Lütfen Eksik Alan Bırakmayın.'),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<String> _uploadImageToStorage(File image) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageReference = FirebaseStorage.instance.ref().child('student_clubs/$fileName');
    UploadTask uploadTask = storageReference.putFile(image);
    TaskSnapshot storageTaskSnapshot = await uploadTask;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  void _resetForm() {
    setState(() {
      _descriptionController.clear();
      _contactInfoController.clear();
      _managementList.clear();
      _clubType = 'Genel';
      _selectedImage = null;
    });
  }
}
