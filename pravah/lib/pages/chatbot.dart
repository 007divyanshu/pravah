// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:pravah/pages/home_page.dart';

class Chatbot extends StatefulWidget {
  const Chatbot({super.key});

  @override
  State<Chatbot> createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _controller = TextEditingController();
  User? user;
  final List<Map<String, String>> _messages = [];
  late final Gemini _gemini;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;

    // Initialize Gemini API inside the Chatbot page
    String? apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey != null && apiKey.isNotEmpty) {
      Gemini.init(apiKey: apiKey);
      _gemini = Gemini.instance;
    } else {
      throw Exception("Gemini API key is missing in .env file");
    }
  }

  // Function to check if the message is related to eco-friendly power generation
  bool isEcoFriendlyQuestion(String message) {
    List<String> keywords = [
      "solar", "wind", "hydro", "geothermal", "biomass", "renewable", "green energy",
      "eco-friendly power", "sustainable energy", "carbon neutral", "clean energy",
      "solar panels", "wind turbines", "hydroelectric", "wave energy"
    ];

    for (String keyword in keywords) {
      if (message.toLowerCase().contains(keyword)) {
        return true;
      }
    }
    return false;
  }

  Future<void> sendMessage() async {
    if (_controller.text.isEmpty) return;

    final userMessage = _controller.text;
    _controller.clear();

    setState(() {
      _messages.add({"role": "user", "text": userMessage});
    });

    try {
      // Combine validation and response generation in a single request
      final response = await _gemini.text(
        "If the following question is related to renewable or green energy generation (solar, wind, hydro, geothermal, biomass, etc.), provide an informative answer. "
        "If not, reply with 'I only discuss green energy topics. 🌱 Try asking about renewable energy!'\n\n"
        "User Question: $userMessage"
      );

      if (response?.output != null) {
        // Remove asterisks from the response
        String cleanedResponse = response!.output!.replaceAll('*', '');

        // Add emojis or symbols based on keywords
        cleanedResponse = _addEmojisToResponse(cleanedResponse);

        setState(() {
          _messages.add({"role": "bot", "text": cleanedResponse});
        });
      } else {
        setState(() {
          _messages.add({"role": "bot", "text": "I'm not sure about that, but feel free to ask about renewable energy! ⚡🌍"});
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({"role": "bot", "text": "Error: Unable to connect to Gemini API."});
      });
    }
  }

  // Function to add emojis or symbols based on keywords
  String _addEmojisToResponse(String response) {
    // Map keywords to emojis or symbols
    final Map<String, String> emojiMap = {
      "solar": "☀️",
      "wind": "🌬️",
      "hydro": "💧",
      "geothermal": "🌋",
      "biomass": "🌱",
      "renewable": "♻️",
      "green energy": "🌿",
      "eco-friendly": "🌍",
      "sustainable": "🔄",
      "carbon neutral": "🌎",
      "clean energy": "⚡",
      "solar panels": "☀️🔧",
      "wind turbines": "🌬️🌀",
      "hydroelectric": "💧⚡",
      "wave energy": "🌊⚡",
    };

    // Replace keywords with emojis
    emojiMap.forEach((keyword, emoji) {
      if (response.toLowerCase().contains(keyword)) {
        response = response.replaceAll(RegExp(keyword, caseSensitive: false), emoji);
      }
    });

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Eco-Friendly Chatbot'),
        leading: BackButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
      ),
      body: user == null
          ? const Center(
              child: Text(
                "No user logged in!",
                style: TextStyle(fontSize: 20),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUser = message["role"] == "user";
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.blue[300] : Colors.green[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            message["text"]!,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ask about green energy...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send, color: Colors.green),
                        onPressed: sendMessage,
                      ),
                    ),
                    // Handle the "Enter" key press
                    onSubmitted: (value) {
                      sendMessage();
                    },
                  ),
                ),
              ],
            ),
    );
  }
}