import 'package:flutter/material.dart';
import '../../models/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';

import '../utils/user_preferences.dart';
import '../widget/appbarWidget.dart';
import '../widget/buttonWidget.dart';
import '../widget/textfieldWidget.dart';

class EditProfilePage extends StatefulWidget {
  //using user id to create image folder for a particular user
  final String? userId;

  EditProfilePage({Key? key, this.userId}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  User user = UserPreferences.myUser;
  var _value = "-1";
  File? _image;
  final imagePicker = ImagePicker();
  String? downloadURL;
  TextStyle commonTextStyle =
      const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

  Future uploadImage() async {
    final postID = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = FirebaseStorage.instance
        .ref()
        .child("${widget.userId}/image")
        .child("post_$postID");
    await ref.putFile(_image!);
    downloadURL = await ref.getDownloadURL();
    print(downloadURL);
  }

  @override
  Widget build(BuildContext context) {
    //showing snackbar for errors
    showSnackBar(String snackText, Duration d) {
      final snackBar = SnackBar(content: Text(snackText), duration: d);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    Future imagePickerMethod() async {
      final pick = await imagePicker.pickImage(source: ImageSource.gallery);

      setState(() {
        if (pick != null) {
          _image = File(pick.path);
        } else {
          //showing snackbar
          showSnackBar("No File Selected", const Duration(milliseconds: 400));
        }
      });
    }

    return Scaffold(
        appBar: buildAppBar(context),
        body: Center(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              Expanded(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                    Expanded(
                      child: CircleAvatar(
                        backgroundColor: const Color(0xffE6E6E6),
                        radius: 50,
                        child: _image == null
                            ? const Center(
                                child: Align(
                                    alignment: Alignment.center,
                                    child: Text("No image selected")))
                            : kIsWeb
                                ? Image.network(
                                    _image!.path) // Use Image.network for web
                                : Image.file(
                                    _image!), // Use Image.file for mobile
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      child: ButtonWidget(
                        text: 'Pick Image',
                        onClicked: () {
                          imagePickerMethod();
                        },
                      ),
                    ),
                  ])),
              const SizedBox(height: 20),
              TextFieldWidget(
                label: 'Full Name',
                text: user.name,
                onChanged: (name) {},
              ),
              const SizedBox(height: 20),
              TextFieldWidget(
                label: 'Email',
                text: user.email,
                onChanged: (email) {},
              ),
              const SizedBox(height: 20),
              TextFieldWidget(
                label: 'Phone No.',
                text: user.phone,
                onChanged: (phone) {},
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Gender', style: commonTextStyle),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
                value: _value,
                items: const [
                  DropdownMenuItem(value: "-1", child: Text("-Select Gender-")),
                  DropdownMenuItem(value: "Male", child: Text("Male")),
                  DropdownMenuItem(value: "Female", child: Text("Female")),
                ],
                onChanged: (newValue) {
                  // Handle the value change here
                  setState(() {
                    _value = newValue as String;
                  });
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                child: ButtonWidget(
                  text: 'Save',
                  onClicked: () {
                    // Call uploadImage here before saving other user details
                    if (_image != null) {
                      uploadImage().whenComplete(() => showSnackBar(
                          "Image uploaded!", const Duration(seconds: 2)));
                    } else {
                      showSnackBar(
                          "Image failed to upload", const Duration(seconds: 2));
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        )));
  }
}
