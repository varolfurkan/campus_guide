import 'package:auto_size_text/auto_size_text.dart';
import 'package:campus_guide/bloc/admin_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: const Text('Bildirimler', style: TextStyle(color: Colors.white)),
            centerTitle: true,
            backgroundColor: const Color(0xFF007BFF),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(FontAwesomeIcons.bell, color: Colors.white),
                      onPressed: () {
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
                ),
              ),
            ],
          ),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
            itemCount: state.notifications?.length ?? 0,
            itemBuilder: (context, index) {
              var notification = state.notifications![index];
              bool isRead = state.readNotifications?.contains(notification['id']) ?? false;
              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(notification['notification_title'] ?? 'Başlık Yok'),
                        content: Text(notification['notification_description'] ?? 'Açıklama Yok'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Kapat'),
                          ),
                        ],
                      );
                    },
                  );
                  context.read<AdminCubit>().markNotificationAsRead(notification['id']);
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    leading: Icon(
                      isRead ? Icons.check : Icons.notifications,
                      color: isRead ? Colors.green : Colors.red,
                    ),
                    title: Text(
                      notification['notification_title'] ?? 'Başlık Yok',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoSizeText(
                          notification['notification_description'] ?? 'Açıklama Yok',
                          style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        RichText(
                          text: TextSpan(
                            text: 'Kulüp: ',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                            children: [
                              TextSpan(
                                text: notification['clubName'] ?? 'Bilinmiyor',
                                style: const TextStyle(fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
