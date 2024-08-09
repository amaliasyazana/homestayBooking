import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../admin/dashboard.dart';
import '../user/listScreen.dart';
import 'signupPage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static Future<User?> loginUsingEmailPassword(
      {required String email,
      required String password,
      required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        print("No user found for that email");
      }
    }
    return user;
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _emailController = TextEditingController();
    TextEditingController _passwordController = TextEditingController();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Text(
                "Anna Homestay",
                style: TextStyle(
                    color: Colors.indigo[500],
                    fontSize: 50.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const Text(
              "Booking App",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 44.0,
            ),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: "User Email",
                prefixIcon: Icon(
                  Icons.mail,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(
              height: 26.0,
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: "User Password",
                prefixIcon: Icon(
                  Icons.lock,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(
              height: 12.0,
            ),
            const Text(
              "Forget password?",
              style: TextStyle(color: Colors.blue),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const Text("Don't have an account?"),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const SignUpPage()));
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const Text("Or"),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => ListScreen()));
                    },
                    child: const Text(
                      "Login as Customer",
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ))
              ],
            ),
            const SizedBox(
              height: 88.0,
            ),
            Container(
              width: double.infinity,
              child: RawMaterialButton(
                fillColor: Colors.indigo[500],
                elevation: 0.0,
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                onPressed: () async {
                  User? user = await loginUsingEmailPassword(
                      email: _emailController.text,
                      password: _passwordController.text,
                      context: context);
                  print(user);
                  if (user != null) {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) =>
                            AdminDashboard())); //tukar path pergi admin dashboard ama
                  }
                },
                child: const Text(
                  "Login",
                  style: TextStyle(color: Colors.white, fontSize: 18.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
