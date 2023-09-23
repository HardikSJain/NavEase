import 'dart:convert';
import 'package:http/http.dart' as http;

String baseUrl = 'http://192.168.0.105:5000';

Future<bool> getBackendStatusAPI() async {
  try {
    var url = Uri.parse('$baseUrl/navapi');
    final response = await http.get(url);

    return true;
  } catch (e) {
    return false;
  }
}

Future<List<dynamic>> fetchDirection(
  String currentPosition,
  String finalPosition,
) async {
  final apiUrl = '$baseUrl/navapi';
  final Map<String, String> requestData = {
    'start': currentPosition,
    'goal': finalPosition,
  };

  final response = await http.post(Uri.parse(apiUrl),
      body: json.encode(requestData),
      headers: {'Content-Type': 'application/json'});

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    // List<dynamic> path = data['Path'];
    List<dynamic> instructions = data['Instructions'];

    return instructions;
  } else {
    throw Exception('Failed to fetch direction');
  }
}
