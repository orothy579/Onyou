import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn(scopes: ['profile', 'email']).signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    final data = await FirebaseAuth.instance.signInWithCredential(credential);
    await FirebaseFirestore.instance.collection('users').doc(data.user!.uid).set({
      'name' : data.user!.displayName,
      'email': data.user!.email,
      'uid': data.user!.uid,
      'image': data.user!.photoURL,
      'liked' : [],
      'prayTitle':[],
    }, SetOptions(merge : true));
    return data.user;
  }

  Future<User?> signInWithAnonymously() async {
    final data = await FirebaseAuth.instance.signInAnonymously();

    await FirebaseFirestore.instance.collection('users').doc(data.user!.uid).set({
      'name' : "익명",
      'email': '익명',
      'uid': data.user!.uid,
      'image': 'https://img.freepik.com/premium-vector/cute-jesus-with-finger-heart-shape_123847-889.jpg',
      'liked' : [],
      'prayTitle':[],
      'praynumber': 0,
      'total_time' : 0,
    }, SetOptions(merge : true));
    return data.user;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ListView(
          children:
          <Widget>[
            Text("Onyou"),
            ElevatedButton(
                onPressed: () {
                  signInWithGoogle().then((value) => Navigator.pushNamed(context, '/home'));
                },
                child: Text('구글로 로그인')
            ),
            const SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: () {
                signInWithAnonymously().then((value) =>
                    Navigator.pushNamed(context,'/home')

                );
              },
              child: const Text('익명으로 로그인',
                  style: TextStyle(
                    fontSize: 20,
                  )),
              // style: ButtonStyle(
              //   backgroundColor: MaterialStateProperty.all(Colors.purple.shade100),
              //   overlayColor: MaterialStateProperty.all(Colors.purple),
              //   padding: MaterialStateProperty.all(const EdgeInsets.all(15)),
              //   shape: MaterialStateProperty.all(
              //     RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(30),
              //     ),
              //   ),
              // ),
            ),

          ],

        )
      )
    );
  }
}
