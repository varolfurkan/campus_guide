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
        widget.club['members'] = isFollowing ? (widget.club['members'] ?? 0) + 1 : (widget.club['members'] ?? 0) - 1;
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
                    '${club['events'].length} Etkinlik',
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
          _buildEventList(List<Map<String, dynamic>>.from(club['events'] ?? [])),
          _buildSectionTitle('Geçmiş Etkinlikler'),
          _buildEventList(List<Map<String, dynamic>>.from(club['pastEvents'] ?? [])),
          _buildSectionTitle('Kulüp Yönetimi'),
          _buildManagementInfo(List<Map<String, dynamic>>.from(club['management'] ?? [])),
          _buildSectionTitle('İletişim'),
          Text(club['contactInfo'] ?? 'No contact information available'),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical:8.0),
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
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      event['event_title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),

                    Row(
                      children: [
                        _buildInfoChip(
                          event['type'],
                          event['type'] == 'Özel' ? Colors.red : Colors.green,
                          false,
                          textColor: event['type'] == 'Özel' ? Colors.red : Colors.green,
                          backgroundColor: Colors.white,
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_month),
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
                          icon: Icons.people,
                        ),
                      ],
                    ),
                  ],
                ),
                Text(event['clubName'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Tarih: ${event['date']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Konum: ${event['location'] ?? 'Belirtilmedi'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Açıklama: ${event['description'] ?? 'Açıklama yok'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

          ),
        );
      },
    );
  }

  Widget _buildInfoChip(String label, Color color, bool isType, {Color textColor = Colors.green, Color backgroundColor = Colors.transparent, IconData? icon}) {
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isType ? color : textColor,
              fontSize: 14,
            ),
          ),
          if (icon != null)
          Icon(
            icon,
            color: color,
            size: 16,
          ),
        ],
      ),
      backgroundColor: isType ? Colors.white : backgroundColor,
      shape: StadiumBorder(side: BorderSide(color: color)),
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 5),
    );
  }


  Widget _buildManagementInfo(List<Map<String, dynamic>> management) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: management.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${entry['role'] ?? 'Unknown'}: ${entry['name'] ?? 'Unknown'}'),
            const SizedBox(height: 8.0),
          ],
        );
      }).toList(),
    );
  }
}
