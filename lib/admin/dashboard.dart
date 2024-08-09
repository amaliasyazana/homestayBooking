import 'package:annahomestay/admin/manage_property.dart';
import 'package:annahomestay/controller/manageBooking_controller.dart';
import 'package:annahomestay/controller/manageProperty_controller.dart';
import 'package:annahomestay/login/loginPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/booking.dart';
import '../repository/booking_repository.dart';
import 'manage_booking.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final homestayController = Get.put(HomestayController());
  final bookingController = Get.put(BookingController());
  final BookingRepository _bookingRepository = BookingRepository.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo[800],
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()));
            },
            icon: const Icon(Icons.logout_outlined),
            color: Colors.white,
          )
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20.0),
              Text(
                'WELCOME, ADMIN!',
                style: TextStyle(
                  fontSize: 34.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[900],
                ),
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      MaterialPageRoute route = MaterialPageRoute(
                          builder: (context) => const ManageProperty());
                      Navigator.push(context, route);
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(170, 150),
                      backgroundColor: Colors.indigo[100],
                      shape: const OvalBorder(),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.network(
                          'https://icons.veryicon.com/png/o/miscellaneous/home-icon-1/house-add.png',
                          height: 35,
                          width: 35,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 8.0),
                        const Expanded(
                          child: Text(
                            'Manage Property Listings',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.indigo),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      List<BookingModel> bookings =
                          await _bookingRepository.getBookings().first;
                      MaterialPageRoute route = MaterialPageRoute(
                          builder: (context) => ManageBooking());
                      Navigator.push(context, route);
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(170, 150),
                      backgroundColor: Colors.indigo[100],
                      shape: const OvalBorder(),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          'https://cdn-icons-png.flaticon.com/512/4336/4336640.png',
                          height: 35,
                          width: 35,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 8.0),
                        const Expanded(
                          child: Text(
                            'Manage Customer Booking',
                            style: TextStyle(color: Colors.indigo),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FutureBuilder<int>(
                    future: homestayController.getTotalPropertyCount(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return AnalyticsLayout1(
                          controller: homestayController, // Pass the controller
                          title: 'Total Listings',
                          value: snapshot.data?.toString() ?? '0',
                        );
                      }
                    },
                  ),
                  //Add other analytics layouts if needed
                  FutureBuilder<int>(
                    future: bookingController.getTotalBookingCount(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return AnalyticsLayout2(
                          controller: bookingController, // Pass the controller
                          title: 'Total Bookings',
                          value: snapshot.data?.toString() ?? '0',
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnalyticsLayout1 extends StatelessWidget {
  final HomestayController controller; // Pass the controller as a parameter
  final String title;
  final String value;

  AnalyticsLayout1({
    Key? key,
    required this.controller,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.indigo[100],
      ),
      child: Column(
        children: [
          FutureBuilder<int>(
            future: controller.getTotalPropertyCount(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return Text(
                  snapshot.data?.toString() ?? '0',
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }
            },
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }
}

class AnalyticsLayout2 extends StatelessWidget {
  final BookingController controller; // Pass the controller as a parameter
  final String title;
  final String value;

  AnalyticsLayout2({
    Key? key,
    required this.controller,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.indigo[100],
      ),
      child: Column(
        children: [
          FutureBuilder<int>(
            future: controller.getTotalBookingCount(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return Text(
                  snapshot.data?.toString() ?? '0',
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }
            },
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }
}
