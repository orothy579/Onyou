import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:onebody/screens/team/Dialog.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../model/utils.dart';
import '../../style/app_styles.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarState();
}

class _CalendarState extends State<CalendarPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        title: const Text(
          "공동체 일정",
          style: TextStyle(fontSize: 15, color: Color(0xff52525C) , fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<Map<DateTime, List<Event>>>(
          stream: Provider.of<EventProvider>(context, listen: false)
              .getEventsFromFirebase(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Text("Something went wrong: ${snapshot.error}");
            } else {
              final allEvents = snapshot.data;
              return Column(
                children: [
                  SizedBox(
                    height: 18.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 20),
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),

                            boxShadow: [
                              BoxShadow(
                                color: Color(0xff0014FF).withOpacity(1), // 그림자의 색상
                                spreadRadius: 0.5,  // 그림자의 확장 반경
                                offset: Offset(2, 0),
                              )
                            ]

                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(color: Color(0xff52525C), width: 2.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)
                              ),
                              elevation: 1.0,
                              padding: EdgeInsets.fromLTRB(2, 0, 0, 0)
                          ),
                          onPressed: () async {
                            _showEventInputDialog(context, _selectedDay!);
                          },
                          child: Icon(
                            Icons.add,
                            color: Color(0xff52525C),
                            size: 18.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 18.0,
                  ),
                  Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 15),
                        width: 400,
                        height: 440,
                        decoration: BoxDecoration(
                          color: Color(0xff4CC9D2),
                          border:
                              Border.all(color: Color(0xff52525C), width: 1),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(20, 18, 20, 0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border:
                              Border.all(color: Color(0xff52525C), width: 1),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: TableCalendar<Event>(
                          locale: 'ko_KR',
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
                          headerStyle: HeaderStyle(
                            titleCentered: true,
                          ),
                          calendarStyle: CalendarStyle(
                            defaultTextStyle: TextStyle().copyWith(
                              fontSize: 16.0,
                            ),
                            cellMargin: EdgeInsets.all(6.0),
                            cellPadding: EdgeInsets.all(6.0),
                            outsideDaysVisible: false,
                            cellAlignment: Alignment.center,
                            canMarkersOverflow: true,
                            weekendTextStyle: TextStyle().copyWith(
                              fontSize: 16.0,
                              color: Colors.lightGreen[800],
                            ),
                            holidayTextStyle: TextStyle().copyWith(
                              fontSize: 16.0,
                              color: Colors.lightGreen[800],
                            ),
                            // selectedDecoration: BoxDecoration(
                            //   color: mainGreen,
                            //   shape: BoxShape.circle,
                            // ),
                            // todayDecoration: BoxDecoration(
                            //   color: Colors.lightGreen[200],
                            //   shape: BoxShape.circle,
                            // ),
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
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  StreamBuilder<List<Event>>(
                    stream: getEventsByDate(_selectedDay),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final events = snapshot.data;
                        return SizedBox(
                          height: MediaQuery.of(context).size.height,
                          child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: events?.length,
                            itemBuilder: (context, index) {
                              final event = events?[index];
                              Color containerColor;
                              Color listTextColor;

                              switch (index % 3) {
                                case 0:
                                  containerColor = Color(0xffFFF27E);
                                  listTextColor = Color(0xff52525C);
                                  break;
                                case 1:
                                  containerColor = Color(0xffCFFFDC);
                                  listTextColor = Color(0xff52525C);
                                  break;
                                case 2:
                                  containerColor = Color(0xff0014FF);
                                  listTextColor = Colors.white;

                                  break;
                                  default:
                                    containerColor = Colors.white;
                                    listTextColor = Color(0xff52525C);

                              }
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  color: containerColor,
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: ListTile(
                                  title: Text('${event?.title}' ,style: TextStyle(color: listTextColor),),
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      _showDeleteConfirmationDialog(
                                          context, _focusedDay, event!);
                                    },
                                  ),
                                  onLongPress: () {
                                    _showDeleteConfirmationDialog(
                                        context, _focusedDay, event!);
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
      ),
    );
  }
}
