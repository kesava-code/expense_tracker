import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onTap;

  const SummaryCard({
    super.key,
    required this.title,
    required this.content,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(
                  content,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
            const Icon(Icons.arrow_forward),
          ],
        ),
      ),
    );
  }
}
