import 'package:annahomestay/models/homestay.dart';
import 'package:annahomestay/repository/homestay_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomestayController extends GetxController {
  static HomestayController get instance => Get.find();
  //final homestayRepository = HomestayRepository.instance;

  String? id;
  final name = TextEditingController();
  final capacity = TextEditingController();
  final category = TextEditingController();
  final price = TextEditingController();
  final imageUrl = TextEditingController();

  final homestayRepo = Get.put(HomestayRepository());

  Future<int> getTotalPropertyCount() async {
    return homestayRepo.getTotalPropertyCount();
  }

  Future<void> createHomestay(Homestay homestay) async {
    await homestayRepo.createHomestay(homestay);
    update();
  }

  getAllHomestayDetails() {
    return homestayRepo.getAllHomestayDetails();
  }

  Future<void> removeHomestay(Homestay homestayId) async {
    try {
      await homestayRepo.removeHomestay(homestayId);
      update();
    } catch (e) {
      throw 'Something went wrong';
    }
  }

  Future<void> updateHomestay(Homestay homestayId, Homestay homestay) async {
    try {
      await homestayRepo.updateHomestay(homestayId, homestay);
      update();
    } catch (e) {
      throw 'Something went wrong';
    }
  }
}
