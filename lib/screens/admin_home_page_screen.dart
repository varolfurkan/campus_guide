import 'package:campus_guide/bloc/admin_bloc.dart';
import 'package:campus_guide/screens/club_management_screen.dart';
import 'package:campus_guide/screens/event_management_screen.dart';
import 'package:campus_guide/screens/notification_management_screen.dart';
import 'package:campus_guide/screens/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminHomePageScreen extends StatefulWidget {
  const AdminHomePageScreen({super.key});

  @override
  State<AdminHomePageScreen> createState() => _AdminHomePageScreenState();
}

class _AdminHomePageScreenState extends State<AdminHomePageScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminCubit>().getNotifications();
  }
  final List<String> managementTools = [
    'Kulüp Yönetimi',
    'Etkinlik Yönetimi',
    'Duyurular',
  ];

  final List<String> studentTools = [
    'Forum',
    'Kampüs Haritaları',
    'Ders Programı',
    'Dijital Kütüphane',
    'AI Mentor',
    'Etkinlik Takvimi',
  ];

  final List<String> managementIcons = [
    'img/admin_page_icon/kulup_yonetimi.png',
    'img/admin_page_icon/etkinlik_yonetimi.png',
    'img/admin_page_icon/duyurular.png',
  ];

  final List<String> studentIcons = [
    'img/admin_page_icon/forum.png',
    'img/admin_page_icon/kampus_haritalari.png',
    'img/admin_page_icon/ders_programi.png',
    'img/admin_page_icon/dijital_kutuphane.png',
    'img/admin_page_icon/ai_mentor.png',
    'img/admin_page_icon/etkinlik_takvimi.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            context.read<AdminCubit>().navigateToProfile(context);
          },
          child: const Icon(FontAwesomeIcons.user, color: Colors.white),
        ),
        title: const Text('Kampüs Rehberi Admin', style: TextStyle(color: Colors.white)),
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
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text('Yönetim Araçları', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: managementTools.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      if (managementTools[index] == 'Kulüp Yönetimi') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ClubManagementScreen()),
                        );
                      } else if (managementTools[index] == 'Etkinlik Yönetimi') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EventManagementScreen()),
                        );
                      } else if (managementTools[index] == 'Duyurular') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => NotificationManagementScreen()),
                        );
                      }
                    },
                    child: _buildGridItem(managementTools[index], managementIcons[index]),
                  );

                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text('Öğrenci Araçları', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: studentTools.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  return _buildGridItem(studentTools[index], studentIcons[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(String title, String iconPath) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(iconPath, height: 120),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
