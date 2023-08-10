import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onebody/screens/team/Dialog.dart';
import 'package:onebody/screens/team/teamDetail.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../style/app_styles.dart';
import '../../model/utils.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({Key? key}) : super(key: key);

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    eventProvider.getEventsFromFirebase();
    return Scaffold(
        body: Consumer<EventProvider>(builder: (context, eventProvider, _) {
      return CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            title: Text(
              "Onebody Community",
              style: TextStyle(fontSize: 10),
            ),
            actions: <Widget>[
              IconButton(
                  icon: const Icon(
                    Icons.exit_to_app,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushNamed(context, '/login');
                  }),
            ],
            // 최대 높이
            expandedHeight: 30,
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              <Widget>[
                Column(
                  children: [
                    SizedBox(
                      height: 18.0,
                    ),
                    Center(
                      child: Container(
                          height: 25,
                          width: 100,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: boxGrey,
                              borderRadius: BorderRadius.circular(10)),
                          child: Text("함께 기도해요", style: headLineGreenStyle)),
                    ),
                    SizedBox(
                      height: 18.0,
                    ),

                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('teams')
                          .snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Something went wrong');
                        }

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text("Loading");
                        }

                        List<Widget> teamWidgets = snapshot.data!.docs
                            .map((DocumentSnapshot document) {
                          Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                          return FutureBuilder<QuerySnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('teams')
                                .doc(document.id)
                                .collection('prayerTitles')
                                .get(),
                            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> prayerSnapshot) {
                              if (prayerSnapshot.hasError) {
                                return Text('Something went wrong');
                              }

                              if (prayerSnapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              }

                              String prayerTitle = "No prayers found for this team";
                              if (prayerSnapshot.data != null && prayerSnapshot.data!.docs.isNotEmpty) {
                                final Random random = Random();
                                final int randomIndex = random.nextInt(prayerSnapshot.data!.docs.length);
                                final DocumentSnapshot randomPrayerDoc = prayerSnapshot.data!.docs[randomIndex];
                                final Map<String, dynamic> randomPrayerData = randomPrayerDoc.data() as Map<String, dynamic>;
                                prayerTitle = randomPrayerData['description'];
                              }

                              return Container(
                                margin: EdgeInsets.all(10.0),
                                padding: EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(data['imgURL']), // Using the imgURL from Firestore
                                    fit: BoxFit.contain, // Use BoxFit to define how the image should fill its box.
                                  ),
                                  color: Colors.white70,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: GestureDetector(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Text(
                                          data['name'],
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        // SizedBox(height: 400), // add a spacing between the name and the prayer title
                                        // Text(
                                        //   prayerTitle,
                                        //   style: TextStyle(
                                        //     color: Colors.black,
                                        //     fontSize: 18,
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TeamDetailPage(
                                              teamDocument: document
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );

                            },
                          );
                        }).toList();

                        return CarouselSlider(
                          options: CarouselOptions(
                            height: 550,
                            aspectRatio: 1024/1280,
                            viewportFraction: 1.0,
                            initialPage: 0,
                            enableInfiniteScroll: true,
                            reverse: false,
                            autoPlay: true,
                            autoPlayInterval: Duration(seconds: 5),
                            autoPlayAnimationDuration: Duration(milliseconds: 800),
                            autoPlayCurve: Curves.fastOutSlowIn,
                            enlargeCenterPage: true,
                            onPageChanged: (index, reason) {},
                            scrollDirection: Axis.horizontal,
                          ),
                          items: teamWidgets,
                        );
                      },
                    ),


                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }));
  }
}
