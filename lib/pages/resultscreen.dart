import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for using Clipboard

import 'package:http/http.dart' as http;
import 'package:newsapp/constant/constant.dart';
import 'dart:convert';

import 'package:permission_handler/permission_handler.dart';

class ResultScreen extends StatefulWidget {
  final String scanText;

  const ResultScreen({Key? key, required this.scanText}) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String? summaryText;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> sendDesc(String desc) async {
    setState(() {
      isLoading = true;
    });
    try {
      String text = desc.replaceAll("\n", "");
      text = text.replaceAll('"', "");
      final body = {'text': text};
      var url =
          '${Apiurl.backendUrl}/text-summarizer/summarize/';
      final uri = Uri.parse(url);
      final response = await http.post(
        uri,
        body: body,
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          summaryText = data['result']['summary_text'];
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SummaryScreen(summaryText: summaryText!),
          ),
        );
      }
    } catch (error) {
      print("error");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              Text(widget.scanText),
              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator(
                      color: Colors.blue,
                    )
                  : summaryText != null
                      ? Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(summaryText!),
                          ),
                        )
                      : Container(), // Show card only when summaryText is available
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: widget.scanText));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Copied to clipboard'),
                      ));
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                    ),
                    child: Text('Copy'),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      sendDesc(widget.scanText);
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                    ),
                    child: Text('Send'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SummaryScreen extends StatelessWidget {
  final String summaryText;

  const SummaryScreen({Key? key, required this.summaryText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(summaryText);
    return Scaffold(
      appBar: AppBar(
        title: Text('Summary'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30.0),
          child: Text(summaryText),
        ),
      ),
    );
  }
}
