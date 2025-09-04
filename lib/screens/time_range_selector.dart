// lib/widgets/time_range_selector.dart
import 'package:flutter/material.dart';

class TimeRangeSelector extends StatelessWidget {
  final int selectedHours;
  final Function(int) onChanged;

  const TimeRangeSelector({
    super.key,
    required this.selectedHours,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final timeRanges = [
      {'label': '1 giờ', 'hours': 1},
      {'label': '6 giờ', 'hours': 6},
      {'label': '24 giờ', 'hours': 24},
      {'label': '7 ngày', 'hours': 168},
      {'label': '30 ngày', 'hours': 720},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Color(0xFF00BCD4)),
            const SizedBox(width: 12),
            const Text(
              'Khoảng thời gian:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            ...timeRanges.map(
              (range) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(range['label'] as String),
                  selected: selectedHours == range['hours'],
                  onSelected: (_) => onChanged(range['hours'] as int),
                  selectedColor: const Color(0xFF00BCD4).withOpacity(0.3),
                  checkmarkColor: const Color(0xFF00BCD4),
                  labelStyle: TextStyle(
                    color:
                        selectedHours == range['hours']
                            ? const Color(0xFF00BCD4)
                            : Colors.white70,
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
