import 'package:campus_guide/bloc/admin_bloc.dart';
import 'package:campus_guide/bloc/user_bloc.dart';
import 'package:campus_guide/screens/digital_library.dart';
import 'package:campus_guide/screens/notification_screen.dart';
import 'package:campus_guide/screens/schedule_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StudentHomePageScreen extends StatefulWidget {
  const StudentHomePageScreen({super.key});

  @override
  State<StudentHomePageScreen> createState() => _StudentHomePageScreenState();
}

class _StudentHomePageScreenState extends State<StudentHomePageScreen> {
  int _currentIndex = 0;
  List<Map<String, dynamic>> uploadedNotes = [];
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
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

  final List<String> imgList = [
    'img/homepage_slider/ornek_slider.png',
    'img/homepage_slider/ornek_slider2.png',
    'img/homepage_slider/ornek_slider3.png',
    'img/homepage_slider/ornek_slider4.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            context.read<UserCubit>().navigateToProfile(context);
          },
          child: const Icon(FontAwesomeIcons.user, color: Colors.white),
        ),
        title: const Text('Kampüs Rehberi', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF007BFF),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: BlocBuilder<AdminCubit, AdminState>(
              builder: (context, state) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(FontAwesomeIcons.bell, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NotificationScreen()),
                        );
                        context.read<AdminCubit>().getNotifications();
                      },
                    ),
                    if (state.unreadNotificationCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            state.unreadNotificationCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Kampüs Rehberi\'nde Ara',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Kampüs Haberleri', style: TextStyle(fontWeight: FontWeight.bold),)),
              ),
              CarouselSlider(
                options: CarouselOptions(
                  viewportFraction: 1.0,
                  height: 180.0,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                items: imgList.map((i) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          image: DecorationImage(
                            image: AssetImage(i),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: imgList.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () => setState(() {
                      _currentIndex = entry.key;
                    }),
                    child: Container(
                      width: 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey
                            : Colors.black)
                            .withOpacity(_currentIndex == entry.key ? 0.9 : 0.4),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Kısayollar', style: TextStyle(fontWeight: FontWeight.bold),)),
              ),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildGridItem('Öğrenci\nKulüpleri', FontAwesomeIcons.users),
                  _buildGridItem('Haritalar', FontAwesomeIcons.map),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SchedulePage()),
                      );
                    },
                    child:
                    _buildGridItem('Ders\nProgramı', FontAwesomeIcons.book),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DigitalLibraryScreen()),
                      );
                    },
                    child: _buildGridItem('Dijital\nKütüphane', FontAwesomeIcons.landmark),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Öne Çıkan Etkinlikler', style: TextStyle(fontWeight: FontWeight.bold),)),
              ),
              Container(
                height: 180.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  image: const DecorationImage(
                    image: AssetImage('img/homepage_slider/ornek_slider4.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Takip Edilen Kulüplerin Duyuruları', style: TextStyle(fontWeight: FontWeight.bold),)),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Henüz eklenen bir duyuru bulunmamaktadır. Yeni kulüpleri incelemek için Öğrenci Kulüpleri sayfasına göz atmaya ne dersin!', style: TextStyle(fontStyle: FontStyle.italic),)),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Yeni Değerlendirmeler', style: TextStyle(fontWeight: FontWeight.bold),)),
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey.shade300,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                title: const Text('A Kişisi'),
                subtitle: const Text('XYZ Kulüphanesi\nKütüphane bakımlı ve geniş bir kitap koleksiyonuna sahip.'),
                trailing: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.yellow),
                    Text('4.5'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Son Yüklenen Notlar', style: TextStyle(fontWeight: FontWeight.bold),),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
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
      ),
    );
  }

  Widget _buildGridItem(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.orange),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(icon, size: 30, color: Colors.black),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

