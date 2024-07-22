import 'package:campus_guide/bloc/user_bloc.dart';
import 'package:campus_guide/screens/bottom_navigator.dart';
import 'package:campus_guide/screens/home_page_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StudentProfile extends StatefulWidget {
  const StudentProfile({super.key});

  @override
  State<StudentProfile> createState() => _StudentProfileState();
}


class _StudentProfileState extends State<StudentProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF007BFF),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: const Text('Profilim', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.bell, color: Colors.white),
            onPressed: () {
              //TODO Bildirimlere yönlendireceğiz unutma !!!
            },
          ),
        ],
      ),
      body: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.error != null) {
            return Center(child: Text('Hata: ${state.error}'));
          } else if (state.firebaseUser != null) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade200,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ProfileSection(
                      title: 'Kişisel Bilgiler',
                      items: [
                        ProfileItem(
                          icon: Icons.person_outlined,
                          label: state.firebaseUser?.displayName ?? 'Kullanıcı Adı Soyadı',
                          onTap: () {
                            // Kullanıcı adı soyadı düzenleme
                          },
                        ),
                        ProfileItem(
                          icon: Icons.email_outlined,
                          label: state.firebaseUser?.email ?? 'hata@hotmail.com',
                          onTap: () {
                            // E-mail adresi düzenleme
                          },
                        ),
                      ],
                    ),
                    ProfileSection(
                      title: 'Hesap Ayarları',
                      items: [
                        ProfileItem(
                          icon: Icons.lock_outlined,
                          label: 'Şifre Değiştirme',
                          onTap: () {
                            // Şifre değiştirme
                          },
                        ),
                        ProfileItem(
                          icon: Icons.language,
                          label: 'Dil ve Bölge Ayarları',
                          onTap: () {
                            // Dil ve bölge ayarları
                          },
                        ),
                      ],
                    ),
                    ProfileSection(
                      title: 'Aktiviteler',
                      items: [
                        ProfileItem(
                          icon: Icons.people,
                          label: 'Takip Edilen Kulüpler',
                          onTap: () {
                            // Takip edilen kulüpler
                          },
                        ),
                        ProfileItem(
                          icon: Icons.event_note,
                          label: 'Geçmiş Etkinlikler',
                          onTap: () {
                            // Geçmiş etkinlikler
                          },
                        ),
                        ProfileItem(
                          icon: Icons.bookmark_border,
                          label: 'Kaydedilenler',
                          onTap: () {
                            // Kaydedilenler
                          },
                        ),
                        ProfileItem(
                          icon: Icons.favorite_border,
                          label: 'Favoriler',
                          onTap: () {
                            // Favoriler
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.sunny),
                          onPressed: () {
                            // Gündüz modu
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.nights_stay),
                          onPressed: () {
                            // Gece modu
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 18,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: TextButton(
                            onPressed: () {
                              context.read<UserCubit>().signOut();
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => const BottomNavigator(homePage: HomePageScreen(),)),
                              );
                            },
                            child: const Text(
                              'Çıkış Yap',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: TextButton(
                            onPressed: () {

                            },
                            child: const Text(
                              'Hesabımı Sil',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text('Kullanıcı bulunamadı.'));
          }
        },
      ),
    );
  }
}

class ProfileSection extends StatelessWidget {
  final String title;
  final List<ProfileItem> items;

  const ProfileSection({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...items,
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ProfileItem({super.key, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFE3F2FD),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w400),),
        // trailing: const Icon(Icons.arrow_forward_ios_rounded),
        onTap: onTap,
      ),
    );
  }
}

