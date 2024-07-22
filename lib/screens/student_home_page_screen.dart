import 'package:campus_guide/bloc/user_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
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
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(FontAwesomeIcons.bell, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
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
                  _buildGridItem('Ders\nProgramı', FontAwesomeIcons.book),
                  _buildGridItem('Dijital\nKütüphane', FontAwesomeIcons.landmark),
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
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Yeni Eklenen Ders Notları', style: TextStyle(fontWeight: FontWeight.bold),)),
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey.shade300,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                title: const Text('Kullanıcı Adı'),
                subtitle: const Text('Saat\nCalculus1.pdf'),
                trailing: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FontAwesomeIcons.heart),
                    SizedBox(width: 10),
                    Icon(FontAwesomeIcons.bookmark),
                    SizedBox(width: 10),
                    Icon(FontAwesomeIcons.download),
                  ],
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
