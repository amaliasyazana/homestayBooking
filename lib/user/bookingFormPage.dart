import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/homestay.dart';

class BookingFormPage extends StatefulWidget {
  final Homestay homestay;
  final DateTime startDate;
  final DateTime endDate;
  final String paymentMethod;
  final int totalPrice;
  const BookingFormPage({
    Key? key,
    required this.homestay,
    required this.startDate,
    required this.endDate,
    required this.paymentMethod,
    required this.totalPrice,
  }) : super(key: key);

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  Future<bool> isDateAvailable() async {
    final query = await bookingsCollection
        .where('homestay', isEqualTo: widget.homestay.houseName)
        .get();
    for (var doc in query.docs) {
      final existingStart = (doc['checkInDate'] as Timestamp).toDate();
      final existingEnd = (doc['checkOutDate'] as Timestamp).toDate();
      // Check for overlap
      if (!(widget.endDate.isBefore(existingStart) || widget.startDate.isAfter(existingEnd))) {
        return false;
      }
    }
    return true;
  }
  final CollectionReference bookingsCollection =
      FirebaseFirestore.instance.collection('bookings');
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _phone = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Information')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Homestay: ${widget.homestay.houseName}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Dates: ${widget.startDate.toLocal().toString().split(' ')[0]} - ${widget.endDate.toLocal().toString().split(' ')[0]}'),
              Text('Payment: ${widget.paymentMethod}'),
              Text('Total Price: RM${widget.totalPrice}'),
              const SizedBox(height: 24),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
                onSaved: (value) => _name = value ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value == null || value.isEmpty ? 'Please enter your email' : null,
                onSaved: (value) => _email = value ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty ? 'Please enter your phone number' : null,
                onSaved: (value) => _phone = value ?? '',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // Check for date conflict
                      bool available = await isDateAvailable();
                      if (!available) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Booking Error'),
                            content: const Text('Selected dates are already booked for this homestay.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                        return;
                      }
                      // Save booking to Firestore
                      await bookingsCollection.add({
                        'name': _name,
                        'email': _email,
                        'phone': _phone,
                        'homestay': widget.homestay.houseName,
                        'checkInDate': widget.startDate,
                        'checkOutDate': widget.endDate,
                        'paymentMethod': widget.paymentMethod,
                        'totalPrice': widget.totalPrice,
                        'timestamp': FieldValue.serverTimestamp(),
                        'approval': 'pending',
                      });
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Booking Submitted'),
                          content: Text('Thank you, $_name! Your booking request has been submitted and is pending admin approval.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: const Text('Confirm Booking'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
