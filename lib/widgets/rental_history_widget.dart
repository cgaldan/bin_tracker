import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/rental_record.dart';

class RentalHistoryWidget extends StatelessWidget {
  final List<int> rentalHistory;
  final Box<RentalRecord> rentalsBox;
  final int maxItems;

  const RentalHistoryWidget({
    super.key,
    required this.rentalHistory,
    required this.rentalsBox,
    this.maxItems = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (rentalHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedHistory = rentalHistory.reversed.toList();
    final limitedHistory = sortedHistory.take(maxItems).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rental History',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...limitedHistory.map((rentalKey) {
          final rental = rentalsBox.get(rentalKey);
          if (rental == null) return const SizedBox.shrink();

          return _RentalHistoryCard(rental: rental);
        }),
      ],
    );
  }
}

class _RentalHistoryCard extends StatelessWidget {
  final RentalRecord rental;

  const _RentalHistoryCard({required this.rental});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                rental.renterName.isNotEmpty
                    ? rental.renterName
                    : 'Unknown Renter',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              _StatusBadge(state: rental.state),
            ],
          ),
          if (rental.renterPhone.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Phone: ${rental.renterPhone}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
          if (rental.renterLoc.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Location: ${rental.renterLoc}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            'Duration: ${(rental.plannedSeconds / 86400).round()} days',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          if (rental.startDate != null) ...[
            const SizedBox(height: 4),
            Text(
              'Started: ${_formatDate(rental.startDate!)}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
          if (rental.endedAt != null) ...[
            const SizedBox(height: 4),
            Text(
              'Ended: ${_formatDate(rental.endedAt!)}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  final RentalState state;

  const _StatusBadge({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: switch (state) {
          RentalState.active => Colors.green.shade100,
          RentalState.paused => Colors.orange.shade100,
          RentalState.completed => Colors.blue.shade100,
        },
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        switch (state) {
          RentalState.active => 'Active',
          RentalState.paused => 'Paused',
          RentalState.completed => 'Completed',
        },
        style: TextStyle(
          fontSize: 12,
          color: switch (state) {
            RentalState.active => Colors.green.shade700,
            RentalState.paused => Colors.orange.shade700,
            RentalState.completed => Colors.blue.shade700,
          },
        ),
      ),
    );
  }
}
