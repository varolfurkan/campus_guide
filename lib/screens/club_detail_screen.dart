import 'package:auto_size_text/auto_size_text.dart';
import 'package:campus_guide/bloc/user_bloc.dart';
import 'package:campus_guide/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClubDetailScreen extends StatefulWidget {
  final String clubId;
  final Map<String, dynamic> club;

  const ClubDetailScreen({Key? key, required this.clubId, required this.club}) : super(key: key);

  @override
  _ClubDetailScreenState createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends State<ClubDetailScreen> {
  late bool isFollowing = false;
  final UserRepository _userRepository = UserRepository();

  @override
  void initState() {
    super.initState();
    checkIfFollowing();
  }

  Future<void> checkIfFollowing() async {
    User? user = await _userRepository.getCurrentUser();
    if (user != null) {
      bool followingStatus = await _userRepository.isFollowingClub(user, widget.clubId);
      setState(() {
        isFollowing = followingStatus;
      });
    }
  }

  Future<void> toggleFollow() async {
    User? user = await _userRepository.getCurrentUser();
    if (user != null) {
      await _userRepository.updateFollowStatus(user, widget.clubId, widget.club, isFollowing);
      setState(() {
        isFollowing = !isFollowing;
      });
      context.read<UserCubit>().followStatusChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    var club = widget.club;

    String clubImage = club['img'] ?? 'https://via.placeholder.com/150';
    String clubTitle = club['title'] ?? 'Bilinmeyen Kulüp Adı';
    String clubDescription = club['description'] ?? 'Açıklama Bulunamadı';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(clubTitle, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF007BFF),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(FontAwesomeIcons.bell, color: Colors.white),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: toggleFollow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: StadiumBorder(
                        side: BorderSide(color: isFollowing ? const Color(0xFFFFA500) : const Color(0xFF7A7979)),
                      ),
                      minimumSize: const Size(100, 42), // Sabit genişlik ayarı
                      maximumSize: const Size(100, 42), // Sabit genişlik ayarı
                    ),
                    child: Text(
                      isFollowing ? 'Takip Ediliyor' : 'Takip Et',
                      style: TextStyle(
                        fontSize: 14,
                        color: isFollowing ? const Color(0xFFFFA500) : const Color(0xFF7A7979),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2, // Takip Ediliyor olduğunda çift satır geçsin diye
                      // minFontSize: 10, // Gerekirse küçülebilecek minimum boyut
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  _buildInfoChip(
                    '${club['type']}',
                    club['type'] == 'Özel' ? Colors.red : Colors.green,
                    club['type'] == 'Özel',
                  ),
                ],
              ),
              const SizedBox(width: 16.0),
              CircleAvatar(
                radius: 40.0,
                backgroundImage: NetworkImage(clubImage),
                backgroundColor: Colors.transparent,
              ),
              const SizedBox(width: 16.0),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildInfoChip(
                    '${club['members']} Üye',
                    Colors.orange,
                    false,
                    textColor: Colors.orange,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 8.0),
                  _buildInfoChip(
                    '${club['events']} Etkinlik',
                    Colors.blue,
                    false,
                    textColor: Colors.blue,
                    backgroundColor: Colors.white,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Text(
            clubDescription,
            style: const TextStyle(fontSize: 16.0),
          ),
          const SizedBox(height: 16.0),
          _buildSectionTitle('Etkinlikler ve Projeler'),
          _buildSectionTitle('Yaklaşan Etkinlikler'),
          _buildEventList(club['upcomingEvents'] ?? []),
          _buildSectionTitle('Geçmiş Etkinlikler'),
          _buildEventList(club['pastEvents'] ?? []),
          _buildSectionTitle('Kulüp Yönetimi'),
          _buildManagementInfo(club['management'] ?? {}),
          _buildSectionTitle('İletişim'),
          Text(club['contact'] ?? 'No contact information available'),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF007BFF)),
      ),
    );
  }

  Widget _buildEventList(List<Map<String, dynamic>> events) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        var event = events[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(color: event['type'] == 'Özel' ? Colors.red : Colors.green, width: 2),
          ),
          child: ListTile(
            title: Text(event['title']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Endüstri Mühendisliği Kulübü'),
                Text('Tarih: ${event['date']}'),
                Text('Konum: ${event['location'] ?? 'Belirtilmedi'}'),
                Text('Açıklama: ${event['description'] ?? 'Açıklama yok'}'),
              ],
            ),
            trailing: Wrap(
              spacing: 8.0,
              children: [
                _buildInfoChip(
                  event['type'],
                  event['type'] == 'Özel' ? Colors.red : Colors.green,
                  false,
                  textColor: event['type'] == 'Özel' ? Colors.red : Colors.green,
                  backgroundColor: Colors.white,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    // Add event to calendar functionality
                  },
                ),
                _buildInfoChip(
                  '12', // Example number, replace with your data
                  Colors.orange,
                  false,
                  textColor: Colors.orange,
                  backgroundColor: Colors.white,
                ),
              ],
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
          fontSize: 14,
        ),
      ),
      backgroundColor: isType ? Colors.white : backgroundColor,
      shape: StadiumBorder(side: BorderSide(color: color)),
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
    );
  }

  Widget _buildManagementInfo(Map<String, dynamic> management) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: management.entries.map((entry) {
        return Text('${entry.key}: ${entry.value}');
      }).toList(),
    );
  }
}

