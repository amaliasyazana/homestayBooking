import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewBookingPage extends StatelessWidget {
  const ViewBookingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Bookings')),
        body: const Center(child: Text('Please log in to view your bookings.')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('bookings')
            .where('email', isEqualTo: user.email)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No bookings found.'));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final booking = docs[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Homestay: ${booking['homestay'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Check-in: ${booking['checkInDate']?.toDate().toString().split(' ')[0] ?? ''}'),
                      Text('Check-out: ${booking['checkOutDate']?.toDate().toString().split(' ')[0] ?? ''}'),
                      Text('Total Price: RM${booking['totalPrice'] ?? ''}'),
                      Text('Approval Status: ${booking['approval'] ?? 'pending'}', style: TextStyle(
                        color: booking['approval'] == 'approved' ? Colors.green : booking['approval'] == 'rejected' ? Colors.red : Colors.orange,
                        fontWeight: FontWeight.bold,
                      )),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
