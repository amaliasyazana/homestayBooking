import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../repository/booking_repository.dart';
import 'package:get/get.dart';

import '../repository/homestay_repository.dart';

class AvailabilityScreen extends StatefulWidget {
  @override
  _AvailabilityScreenState createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  DateTime? checkInDate;
  DateTime? checkOutDate;
  String selectedHomestay = ''; // Can be left empty to check all homestays
  Map<String, Map<String, dynamic>> availability =
      {}; // Modified to include price and capacity
  List<String> homestayNames = [];
  List<String> homestayDetails = [];

  @override
  void initState() {
    super.initState();
    _loadHomestayDetails();
    Get.put(BookingRepository());
    Get.put(HomestayRepository());
  }

  Future<void> _loadHomestayDetails() async {
    try {
      var details = await HomestayRepository.instance.fetchHomestayNames();
      setState(() {
        homestayDetails = details;
      });
    } catch (e) {
      print("Error loading homestay details: $e");
    }
  }

  Future<void> fetchAndDisplayAvailability() async {
    if (checkInDate != null && checkOutDate != null) {
      try {
        // Convert DateTime to Timestamp
        Timestamp checkInTimestamp = Timestamp.fromDate(checkInDate!);
        Timestamp checkOutTimestamp = Timestamp.fromDate(checkOutDate!);

        var availabilityData = await BookingRepository.instance
            .checkAvailabilityForEachHouse(checkInTimestamp, checkOutTimestamp);
        setState(() {
          availability = availabilityData;
        });
      } catch (e) {
        print("Error fetching availability: $e");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select both check-in and check-out dates.'),
          duration: Duration(seconds: 5),
          backgroundColor: Colors.red, // You can adjust the duration as needed
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Homestay Availability',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo[900], // Dark blue app bar
      ),
      backgroundColor: Colors.white, // White background
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Date selection widgets
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: checkInDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (picked != null) setState(() => checkInDate = picked);
                  },
                  child: Text(
                    'Check-in Date',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo[900]), // Dark blue button
                ),
                Text(
                  checkInDate == null
                      ? 'Not selected'
                      : '${checkInDate!.toLocal()}'.split(' ')[0],
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: checkOutDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (picked != null) setState(() => checkOutDate = picked);
                  },
                  child: Text(
                    'Check-out Date',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo[900]), // Dark blue button
                ),
                Text(
                  checkOutDate == null
                      ? 'Not selected'
                      : '${checkOutDate!.toLocal()}'.split(' ')[0],
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          // Button to check availability
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  fetchAndDisplayAvailability(); // Call the function when the button is pressed
                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Check Availability',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ), // Dark blue button
              ),
            ),
          ),

          // Displaying availability using Card widgets
          Expanded(
            child: ListView.builder(
              itemCount: availability.length,
              itemBuilder: (context, index) {
                String homestayName = availability.keys.elementAt(index);
                Map<String, dynamic> homestayInfo = availability[homestayName]!;
                bool isAvailable = homestayInfo['Available'];
                int price = homestayInfo['Price'];
                int capacity = homestayInfo['Capacity'];

                return Card(
                  color: isAvailable ? Colors.green : Colors.red,
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                      homestayName,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ), // White text
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAvailable ? 'Available' : 'Not Available',
                          style: TextStyle(
                            color: Colors.white,
                          ), // White text
                        ),
                        Text(
                          'Price: \$${price.toString()}',
                          style: TextStyle(
                            color: Colors.white,
                          ), // White text
                        ),
                        Text(
                          'Capacity: $capacity',
                          style: TextStyle(
                            color: Colors.white,
                          ), // White text
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
