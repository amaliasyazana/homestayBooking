import 'package:annahomestay/controller/manageBooking_controller.dart';
import 'package:annahomestay/models/booking.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final controller = Get.put(BookingController());

class ManageBooking extends StatefulWidget {
  const ManageBooking({super.key});

  @override
  State<ManageBooking> createState() => _ManageBookingState();
}

class _ManageBookingState extends State<ManageBooking> {
  //String approvalValue = 'Approved';

  // Custom method to format timestamp as ddmmyy
  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String day = dateTime.day.toString().padLeft(2, '0');
    String month = dateTime.month.toString().padLeft(2, '0');
    String year = dateTime.year.toString().substring(0);
    return "$day-$month-$year";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Customer Booking',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo[900],
      ),
      body: FutureBuilder<List<BookingModel>>(
          future: controller.getAllBookingDetails(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (c, index) {
                    // Sorting order: 'pending', 'Approved', 'Not Approved'
                    snapshot.data!.sort((a, b) {
                      if (a.approval == 'pending') {
                        return -1; // 'pending' comes first
                      } else if (b.approval == 'pending') {
                        return 1;
                      } else if (a.approval == 'Approved') {
                        return -1; // 'Approved' comes next
                      } else if (b.approval == 'Approved') {
                        return 1;
                      } else {
                        return 0; // 'Not Approved' comes last
                      }
                    });
                    Color? cardColor = snapshot.data![index].approval ==
                            'pending'
                        ? Colors.red[200]
                        : snapshot.data![index].approval == 'Approved'
                            ? Colors.green[200]
                            : Colors
                                .white; // Default color if neither Approved nor Not Approved
                    return SizedBox(
                        child: Card(
                      color: cardColor,
                      margin: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      snapshot.data![index].homestay,
                                      style: const TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      snapshot.data![index].approval,
                                      style: TextStyle(
                                        color: snapshot.data![index].approval ==
                                                'Not Approved'
                                            ? Colors.blue
                                            : snapshot.data![index].approval ==
                                                    'Approved'
                                                ? Colors.green
                                                : snapshot.data![index]
                                                            .approval ==
                                                        'pending'
                                                    ? Colors.red
                                                    : null,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text('Name: ' + snapshot.data![index].name),
                                    const SizedBox(height: 8.0),
                                    Text('Email: ' +
                                        snapshot.data![index].email),
                                    const SizedBox(height: 8.0),
                                    Text('Phone: ' +
                                        snapshot.data![index].phone),
                                    const SizedBox(height: 8.0),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (snapshot.data![index].approval == 'pending')
                            Positioned(
                              bottom: 16.0,
                              right: 16.0,
                              child: FloatingActionButton.extended(
                                onPressed: () {
                                  handleApproval(
                                      context, snapshot.data![index]);
                                },
                                label: const Text('Approval'),
                              ),
                            ),
                        ],
                      ),
                    ));
                  });
            } else if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}

class ApprovalDialog extends StatefulWidget {
  final BookingModel booking;

  ApprovalDialog({required this.booking});

  @override
  _ApprovalDialogState createState() => _ApprovalDialogState();
}

class _ApprovalDialogState extends State<ApprovalDialog> {
  String? approvalValue;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Approval'),
      content: Column(
        children: [
          RadioListTile(
            title: const Text('Approve'),
            value: 'Approved',
            groupValue: approvalValue,
            onChanged: (value) {
              setState(() {
                approvalValue = value as String;
              });
            },
          ),
          RadioListTile(
            title: const Text('Not Approve'),
            value: 'Not Approved',
            groupValue: approvalValue,
            onChanged: (value) {
              setState(() {
                approvalValue = value as String;
              });
            },
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            // Handle the approval decision
            if (approvalValue != null) {
              controller.updateApproval(widget.booking, approvalValue!);
              Navigator.of(context).pop();
              setState(() {});
            } else {
              // Show a message indicating that a choice must be made
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

void handleApproval(BuildContext context, BookingModel booking) {
  showDialog(
    context: context,
    builder: (context) {
      return ApprovalDialog(booking: booking);
    },
  );
}
