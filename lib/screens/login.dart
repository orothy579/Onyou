import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;

class Bubble extends StatelessWidget {
  final double size;
  final Color color;
  final Offset position;

  Bubble({required this.size, required this.color, required this.position});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: position.dx,
      left: position.dy,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.3),
        ),
      ),
    );
  }
}

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

  @override
  void initState(){
  super.initState();
 }



  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    final data = await FirebaseAuth.instance.signInWithCredential(credential);

    // Check if the user already exists in Firestore
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(data.user!.uid)
        .get();
    if (!userDoc.exists) {
      // User does not exist, set the data
      await FirebaseFirestore.instance
          .collection('users')
          .doc(data.user!.uid)
          .set({
        'name': data.user!.displayName,
        'email': data.user!.email,
        'uid': data.user!.uid,
        'image': data.user!.photoURL,
        'prayTitle': [],
        'status_message': '',
        'teamRef': '', // initially empty, to be updated when user joins a team
      });
    }

    return data.user;
  }

  // Future<void> signInWithKakao() async {
  //   if (await isKakaoTalkInstalled()) {
  //     try {
  //       await UserApi.instance.loginWithKakaoTalk();
  //       print('카카오톡으로 로그인 성공');
  //     } catch (error) {
  //       print('카카오톡으로 로그인 실패 $error');
  //
  //       // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
  //       // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
  //       if (error is PlatformException && error.code == 'CANCELED') {
  //         return;
  //       }
  //       // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
  //       try {
  //         await UserApi.instance.loginWithKakaoAccount();
  //         print('카카오계정으로 로그인 성공');
  //       } catch (error) {
  //         print('카카오계정으로 로그인 실패 $error');
  //       }
  //     }
  //   } else {
  //     try {
  //       await UserApi.instance.loginWithKakaoAccount();
  //       print('카카오계정으로 로그인 성공');
  //     } catch (error) {
  //       print('카카오계정으로 로그인 실패 $error');
  //     }
  //   }
  // }

  Future<User?> signInWithKakao() async {
    String? email;
    String? name;
    String? imageUrl;

    if (await kakao.isKakaoTalkInstalled()) {
      try {
        await kakao.UserApi.instance.loginWithKakaoTalk();
        kakao.User kakaoUser = await kakao.UserApi.instance.me(); // 사용자 정보 요청
        name = kakaoUser.kakaoAccount?.profile?.nickname;
        email = kakaoUser.kakaoAccount?.email;
        imageUrl = kakaoUser.kakaoAccount?.profile?.thumbnailImageUrl;
        print('카카오톡으로 로그인 성공');
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');
        if (error is PlatformException && error.code == 'CANCELED') {
          return null;
        }
        try {
          await kakao.UserApi.instance.loginWithKakaoAccount();
          kakao.User kakaoUser = await kakao.UserApi.instance.me(); // 사용자 정보 요청
          name = kakaoUser.kakaoAccount?.profile?.nickname;
          email = kakaoUser.kakaoAccount?.email;
          imageUrl = kakaoUser.kakaoAccount?.profile?.thumbnailImageUrl;
          print('카카오계정으로 로그인 성공');
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
        }
      }
    } else {
      try {
        await kakao.UserApi.instance.loginWithKakaoAccount();
        kakao.User kakaoUser = await kakao.UserApi.instance.me(); // 사용자 정보 요청
        name = kakaoUser.kakaoAccount?.profile?.nickname;
        email = kakaoUser.kakaoAccount?.email;
        imageUrl = kakaoUser.kakaoAccount?.profile?.thumbnailImageUrl;
        print('카카오계정으로 로그인 성공');
      } catch (error) {
        print('카카오계정으로 로그인 실패 $error');
      }
    }

    UserCredential userCredential =
    await FirebaseAuth.instance.signInAnonymously();

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .get();
    if (!userDoc.exists) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': name,
        'email': email,
        'uid': userCredential.user!.uid,
        'image': imageUrl,
        'prayTitle': [],
        'status_message': '',
        'teamRef': '', // initially empty, to be updated when user joins a team
      });
    }

    return userCredential.user;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final random = Random();

    // 여러 개의 물방울을 생성하는 함수
    List<Widget> generateBubbles(int count) {
      List<Widget> bubbles = [];
      for (int i = 0; i < count; i++) {
        double size = random.nextDouble() * 20 + 3; //1 ~ 21 사이 크기
        Color color = Color.fromRGBO(
          random.nextInt(256),
          random.nextInt(256),
          random.nextInt(256),
          1,
        ); // 랜덤 색상
        Offset position = Offset(
          random.nextDouble() * height, // y 좌표: 0 ~ 300
          random.nextDouble() * width, // x 좌표: 0 ~ 600
        ); // 랜덤 위치
        bubbles.add(Bubble(size: size, color: color, position: position));
      }
      return bubbles;
    }

    return Scaffold(
      body: Stack(
        children: [
          ...generateBubbles(22),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Onebody Community',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 100.0,),
                Padding(
                  padding: EdgeInsets.only(right:128), // 모든 방향으로 16 픽셀의 패딩 적용
                  child: Text(
                    'Let\'s be an Onebody',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF52525C),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 200), // 상단에 8 픽셀의 패딩 적용
                  child: Text(
                    'Welcome home!',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF52525C),
                    ),
                  ),
                ),


                Padding(
                  padding: const EdgeInsets.only(left: 40,right: 40,top: 10),
                  child: Column(
                    children: [
                      Container(
                        child: TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            contentPadding: EdgeInsets.only(left: 10, bottom: 20), // 패딩 조절
                            border: OutlineInputBorder(  // 둥근 테두리를 가진 외곽선
                              borderRadius: BorderRadius.circular(18),  // 둥근 테두리의 반지름 설정
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(color: Colors.black), // 민트색 테두리
                            ),

                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        child: TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            contentPadding: EdgeInsets.only(left: 10, top: 10, bottom: 20), // 패딩 조절

                            border: OutlineInputBorder(  // 둥근 테두리를 가진 외곽선
                              borderRadius: BorderRadius.circular(18),  // 둥근 테두리의 반지름 설정
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(color: Colors.black), // 민트색 테두리
                            ),

                          ),
                          obscureText: true,
                        ),
                      ),
                    ],
                  ),
                ),


                SizedBox(height: 16),
                Container(
                  width: 137,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        UserCredential userCredential =
                            await _auth.signInWithEmailAndPassword(
                          email: _emailController.text,
                          password: _passwordController.text,
                        );

                        if (userCredential.user != null &&
                            userCredential.user!.emailVerified) {
                          // Get user's teamRef
                          var docSnapshot = await FirebaseFirestore.instance
                              .collection('users')
                              .doc(userCredential.user!.uid)
                              .get();
                          var teamRef = docSnapshot.data()?['teamRef'];

                          // If teamRef is null or empty, navigate to profile page
                          if (teamRef == null || teamRef.isEmpty) {
                            Navigator.of(context)
                                .pushReplacementNamed('/profileRegister');
                          } else {
                            Navigator.of(context).pushReplacementNamed(
                                '/home'); // assuming you have a '/home' route
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
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 8)), // 버튼의 높이를 줄입니다.
                      backgroundColor: MaterialStateProperty.all(Color(0xff0014FF)), // 버튼의 배경색을 파란색으로 설정합니다.
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // 버튼의 테두리를 둥글게 만듭니다.
                          side: BorderSide(color: Colors.black), // 버튼의 테두리 색상을 검은색으로 설정합니다.
                        ),
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed(
                        '/register'); // assuming you have a '/register' route
                  },
                  child:  Text(
                    '아직 회원이 아니신가요?',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF52525C),
                    ),
                  ),
                ),
                // SizedBox(height: 16),
                // ElevatedButton(
                //   onPressed: () async {
                //     try {
                //       User? user = await signInWithGoogle();
                //       if (user != null) {
                //         var docSnapshot = await FirebaseFirestore.instance
                //             .collection('users')
                //             .doc(user.uid)
                //             .get();
                //         var teamRef = docSnapshot.data()?['teamRef'];
                //
                //         // If teamRef is null or empty, navigate to profile page
                //         if (teamRef == null || teamRef.isEmpty) {
                //           Navigator.of(context)
                //               .pushReplacementNamed('/profileRegister');
                //         } else {
                //           Navigator.of(context).pushReplacementNamed(
                //               '/home'); // assuming you have a '/home' route
                //         }
                //       }
                //     } catch (error) {
                //       print(error);
                //
                //       // Show error message to the user
                //       ScaffoldMessenger.of(context).showSnackBar(
                //         SnackBar(
                //           content: Text('An error occurred during Google sign in.'),
                //         ),
                //       );
                //     }
                //   },
                //   style: ButtonStyle(
                //     backgroundColor: MaterialStateProperty.all(Colors.white),
                //     side:
                //         MaterialStateProperty.all(BorderSide(color: Colors.black)),
                //     minimumSize: MaterialStateProperty.all(Size(200.0, 50.0)),  // add this line
                //   ),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       Image.asset('assets/g-logo.png', height: 20.0),
                //       Padding(
                //         padding: const EdgeInsets.only(left: 10.0),
                //         child: Text('구글로 로그인',
                //             style:
                //                 TextStyle(color: Colors.black, fontSize: 16.0)),
                //       ),
                //     ],
                //   ),
                // ),
                // SizedBox(height: 16),
                // GestureDetector(
                //   onTap: () async {
                //     try {
                //       User? user = await signInWithKakao();
                //       if (user != null) {
                //         var docSnapshot = await FirebaseFirestore.instance
                //             .collection('users')
                //             .doc(user.uid)
                //             .get();
                //         var teamRef = docSnapshot.data()?['teamRef'];
                //
                //         // If teamRef is null or empty, navigate to profile page
                //         if (teamRef == null || teamRef.isEmpty) {
                //           Navigator.of(context)
                //               .pushReplacementNamed('/profileRegister');
                //         } else {
                //           Navigator.of(context).pushReplacementNamed(
                //               '/home'); // assuming you have a '/home' route
                //         }
                //       }
                //     } catch (error) {
                //       print(error);
                //
                //       // Show error message to the user
                //       ScaffoldMessenger.of(context).showSnackBar(
                //         SnackBar(
                //           content: Text('An error occurred during Kakao sign in.'),
                //         ),
                //       );
                //     }
                //   },
                //   child: Image.asset('assets/kakao_login_large_wide.png'),
                // )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
