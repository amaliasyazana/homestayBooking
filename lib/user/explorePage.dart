import 'package:annahomestay/login/loginPage.dart';
import 'package:flutter/material.dart';
import '../models/homestay.dart';
import '../repository/homestay_repository.dart';
import 'homestayDetailPage.dart';
import 'viewBookingPage.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _ExplorePageBody();
  }
}

class _ExplorePageBody extends StatefulWidget {
  @override
  State<_ExplorePageBody> createState() => _ExplorePageBodyState();
}

class _ExplorePageBodyState extends State<_ExplorePageBody> {
  String _searchText = '';
  String _sortOption = 'None';
  late Future<List<Homestay>> _homestaysFuture;

  @override
  void initState() {
    super.initState();
    _homestaysFuture = HomestayRepository.instance.getAllHomestayDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final result = await showSearch<String>(
                context: context,
                delegate: HomestaySearchDelegate(_homestaysFuture),
              );
              if (result != null) {
                setState(() {
                  _searchText = result;
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
               Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const LoginPage()));
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _ExploreTab(title: 'Homes', icon: Icons.home)),
                Expanded(child: _ExploreTab(title: 'Experience', icon: Icons.explore)),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ViewBookingPage()),
                      );
                    },
                    child: _ExploreTab(title: 'View Booking', icon: Icons.book_online),
                  ),
                ),
              ],
            ),
          ),
          // Add filter dropdown
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Available Homes',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    const Text('Sort by: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      value: _sortOption,
                      items: [
                        DropdownMenuItem(value: 'None', child: Text('None')),
                        DropdownMenuItem(value: 'A-Z', child: Text('Alphabet (A-Z)')),
                        DropdownMenuItem(value: 'PriceLowHigh', child: Text('Price (Low-High)')),
                        DropdownMenuItem(value: 'PriceHighLow', child: Text('Price (High-Low)')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _sortOption = value!;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Homestay>>(
              future: _homestaysFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: \${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No homestay data available.'));
                } else {
                  List<Homestay> homestays = snapshot.data!;
                  final filtered = _searchText.isEmpty
                      ? homestays
                      : homestays.where((h) => h.houseName.toLowerCase().contains(_searchText.toLowerCase())).toList();
                  // In the FutureBuilder, after filtering:
                  List<Homestay> sorted = List.from(filtered);
                  if (_sortOption == 'A-Z') {
                    sorted.sort((a, b) => a.houseName.compareTo(b.houseName));
                  } else if (_sortOption == 'PriceLowHigh') {
                    sorted.sort((a, b) => a.price.compareTo(b.price));
                  } else if (_sortOption == 'PriceHighLow') {
                    sorted.sort((a, b) => b.price.compareTo(a.price));
                  }
                  return ListView.builder(
                    itemCount: sorted.length,
                    itemBuilder: (context, index) {
                      final homestay = sorted[index];
                      return _HomeCard(
                        imageUrl: homestay.imageUrl,
                        title: homestay.houseName,
                        location: homestay.category,
                        price: 'RM${homestay.price}/night',
                        capacity: homestay.capacity,
                        homestay: homestay,
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class HomestaySearchDelegate extends SearchDelegate<String> {
  final Future<List<Homestay>> homestaysFuture;
  HomestaySearchDelegate(this.homestaysFuture);

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
    return FutureBuilder<List<Homestay>>(
      future: homestaysFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final results = snapshot.data!.where((h) => h.houseName.toLowerCase().contains(query.toLowerCase())).toList();
        return ListView(
          children: results.map((h) => ListTile(
            title: Text(h.houseName),
            onTap: () => close(context, h.houseName),
          )).toList(),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<Homestay>>(
      future: homestaysFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final suggestions = snapshot.data!.where((h) => h.houseName.toLowerCase().contains(query.toLowerCase())).toList();
        return ListView(
          children: suggestions.map((h) => ListTile(
            title: Text(h.houseName),
            onTap: () => close(context, h.houseName),
          )).toList(),
        );
      },
    );
  }
}


class _ExploreTab extends StatelessWidget {
  final String title;
  final IconData icon;
  const _ExploreTab({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.indigo),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _HomeCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String location;
  final String price;
  final int capacity;
  final Homestay? homestay;
  const _HomeCard({required this.imageUrl, required this.title, required this.location, required this.price, required this.capacity, this.homestay});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (homestay != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomestayDetailPage(homestay: homestay!),
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.network(
                  imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.home, size: 48)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text('Category: $location', style: const TextStyle(color: Colors.grey)),
                    Text('Capacity: $capacity', style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(price, style: const TextStyle(color: Colors.indigo, fontSize: 16)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
