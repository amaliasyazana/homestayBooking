import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'manage_property.dart';

class _AdminActionIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AdminActionIcon({
    required this.icon,
    required this.label,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(icon, size: 32, color: Colors.indigo),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// --- Search Delegate for Admin Booking ---
class AdminBookingSearchDelegate extends SearchDelegate<String> {
  final Future<List<Map<String, dynamic>>> bookingsFuture;
  AdminBookingSearchDelegate(this.bookingsFuture);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, ''));
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: bookingsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final results = snapshot.data!.where((b) => (b['name'] ?? '').toString().toLowerCase().contains(query.toLowerCase()) || (b['homestay'] ?? '').toString().toLowerCase().contains(query.toLowerCase())).toList();
        return ListView(
          children: results.map((b) => ListTile(
            title: Text(b['name'] ?? ''),
            subtitle: Text(b['homestay'] ?? ''),
            onTap: () => close(context, b['name'] ?? ''),
          )).toList(),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: bookingsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final suggestions = snapshot.data!.where((b) => (b['name'] ?? '').toString().toLowerCase().contains(query.toLowerCase()) || (b['homestay'] ?? '').toString().toLowerCase().contains(query.toLowerCase())).toList();
        return ListView(
          children: suggestions.map((b) => ListTile(
            title: Text(b['name'] ?? ''),
            subtitle: Text(b['homestay'] ?? ''),
            onTap: () => close(context, b['name'] ?? ''),
          )).toList(),
        );
      },
    );
  }
}

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with SingleTickerProviderStateMixin {
  late Future<List<Map<String, dynamic>>> _pendingBookingsFuture;
  late Future<List<Map<String, dynamic>>> _allBookingsFuture;
  late TabController _tabController;
  String? _selectedHomestay;

  @override
  void initState() {
  super.initState();
  _pendingBookingsFuture = fetchPendingBookings();
  _allBookingsFuture = fetchAllBookings();
  _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> fetchPendingBookings() async {
  final snapshot = await FirebaseFirestore.instance
    .collection('bookings')
    .where('approval', isEqualTo: 'pending')
    .get();
  return snapshot.docs.map((doc) {
    final data = doc.data();
    data['bookingId'] = doc.id;
    return data;
  }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchAllBookings() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['bookingId'] = doc.id;
      return data;
    }).toList();
  }

  // String _searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(color: Colors.indigo)),
        backgroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.indigo),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.indigo,
          labelColor: Colors.indigo,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(
              icon: Icon(Icons.pending_actions, color: Colors.indigo),
              text: 'View Pendings',
            ),
            Tab(
              icon: Icon(Icons.list_alt, color: Colors.indigo),
              text: 'View All Bookings',
            ),
            Tab(
              icon: Icon(Icons.add_box, color: Colors.indigo),
              text: 'Add Listing',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // View Pendings Tab
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'Pending Bookings',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _pendingBookingsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No pending bookings.'));
                    } else {
                      final bookings = snapshot.data!;
                      return ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: bookings.length,
                        itemBuilder: (context, index) {
                          final booking = bookings[index];
                          return Container(
                            width: double.infinity,
                            child: Card(
                              margin: const EdgeInsets.all(20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 4,
                              color: Colors.indigo[50],
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Name: ${booking['name'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.indigo)),
                                    Text('Homestay: ${booking['homestay'] ?? ''}', style: const TextStyle(color: Colors.indigo)),
                                    Text('Check-in: ${booking['checkInDate']?.toDate().toString().split(' ')[0] ?? ''}'),
                                    Text('Check-out: ${booking['checkOutDate']?.toDate().toString().split(' ')[0] ?? ''}'),
                                    Text('Payment: ${booking['paymentMethod'] ?? ''}'),
                                    Text('Total Price: RM${booking['totalPrice'] ?? ''}', style: const TextStyle(color: Colors.amber)),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.indigo[700],
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          onPressed: () async {
                                            if (booking['bookingId'] != null) {
                                              await FirebaseFirestore.instance.collection('bookings').doc(booking['bookingId']).update({'approval': 'approved'});
                                              setState(() {
                                                _pendingBookingsFuture = fetchPendingBookings();
                                              });
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Booking approved.'),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text('Approve'),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red[400],
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          onPressed: () async {
                                            if (booking['bookingId'] != null) {
                                              await FirebaseFirestore.instance.collection('bookings').doc(booking['bookingId']).update({'approval': 'rejected'});
                                              setState(() {
                                                _pendingBookingsFuture = fetchPendingBookings();
                                              });
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Booking rejected.'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text('Reject'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          // View All Bookings Tab
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'All Bookings',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _allBookingsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No bookings found.'));
                    } else {
                      final bookings = snapshot.data!;
                      // Get unique homestay names
                      final homestayNames = bookings.map((b) => b['homestay'] as String? ?? '').toSet().toList();
                      // Filter bookings by selected homestay
                      final filteredBookings = _selectedHomestay == null || _selectedHomestay == ''
                          ? bookings
                          : bookings.where((b) => b['homestay'] == _selectedHomestay).toList();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Filter by Homestay',
                                border: OutlineInputBorder(),
                              ),
                              value: _selectedHomestay,
                              items: [
                                const DropdownMenuItem<String>(
                                  value: '',
                                  child: Text('All Homestays'),
                                ),
                                ...homestayNames.map((name) => DropdownMenuItem<String>(
                                      value: name,
                                      child: Text(name),
                                    ))
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedHomestay = value == '' ? null : value;
                                });
                              },
                            ),
                          ),
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: filteredBookings.length,
                            itemBuilder: (context, index) {
                              final booking = filteredBookings[index];
                              return Container(
                                width: double.infinity,
                                child: Card(
                                  margin: const EdgeInsets.all(20),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 4,
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Name: ${booking['name'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.indigo)),
                                        Text('Homestay: ${booking['homestay'] ?? ''}', style: const TextStyle(color: Colors.indigo)),
                                        Text('Check-in: ${booking['checkInDate']?.toDate().toString().split(' ')[0] ?? ''}'),
                                        Text('Check-out: ${booking['checkOutDate']?.toDate().toString().split(' ')[0] ?? ''}'),
                                        Text('Payment: ${booking['paymentMethod'] ?? ''}'),
                                        Text('Total Price: RM${booking['totalPrice'] ?? ''}', style: const TextStyle(color: Colors.amber)),
                                        Text(
                                          'Status: ' +
                                              (booking['approval'] == 'approved'
                                                  ? 'Approved'
                                                  : booking['approval'] == 'rejected'
                                                      ? 'rejected'
                                                      : booking['approval'] ?? ''),
                                          style: TextStyle(
                                            color: booking['approval'] == 'approved'
                                                ? Colors.green
                                                : booking['approval'] == 'rejected'
                                                    ? Colors.red
                                                    : Colors.orange,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          // Add Listing Tab
          ManageProperty(),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${booking['name'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text('Homestay: ${booking['homestay'] ?? ''}', style: const TextStyle(color: Colors.grey)),
              Text('Payment: ${booking['paymentMethod'] ?? ''}'),
              Text('Total Price: RM${booking['totalPrice'] ?? ''}', style: const TextStyle(color: Colors.indigo)),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Approve booking logic
                    },
                    child: const Text('Approve'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Reject booking logic
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Reject'),
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
