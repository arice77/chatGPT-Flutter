import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// ignore: must_be_immutable
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loading = false;
  String ans = '';

  TextEditingController questionText = TextEditingController();

  OutlineInputBorder outlineInputBorder = const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      borderSide: BorderSide(
        color: Colors.black,
        width: 3,
      ));

  Future<String> createCompletion(String question) async {
    setState(() {
      loading = true;
    });

    try {
      const apiKey = 'YOU_API_KEY';
      const model = 'text-davinci-003';
      String prompt = '$question\nA'; // Update the prompt here
      const temperature = 0;
      const maxTokens = 2000;
      const topP = 1.0;
      const frequencyPenalty = 0.0;
      const presencePenalty = 0.0;
      final stop = ['\n'];

      const url = 'https://api.openai.com/v1/completions';
      final body = jsonEncode({
        'model': model,
        'prompt': prompt,
        'temperature': temperature,
        'max_tokens': maxTokens,
        'top_p': topP,
        'frequency_penalty': frequencyPenalty,
        'presence_penalty': presencePenalty,
        'stop': stop,
      });
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      };

      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);
      if (response.statusCode != 200) {}

      final responseBody = await jsonDecode(response.body)['choices'];
      setState(() {
        loading = false;
      });

      return await responseBody[0]['text'];
    } catch (e) {
      ScaffoldMessenger.maybeOf(context)!
          .showSnackBar(const SnackBar(content: Text('Something went wrong!')));
      setState(() {
        loading = false;
      });
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
          body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Ask me anything ?',
                style: TextStyle(fontSize: 30),
              ),
              const SizedBox(
                height: 15,
              ),
              TextField(
                controller: questionText,
                decoration: InputDecoration(
                    enabledBorder: outlineInputBorder,
                    focusedBorder: outlineInputBorder),
              ),
              if (ans != '' && ans.isNotEmpty)
                Container(
                  width: double.infinity,
                  height: 150,
                  margin: const EdgeInsets.only(top: 10),
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                  decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(15)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ans:',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                            child: Text(
                          '${ans.substring(1, 2).toUpperCase()}${ans.substring(2)}',
                          style: const TextStyle(fontSize: 18),
                        ))
                      ]),
                ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 100,
                height: 60,
                child: loading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.black),
                      )
                    : Builder(builder: (context) {
                        return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                backgroundColor: Colors.black),
                            onPressed: () async {
                              if (questionText.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('TextField cannot be empty')));
                              } else {
                                ans = await createCompletion(questionText.text);
                                setState(() {
                                  ans = ans;
                                });
                              }
                            },
                            child: const Text('Submit'));
                      }),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
