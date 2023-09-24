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
  int directionIndex = 0; // Index to keep track of the current direction

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
    await Future.delayed(const Duration(seconds: 5));

    await _startListeningCurrent();

    await Future.delayed(const Duration(seconds: 5));

    _speakResponse("From the $currentPosition, where do you want to reach?");
    await Future.delayed(const Duration(seconds: 5));
    await _startListeningFinal();

    await Future.delayed(const Duration(seconds: 5));
    if (currentPosition == finalPosition) {
      _speakResponse("You are already in $currentPosition");
      return;
    }

    // await Future.delayed(Duration(seconds: 5));

    directions = await fetchDirection(currentPosition, finalPosition);

    print(directions);
    _speakDirections();
  }

  Future<void> _speakDirections() async {
    if (directionIndex < directions.length) {
      final direction = directions[directionIndex];
      String distance = direction[0].toString();
      String instruction = direction[1];

      await flutterTts.speak("$instruction for $distance meters.");

      directionIndex++;
    } else {
      // All directions have been spoken
      print("Reached final position.");
      await flutterTts.speak("$finalPosition is in front of you");
    }
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
    return GestureDetector(
      onDoubleTap: () {
        _speakDirections();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("NavEase"),
          backgroundColor: Colors.black,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Text(
              "Welcome to Bhaskaracharya Building!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Current Position: $currentPosition",
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            Text(
              "Final Position: $finalPosition",
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 1000,
              child: GraphVisualization(
                currentPosition: currentPosition,
                finalPosition: finalPosition,
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          onPressed: () {
            directionIndex = 0; // Index to keep track of the current direction

            _speakPrompt();
          },
          child: const Icon(Icons.mic),
        ),
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
      "entrance": const Offset(0, 0) * scaleFactor,
      "Intersection 01": const Offset(0, -5) * scaleFactor,
      "Intersection 02": const Offset(0, -10) * scaleFactor,
      "Intersection 03": const Offset(-5, -10) * scaleFactor,
      "Intersection 04": const Offset(-5, -15) * scaleFactor,
      "Intersection 05": const Offset(-5, -20) * scaleFactor,
      "Intersection 06": const Offset(0, -20) * scaleFactor,
      "Intersection 07": const Offset(5, -20) * scaleFactor,
      "Intersection 08": const Offset(5, -15) * scaleFactor,
      "Intersection 09": const Offset(5, -10) * scaleFactor,
      "lift 01": const Offset(2, -5) * scaleFactor,
      "lift 02": const Offset(0, -21) * scaleFactor,
      "tpo": const Offset(-6, -10) * scaleFactor,
      "washroom": const Offset(-6, -20) * scaleFactor,
      "classroom 01": const Offset(-6, -15) * scaleFactor,
      "classroom 02": const Offset(-6, -21) * scaleFactor,
      "classroom 03": const Offset(5, -21) * scaleFactor,
      "classroom 04": const Offset(6, -20) * scaleFactor,
      "classroom 05": const Offset(6, -15) * scaleFactor,
      "classroom 06": const Offset(6, -10) * scaleFactor,
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
          ..color = Colors.pink
          ..style = PaintingStyle.fill;
      }

      canvas.drawCircle(position, 30, nodePaint);

      final textSpan = TextSpan(
        text: node,
        style: const TextStyle(
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
