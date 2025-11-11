import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  static const String _calendarKey = 'calendar_enabled';
  static const String _notifKey = 'notifications_enabled';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkPermissions();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _calendarEnabled = prefs.getBool(_calendarKey) ?? false;
      _notificationsEnabled = prefs.getBool(_notifKey) ?? false;
    });
  }
  Future<void> _saveCalendar(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_calendarKey, val);
  }
  Future<void> _saveNotif(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notifKey, val);
  }

  Future<void> _checkPermissions() async {
    // Implement permission check logic if needed
  }

  @override
  Widget build(BuildContext context) {
    // Palette
    const darkBg = Color(0xFF181A20);
    const cardBg = Color(0xFF23252B);
    const accentGreen = Color(0xFF6DFD7D);
    const accentBlue = Color(0xFF4886FE);

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: accentGreen),
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [accentBlue, accentGreen],
          ).createShader(bounds),
          child: const Text(
            'Calendar & Reminders',
            style: TextStyle(
              color: Colors.white, // This is replaced by the gradient
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            _sectionHeader('Calendar Integration', accentGreen),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.09),
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              margin: const EdgeInsets.only(bottom: 22),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('Sync to Calendar', style: TextStyle(color: accentGreen, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Add workouts to your device calendar', style: TextStyle(color: Colors.grey)),
                    value: _calendarEnabled,
                    activeColor: accentGreen,
                    inactiveTrackColor: Colors.grey.shade800,
                    onChanged: (value) async {
                      if (value) {
                        final hasPermission = await CalendarService.requestPermissions();
                        if (hasPermission) {
                          setState(() => _calendarEnabled = true);
                          await _saveCalendar(true);
                        } else {
                          _showPermissionDialog('Calendar');
                        }
                      } else {
                        setState(() => _calendarEnabled = false);
                        await _saveCalendar(false);
                      }
                    },
                  ),
                  if (_calendarEnabled) ...[
                    const Divider(color: Colors.grey, height: 1),
                    ListTile(
                      leading: Icon(Icons.access_time, color: accentGreen),
                      title: Text('Preferred Workout Time', style: TextStyle(color: accentGreen)),
                      subtitle: Text(_workoutTime.format(context), style: TextStyle(color: Colors.grey[300])),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: accentGreen),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _workoutTime,
                        );
                        if (time != null) setState(() => _workoutTime = time);
                      },
                    ),
                    const Divider(color: Colors.grey, height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton.icon(
                        onPressed: _syncCurrentProgram,
                        icon: Icon(Icons.sync, color: darkBg),
                        label: const Text('Sync Current Program'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentGreen,
                          foregroundColor: darkBg,
                          minimumSize: const Size(double.infinity, 44),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            _sectionHeader('Workout Reminders', accentBlue),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.09),
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              margin: const EdgeInsets.only(bottom: 22),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('Daily Reminders', style: TextStyle(color: accentBlue, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Get notified about your workouts', style: TextStyle(color: Colors.grey)),
                    value: _notificationsEnabled,
                    activeColor: accentBlue,
                    inactiveTrackColor: Colors.grey.shade800,
                    onChanged: (value) async {
                      if (value) {
                        final hasPermission = await NotificationService.requestPermission();
                        if (hasPermission) {
                          setState(() => _notificationsEnabled = true);
                          await _saveNotif(true);
                          _scheduleReminders();
                        } else {
                          _showPermissionDialog('Notifications');
                        }
                      } else {
                        setState(() => _notificationsEnabled = false);
                        await _saveNotif(false);
                        await NotificationService.cancelAllNotifications();
                      }
                    },
                  ),
                  if (_notificationsEnabled) ...[
                    const Divider(color: Colors.grey, height: 1),
                    ListTile(
                      leading: Icon(Icons.notifications, color: accentBlue),
                      title: Text('Reminder Time', style: TextStyle(color: accentBlue)),
                      subtitle: Text(_reminderTime.format(context), style: TextStyle(color: Colors.grey[300])),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: accentBlue),
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
                    const Divider(color: Colors.grey, height: 1),
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
                        icon: Icon(Icons.send, color: accentBlue),
                        label: Text('Send Test Notification', style: TextStyle(color: accentBlue)),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 44),
                          side: BorderSide(color: accentBlue, width: 2),
                          foregroundColor: accentBlue,
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: accentBlue),
                      const SizedBox(width: 8),
                      Text(
                        'How it works',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: accentBlue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _infoBullet('Calendar sync adds your workouts as events.'),
                  const SizedBox(height: 6),
                  _infoBullet('Reminders notify you before workout time.'),
                  const SizedBox(height: 6),
                  _infoBullet('You can customize times for each feature.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 2),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _infoBullet(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('• ', style: TextStyle(color: Colors.grey[400])),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey[400], fontSize: 14.5),
          ),
        ),
      ],
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
        backgroundColor: const Color(0xFF23252B),
        title: Text('$permissionType Permission Required', style: const TextStyle(color: Color(0xFF6DFD7D))),
        content: Text(
          'Please grant $permissionType permission in your device settings to use this feature.',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6DFD7D),
              foregroundColor: const Color(0xFF23252B),
            ),
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
