// import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;

// class HomePage extends StatefulWidget {
//   const HomePage({Key? key}) : super(key: key);

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final FlutterTts flutterTts = FlutterTts();
//   final stt.SpeechToText _speech = stt.SpeechToText();

//   bool isListening = false;
//   String currentPosition = "";
//   String finalPosition = "";

//   @override
//   void initState() {
//     super.initState();
//     _speakPrompt();
//   }

//   Future<void> _speakPrompt() async {
//     await flutterTts.setLanguage("en-US");
//     await flutterTts.setPitch(1.0);
//     await flutterTts.setSpeechRate(0.6);

//     String textToSpeak =
//         "Hello, Welcome to Bhaskaracharya Building. Where are you currently?";

//     await flutterTts.speak(textToSpeak);
//     await Future.delayed(Duration(seconds: 5));

//     await _startListeningCurrent();

//     await Future.delayed(Duration(seconds: 5));

//     _speakResponse("From the $currentPosition, where do you want to reach?");
//     await Future.delayed(Duration(seconds: 5));
//     await _startListeningFinal();
//     await Future.delayed(Duration(seconds: 5));

//     // List<dynamic> directions =
//     //     await fetchDirection(currentPosition, finalPosition);
//     // print(directions);
//   }

//   Future<void> _startListeningCurrent() async {
//     bool available = await _speech.initialize(
//       onStatus: (status) {
//         print("Speech recognition status: $status");
//       },
//     );

//     if (available) {
//       _speech.listen(
//         onResult: (result) {
//           final recognizedWords = result.recognizedWords;
//           print("User said: $recognizedWords");
//           setState(() {
//             currentPosition = recognizedWords;
//           });
//         },
//       );
//       setState(() {
//         isListening = true;
//       });
//     } else {
//       print("Speech recognition is not available");
//     }
//   }

//   Future<void> _startListeningFinal() async {
//     bool available = await _speech.initialize(
//       onStatus: (status) {
//         print("Speech recognition status: $status");
//       },
//     );

//     if (available) {
//       _speech.listen(
//         onResult: (result) {
//           final recognizedWords = result.recognizedWords;
//           print("User said: $recognizedWords");
//           setState(() {
//             finalPosition = recognizedWords;
//           });
//         },
//       );
//       setState(() {
//         isListening = true;
//       });
//     } else {
//       print("Speech recognition is not available");
//     }
//   }

//   Future<void> _speakResponse(String text) async {
//     await flutterTts.speak(text);
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     flutterTts.stop();
//     _speech.stop();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Home Page"),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text("Welcome to Bhaskaracharya Building!"),
//             SizedBox(height: 20),
//             Text("Current Position: $currentPosition"),
//             Text("Final Position: $finalPosition"),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           _speakPrompt();
//         },
//         child: Icon(Icons.mic),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:graphview/GraphView.dart'; // Import the graphview package

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool isListening = false;
  String currentPosition = "";
  String finalPosition = "";

  @override
  void initState() {
    super.initState();
    _speakPrompt();
  }

  Future<void> _speakPrompt() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.6);

    String textToSpeak =
        "Hello, Welcome to Bhaskaracharya Building. Where are you currently?";

    await flutterTts.speak(textToSpeak);
    await Future.delayed(Duration(seconds: 5));

    await _startListeningCurrent();

    await Future.delayed(Duration(seconds: 5));

    _speakResponse("From the $currentPosition, where do you want to reach?");
    await Future.delayed(Duration(seconds: 5));
    await _startListeningFinal();
    await Future.delayed(Duration(seconds: 5));
  }

  Future<void> _startListeningCurrent() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        print("Speech recognition status: $status");
      },
    );

    if (available) {
      _speech.listen(
        onResult: (result) {
          final recognizedWords = result.recognizedWords;
          print("User said: $recognizedWords");
          setState(() {
            currentPosition = recognizedWords;
          });
        },
      );
      setState(() {
        isListening = true;
      });
    } else {
      print("Speech recognition is not available");
    }
  }

  Future<void> _startListeningFinal() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        print("Speech recognition status: $status");
      },
    );

    if (available) {
      _speech.listen(
        onResult: (result) {
          final recognizedWords = result.recognizedWords;
          print("User said: $recognizedWords");
          setState(() {
            finalPosition = recognizedWords;
          });
        },
      );
      setState(() {
        isListening = true;
      });
    } else {
      print("Speech recognition is not available");
    }
  }

  Future<void> _speakResponse(String text) async {
    await flutterTts.speak(text);
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
    _speech.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome to Bhaskaracharya Building!"),
            SizedBox(height: 20),
            Text("Current Position: $currentPosition"),
            Text("Final Position: $finalPosition"),
            SizedBox(height: 20),
            // Expanded(
            // child: GraphVisualization(),
            // ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _speakPrompt();
        },
        child: Icon(Icons.mic),
      ),
    );
  }
}
