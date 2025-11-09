import 'package:flutter/material.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/program.dart';
import '../models/workout.dart';
import 'package:timezone/timezone.dart' as tz;


class CalendarService {
  static final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
  static String? _selectedCalendarId;

  // Request calendar permissions
  static Future<bool> requestPermissions() async {
    final calendarStatus = await Permission.calendar.request();
    return calendarStatus.isGranted;
  }

  // Get available calendars
  static Future<List<Calendar>> getCalendars() async {
    final hasPermission = await requestPermissions();
    if (!hasPermission) return [];

    try {
      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      return calendarsResult.data ?? [];
    } catch (e) {
      print('Error getting calendars: $e');
      return [];
    }
  }

  // Select a calendar (or use default)
  static Future<String?> selectCalendar() async {
    final calendars = await getCalendars();
    if (calendars.isEmpty) return null;

    // Try to find a writable calendar
    for (var calendar in calendars) {
      if (calendar.isReadOnly == false) {
        _selectedCalendarId = calendar.id;
        return calendar.id;
      }
    }

    // If no writable calendar, use first one
    _selectedCalendarId = calendars.first.id;
    return calendars.first.id;
  }

  // Add program workouts to calendar
  static Future<bool> addProgramToCalendar(
    Program program, {
    DateTime? startDate,
    TimeOfDay? preferredTime,
  }) async {
    final hasPermission = await requestPermissions();
    if (!hasPermission) return false;

    if (_selectedCalendarId == null) {
      await selectCalendar();
    }

    if (_selectedCalendarId == null) return false;

    final start = startDate ?? DateTime.now();
    final time = preferredTime ?? const TimeOfDay(hour: 9, minute: 0);

    try {
      // Add each workout as a calendar event
      for (int weekDay = 0; weekDay < program.workouts.length; weekDay++) {
        final workout = program.workouts[weekDay];
        
        if (workout.isRestDay) continue; // Skip rest days

        // Calculate the date for this workout (starting from startDate)
        final workoutDate = start.add(Duration(days: weekDay));
        final workoutStart = DateTime(
          workoutDate.year,
          workoutDate.month,
          workoutDate.day,
          time.hour,
          time.minute,
        );
        final workoutEnd = workoutStart.add(
          Duration(minutes: workout.durationMinutes),
        );

        // Create event
        final event = Event(
          _selectedCalendarId,
          title: '${program.name}: ${workout.name}',
          description: _buildEventDescription(workout),
          start: TZDateTime.from(workoutStart, local),
          end: TZDateTime.from(workoutEnd, local),
          location: 'Fitness App',
        );

        // Add to calendar
        await _deviceCalendarPlugin.createOrUpdateEvent(event);
      }

      return true;
    } catch (e) {
      print('Error adding to calendar: $e');
      return false;
    }
  }

  // Remove program events from calendar
  static Future<bool> removeProgramFromCalendar(String programName) async {
    final hasPermission = await requestPermissions();
    if (!hasPermission) return false;

    if (_selectedCalendarId == null) {
      await selectCalendar();
    }

    if (_selectedCalendarId == null) return false;

    try {
      // Get all events
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 7));
      final endDate = now.add(const Duration(days: 90));

      final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
        _selectedCalendarId,
        RetrieveEventsParams(
          startDate: startDate,
          endDate: endDate,
        ),
      );

      final events = eventsResult.data ?? [];

      // Delete events that match the program name
      for (var event in events) {
        if (event.title?.contains(programName) == true) {
          await _deviceCalendarPlugin.deleteEvent(
            _selectedCalendarId,
            event.eventId!,
          );
        }
      }

      return true;
    } catch (e) {
      print('Error removing from calendar: $e');
      return false;
    }
  }

  static String _buildEventDescription(Workout workout) {
    final buffer = StringBuffer();
    buffer.writeln('${workout.description}\n');
    buffer.writeln('Duration: ${workout.durationMinutes} minutes');
    buffer.writeln('Difficulty: ${workout.difficulty}\n');
    
    if (workout.exercises.isNotEmpty) {
      buffer.writeln('Exercises:');
      for (var exercise in workout.exercises) {
        buffer.writeln('• ${exercise.name} - ${exercise.sets}x${exercise.reps}');
      }
    }
    
    return buffer.toString();
  }
}

// Timezone helper
final local = tz.getLocation('UTC');