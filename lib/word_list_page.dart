import 'package:flutter/material.dart';

import 'word_model.dart';

class WordListPage extends StatelessWidget {
  const WordListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelime Listesi'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: basicWords.length,
        itemBuilder: (context, index) {
          final word = basicWords[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: Text(word.english),
                subtitle: Text(word.turkish),
              ),
            ),
          );
        },
      ),
    );
  }
}
