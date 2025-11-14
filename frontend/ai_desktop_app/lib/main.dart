import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Desktop App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _status = 'Not connected';
  String _response = '';
  bool _loading = false;
  final _controller = TextEditingController();

  // バックエンド接続確認
  Future<void> checkBackend() async {
    setState(() => _loading = true);
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => _status = 'Connected - Model: ${data['model_loaded']}');
      }
    } catch (e) {
      setState(() => _status = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  // AI生成
  Future<void> generate() async {
    if (_controller.text.isEmpty) return;

    setState(() => _loading = true);
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/generate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'text': _controller.text}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => _response = data['response'] ?? 'No response');
      }
    } catch (e) {
      setState(() => _response = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Desktop App - Test')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _loading ? null : checkBackend,
              child: const Text('Check Backend Connection'),
            ),
            const SizedBox(height: 10),
            Text('Status: $_status', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter prompt',
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loading ? null : generate,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Generate'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _response.isEmpty ? 'Response will appear here' : _response,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
