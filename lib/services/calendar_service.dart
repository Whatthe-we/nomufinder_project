import 'package:add_2_calendar/add_2_calendar.dart';

class CalendarService {
  static void addAppointmentToCalendar({
    required String title,
    required String description,
    required String location,
    required DateTime startTime,
    required DateTime endTime,
  }) {
    final Event event = Event(
      title: title,
      description: description,
      location: location,
      startDate: startTime,
      endDate: endTime,
      iosParams: const IOSParams(reminder: Duration(minutes: 30)),
      androidParams: const AndroidParams(emailInvites: []),
    );

    Add2Calendar.addEvent2Cal(event);
  }
}
