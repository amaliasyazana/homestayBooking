import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../utils/user_preferences.dart';
import '../widget/appbarWidget.dart';
import '../widget/buttonWidget.dart';
import 'editProfile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    const user = UserPreferences.myUser;

    return Builder(
      builder: (context) => Scaffold(
        appBar: buildAppBar(context),
        body: Center(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(children: [
                  const SizedBox(height: 24),
                  const CircleAvatar(
                    backgroundColor: Color(0xffE6E6E6),
                    radius: 50,
                    child: Icon(
                      Icons.person,
                      color: Color(0xffCCCCCC),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                      height: 50,
                      child: ButtonWidget(
                          text: "Edit Profile",
                          onClicked: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => EditProfilePage()),
                            );
                          })),
                  const SizedBox(height: 24),
                  buildName(user),
                  const SizedBox(height: 24),
                  Center(child: buildUpgradeButton()),
                ]))),
      ),
    );
  }

  Widget buildName(User user) => Column(
        children: [
          Text(
            user.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            user.phone,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            user.gender,
            style: const TextStyle(color: Colors.grey),
          )
        ],
      );

  Widget buildUpgradeButton() => ButtonWidget(
        text: 'Whatsapp',
        onClicked: () {},
      );
}
