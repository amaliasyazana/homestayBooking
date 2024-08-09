import 'package:flutter/material.dart';
import '../models/homestay.dart';
import 'bookingscreen.dart';

class DescriptionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Homestay homestay =
        ModalRoute.of(context)!.settings.arguments as Homestay;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo[900],
        title: Text('Homestay Details', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Centered House Name as a title with cursive font
            Image.network(
              homestay.imageUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            Text(
              homestay.houseName,
              style: TextStyle(
                fontSize: 36.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Pacifico', // Set the cursive font
                color: Colors.indigo[900],
              ),
            ),
            SizedBox(height: 16.0),

            // Divider for separation
            Container(
              width: 100.0,
              height: 2.0,
              color: Colors.indigo[900],
              margin: EdgeInsets.symmetric(vertical: 10.0),
            ),

            // Other details with improved styling
            DetailsCard(label: 'Category', value: homestay.category),
            DetailsCard(label: 'Capacity', value: homestay.capacity.toString()),
            DetailsCard(
                label: 'Price', value: '\RM${homestay.price.toString()}'),
            // Add more details as needed

            // Book Homestay Button
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BookingScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[900],
                padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text('Book Homestay'),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailsCard extends StatelessWidget {
  final String label;
  final String value;

  DetailsCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 200.0, // Set the desired width
        margin: EdgeInsets.symmetric(vertical: 8.0),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.indigo[100], // Light blue background color
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.indigo[900],
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              value,
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
