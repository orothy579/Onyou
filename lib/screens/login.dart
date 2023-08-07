import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['profile', 'email']);
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    final data = await FirebaseAuth.instance.signInWithCredential(credential);

    // Check if the user already exists in Firestore
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(data.user!.uid).get();
    if (!userDoc.exists) {
      // User does not exist, set the data
      await FirebaseFirestore.instance.collection('users').doc(data.user!.uid).set({
        'name' : data.user!.displayName,
        'email': data.user!.email,
        'uid': data.user!.uid,
        'image': data.user!.photoURL,
        'prayTitle':[],
        'status_message': '',
        'teamRef': '', // initially empty, to be updated when user joins a team
      });
    }

    return data.user;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Enter your email',
                border: UnderlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                border: UnderlineInputBorder(),
              ),
              obscureText: true,
            ),

            SizedBox(height: 16),

            ElevatedButton(
              onPressed: () async {
                try {
                  UserCredential userCredential = await _auth.signInWithEmailAndPassword(
                    email: _emailController.text,
                    password: _passwordController.text,
                  );

                  if (userCredential.user != null && userCredential.user!.emailVerified) {
                    // Get user's teamRef
                    var docSnapshot = await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).get();
                    var teamRef = docSnapshot.data()?['teamRef'];

                    // If teamRef is null or empty, navigate to profile page
                    if (teamRef == null || teamRef.isEmpty) {
                      Navigator.of(context).pushReplacementNamed('/profileRegister');
                    } else {
                      Navigator.of(context).pushReplacementNamed('/home'); // assuming you have a '/home' route
                    }

                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please verify your email first.'),
                      ),
                    );
                  }
                } catch (e) {
                  print(e);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to login.'),
                    ),
                  );
                }
              },
              child: Text('Login'),
            ),

            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/register'); // assuming you have a '/register' route
              },
              child: Text('New user? Register'),
            ),

            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                try {
                  User? user = await signInWithGoogle();
                  if (user != null) {
                    var docSnapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
                    var teamRef = docSnapshot.data()?['teamRef'];

                    // If teamRef is null or empty, navigate to profile page
                    if (teamRef == null || teamRef.isEmpty) {
                      Navigator.of(context).pushReplacementNamed('/profileRegister');
                    } else {
                      Navigator.of(context).pushReplacementNamed('/home'); // assuming you have a '/home' route
                    }
                  }
                } catch (error) {
                  print(error);

                  // Show error message to the user
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('An error occurred during Google sign in.'),
                    ),
                  );
                }
              },

              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                side: MaterialStateProperty.all(BorderSide(color: Colors.black)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network('https://developers.google.com/identity/images/g-logo.png', height: 20.0),
                  Padding(
                    padding: const EdgeInsets.only(left: 24.0),
                    child: Text('Sign in with Google', style: TextStyle(color: Colors.black54, fontSize: 16.0)),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
