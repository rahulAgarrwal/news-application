import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:newsapp2/Models/chat_message.dart';
import 'package:newsapp2/Provider/chatService.dart';
import 'package:newsapp2/Provider/newsprovider.dart';
import 'package:newsapp2/Screens/MainScreen.dart';
import 'package:newsapp2/Widgets/myDrawer.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

FlutterTts flutterTts = FlutterTts();
bool speakerOn = true;
final TextEditingController _messageController = TextEditingController();
ScrollController _scrollController = ScrollController();
late Function voidCallback;
bool awaitingResponse = false;

class GptScreen extends StatefulWidget {
  const GptScreen({super.key});

  @override
  State<GptScreen> createState() => _GptScreenState();
}

class _GptScreenState extends State<GptScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setcallback();
  }

  setcallback() {
    voidCallback = setState;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    final mediaobj = MediaQuery.of(context).size;
    return Scaffold(
      drawer: const MyDrawer(),
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xffF6F7FB),
      body: Column(
        children: [
          // Your custom app bar
          appbar(mediaobj, null, context), //it is my app bar

          // Expanded ensures that the widget fills available space
          const Expanded(
            child: ChatWidget(),
          ),

          // Input widget at the bottom
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: mediaobj.width * 0.02,
              vertical: mediaobj.height*0.02
            ),
            child: const InputWidget(),
          ),
        ],
      ),
    );
  }
}

Container appbar(Size mediaobj, String? locality, BuildContext context) {
  return Container(
    height: mediaobj.height * 0.12,
    width: double.infinity,
    padding: EdgeInsets.fromLTRB(mediaobj.width * 0.01, mediaobj.height * 0.05,
        mediaobj.width * 0.01, 0),
    decoration: BoxDecoration(
        color: const Color(0xff02011D),
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(mediaobj.width * 0.05),
            bottomRight: Radius.circular(mediaobj.width * 0.05))),
    child: Row(
      children: [
        IconButton(
            onPressed:(){
              print('Drawer');
             Scaffold.of(globalcontext!).openDrawer();
            },
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
              size: 40,
            )),
        const SizedBox(
          width: 15,
        ),
        SvgPicture.asset(
          'assets/Icons/robot.svg',
          width: 30,
          height: 30,
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('AskGPT',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700,fontSize:18)),
              Text(
                "• online",
                style: TextStyle(color: Color(0xff2BE03D),fontSize: 15),
              ),
            ],
          ),
        ),
        const Spacer(),
        IconButton(
            onPressed: () {
              if (speakerOn) {
                flutterTts.stop();
              }
              speakerOn = !speakerOn;
              voidCallback(() {});
            },
            icon: Icon(
              speakerOn ? Icons.volume_up : Icons.volume_mute,
              color: speakerOn ? Colors.green : Colors.white,
              size: 30,
            )),
        const SizedBox(
          width: 10,
        )
      ],
    ),
  );
}

class ChatWidget extends ConsumerStatefulWidget {
  const ChatWidget({super.key});

  @override
  ConsumerState<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends ConsumerState<ChatWidget> {
  @override
  Widget build(BuildContext context) {
    final chats = ref.watch(chatProvider).chats;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    });

    return Container(
      child: ListView.builder(
  // reverse: true,
  controller: _scrollController,
  itemBuilder: (context, index) {
    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: chats[index].content));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message copied to clipboard')),
        );
      },
      child: Align(
        alignment: chats[index].isUserMessage
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth:MediaQuery.of(context).size.width*0.8),
          padding: const EdgeInsets.all(8.0),
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: chats[index].isUserMessage
                ? 
                 const Color(0xff1c6afc).withOpacity(0.73):Colors.white,
            borderRadius: chats[index].isUserMessage
                ? const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  )
                : const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(chats[index].content,style: TextStyle(color: chats[index].isUserMessage
                  ? 
                  Colors.white:Colors.black,),),
          ),
        ),
      ),
    );
  },
  itemCount: chats.length,
),
    );
  }
}

class InputWidget extends ConsumerStatefulWidget {
  const InputWidget({super.key});

  @override
  ConsumerState<InputWidget> createState() => _InputWidgetState();
}

class _InputWidgetState extends ConsumerState<InputWidget> {
  final TextEditingController _messageController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
  }

  void _toggleListening() async {
    if (_isListening) {
      _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (val) {
        if (val == 'listening') {
          setState(() => _isListening = true);
        }
      },
    );

    if (available) {
      _speech.listen(
        onResult: (val) {
          if (val.finalResult) {
            _messageController.text = val.recognizedWords;
            setState(() => _isListening = false);
          }
        },
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    return awaitingResponse
        ? Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: Colors.black,
              size: 40,
            ),
          )
        : Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(35),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                // mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'just write it down!!!',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _toggleListening,
                    child: Icon(
                      Icons.mic,
                      color: _isListening ? Colors.green : Colors.grey,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (_messageController.text.length > 10) {
                        ref.read(chatProvider).addChats(
                            ChatMessage(_messageController.text, true));
                        
                        setState(() {
                          _messageController.text = "";
                          awaitingResponse = true;
                        });

                        final response = await ChatApi().completeChat(
                            ref.read(chatProvider).chats);
                        ref.read(chatProvider).addChats(ChatMessage(response, false));
                        if(speakerOn){
                          flutterTts.speak(response);
                        }
                        setState(() {
                          awaitingResponse = false;
                        });
                      }
                    },
                    child: SvgPicture.asset(
                      'assets/Icons/sendButton.svg',
                    ),
                  )
                ],
              ),
            ),
          );
  }
}
