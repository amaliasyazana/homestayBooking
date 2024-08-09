import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'loginPage.dart';
import 'loginScreen.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _userNameTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            height: MediaQuery.of(context).size.height - 50,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    const SizedBox(height: 60.0),
                    const Text(
                      "Sign up",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Create your account",
                      style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    TextField(
                      controller: _userNameTextController,
                      obscureText: false,
                      decoration: InputDecoration(
                          hintText: "Username",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none),
                          fillColor: Color.fromARGB(255, 255, 94, 220)
                              .withOpacity(0.1),
                          filled: true,
                          prefixIcon: const Icon(Icons.person)),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _emailTextController,
                      obscureText: false,
                      decoration: InputDecoration(
                          hintText: "Email",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none),
                          fillColor: Color.fromARGB(255, 255, 94, 220)
                              .withOpacity(0.1),
                          filled: true,
                          prefixIcon: const Icon(Icons.email)),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordTextController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Password",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none),
                        fillColor:
                            Color.fromARGB(255, 255, 94, 220).withOpacity(0.1),
                        filled: true,
                        prefixIcon: const Icon(Icons.password),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Confirm Password",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none),
                        fillColor:
                            Color.fromARGB(255, 255, 94, 220).withOpacity(0.1),
                        filled: true,
                        prefixIcon: const Icon(Icons.password),
                      ),
                      obscureText: true,
                    ),
                  ],
                ),
                Container(
                    padding: const EdgeInsets.only(top: 3, left: 3),
                    child: ElevatedButton(
                      onPressed: () {
                        FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                                email: _emailTextController.text,
                                password: _passwordTextController.text)
                            .then((value) {
                          print("Created New Account");
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()));
                        }).onError((error, StackTrace) {
                          print("Error ${error.toString()}");
                        });
                      },
                      child: const Text(
                        "Sign up",
                        style: TextStyle(fontSize: 20),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Color.fromARGB(255, 255, 94, 220),
                      ),
                    )),
                const Center(child: Text("Or")),
                Container(
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Color.fromARGB(255, 255, 94, 220),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset:
                            const Offset(0, 1), // changes position of shadow
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      signInWithGoogle();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 30.0,
                          width: 30.0,
                          // decoration: const BoxDecoration(
                          //   image: DecorationImage(
                          //       image: AssetImage(
                          //           'assets/images/login_signup/google.png'),
                          //       fit: BoxFit.cover),
                          //   shape: BoxShape.circle,
                          // ),
                        ),
                        const SizedBox(width: 18),
                        const Text(
                          "Sign In with Google",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 255, 94, 220),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text("Already have an account?"),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()));
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 94, 220),
                          ),
                        ))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // signInWithGoogle() async {
  //   try {
  //     GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  //     if (googleUser == null) {
  //       // User canceled the sign-in process
  //       return;
  //     }

  //     GoogleSignInAuthentication? googleAuth = await googleUser.authentication;

  //     AuthCredential credential = GoogleAuthProvider.credential(
  //         accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

  //     UserCredential userCredential =
  //         await FirebaseAuth.instance.signInWithCredential(credential);

  //     print("Signed in with Google: ${userCredential.user?.displayName}");

  //     // Navigate to the next screen or perform other actions after successful sign-in
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => MyApp()),
  //     );
  //   } catch (e) {
  //     print("Error signing in with Google: $e");
  //     // Handle the error (show a message to the user, etc.)
  //   }
  // }

  signInWithGoogle() async {
    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    print(userCredential.user?.displayName);
  }
}
