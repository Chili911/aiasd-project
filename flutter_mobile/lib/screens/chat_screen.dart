
import 'package:material_ui/material_ui.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  bool loading = false;

  final List<Map<String, String>> messages = [
    {
      'role': 'assistant',
      'text': 'Hi! I am your Weatherly AI assistant. Ask me about weather, clothing or what to wear today!',
    },
  ];

  final suggestions = [
    'What should I wear today?',
    'What should I wear in rainy weather?',
    'How should I dress for cold weather?',
    'What should I pack for a winter trip?',
  ];

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !scrollController.hasClients) return;

      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> sendMessage([String? suggestion]) async {
    final message = (suggestion ?? controller.text).trim();

    if (message.isEmpty || loading) return;

    if (message.length > 1500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please shorten your message.')),
      );
      return;
    }

    setState(() {
      messages.add({'role': 'user', 'text': message});
      loading = true;
    });

    controller.clear();
    scrollToBottom();

    try {
      final city = LocationService.city;
      final country = LocationService.country;

      final prompt = '''
You are Weatherly, a friendly weather and clothing assistant.
Give practical, clear and concise advice.
Do not invent live weather conditions.

Selected location: ${city.isEmpty ? 'Not selected' : '$city, $country'}

User question: $message
''';

      final response = await ApiService.post(
        '/chat',
        {'message': prompt},
      );

      final answer = response['answer']?.toString().trim() ?? '';

      if (answer.isEmpty) {
        throw Exception('The assistant returned an empty response.');
      }

      if (!mounted) return;

      setState(() {
        messages.add({
          'role': 'assistant',
          'text': answer,
        });
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        messages.add({
          'role': 'error',
          'text': error.toString().replaceFirst('Exception: ', ''),
        });
      });
    } finally {
      if (mounted) {
        setState(() => loading = false);
        scrollToBottom();
      }
    }
  }

  Widget messageBubble(Map<String, String> message) {
    final isUser = message['role'] == 'user';
    final isError = message['role'] == 'error';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 18,
              backgroundColor: isError
                  ? Colors.red.shade100
                  : const Color(0xFFEDE9FE),
              child: Icon(
                isError ? Icons.error_outline : Icons.auto_awesome,
                color: isError ? Colors.red : AppTheme.primary,
                size: 19,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isUser
                    ? AppTheme.primary
                    : isError
                        ? Colors.red.shade50
                        : Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                message['text'] ?? '',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: isUser
                      ? Colors.white
                      : AppTheme.textColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weatherly AI',
          style: TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Clear conversation',
            onPressed: loading ? null : () {
              setState(() {
                messages.clear();
                messages.add({
                  'role': 'assistant',
                  'text': 'Hi! How can I help you today?',
                });
              });
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FE),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: AppTheme.primary),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Your personal weather and outfit assistant',
                          style: TextStyle(color: AppTheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                ValueListenableBuilder<Map<String, dynamic>?>(
                  valueListenable: LocationService.selectedLocation,
                  builder: (context, location, child) {
                    return Text(
                      location == null
                          ? 'No location selected'
                          : '${location['city']}, ${location['country']}',
                      style: const TextStyle(color: Colors.grey),
                    );
                  },
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      ...messages.map(messageBubble),
                      if (messages.length == 1)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: suggestions.map((question) {
                            return ActionChip(
                              label: Text(question),
                              onPressed: loading
                                  ? null
                                  : () => sendMessage(question),
                            );
                          }).toList(),
                        ),
                      if (loading)
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Weatherly is thinking...'),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const Text(
                  '20 messages per day',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          maxLength: 1500,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => sendMessage(),
                          decoration: const InputDecoration(
                            hintText: 'Ask Weatherly...',
                            counterText: '',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: AppTheme.primary,
                        child: IconButton(
                          onPressed: loading
                              ? null
                              : () => sendMessage(),
                          icon: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                          ),
                        ),
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
  }
}
