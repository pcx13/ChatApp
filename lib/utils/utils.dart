import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Utils {
  static final messengerKey = GlobalKey<ScaffoldMessengerState>();

  static showSnackBar(String? text, Color color) {
    if (text == null) return;

    final snackBar = SnackBar(
      content: Text(text),
      backgroundColor: color,
    );

    messengerKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static StreamTransformer<QuerySnapshot<Map<String, dynamic>>, List<T>>
      transformer<T>(T Function(Map<String, dynamic> json) fromJson) =>
          StreamTransformer<QuerySnapshot<Map<String, dynamic>>,
              List<T>>.fromHandlers(
            handleData: (QuerySnapshot<Map<String, dynamic>> data,
                EventSink<List<T>> sink) {
              final snaps = data.docs.map((e) => e.data()).toList();
              final users = snaps.map((e) => fromJson(e)).toList();

              sink.add(users);
            },
          );

  static DateTime? toDateTime(Timestamp? value) {
    if (value == null) return null;

    return value.toDate();
  }

  static dynamic fromDateTimeToJson(DateTime? date) {
    if (date == null) return null;

    return date.toUtc();
  }

  static String readTime(String time) {
    if (time != '') {
      final readAt = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
      final dateFormat = DateFormat('d MMM yyyy, HH:mm');
      return dateFormat.format(readAt);
    } else {
      return 'Not seen yet';
    }
  }

  static Text selectionCount(HashSet set) {
    return Text('${set.length}');
  }
}
