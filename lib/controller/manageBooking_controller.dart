import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/booking.dart';
import '../repository/booking_repository.dart';

class BookingController extends GetxController {
  static BookingController get instance => Get.put(BookingController());

  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final homestay = TextEditingController();
  final approval = TextEditingController();

  String selectedHomestay = '';
  DateTime? checkInDate;
  DateTime? checkOutDate;

  final bookingRepo = Get.put(BookingRepository());

  Future<int> getTotalBookingCount() async {
    return bookingRepo.getTotalBookingCount();
  }

  Future<void> createBooking(BookingModel booking) async {
    await bookingRepo.createBooking(booking);
  }

  Future<void> refreshData() async {
    // Fetch the data again
    await getAllBookingDetails();
    // Trigger a rebuild of the widget tree
    update();
  }

  getAllBookingDetails() {
    return bookingRepo.getAllBookingDetails();
  }

  Future<void> removeBooking(BookingModel booking) async {
    try {
      await bookingRepo.removeBooking(booking);
      update();
    } catch (e) {
      throw 'Something went wrong';
    }
  }

  Future<void> updateApproval(
      BookingModel bookingId, String approvalValue) async {
    try {
      await bookingRepo.updateApproval(bookingId, approvalValue);
      update();
      getAllBookingDetails();
    } catch (e) {
      throw 'Something went wrong';
    }
  }
}
