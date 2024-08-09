import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/homestay.dart';
import '../repository/homestay_repository.dart'; // Adjust this import path to your HomestayRepository

class HomestayFilterPage extends StatelessWidget {
  final HomestayRepository _controller = Get.put(HomestayRepository());
  final TextEditingController _capacityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Homestay Filter',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.indigo[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter by Category:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            buildCategoryDropdown(),
            SizedBox(height: 16),
            TextField(
              controller: _capacityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter capacity',
                hintText: 'e.g., 4',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                int? capacity = int.tryParse(_capacityController.text);
                if (capacity != null) {
                  _controller.selectedCapacity.value = capacity;
                  _controller.fetchFilteredHomestays();
                } else {
                  print("Please enter a valid capacity");
                }
              },
              child: Text(
                'Filter',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[900],
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (_controller.filteredHomestays.isEmpty) {
                  return Center(
                    child: Text(
                      'No homestays found.',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: _controller.filteredHomestays.length,
                    itemBuilder: (context, index) {
                      Homestay homestay = _controller.filteredHomestays[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          title: Text(
                            homestay.houseName,
                            style: TextStyle(fontSize: 20),
                          ),
                          subtitle: Text(
                            '${homestay.category} - Capacity: ${homestay.capacity}',
                            style: TextStyle(fontSize: 16),
                          ),
                          trailing: Text(
                            '\RM${homestay.price.toString()}',
                            style: TextStyle(fontSize: 18),
                          ),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              homestay.imageUrl,
                              fit: BoxFit.cover,
                              width: 80,
                              height: 80,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              }),
            ),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/booking');
                  //  navigate to  booking page
                },
                child: Text(
                  'Book Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo[900],
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCategoryDropdown() {
    return Obx(() {
      List<String> allCategories = [
        'All',
        ..._controller.categories.where((c) => c != 'All')
      ];
      if (allCategories.isEmpty) {
        return CircularProgressIndicator();
      } else {
        if (!allCategories.contains(_controller.selectedCategory.value)) {
          _controller.selectedCategory.value = 'All';
        }

        return DropdownButton<String>(
          value: _controller.selectedCategory.value,
          onChanged: (newValue) {
            _controller.selectedCategory.value = newValue ?? 'All';
          },
          items: allCategories.map((category) {
            return DropdownMenuItem(
              child: Text(
                category,
                style: TextStyle(fontSize: 18),
              ),
              value: category,
            );
          }).toList(),
        );
      }
    });
  }
}
