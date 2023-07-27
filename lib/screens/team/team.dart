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

  // void _selectDate(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: _focusedDay, // 기본 날짜를 선택합니다. 여기서 selectedDate는 DateTime 객체입니다.
  //     firstDate: DateTime(2021, 8),
  //     lastDate: DateTime(2101),
  //   );
  //   if (picked != null && picked != _focusedDay)
  //     setState(() {
  //       _focusedDay = picked;
  //     });
  //   // 이제 selectedDate에 선택된 날짜가 저장되었습니다. 이 날짜에 이벤트를 추가할 수 있습니다.
  //    _addEvent(_selectedDay!);
  // }

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

  void uploadTeam(String teamName) async {
    DocumentReference docRef = _db.collection('teams').doc(teamName); // 새로운 팀 문서 참조 생성

    Map<String, dynamic> teamData = {
      'name': teamName,
      'users': [
        '09a81GTEiDXmbY7x1OYTHkhgqOm2',
        '5SsMr0RhztTjiwoCCH7clxhOlvd2',
        // 팀에 속한 유저들의 ID 또는 참조
      ],
      'prayerTitle': [
        '감사합니다',
        '고맙습니다.',
        // 팀의 기도 제목
      ],
    };

    await docRef.set(teamData); // 팀 데이터 업로드

    CollectionReference storiesRef = docRef.collection('stories'); // 팀의 stories 서브컬렉션 참조

    Map<String, dynamic> storyData = {
      'title': '이야기 제목',
      'description': '이야기 내용',
      'u_image' :'https://dfstudio-d420.kxcdn.com/wordpress/wp-content/uploads/2019/06/digital_camera_photo-980x653.jpg',
      'create_timestamp': FieldValue.serverTimestamp(), // 서버 시간으로 생성 타임스탬프 설정
    };

    await storiesRef.add(storyData); // 이야기 데이터 업로드
  }


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
                    uploadTeam("TEST");
                    // Navigator.pushNamed(context, '/login');
                    // await FirebaseAuth.instance.signOut();
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
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Text('Something went wrong');
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text("Loading");
                          }

                          List<Widget> teamWidgets = snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                            Map<String, dynamic> data =
                                document.data() as Map<String, dynamic>;
                            return Container(
                              margin: EdgeInsets.all(10.0), // 위젯 주변에 마진 추가
                              padding: EdgeInsets.all(10.0), // 위젯 내부에 패딩 추가
                              decoration: BoxDecoration(
                                color: camel, // Living Coral 색상
                                borderRadius: BorderRadius.circular(15), // 테두리 둥글게
                                boxShadow: [ // 그림자 효과
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: Offset(0, 3), // 그림자 위치
                                  ),
                                ],
                              ),
                              child: Center(
                                child: GestureDetector(
                                  child: Text(
                                    data['name'],
                                    style: TextStyle( // 텍스트 스타일링
                                      color: Colors.white, // 텍스트 색상
                                      fontWeight: FontWeight.bold, // 텍스트 두께
                                      fontSize: 20, // 텍스트 크기
                                    ),
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
                          }).toList();

                          return CarouselSlider(
                            options: CarouselOptions(
                              height: 400,
                              aspectRatio: 16/9, // 화면 비율 조정
                              viewportFraction: 0.8, // Carousel에서 보여지는 아이템의 비율을 설정 (0.0 ~ 1.0)
                              initialPage: 0, // 초기 페이지를 설정
                              enableInfiniteScroll: true, // 무한 스크롤을 활성화
                              reverse: false, // 역방향 스크롤을 활성화
                              autoPlay: true, // 자동 플레이를 활성화
                              autoPlayInterval: Duration(seconds: 3), // 자동 플레이 간격을 설정
                              autoPlayAnimationDuration: Duration(milliseconds: 800), // 페이지 전환 애니메이션 지속 시간을 설정
                              autoPlayCurve: Curves.fastOutSlowIn, // 페이지 전환 애니메이션 효과를 설정
                              enlargeCenterPage: true, // 중앙의 아이템을 확대하여 강조 효과를 줌
                              onPageChanged: (index, reason) { // 페이지 변경 시 이벤트 핸들러
                                // 페이지가 변경될 때 마다 수행할 작업을 여기에 작성
                              },
                              scrollDirection: Axis.horizontal, // 스크롤 방향을 설정 (가로 또는 세로)
                            ),
                            items: teamWidgets,
                          );
                        },
                      ),
                    StreamBuilder<Map<DateTime, List<Event>>>(
                      stream: Provider.of<EventProvider>(context, listen: false)
                          .getEventsFromFirebase(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Text(
                              "Something went wrong: ${snapshot.error}");
                        } else {
                          final allEvents = snapshot.data;
                          return Column(
                            children: [
                              Container(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () {
                                    showDateRangePicker(
                                      context: context,
                                      firstDate: DateTime(2023, 1, 1),
                                      lastDate: DateTime(2023, 12, 31),
                                    ).then((dateRange) {
                                      if (dateRange != null) {
                                        // 선택한 날짜 범위 처리
                                        setState(() {
                                          // _selectedDateRange = dateRange;
                                        });
                                      }
                                    });
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 18.0,
                              ),
                              Stack(
                                children: <Widget>[
                                  Positioned(
                                    top: 10,
                                    left: 150,
                                    right: 150,
                                    child: Container(
                                      height: 25,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: boxGrey,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "공동체 일정",
                                        style: headLineGreenStyle,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      icon: Icon(Icons.add),
                                      padding: EdgeInsets.only(right: 10.0),
                                      onPressed: () async {
                                        _showEventInputDialog(
                                            context, _selectedDay!);
                                      }, // 오른쪽 여백 추가
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 18.0,
                              ),
                              TableCalendar<Event>(
                                firstDay: kFirstDay,
                                lastDay: kLastDay,
                                focusedDay: _focusedDay,
                                availableCalendarFormats: {
                                  CalendarFormat.month: 'Month'
                                },
                                selectedDayPredicate: (day) =>
                                    isSameDay(_selectedDay, day),
                                rangeStartDay: _rangeStart,
                                sixWeekMonthsEnforced: false,
                                rangeEndDay: _rangeEnd,
                                calendarFormat: _calendarFormat,
                                rangeSelectionMode: _rangeSelectionMode,
                                eventLoader: (day) {
                                  return allEvents?[day] ?? [];
                                },
                                startingDayOfWeek: StartingDayOfWeek.sunday,
                                calendarStyle: CalendarStyle(
                                  outsideDaysVisible: false,
                                ),
                                onDaySelected: _onDaySelected,
                                onRangeSelected: _onRangeSelected,
                                onFormatChanged: (format) {
                                  if (_calendarFormat != format) {
                                    setState(() {
                                      _calendarFormat = format;
                                    });
                                  }
                                },
                                onPageChanged: (focusedDay) {
                                  _focusedDay = focusedDay;
                                },
                                // onDayLongPressed: (date, events) {
                                //   _showEventInputDialog(context, date);
                                // },
                              ),
                              StreamBuilder<List<Event>>(
                                stream: getEventsByDate(_selectedDay),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    final events = snapshot.data;
                                    return SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height,
                                      child: ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: events?.length,
                                        itemBuilder: (context, index) {
                                          final event = events?[index];
                                          return Container(
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 12.0,
                                              vertical: 4.0,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(),
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            child: ListTile(
                                              title: Text('${event?.title}'),
                                              trailing: IconButton(
                                                icon: Icon(
                                                  Icons.delete,
                                                  color: Colors.grey,
                                                ),
                                                onPressed: () {
                                                  _showDeleteConfirmationDialog(
                                                      context,
                                                      _focusedDay,
                                                      event!);
                                                },
                                              ),
                                              onLongPress: () {
                                                _showDeleteConfirmationDialog(
                                                    context,
                                                    _focusedDay,
                                                    event!);
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    return CircularProgressIndicator();
                                  }
                                },
                              ),
                            ],
                          );
                        }
                      },
                    ),
                    SizedBox(height: 8.0),
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
