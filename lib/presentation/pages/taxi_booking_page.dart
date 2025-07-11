import 'package:flutter/material.dart';

class TaxiBookingPage extends StatelessWidget {
  final String? destinationId;

  const TaxiBookingPage({super.key, this.destinationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Taxi Booking')),
      body: Center(
        child: Text(
          'Taxi Booking Page\n${destinationId != null ? 'Destination: $destinationId' : ''}',
          style: const TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
