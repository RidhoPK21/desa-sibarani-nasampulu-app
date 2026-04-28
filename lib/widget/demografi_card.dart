import 'package:flutter/material.dart';

class DemografiSection extends StatelessWidget {
  const DemografiSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: const [
            Expanded(child: _StatCard(label: 'TOTAL\nPENDUDUK', value: '110', sub: 'Jiwa')),
            SizedBox(width: 12),
            Expanded(child: _StatCard(label: 'Laki - Laki', value: '50')),
            SizedBox(width: 12),
            Expanded(child: _StatCard(label: 'Perempuan', value: '60')),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Lihat Detail Infografis Publik',
              style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final String? sub;
  const _StatCard({required this.label, required this.value, this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.person_outline, color: Colors.white70, size: 28),
          const SizedBox(height: 6),
          Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 10)),
          Text(value,
            style: const TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          if (sub != null)
            Text(sub!, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }
}