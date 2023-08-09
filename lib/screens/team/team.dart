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
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  Stream<List<Event>> getEventsByDate(DateTime? selectedDate) {
    final firestore = FirebaseFirestore.instance;
    final eventsCollection = firestore.collection('events');

    return eventsCollection.snapshots().map((querySnapshot) {
      final selectedEvents = <Event>[];

      querySnapshot.docs.forEach((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final eventDate = DateTime.parse(doc.id);
        final events = data['events'] as List<dynamic>;

        if (isSameDay(eventDate, selectedDate)) {
          final eventList = events.map((eventData) {
            final title = eventData['title'] as String;
            return Event(title);
          }).toList();

          selectedEvents.addAll(eventList);
        }
      });

      return selectedEvents;
    });
  }

  List<Event> _getEventsForDay(DateTime day) {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    return eventProvider.kEvents[day] ?? [];
  }

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    // Implementation example
    final days = daysInRange(start, end);

    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    // `start` or `end` could be null
    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
      showDialog(
        context: context,
        builder: (context) => EventInputDialog(onSave: _saveEvent),
      );
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }

    // 범위 선택 후, 범위에 이벤트를 추가하기 위한 다이얼로그를 즉시 보여줍니다.
  }

  void _saveEvent(String title) {
    final newEvent = Event(title);
    final range = _rangeEnd!.difference(_rangeStart!).inDays;

    for (var i = 0; i <= range; i++) {
      final date = _rangeStart!.add(Duration(days: i));
      final firestore = FirebaseFirestore.instance;
      final eventsCollection = firestore.collection('events');

      eventsCollection.doc(date.toIso8601String()).set({
        'events': FieldValue.arrayUnion([
          {'title': newEvent.title}
        ])
      }, SetOptions(merge: true));
    }

    _rangeSelectionMode = RangeSelectionMode.toggledOff;

    setState(() {
      // to force re-rendering
    });
  }

  void _addEvent(DateTime date, Event event) async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    // Create a Firestore instance
    final firestore = FirebaseFirestore.instance;

    // Upload the event to Firebase
    await firestore.collection('events').doc(date.toIso8601String()).set({
      'events': FieldValue.arrayUnion([
        {
          'title': event.title,
        }
      ]),
    }, SetOptions(merge: true));

    // Update the local event map with the new event
    eventProvider.kEvents.update(date, (existingEvents) {
      existingEvents.add(event);
      return existingEvents;
    }, ifAbsent: () => [event]);

    // Notify listeners of the updated events
    eventProvider.notifyListeners();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _showEventInputDialog(BuildContext context, DateTime date) {
    showDialog(
      context: context,
      builder: (context) {
        String eventTitle = '';

        return AlertDialog(
          title: Text('Add Event'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              onChanged: (value) {
                eventTitle = value;
              },
              decoration: InputDecoration(
                labelText: 'Event Title',
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter an event title';
                }
                return null;
              },
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final event = Event(eventTitle);
                  _addEvent(date, event);
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _deleteEvent(DateTime date, Event event) async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    // Create a Firestore instance
    final firestore = FirebaseFirestore.instance;

    // Delete the event from Firebase
    await firestore.collection('events').doc(date.toIso8601String()).update({
      'events': FieldValue.arrayRemove([
        {'title': event.title},
      ]),
    });

    // Update the local event map by removing the event
    eventProvider.kEvents.update(date, (existingEvents) {
      existingEvents.remove(event);
      return existingEvents;
    });

    // Notify listeners of the updated events
    eventProvider.notifyListeners();
  }

  _showDeleteConfirmationDialog(
      BuildContext context, DateTime date, Event event) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Event'),
          content: Text('Are you sure you want to delete this event?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteEvent(date, event);
                Navigator.pop(context);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  final FirebaseFirestore _db = FirebaseFirestore.instance;


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
                                        SizedBox(height: 20),
                                        Text(
                                          data['name'],
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 30,
                                          ),
                                        ),
                                        SizedBox(height: 150), // add a spacing between the name and the prayer title
                                        Text(
                                          prayerTitle,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                          ),
                                        ),
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
                            aspectRatio: 16/9,
                            viewportFraction: 0.9,
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
