import 'package:flutter/material.dart';
import '../models/homestay.dart';
import 'bookingFormPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomestayDetailPage extends StatefulWidget {
  final Homestay homestay;
  const HomestayDetailPage({Key? key, required this.homestay}) : super(key: key);

  @override
  State<HomestayDetailPage> createState() => _HomestayDetailPageState();
}

class _HomestayDetailPageState extends State<HomestayDetailPage> {
  Future<bool> isDateAvailable(DateTime start, DateTime end) async {
    final bookingsCollection = FirebaseFirestore.instance.collection('bookings');
    final query = await bookingsCollection
        .where('homestay', isEqualTo: widget.homestay.houseName)
        .get();
    for (var doc in query.docs) {
      final existingStart = (doc['checkInDate'] as Timestamp).toDate();
      final existingEnd = (doc['checkOutDate'] as Timestamp).toDate();
      // Check for overlap
      if (!(end.isBefore(existingStart) || start.isAfter(existingEnd))) {
        return false;
      }
    }
    return true;
  }
  DateTime? _startDate;
  DateTime? _endDate;
  // Removed guest selector
  String _paymentMethod = 'Online Banking';

  int get _totalPrice {
    if (_startDate == null || _endDate == null) return 0;
    final nights = _endDate!.difference(_startDate!).inDays;
    return nights > 0 ? nights * widget.homestay.price : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.homestay.houseName),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  widget.homestay.imageUrl,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 220,
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.home, size: 48)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(widget.homestay.houseName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Category: ${widget.homestay.category}', style: const TextStyle(fontSize: 18, color: Colors.grey)),
              Text('Capacity: ${widget.homestay.capacity}', style: const TextStyle(fontSize: 18, color: Colors.grey)),
              const SizedBox(height: 8),
              Text('Price: RM${widget.homestay.price}/night', style: const TextStyle(fontSize: 20, color: Colors.indigo)),
              const SizedBox(height: 16),
              const Text('Description:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Enjoy a comfortable stay at ${widget.homestay.houseName}. Perfect for families and groups. Book now for a memorable experience!',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              // Booking Section
              const Text('Booking Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    bool available = await isDateAvailable(picked.start, picked.end);
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
                    setState(() {
                      _startDate = picked.start;
                      _endDate = picked.end;
                    });
                  }
                },
                child: Text(_startDate == null || _endDate == null
                    ? 'Select Dates'
                    : '${_startDate!.toLocal().toString().split(' ')[0]} - ${_endDate!.toLocal().toString().split(' ')[0]}'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Payment: '),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _paymentMethod,
                    items: const [
                      DropdownMenuItem(value: 'Online Banking', child: Text('Online Banking')),
                      DropdownMenuItem(value: 'Credit Card', child: Text('Credit Card')),
                      DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _paymentMethod = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('Total Price: RM$_totalPrice', style: const TextStyle(fontSize: 18, color: Colors.indigo)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _startDate != null && _endDate != null
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookingFormPage(
                                homestay: widget.homestay,
                                startDate: _startDate!,
                                endDate: _endDate!,
                                paymentMethod: _paymentMethod,
                                totalPrice: _totalPrice,
                              ),
                            ),
                          );
                        }
                      : null,
                  child: const Text('Book Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
