import 'dart:io';

import 'package:annahomestay/controller/manageProperty_controller.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:annahomestay/models/homestay.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ManageProperty extends StatefulWidget {
  const ManageProperty({Key? key}) : super(key: key);

  @override
  State<ManageProperty> createState() => _ManagePropertyState();
}

class _ManagePropertyState extends State<ManageProperty> {
  String imageUrl = '';
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomestayController());
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Property',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo[800],
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              AlertDialog alertDialog = AlertDialog(
                title: const Text('Add Homestay'),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: controller.name,
                        decoration:
                            const InputDecoration(labelText: 'House Name'),
                      ),
                      TextField(
                        controller: controller.capacity,
                        decoration:
                            const InputDecoration(labelText: 'Capacity'),
                      ),
                      TextField(
                        controller: controller.category,
                        decoration:
                            const InputDecoration(labelText: 'Category'),
                      ),
                      TextField(
                        controller: controller.price,
                        decoration: const InputDecoration(labelText: 'Price'),
                      ),
                      Center(
                        child: IconButton(
                            onPressed: () async {
                              final file = await ImagePicker()
                                  .pickImage(source: ImageSource.gallery);
                              if (file == null) {
                                return;
                              }
                              String fileName = DateTime.now()
                                  .microsecondsSinceEpoch
                                  .toString();

                              Reference referenceRoot =
                                  FirebaseStorage.instance.ref();

                              Reference referenceDirecImages =
                                  referenceRoot.child('images');

                              Reference referenceImageToUpload =
                                  referenceDirecImages.child(fileName);

                              try {
                                // Upload image in the background without freezing the UI
                                await referenceImageToUpload
                                    .putFile(File(file.path));

                                imageUrl = await referenceImageToUpload
                                    .getDownloadURL();
                              } catch (error) {
                                // Handle error
                                print(error.toString());
                              }
                            },
                            icon: const Icon(Icons.camera_alt)),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      // Validate and add homestay to the list
                      if (controller.name.text.isNotEmpty &&
                          controller.capacity.text.isNotEmpty &&
                          controller.category.text.isNotEmpty &&
                          controller.price.text.isNotEmpty) {
                        setState(() {
                          final homestay = Homestay(
                              houseName: controller.name.text.trim(),
                              category: controller.category.text.trim(),
                              capacity: int.parse(controller.capacity.text),
                              price: int.parse(controller.price.text),
                              imageUrl: imageUrl);

                          HomestayController.instance.createHomestay(homestay);
                        });
                        Navigator.pop(context); // Close the dialog
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
              showDialog(
                  context: context,
                  builder: (context) {
                    return alertDialog;
                  });
            },
            icon: const Icon(Icons.add),
            color: Colors.white,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<List<Homestay>>(
            future: controller.getAllHomestayDetails(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                //Homestay homestayData = snapshot.data as Homestay;
                return ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (c, index) {
                    return SizedBox(
                      width: 100,
                      child: Card(
                        margin: const EdgeInsets.all(20),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            //mainAxisSize: MainAxisSize.min,
                            children: [
                              // Image.asset(
                              //   imageUrl.isNotEmpty
                              //       ? imageUrl[index]
                              //       : snapshot.data![index].imageUrl,
                              //   width: double.infinity,
                              //   height: 200,
                              //   fit: BoxFit.cover,
                              // ),
                              Image.network(
                                snapshot.data![index].imageUrl,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      snapshot.data![index].houseName,
                                      style: const TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text('Capacity: ' +
                                        snapshot.data![index].capacity
                                            .toString()),
                                    const SizedBox(height: 8.0),
                                    Text('Price: RM' +
                                        snapshot.data![index].price.toString()),
                                    const SizedBox(height: 8.0),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            String imageUrl =
                                                snapshot.data![index].imageUrl;
                                            // Create a new instance of the controller for the 'Edit Homestay' dialog
                                            HomestayController editController =
                                                HomestayController();

                                            // Set initial values from the selected homestay
                                            editController.id =
                                                snapshot.data![index].id;
                                            editController.name.text =
                                                snapshot.data![index].houseName;
                                            editController.capacity.text =
                                                snapshot.data![index].capacity
                                                    .toString();
                                            editController.category.text =
                                                snapshot.data![index].category;
                                            editController.price.text = snapshot
                                                .data![index].price
                                                .toString();
                                            editController.imageUrl.text =
                                                snapshot.data![index].imageUrl;

                                            Homestay homestay = Homestay(
                                                id: snapshot.data![index].id,
                                                houseName: snapshot
                                                    .data![index].houseName,
                                                category: snapshot
                                                    .data![index].category,
                                                capacity: snapshot
                                                    .data![index].capacity,
                                                price:
                                                    snapshot.data![index].price,
                                                imageUrl: snapshot
                                                    .data![index].imageUrl);

                                            AlertDialog alertDialog =
                                                AlertDialog(
                                              title:
                                                  const Text('Edit Homestay'),
                                              content: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    TextField(
                                                      controller:
                                                          editController.name,
                                                      decoration:
                                                          const InputDecoration(
                                                              labelText:
                                                                  'House Name'),
                                                    ),
                                                    TextField(
                                                      controller: editController
                                                          .capacity,
                                                      decoration:
                                                          const InputDecoration(
                                                              labelText:
                                                                  'Capacity'),
                                                    ),
                                                    TextField(
                                                      controller: editController
                                                          .category,
                                                      decoration:
                                                          const InputDecoration(
                                                              labelText:
                                                                  'Category'),
                                                    ),
                                                    TextField(
                                                      controller:
                                                          editController.price,
                                                      decoration:
                                                          const InputDecoration(
                                                              labelText:
                                                                  'Price'),
                                                    ),
                                                    Center(
                                                      child: IconButton(
                                                          onPressed: () async {
                                                            final file =
                                                                await ImagePicker()
                                                                    .pickImage(
                                                                        source:
                                                                            ImageSource.gallery);
                                                            if (file == null) {
                                                              return;
                                                            }
                                                            String fileName =
                                                                DateTime.now()
                                                                    .microsecondsSinceEpoch
                                                                    .toString();

                                                            Reference
                                                                referenceRoot =
                                                                FirebaseStorage
                                                                    .instance
                                                                    .ref();

                                                            Reference
                                                                referenceDirecImages =
                                                                referenceRoot
                                                                    .child(
                                                                        'images');

                                                            Reference
                                                                referenceImageToUpload =
                                                                referenceDirecImages
                                                                    .child(
                                                                        fileName);

                                                            try {
                                                              // Upload image in the background without freezing the UI
                                                              await referenceImageToUpload
                                                                  .putFile(File(
                                                                      file.path));

                                                              imageUrl = await referenceImageToUpload
                                                                      .getDownloadURL() ??
                                                                  snapshot
                                                                      .data![
                                                                          index]
                                                                      .imageUrl;
                                                            } catch (error) {
                                                              // Handle error
                                                              print(error
                                                                  .toString());
                                                            }
                                                          },
                                                          icon: const Icon(Icons
                                                              .camera_alt)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                        context); // Close the dialog
                                                  },
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    // Validate and update homestay in the list
                                                    if (editController.name.text.isNotEmpty &&
                                                        editController.capacity
                                                            .text.isNotEmpty &&
                                                        editController.category
                                                            .text.isNotEmpty &&
                                                        editController.price
                                                            .text.isNotEmpty) {
                                                      // uploadIma
                                                      setState(() {
                                                        final updatedHomestay =
                                                            Homestay(
                                                          houseName:
                                                              editController
                                                                  .name.text
                                                                  .trim(),
                                                          category:
                                                              editController
                                                                  .category.text
                                                                  .trim(),
                                                          capacity: int.parse(
                                                              editController
                                                                  .capacity
                                                                  .text),
                                                          price: int.parse(
                                                              editController
                                                                  .price.text),
                                                          imageUrl: imageUrl,
                                                        );

                                                        // Assuming you have a method to update homestay in the controller
                                                        controller
                                                            .updateHomestay(
                                                                updatedHomestay,
                                                                homestay);
                                                      });
                                                      Navigator.pop(
                                                          context); // Close the dialog
                                                    }
                                                  },
                                                  child: const Text('Update'),
                                                ),
                                              ],
                                            );

                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return alertDialog;
                                                });
                                          },
                                          child: const Text(
                                            'Edit',
                                            style: TextStyle(
                                              color: Colors.blue,
                                            ),
                                            //textAlign: TextAlign.end,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              final homestay =
                                                  snapshot.data![index];
                                              controller
                                                  .removeHomestay(homestay);
                                            });
                                          },
                                          child: const Text(
                                            'Remove',
                                            style: TextStyle(
                                              color: Colors.red,
                                            ),
                                            //textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ]),
                      ),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }),
      ),
    );
  }
}
