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
      debugPrint('Error getting calendars: $e');
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
      int eventsCreated = 0;
      
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

        // Create event with program marker in title
        final event = Event(
          _selectedCalendarId,
          title: '🏋️ ${program.name}: ${workout.name}',
          description: _buildEventDescription(workout, program.name),
          start: TZDateTime.from(workoutStart, local),
          end: TZDateTime.from(workoutEnd, local),
          location: 'FitTrack App', // Marker for our app's events
        );

        // Add to calendar
        final result = await _deviceCalendarPlugin.createOrUpdateEvent(event);
        if (result?.isSuccess ?? false) {
          eventsCreated++;
          debugPrint('Created event: ${event.title}');
        }
      }

      debugPrint('Created $eventsCreated events for ${program.name}');
      return eventsCreated > 0;
    } catch (e) {
      debugPrint('Error adding to calendar: $e');
      return false;
    }
  }

  // Remove program events from calendar - FIXED VERSION
  static Future<bool> removeProgramFromCalendar(String programName) async {
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      debugPrint('❌ Calendar permission denied');
      return false;
    }

    try {
      // Get ALL calendars, not just the selected one
      final calendars = await getCalendars();
      if (calendars.isEmpty) {
        debugPrint('❌ No calendars found');
        return false;
      }

      debugPrint('🔍 Searching for events in ${calendars.length} calendars...');

      int totalDeleted = 0;
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 30)); // Look back 30 days
      final endDate = now.add(const Duration(days: 365)); // Look forward 1 year

      // Search through ALL calendars
      for (var calendar in calendars) {
        if (calendar.isReadOnly == true) {
          debugPrint('⏭️  Skipping read-only calendar: ${calendar.name}');
          continue;
        }

        debugPrint('📅 Checking calendar: ${calendar.name} (${calendar.id})');

        try {
          final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
            calendar.id,
            RetrieveEventsParams(
              startDate: startDate,
              endDate: endDate,
            ),
          );

          final events = eventsResult.data ?? [];
          debugPrint('   Found ${events.length} events in this calendar');

          // Delete events that match the program name
          for (var event in events) {
            // Check if this event belongs to our program
            final titleMatches = event.title?.contains(programName) ?? false;
            final locationMatches = event.location?.contains('FitTrack') ?? false;
            
            if (titleMatches && locationMatches) {
              debugPrint('   🗑️  Deleting: ${event.title}');
              
              final deleteResult = await _deviceCalendarPlugin.deleteEvent(
                calendar.id,
                event.eventId!,
              );

              if (deleteResult.isSuccess) {
                totalDeleted++;
                debugPrint('   ✅ Deleted successfully');
              } else {
                debugPrint('   ❌ Failed to delete: ${deleteResult.errors}');
              }
            }
          }
        } catch (e) {
          debugPrint('   ❌ Error checking calendar ${calendar.name}: $e');
        }
      }

      debugPrint('✅ Total events deleted: $totalDeleted');
      return totalDeleted > 0;
    } catch (e) {
      debugPrint('❌ Error removing from calendar: $e');
      return false;
    }
  }

  static String _buildEventDescription(Workout workout, String programName) {
    final buffer = StringBuffer();
    buffer.writeln('Program: $programName');
    buffer.writeln('${workout.description}\n');
    buffer.writeln('Duration: ${workout.durationMinutes} minutes');
    buffer.writeln('Difficulty: ${workout.difficulty}\n');
    
    if (workout.exercises.isNotEmpty) {
      buffer.writeln('Exercises:');
      for (var exercise in workout.exercises) {
        buffer.writeln('• ${exercise.name} - ${exercise.sets}x${exercise.reps}');
      }
    }
    
    buffer.writeln('\n📱 Created by FitTrack App');
    
    return buffer.toString();
  }
}

// Timezone helper
final local = tz.getLocation('UTC');