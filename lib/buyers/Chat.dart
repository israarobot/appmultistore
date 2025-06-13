import 'package:flutter/material.dart';
import 'dart:math';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final Random _random = Random();

  // Sample list of e-commerce question-answer pairs (expand to 1000 in a real app)
  final List<Map<String, String>> _ecommerceQA = [
    {
      'question': 'What are the latest trends in e-commerce for 2025?',
      'answer': 'In 2025, e-commerce trends include AI-driven personalization, immersive AR shopping experiences, and a rise in sustainable packaging solutions.'
    },
    {
      'question': 'Can you recommend popular products in electronics?',
      'answer': 'Popular electronics include the latest iPhone, Sony noise-canceling headphones, and smart home devices like the Amazon Echo.'
    },
    {
      'question': 'ما',
      'answer': 'ماماماماماماماماماماماماماماماما'
    },
    {
      'question': 'What are the benefits of buying from sustainable brands?',
      'answer': 'Sustainable brands reduce environmental impact, use ethical labor practices, and often offer high-quality, durable products.'
    },
    {
      'question': 'Are there any discounts on home appliances this month?',
      'answer': 'Many retailers offer discounts during seasonal sales like Black Friday or mid-year clearances. Check sites like Amazon or Best Buy.'
    },
    {
      'question': 'How can I track my order after purchase?',
      'answer': 'Most e-commerce platforms provide a tracking link in your order confirmation email or account dashboard.'
    },
    {
      'question': 'What’s the return policy for beauty products?',
      'answer': 'Return policies vary, but many retailers allow returns within 30 days if the product is unopened or defective. Check the store’s terms.'
    },
    {
      'question': 'Which smartphones have the best camera features?',
      'answer': 'Top smartphones for cameras in 2025 include the iPhone 16 Pro, Samsung Galaxy S25 Ultra, and Google Pixel 10.'
    },
    {
      'question': 'How do I find eco-friendly packaging products?',
      'answer': 'Look for brands advertising compostable or recyclable packaging, or search marketplaces like Etsy for eco-conscious sellers.'
    },
    {
      'question': 'bonjour',
      'answer': 'bonjour cv'
    },
  ];

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        // Add user message
        _messages.add({
          'text': _controller.text,
          'isUser': true,
          'timestamp': DateTime.now(),
        });
      });

      // Check for "hello", question match, or "he"
      String userInput = _controller.text.toLowerCase().trim();
      if (userInput == 'hello') {
        _sendBotResponse("Hello, how can I help you? ${_getRandomQA()['question']}");
      } else {
        for (var qa in _ecommerceQA) {
          if (userInput.contains(qa['question']!.toLowerCase()) || qa['question']!.toLowerCase().contains(userInput)) {
            _sendBotResponse(qa['answer']!);
            _controller.clear();
            return;
          }
        }
        // Check for standalone "he"
        if (RegExp(r'\bhe\b', caseSensitive: false).hasMatch(userInput)) {
          _sendBotResponse(_random.nextBool() ? "Yes" : "No");
        } else {
          // If no match, respond with a default message
          _sendBotResponse("Sorry, I don't have an answer for that. Try asking something like: ${_getRandomQA()['question']}");
        }
      }

      _controller.clear();
    }
  }

  void _sendBotResponse(String message) {
    // Simulate bot response delay
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _messages.add({
          'text': message,
          'isUser': false,
          'timestamp': DateTime.now(),
        });
      });
    });
  }

  Map<String, String> _getRandomQA() {
    return _ecommerceQA[_random.nextInt(_ecommerceQA.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Commerce Chat'),
        backgroundColor: const Color(0xFF93441A),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['isUser'] as bool;
                return ListTile(
                  title: Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: isUser ? const Color(0xFF93441A) : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        message['text'] as String,
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black,
                        ),
                      ),
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
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  backgroundColor: const Color(0xFF93441A),
                  mini: true,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}