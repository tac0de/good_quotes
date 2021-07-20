import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

Future<List<Quote>> fetchQuotes() async {
  final response = await rootBundle.loadString('assets/json/quotes.json');
  return compute(parseQuotes, response);
}

List<Quote> parseQuotes(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Quote>((json) => Quote.fromJson(json)).toList();
}

class Quote {
  final String topic;
  final String quote;
  final String author;

  Quote({this.topic, this.quote, this.author});

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      topic: json['topic'] as String,
      quote: json['quote'] as String,
      author: json['author'] as String,
    );
  }
}
