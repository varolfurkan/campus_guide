import 'package:campus_guide/bloc/admin_bloc.dart';
import 'package:campus_guide/bloc/user_bloc.dart';
import 'package:campus_guide/screens/digital_library.dart';
import 'package:campus_guide/screens/notification_screen.dart';
import 'package:campus_guide/screens/schedule_screen.dart';
import 'package:campus_guide/screens/student_clubs.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  bool isLoggedIn = false; // Kullanıcının giriş durumunu belirten değişken

  @override
  void initState() {
    super.initState();
    context.read<AdminCubit>().getNotifications();
  }

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
                  child: Text('Öne Çıkan Etkinlikler', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
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
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const StudentClubs()),
                      );
                    },
                    child: _buildGridItem('Öğrenci\nKulüpleri', FontAwesomeIcons.users),
                  ),
                  _buildGridItem('Kampüs\nHaritaları', FontAwesomeIcons.map),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SchedulePage()),
                      );
                    },
                    child: _buildGridItem('Ders\nProgramı', FontAwesomeIcons.book),
                  ),
                  _buildGridItem('Ulaşım\nİmkanları', FontAwesomeIcons.busSimple),
                  _buildGridItem('Mekan\nKeşfi', FontAwesomeIcons.utensils),
                  GestureDetector(
                    onTap: () {
                      if (isLoggedIn) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DigitalLibraryScreen()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Dijital Kütüphane erişimi için öncelikle giriş yapmanız ya da kayıt olmanız gerekmektedir.',
                            ),
                          ),
                        );
                      }
                    },
                    child: _buildGridItem('Dijital\nKütüphane', FontAwesomeIcons.landmark),
                  ),
                ],
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
        color: const Color(0xFFFFC107),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: FaIcon(icon, size: 35, color: Colors.black),
          ),
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
