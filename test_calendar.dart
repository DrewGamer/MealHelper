import 'package:flutter/material.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

void main() async {
  var config = CalendarDatePicker2WithActionButtonsConfig(
    calendarType: CalendarDatePicker2Type.range,
  );
  List<DateTime?>? values = await showCalendarDatePicker2Dialog(
    context: null as dynamic,
    config: config,
    dialogSize: const Size(325, 400),
    value: [],
  );
}
