import 'package:campus_guide/services/gemini_api_service.dart';
import 'package:flutter/material.dart';

class AiMentorScreen extends StatefulWidget {
  const AiMentorScreen({super.key});

  @override
  _AiMentorScreenState createState() => _AiMentorScreenState();
}

class _AiMentorScreenState extends State<AiMentorScreen> {
  final List<Map<String, String>> messages = [];
  final TextEditingController _controller = TextEditingController();
  final GeminiApiService _apiService = GeminiApiService();

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;
    setState(() {
      messages.add({"text": _controller.text, "sender": "user"});
      messages.add({"text": "AI is typing...", "sender": "bot"}); // Geçici mesaj
    });

    String userInput = _controller.text;
    _controller.clear();

    try {
      final response = await _apiService.getResponse(userInput);
      setState(() {
        messages.removeLast(); // Geçici mesajı kaldır
        messages.add({"text": response, "sender": "bot"}); // Gerçek yanıtı ekle
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        messages.removeLast(); // Geçici mesajı kaldır
        messages.add({"text": "Error: $e", "sender": "bot"}); // Hata mesajını ekle
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('AI Mentor', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF007BFF),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = message['sender'] == 'user';
                return Container(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isUser)
                          ClipOval(
                            child: Image.asset('img/icons/ai_mentor.png', width: 35, height: 35, fit: BoxFit.cover),
                          ),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            decoration: BoxDecoration(
                              color: isUser ? Colors.blue[50] : Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              message['text']!,
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                        if (isUser)
                          ClipOval(
                            child: Image.network('https://via.placeholder.com/35', width: 35, height: 35, fit: BoxFit.cover),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Bir mesaj yazın...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
