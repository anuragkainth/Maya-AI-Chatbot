import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gpt_app/secrets.dart';
import 'package:http/http.dart' as http;

class OpenAIServices {

  final List<Map<String,String>> messages = [];

  Future<String> isArtPrompt(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey"
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              "role": "user",
              "content":
                  "Does this message have words 'generate' and 'image' in it?: $prompt . Simply answer with a yes or a no."
            },
          ]
        }),
      );
      print(response.body);
      if (response.statusCode == 200) {

        String content = jsonDecode(response.body)["choices"][0]["message"]["content"];
        content = content.trim();

        switch(content){
          case 'yes':
          case 'Yes':
          case 'yes.':
          case 'Yes.':
            final res = dallEAPI(prompt);
            return res;
          default:
            final res = await chatGPTApi('You are a AI voice assistant called Maya, built by Anurag Kainth, here is some prompt for you: $prompt. response in maximum 50 words');
            return res;
        }
      }
      return 'An Internal Error Occurred.';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> chatGPTApi(String prompt) async {
    messages.add({
      "role": "user",
      "content": prompt
    });
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey"
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": messages
        }),
      );
      print(response.body);
      if (response.statusCode == 200) {

        String content = jsonDecode(response.body)["choices"][0]["message"]["content"];
        content = content.trim();
        
        messages.add({
          'role': 'assistant',
          'content': content
        });
        return content;
      }
      return 'An Internal Error Occurred.';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> dallEAPI(String prompt) async {
    messages.add({
      "role": "user",
      "content": prompt
    });
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey"
        },
        body: jsonEncode({
          "prompt": prompt,
          "n": 1,
          "size": "1024x1024"
        }),
      );
      print(response.body);
      if (response.statusCode == 200) {

        String imageUrl = jsonDecode(response.body)["data"][0]["url"];

        messages.add({
          'role': 'assistant',
          'content': imageUrl
        });

        return imageUrl;
      }
      return 'An Internal Error Occurred.';
    } catch (e) {
      return e.toString();
    }
  }
}
