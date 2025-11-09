import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/calendar_service.dart';
import '../services/notification_service.dart';
import '../providers/program_provider.dart';
import 'package:permission_handler/permission_handler.dart';


class CalendarSettingsScreen extends StatefulWidget {
  const CalendarSettingsScreen({Key? key}) : super(key: key);

  @override
  State<CalendarSettingsScreen> createState() => _CalendarSettingsScreenState();
}

class _CalendarSettingsScreenState extends State<CalendarSettingsScreen> {
  bool _calendarEnabled = false;
  bool _notificationsEnabled = false;
  TimeOfDay _workoutTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 30);

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // Check permissions status would go here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar & Reminders'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Calendar Integration Section
          _buildSectionTitle('Calendar Integration'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Sync to Calendar'),
                  subtitle: const Text('Add workouts to your device calendar'),
                  value: _calendarEnabled,
                  onChanged: (value) async {
                    if (value) {
                      final hasPermission = await CalendarService.requestPermissions();
                      if (hasPermission) {
                        setState(() => _calendarEnabled = true);
                      } else {
                        _showPermissionDialog('Calendar');
                      }
                    } else {
                      setState(() => _calendarEnabled = false);
                    }
                  },
                ),
                if (_calendarEnabled) ...[
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Preferred Workout Time'),
                    subtitle: Text(_workoutTime.format(context)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _workoutTime,
                      );
                      if (time != null) {
                        setState(() => _workoutTime = time);
                      }
                    },
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton.icon(
                      onPressed: _syncCurrentProgram,
                      icon: const Icon(Icons.sync),
                      label: const Text('Sync Current Program'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Notifications Section
          _buildSectionTitle('Workout Reminders'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Daily Reminders'),
                  subtitle: const Text('Get notified about your workouts'),
                  value: _notificationsEnabled,
                  onChanged: (value) async {
                    if (value) {
                      final hasPermission = await NotificationService.requestPermission();
                      if (hasPermission) {
                        setState(() => _notificationsEnabled = true);
                        _scheduleReminders();
                      } else {
                        _showPermissionDialog('Notifications');
                      }
                    } else {
                      setState(() => _notificationsEnabled = false);
                      await NotificationService.cancelAllNotifications();
                    }
                  },
                ),
                if (_notificationsEnabled) ...[
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('Reminder Time'),
                    subtitle: Text(_reminderTime.format(context)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _reminderTime,
                      );
                      if (time != null) {
                        setState(() => _reminderTime = time);
                        _scheduleReminders();
                      }
                    },
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await NotificationService.sendMotivationalNotification();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Test notification sent!')),
                          );
                        }
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('Send Test Notification'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    const Text(
                      'How it works',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('• Calendar sync adds your workouts as events'),
                const SizedBox(height: 6),
                const Text('• Reminders notify you before workout time'),
                const SizedBox(height: 6),
                const Text('• You can customize times for each feature'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Future<void> _syncCurrentProgram() async {
    final provider = context.read<ProgramProvider>();
    final program = provider.selectedProgram;

    if (program == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No program selected')),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final success = await CalendarService.addProgramToCalendar(
      program,
      preferredTime: _workoutTime,
    );

    if (mounted) Navigator.pop(context);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Program synced to calendar!'
                : 'Failed to sync program',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _scheduleReminders() async {
    await NotificationService.scheduleDailyReminder(
      id: 1,
      title: 'Workout Reminder',
      body: 'Time for your workout! Let\'s get moving! 💪',
      time: _reminderTime,
    );
  }

  void _showPermissionDialog(String permissionType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permissionType Permission Required'),
        content: Text(
          'Please grant $permissionType permission in your device settings to use this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}