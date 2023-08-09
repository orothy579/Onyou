// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/foundation.dart';

/// Example event class.
class Event {
  final String title;

  const Event(this.title);

  @override
  String toString() => title;
}

/// Example events.
///
/// Using a [LinkedHashMap] is highly recommended if you decide to use a map.

class EventProvider extends ChangeNotifier {
  final kEvents = LinkedHashMap<DateTime, List<Event>>(
    equals: isSameDay,
    hashCode: getHashCode,
  );

  Stream<Map<DateTime, List<Event>>> getEventsFromFirebase() {
    final firestore = FirebaseFirestore.instance;
    final eventsCollection = firestore.collection('events');

    return eventsCollection.snapshots().map((querySnapshot) {
      kEvents.clear();

      querySnapshot.docs.forEach((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final eventDate = DateTime.parse(doc.id);
        final events = data['events'] as List<dynamic>;

        final eventList = events.map((eventData) {
          final title = eventData['title'] as String;
          return Event(title);
        }).toList();

        if (kEvents[eventDate] != null) {
          kEvents[eventDate]?.addAll(eventList);
        } else {
          kEvents[eventDate] = eventList;
        }
      });

      return kEvents; // 이벤트 맵을 그대로 반환합니다.
    });
  }


}




int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
        (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 10, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 10, kToday.day);