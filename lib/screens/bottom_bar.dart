import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onebody/screens/home.dart';

import '../app_styles.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({Key? key}) : super(key: key);

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    const Text("Search"),
    const Text("Tickets"),
    const Text("Profile")
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  late ScrollController _scrollController;

  @override
  Widget build(BuildContext context) {
    var controller = PrimaryScrollController.of(context);

    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: mainGreen,
      //   elevation: 0,
      //   automaticallyImplyLeading: false,
      //   title: Text(
      //     "Onebody Community",
      //     style: TextStyle(fontSize: 10, color: Colors.white),
      //   ),
      //   // leading:
      //   // IconButton(
      //   //     icon: const Icon(
      //   //       Icons.exit_to_app,
      //   //       color: Colors.white,
      //   //     ),
      //   //     onPressed: () async {
      //   //       Navigator.pushNamed(context, '/login');
      //   //       await FirebaseAuth.instance.signOut();
      //   //     }
      //   // ),
      //
      //   actions: <Widget>[
      //     IconButton(
      //         icon: Icon(
      //           Icons.shopping_cart,
      //           color: Colors.white,
      //         ),
      //         onPressed: () => {Navigator.pushNamed(context, '/wishlist')}),
      //     IconButton(
      //         icon: Icon(
      //           Icons.add,
      //           color: Colors.white,
      //         ),
      //         onPressed: () {
      //           Navigator.push(
      //             context,
      //             PageRouteBuilder(
      //               pageBuilder: (context, __, ___) => AddNoticePage(),
      //               transitionDuration: Duration.zero,
      //               reverseTransitionDuration: Duration.zero,
      //             ),
      //           );
      //         }),
      //     IconButton(
      //         icon: Icon(
      //           Icons.add_circle,
      //           color: Colors.white,
      //         ),
      //         onPressed: () {
      //           Navigator.push(
      //             context,
      //             PageRouteBuilder(
      //               pageBuilder: (context, __, ___) => AddStoryPage(),
      //               transitionDuration: Duration.zero,
      //               reverseTransitionDuration: Duration.zero,
      //             ),
      //           );
      //         }),
      //   ],
      // ),
        body: CustomScrollView(
          shrinkWrap: true,
          // CustomScrollView는 children이 아닌 slivers를 사용하며, slivers에는 스크롤이 가능한 위젯이나 리스트가 등록가능함
          slivers: <Widget>[
            // 앱바 추가
            SliverAppBar(
              title: Text("Shalom"),
              // floating 설정. SliverAppBar는 스크롤 다운되면 화면 위로 사라짐.
              // true: 스크롤 업 하면 앱바가 바로 나타남. false: 리스트 최 상단에서 스크롤 업 할 때에만 앱바가 나타남
              floating: true,
              // 최대 높이
              expandedHeight: 100,
            ),
            // 리스트 추가
            SliverList(
              delegate: SliverChildListDelegate(

                <Widget>[
                  Center(child: _widgetOptions[_selectedIndex])
                ],
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: false,
                addSemanticIndexes: false,
              ),
            ),
          ],
        ),
        bottomNavigationBar: GestureDetector(
          onDoubleTap: () {
            controller.animateTo(0,
                duration: Duration(milliseconds: 280), curve: Curves.linear);
          },
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            elevation: 10,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedItemColor: mainGreen,
            unselectedItemColor: Colors.black,
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  label: "홈", ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.groups_outlined), label: "팀"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart_outlined), label: "굿즈"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined), label: "설정"),
            ],
          ),
        ));
  }
}
