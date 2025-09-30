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
  String? _selectedHomestay;

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: FutureBuilder<List<BookingModel>>(
              future: controller.getAllBookingDetails(),
              builder: (context, snapshot) {
                List<String> homestayNames = [];
                if (snapshot.hasData) {
                  homestayNames = snapshot.data!
                      .map((b) => b.homestay)
                      .toSet()
                      .toList();
                  homestayNames.sort();
                }
                return DropdownButton<String>(
                  value: _selectedHomestay,
                  hint: Text('Filter by Homestay'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Homestays')),
                    ...homestayNames.map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedHomestay = value;
                    });
                  },
                  isExpanded: true,
                );
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<BookingModel>>(
                future: controller.getAllBookingDetails(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final filtered = _selectedHomestay == null || _selectedHomestay == ''
                        ? snapshot.data!
                        : snapshot.data!.where((b) => b.homestay == _selectedHomestay).toList();
                    // Sorting order: 'pending', 'Approved', 'Not Approved'
                    filtered.sort((a, b) {
                      if (a.approval == 'pending' || a.approval == 'Pending') {
                        return -1; // 'pending' comes first
                      } else if (b.approval == 'pending' || b.approval == 'Pending') {
                        return 1;
                      } else if (a.approval == 'Approved' || a.approval == 'approved') {
                        return -1; // 'Approved' comes next
                      } else if (b.approval == 'Approved' || b.approval == 'approved') {
                        return 1;
                      } else {
                        return 0; // 'Not Approved' comes last
                      }
                    });
                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final booking = filtered[index];
                        return SizedBox(
                            child: Card(
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
                                          booking.homestay,
                                          style: const TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        // ...other info...
                                        Text(
                                          'Approval: ${booking.approval}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: booking.approval ==
                                                    'pending' || booking.approval == 'Pending'
                                                ? Colors.orange
                                                : booking.approval ==
                                                        'Approved' || booking.approval == 'approved'
                                                    ? Colors.green
                                                    : Colors.red,
                                          ),
                                        ),
                                        const SizedBox(height: 8.0),
                                        Text('Name: ' + booking.name),
                                        const SizedBox(height: 8.0),
                                        Text('Email: ' + booking.email),
                                        const SizedBox(height: 8.0),
                                        Text('Phone: ' + booking.phone),
                                        const SizedBox(height: 8.0),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (booking.approval == 'pending')
                                Positioned(
                                  bottom: 16.0,
                                  right: 16.0,
                                  child: FloatingActionButton.extended(
                                    onPressed: () {
                                      handleApproval(context, booking);
                                    },
                                    label: const Text('Approval'),
                                  ),
                                ),
                            ],
                          ),
                        ));
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                }),
          ),
        ],
      ),
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
