import 'package:flutter/material.dart';

class NearbyPlaceSkeletonCard extends StatelessWidget {
  const NearbyPlaceSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 172,
      height: 86,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Container(height: 8, width: 120, color: Colors.grey.shade300),
            const SizedBox(height: 4),
            Container(height: 6, width: 80, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}
