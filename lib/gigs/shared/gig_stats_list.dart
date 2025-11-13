import 'package:flutter/material.dart';

class GigStatsList extends StatelessWidget {
  final List<String> items;

  const GigStatsList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((e) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              const Icon(Icons.check_circle, size: 18, color: Colors.blue),
              const SizedBox(width: 6),
              Text(e),
            ],
          ),
        );
      }).toList(),
    );
  }
}
