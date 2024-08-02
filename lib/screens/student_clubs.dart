import 'package:campus_guide/bloc/admin_bloc.dart';
import 'package:campus_guide/bloc/user_bloc.dart';
import 'package:campus_guide/screens/club_detail_screen.dart';
import 'package:campus_guide/screens/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StudentClubs extends StatefulWidget {
  const StudentClubs({super.key});

  @override
  State<StudentClubs> createState() => _StudentClubsState();
}

class _StudentClubsState extends State<StudentClubs> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<UserCubit>().getStudentClubs();
    if (context.read<UserCubit>().state.firebaseUser != null) {
      if (context.read<AdminCubit>().state.isAdmin) {
        context.read<UserCubit>().getStudentClubs();
      } else {
        context.read<UserCubit>().getFollowedClubs();
      }
    }
  }
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
        title: const Text('Öğrenci Kulüpleri', style: TextStyle(color: Colors.white)),
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
      body: BlocListener<UserCubit, UserState>(
        listenWhen: (previous, current) => previous.followStatusChanged != current.followStatusChanged,
        listener: (context, state) {
          if (context.read<UserCubit>().state.firebaseUser != null) {
            context.read<UserCubit>().getFollowedClubs();
          }
          context.read<UserCubit>().getStudentClubs();
        },
        child: BlocBuilder<UserCubit, UserState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.error != null) {
              return Center(child: Text('Hata: ${state.error}'));
            } else if (state.studentClubs.isEmpty) {
              return const Center(child: Text('Henüz kulüp yok.'));
            } else {
              List<Map<String, dynamic>> clubs = state.studentClubs;
              List<Map<String, dynamic>> followedClubs = state.followedClubs;

              return ListView(
                padding: const EdgeInsets.all(8.0),
                children: [
                  if (followedClubs.isNotEmpty) ...[
                    _buildSectionTitle('Takip Edilen Kulüpler'),
                    _buildClubList(context, followedClubs),
                  ],
                  _buildSectionTitle('Öğrenci Kulüpleri'),
                  _buildClubList(context, clubs),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Hepsini Gör',
            style: TextStyle(color: Colors.blue),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _buildClubList(BuildContext context, List<Map<String, dynamic>> clubs) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: clubs.length,
      itemBuilder: (context, index) {
        var club = clubs[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClubDetailScreen(clubId: club['id'] ?? '', club: club),
                ),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: const BorderSide(color: Colors.orange, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite_border, color: Colors.orange),
                      onPressed: () {
                        if (context.read<UserCubit>().state.firebaseUser != null) {
                          context.read<UserCubit>().updateFollowStatus(club['id'], club);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StudentClubs(),
                            ),
                          );
                        }
                      },
                    ),
                    CircleAvatar(
                      radius: 25.0,
                      backgroundImage: NetworkImage(club['img'] ?? ''),
                      backgroundColor: Colors.transparent,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            club['title'] ?? 'Başlık Yok',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                          ),
                          const SizedBox(height: 4.0),
                          Row(
                            children: [
                              Expanded(
                                child: Wrap(
                                  spacing: 8.0,
                                  runSpacing: 4.0,
                                  children: [
                                    _buildInfoChip(
                                      '${club['type'] ?? 'Tür Yok'}',
                                      club['type'] == 'Özel' ? Colors.red : Colors.green,
                                      club['type'] == 'Özel',
                                    ),
                                    _buildInfoChip(
                                      '${club['members'] ?? '0'} Üye',
                                      Colors.orange,
                                      false,
                                      textColor: Colors.orange,
                                      backgroundColor: Colors.white,
                                    ),
                                    _buildInfoChip(
                                      '${club['events'].length} Etkinlik',
                                      Colors.blue,
                                      false,
                                      textColor: Colors.blue,
                                      backgroundColor: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(String label, Color color, bool isType, {Color textColor = Colors.green, Color backgroundColor = Colors.transparent}) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: isType ? color : textColor,
        ),
      ),
      backgroundColor: isType ? Colors.white : backgroundColor,
      shape: StadiumBorder(side: BorderSide(color: color)),
    );
  }
}

