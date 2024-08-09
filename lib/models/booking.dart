import 'package:cloud_firestore/cloud_firestore.dart';

// booking_model.dart

class BookingModel {
  late String name;
  late String email;
  late String phone;
  late String homestay;
  late DateTime? checkInDate;
  late DateTime? checkOutDate;
  late String approval;
  late String keycode;

  String? id; // Add this line to include the id property

  BookingModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.homestay,
    this.checkInDate,
    this.checkOutDate,
    this.approval = 'pending',
    this.id,
    this.keycode = '',
  });

  // Create a factory method to convert a Map to a BookingModel
  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      homestay: map['homestay'],
      checkInDate: (map['checkInDate'] as Timestamp?)?.toDate(),
      checkOutDate: (map['checkOutDate'] as Timestamp?)?.toDate(),
      id: map['id'], // Add this line to include the id property
      approval: map['approval'] ??
          'pending', //Include the aproval field with a default value
      keycode: map['keycode'] ?? '', // Include the "keycode" field
    );
  }

  //Map homestay from firebase to homestayModel
  factory BookingModel.fromSnapshot(QueryDocumentSnapshot<Object?> document) {
    // final data = document.data()!;
    final data = document.data() as Map<String, dynamic>;

    return BookingModel(
        id: document.id,
        name: data["name"],
        email: data["email"],
        phone: data["phone"],
        homestay: data["homestay"],
        // checkInDate: data["checkInDate" as Timestamp?],
        // checkOutDate: data["checkOutDate" as Timestamp?],
        approval: data['approval']);
  }

  // Convert the BookingModel to a Map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'homestay': homestay,
      'checkInDate': checkInDate,
      'checkOutDate': checkOutDate,
      'id': id, // Add this line to include the id property
      'approval': approval, //Include the approval field
      'keycode': keycode //Include te "Keycode" field
    };
  }
}
