import 'package:annahomestay/user/homestayFilter.dart';
import 'package:annahomestay/user/profile/profilePage.dart';
import 'package:flutter/material.dart';

import '../login/loginPage.dart';
import '../models/booking.dart';
import '../models/homestay.dart';
import '../repository/booking_repository.dart';
import '../repository/homestay_repository.dart';
import 'bookingstatus.dart';

class ListScreen extends StatelessWidget {
  final HomestayRepository _homestayRepository = HomestayRepository.instance;
  final BookingRepository _bookingRepository = BookingRepository.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo[900],
        title: Center(
          child: Text(
            'ANNA HOMESTAY',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            // Handle the profile icon click
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => ProfilePage()));
            // You can navigate to the user profile page or show a user menu here
          },
          icon: Icon(
            Icons.account_circle,
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              disabledBackgroundColor: Colors.orange[300],
              backgroundColor: Colors.indigo[900],
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => HomestayFilterPage()));
            },
            child: Row(
              children: [
                Icon(Icons.book),
                SizedBox(width: 8.0),
                Text('BOOK NOW'),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const LoginPage()));
                  },
                  icon: const Icon(Icons.logout_outlined),
                  color: Colors.white,
                )
              ],
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'WELCOME TO ANNA HOMESTAY!',
                  style: TextStyle(
                    fontSize: 34.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[900],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.0),
                Container(
                  // Applying gradient
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.indigo.shade50, Colors.indigo.shade200],
                    ),
                    color: Colors.indigo[50],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    'Discover the art of hospitality in every corner of comfort – where cherished memories are crafted, and moments become stories. Welcome to a homestay experience beyond the ordinary, where the warmth of home meets the adventure of travel.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.indigo[500],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Homestay>>(
              future: _homestayRepository.getAllHomestayDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No homestay data available.');
                } else {
                  List<Homestay> homestays = snapshot.data!;
                  return ListView.builder(
                    itemCount: homestays.length,
                    itemBuilder: (context, index) {
                      return HomestayRow(homestay: homestays[index]);
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                // Fetch the actual booking details from Firestore
                List<BookingModel> bookings =
                    await _bookingRepository.getBookings().first;

                if (bookings.isNotEmpty) {
                  // Pass the first booking details to the BookingStatusPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingStatusPage(
                        booking: bookings.first,
                      ),
                    ),
                  );
                } else {
                  // Handle the case where no booking data is available
                  // You can show a snackbar or navigate to an error page
                  print('No booking data available.');
                }
              },
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: Colors.indigo[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Container(
                width: 150.0, // Adjust the width as needed
                height: 50.0,
                child: Center(
                  child: Text(
                    'Booking Status',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.orange[200],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomestayRow extends StatefulWidget {
  final Homestay homestay;

  HomestayRow({required this.homestay});

  @override
  _HomestayRowState createState() => _HomestayRowState();
}

class _HomestayRowState extends State<HomestayRow> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/description',
            arguments: widget.homestay,
          );
        },
        child: Card(
          elevation: isHovered ? 8.0 : 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          color: widget.homestay.category == 'A'
              ? Colors.red[200]
              : widget.homestay.category == 'B'
                  ? Colors.orange[200]
                  : widget.homestay.category == 'C'
                      ? Colors.blue[200]
                      : widget.homestay.category == 'D'
                          ? Colors.purple[200]
                          : isHovered
                              ? Colors.indigo[300]
                              : Colors.indigo[200],
          child: Container(
            width: 200,
            height: 100,
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: AnimatedDefaultTextStyle(
                duration: Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: isHovered ? 20.0 : 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                child: Text(
                  widget.homestay.houseName,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
