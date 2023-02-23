
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../style/app_styles.dart';
import '../model/utils.dart';
import 'addPages/addnotice.dart';
import 'addPages/addstory.dart';

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

  List<Event> _getEventsForDay(DateTime day) {
    // Implementation example
    return kEvents[day] ?? [];
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
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }
  }

  List<Widget> list_whoarewe = <Widget>[
    Center(
      child: Text("OBC"),
    ),
    Center(
      child: Text("OEC"),
    ),
    Center(
      child: Text("OSW"),
    ),
    Center(
      child: Text("OCB(서울경기지부)"),
    ),
    Center(
      child: Text("OCB(충청)"),
    ),
    Center(
      child: Text("OCB(경기)"),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
      slivers: [
        SliverAppBar(
          automaticallyImplyLeading: false,
          title: Text(
            "Onebody Community",
            style: TextStyle(fontSize: 10),
          ),
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                ),
                onPressed: () => {Navigator.pushNamed(context, '/wishlist')}),
            IconButton(
                icon: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, __, ___) => AddNoticePage(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                }),
            IconButton(
                icon: Icon(
                  Icons.add_circle,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, __, ___) => AddStoryPage(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                }),
            IconButton(
                icon: const Icon(
                  Icons.exit_to_app,
                  color: Colors.white,
                ),
                onPressed: () async {
                  Navigator.pushNamed(context, '/login');
                  await FirebaseAuth.instance.signOut();
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
                  Container(
                      child: CarouselSlider(
                    options: CarouselOptions(
                      height: 300,
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 10),
                      viewportFraction: 1,
                    ),
                    items: list_whoarewe
                        .map((item) => Container(
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              child: Center(child: item),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: camel,
                              ),
                            ))
                        .toList(),
                  )),
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
                        child: Text("공동체 일정", style: headLineGreenStyle)),
                  ),
                  TableCalendar<Event>(
                    firstDay: kFirstDay,
                    lastDay: kLastDay,
                    focusedDay: _focusedDay,
                    availableCalendarFormats: {CalendarFormat.month : 'Month'},
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    rangeStartDay: _rangeStart,
                    sixWeekMonthsEnforced: true,
                    rangeEndDay: _rangeEnd,
                    calendarFormat: _calendarFormat,
                    rangeSelectionMode: _rangeSelectionMode,
                    eventLoader: _getEventsForDay,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    calendarStyle: CalendarStyle(
                      // Use `CalendarStyle` to customize the UI
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

                  ),
                  const SizedBox(height: 8.0),
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: ValueListenableBuilder<List<Event>>(
                      valueListenable: _selectedEvents,
                      builder: (context, value, _) {
                        return ListView.builder(
                          physics:NeverScrollableScrollPhysics(),
                          itemCount: value.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 4.0,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: ListTile(
                                onTap: () => print('${value[index]}'),
                                title: Text('${value[index]}'),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    ));
  }
}
