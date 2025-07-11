import 'package:flutter/material.dart';

class HotelBookingPage extends StatelessWidget {
  final String? destinationId;

  const HotelBookingPage({super.key, this.destinationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hotel Booking')),
      body: Center(
        child: Text(
          'Hotel Booking Page\n${destinationId != null ? 'Destination: $destinationId' : ''}',
          style: const TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
