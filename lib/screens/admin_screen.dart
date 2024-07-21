import 'package:campus_guide/bloc/admin_bloc.dart';
import 'package:campus_guide/screens/bottom_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
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
        title: const Text('Kulüp Yönetim Sayfası', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.bell, color: Colors.white),
            onPressed: () {
              // Bildirimlere yönlendireceğiz unutma !!!
            },
          ),
        ],
      ),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.error != null) {
            return Center(child: Text('Hata: ${state.error}'));
          } else if (state.isAdmin) {
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
                    AdminSection(
                      title: 'Kişisel Bilgiler',
                      items: [
                        AdminItem(
                          icon: Icons.person_outlined,
                          label: state.isAdmin
                              ? state.adminName ?? 'Admin Adı'
                              : 'Admin bulunamadı',
                          onTap: () {
                            // Kullanıcı adı soyadı düzenleme
                          },
                        ),
                        AdminItem(
                          icon: Icons.email_outlined,
                          label: state.firebaseUser?.email ?? 'E-posta bulunamadı',
                          onTap: () {
                            // E-mail adresi düzenleme
                          },
                        ),
                      ],
                    ),
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
                              context.read<AdminCubit>().signOut();
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => const BottomNavigator()),
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
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text('Admin bulunamadı.'));
          }
        },
      ),
    );
  }
}

class AdminSection extends StatelessWidget {
  final String title;
  final List<AdminItem> items;

  const AdminSection({super.key, required this.title, required this.items});

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

class AdminItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const AdminItem({super.key, required this.icon, required this.label, required this.onTap});

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