import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:frontend/services/apiService.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:graphview/GraphView.dart'; // Import the graphview package

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

  List<dynamic> directions = [];

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
    directions = await fetchDirection(currentPosition, finalPosition);

    print(directions);
    // _speakResponse(directions)
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
      body: ListView(
        padding: const EdgeInsets.all(16.0), // Add padding to your content
        children: [
          Text("Welcome to Bhaskaracharya Building!"),
          SizedBox(height: 20),
          Text("Current Position: $currentPosition"),
          Text("Final Position: $finalPosition"),
          SizedBox(height: 20),
          Container(
            height: 1000, // Adjust the height as needed
            child: GraphVisualization(
              currentPosition: currentPosition,
              finalPosition: finalPosition,
            ),
          ),
        ],
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

class GraphVisualization extends StatelessWidget {
  final String currentPosition;
  final String finalPosition;

  GraphVisualization(
      {required this.currentPosition, required this.finalPosition});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CustomPaint(
          painter: GraphPainter(
              currentPosition: currentPosition, finalPosition: finalPosition),
        ),
      ),
    );
  }
}

class GraphPainter extends CustomPainter {
  final String currentPosition;
  final String finalPosition;

  GraphPainter({required this.currentPosition, required this.finalPosition});

  @override
  void paint(Canvas canvas, Size size) {
    final scaleFactor = 20.0;

    // Define the positions of nodes
    final nodePositions = {
      "entrance": Offset(0, 0) * scaleFactor,
      "Intersection 01": Offset(0, -5) * scaleFactor,
      "Intersection 02": Offset(0, -10) * scaleFactor,
      "Intersection 03": Offset(-5, -10) * scaleFactor,
      "Intersection 04": Offset(-5, -15) * scaleFactor,
      "Intersection 05": Offset(-5, -20) * scaleFactor,
      "Intersection 06": Offset(0, -20) * scaleFactor,
      "Intersection 07": Offset(5, -20) * scaleFactor,
      "Intersection 08": Offset(5, -15) * scaleFactor,
      "Intersection 09": Offset(5, -10) * scaleFactor,
      "lift 01": Offset(2, -5) * scaleFactor,
      "lift 02": Offset(0, -21) * scaleFactor,
      "tpo": Offset(-6, -10) * scaleFactor,
      "washroom": Offset(-6, -20) * scaleFactor,
      "classroom 01": Offset(-6, -15) * scaleFactor,
      "classroom 02": Offset(-6, -21) * scaleFactor,
      "classroom 03": Offset(5, -21) * scaleFactor,
      "classroom 04": Offset(6, -20) * scaleFactor,
      "classroom 05": Offset(6, -15) * scaleFactor,
      "classroom 06": Offset(6, -10) * scaleFactor,
    };

    // Define the edges between nodes
    final edges = [
      ["entrance", "Intersection 01"],
      ["Intersection 01", "lift 01"],
      ["Intersection 01", "Intersection 02"],
      ["Intersection 02", "Intersection 03"],
      ["Intersection 02", "Intersection 09"],
      ["Intersection 03", "Intersection 04"],
      ["Intersection 04", "Intersection 05"],
      ["Intersection 05", "Intersection 06"],
      ["Intersection 06", "Intersection 07"],
      ["Intersection 07", "Intersection 08"],
      ["Intersection 08", "Intersection 09"],
      ["Intersection 03", "tpo"],
      ["Intersection 05", "washroom"],
      ["Intersection 06", "lift 02"],
      ["Intersection 04", "classroom 01"],
      ["Intersection 05", "classroom 02"],
      ["Intersection 07", "classroom 03"],
      ["Intersection 07", "classroom 04"],
      ["Intersection 08", "classroom 05"],
      ["Intersection 09", "classroom 06"],
    ];

    nodePositions.forEach((node, position) {
      Paint nodePaint;
      // Paint nodePaint;
      if (node == currentPosition) {
        // Highlight the currentPosition node with a different color
        nodePaint = Paint()
          ..color = Colors.green // Change the color as desired
          ..style = PaintingStyle.fill;
      } else if (node == finalPosition) {
        // Highlight the finalPosition node with a different color
        nodePaint = Paint()
          ..color = Colors.red // Change the color as desired
          ..style = PaintingStyle.fill;
      } else {
        nodePaint = Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.fill;
      }

      canvas.drawCircle(position, 30, nodePaint);

      final textSpan = TextSpan(
        text: node,
        style: TextStyle(
          fontSize: 10,
          color: Colors.white,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
          minWidth: 0, maxWidth: 100); // Adjust the width as needed
      textPainter.paint(
        canvas,
        position - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    });

    // Draw edges
    final edgePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    edges.forEach((edge) {
      final start = nodePositions[edge[0]];
      final end = nodePositions[edge[1]];
      canvas.drawLine(start!, end!, edgePaint);
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
