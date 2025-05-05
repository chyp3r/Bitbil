import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: 'user');
  final _bot = const types.User(id: 'bot', firstName: 'Bitbil');

  GenerativeModel? _model;
  ChatSession? _chatSession;
  bool _isBotTyping = false;
  String? _apiKey;
  TextEditingController _textController = new TextEditingController();
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _loadApiKeyAndInitModel();
  }

  void _loadApiKeyAndInitModel() {
    _apiKey = dotenv.env['API_KEY'];

    if (_apiKey == null || _apiKey!.isEmpty) {
      print("Error: API_KEY not found in .env file.");
      _addMessage(types.TextMessage(
        author: _bot,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: _uuid.v4(),
        text:
            "Configuration Error: API Key is missing. Please check your setup.",
      ));
      return;
    }

    try {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash-latest', // Or 'gemini-pro' etc.
        apiKey: _apiKey!,
      );

      _chatSession = _model?.startChat();

      _addMessage(types.TextMessage(
        author: _bot,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: _uuid.v4(),
        text: "Merhaba ben Bitbil! Size nasıl yardımcı olabilirim?",
      ));
    } catch (e) {
      print("Error initializing Gemini Model: $e");
      _addMessage(types.TextMessage(
        author: _bot,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: _uuid.v4(),
        text:
            "Error initializing AI model. Please check API key or configuration.",
      ));
      _model = null;
      _chatSession = null;
    }
    setState(() {});
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _setBotTyping(bool isTyping) {
    setState(() {
      _isBotTyping = isTyping;
    });
  }

  void _handleSendPressed(types.PartialText message) async {
    if (_model == null || _chatSession == null) {
      _addMessage(types.TextMessage(
        author: _bot,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: _uuid.v4(),
        text:
            "Sorry, the AI model is not available due to a configuration issue.",
      ));
      return;
    }

    final userMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: _uuid.v4(),
      text: message.text,
    );

    _addMessage(userMessage);

    _setBotTyping(true);

    try {
      // Send the user's message text to the chat session
      final response = await _chatSession?.sendMessage(
        Content.text(
            "${message.text} bu soruyu cevaplarken bir çiftçi olduğunu düşün. Cevap verdiğin insan da bir çiftçi. Dolayısıyla verdiğin cevap olabildiğince anlaşılır ve dostça olmalı. 30 kelime civarı kullan."),
      );

      _setBotTyping(false);

      final String? responseText = response?.text;
      if (responseText != null && responseText.isNotEmpty) {
        final botMessage = types.TextMessage(
          author: _bot,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: _uuid.v4(),
          text: responseText,
        );
        _addMessage(botMessage);
      } else {
        _addMessage(types.TextMessage(
          author: _bot,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: _uuid.v4(),
          text:
              "Sorry, I couldn't generate a response. It might be due to safety filters.",
        ));
      }
    } catch (e) {
      _setBotTyping(false);
      print('Error sending message to Gemini: $e');
      _addMessage(types.TextMessage(
        author: _bot,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: _uuid.v4(),
        text: 'Sorry, an error occurred: ${e.toString()}',
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          'Bitbil Bot',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        )),
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 59, 182, 110),
                Color.fromARGB(255, 89, 205, 137),
                Color.fromARGB(255, 135, 229, 174)
              ],
              begin: Alignment.center,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Chat(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: _user,
        showUserAvatars: true,
        showUserNames: true,
        customBottomWidget: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border.all(
                      color: Colors.grey.shade400,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    textInputAction: TextInputAction.send,
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        _handleSendPressed(
                            types.PartialText(text: value.trim()));
                        _textController.clear();
                      }
                    },
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Mesaj',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  _handleSendPressed(
                      types.PartialText(text: _textController.text));
                  _textController.clear();
                },
              ),
            ],
          ),
        ),
        theme: DefaultChatTheme(
          primaryColor: Color(0xFFB2FF59),
          secondaryColor: Color.fromARGB(255, 149, 242, 188),
          inputBackgroundColor: Theme.of(context).colorScheme.surface,
          inputTextColor: Theme.of(context).colorScheme.onSurface,
          messageInsetsVertical: 8.0,
          messageInsetsHorizontal: 12.0,
        ),
        typingIndicatorOptions: TypingIndicatorOptions(
          typingUsers: _isBotTyping ? [_bot] : [],
        ),
        textMessageBuilder: (types.TextMessage message,
            {required int messageWidth, required bool showName}) {
          final isUserMessage = message.author.id == _user.id;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: EdgeInsets.only(
              top: 4,
              bottom: 4,
              left: isUserMessage ? 10 : 10,
              right: isUserMessage ? 10 : 10,
            ),
            decoration: BoxDecoration(
              color: isUserMessage
                  ? Color(0xFFB2FF59)
                  : Color.fromARGB(255, 149, 242, 188),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: isUserMessage
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          );
        },
      ),
    );
  }
}
