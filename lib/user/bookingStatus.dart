import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/booking.dart';
import '../repository/booking_repository.dart';

class BookingStatusPage extends StatelessWidget {
  final BookingModel booking;
  final BookingRepository _bookingRepository = BookingRepository.instance;
  static BookingRepository get instance => Get.put(BookingRepository());

  BookingStatusPage({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Status', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FutureBuilder<List<BookingModel>>(
                future: _bookingRepository.getBookings().first,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('No booking data available.');
                  } else {
                    List<BookingModel> bookings = snapshot.data!;
                    return Column(
                      children: bookings.map((booking) {
                        Color statusColor = Colors.white; // Default color

                        // Set background color based on the status
                        if (booking.approval == 'pending') {
                          statusColor = Color.fromARGB(255, 255, 249, 182);
                        } else if (booking.approval == 'Approved') {
                          statusColor = Color.fromARGB(255, 154, 255, 156);
                        } else if (booking.approval == 'Not Approved') {
                          statusColor = Color.fromARGB(255, 255, 158, 151);
                        }

                        return Center(
                          child: Container(
                            width: 300.0, // Adjust the width as needed
                            child: Card(
                              color: statusColor,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Full Name: ${booking.name}'),
                                    SizedBox(height: 8.0),
                                    Text('Homestay Name: ${booking.homestay}'),
                                    SizedBox(height: 8.0),
                                    Text('Status: ${booking.approval}'),
                                    // SizedBox(height: 8.0),
                                    // Text('Keycode: ${booking.keycode}'),
                                    // Add other fields here, such as phone number, email, date, etc.
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
