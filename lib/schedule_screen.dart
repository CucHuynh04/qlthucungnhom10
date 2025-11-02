// lib/schedule_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'pet_service.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _selectedScheduleType = 'all'; // 'all', 'care', 'vaccination', 'play'

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _initializeLocale();
  }

  Future<void> _initializeLocale() async {
    // Use proper locale based on current language
    final localeCode = context.locale.languageCode == 'vi' ? 'vi_VN' : 'en_US';
    await initializeDateFormatting(localeCode, null);
  }


  @override
  Widget build(BuildContext context) {
    final petService = context.watch<PetService>();
    
    return FutureBuilder<void>(
      future: _initializeLocale(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        return Scaffold(
          extendBody: true,
          body: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                children: [
                  // Calendar
                  Card(
                    margin: const EdgeInsets.all(16),
                    child: TableCalendar<String>(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      eventLoader: (day) => _getEventsForDay(day, petService),
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      locale: context.locale.languageCode == 'vi' ? 'vi_VN' : 'en_US',
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: false,
                        markersMaxCount: 3,
                        markerDecoration: BoxDecoration(
                          color: Colors.teal[700],
                          shape: BoxShape.circle,
                        ),
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: true,
                        titleCentered: true,
                        formatButtonShowsNext: false,
                        formatButtonDecoration: BoxDecoration(
                          color: Colors.teal[700],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        formatButtonTextStyle: const TextStyle(color: Colors.white),
                        leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white),
                        rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white),
                      ),
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        if (!isSameDay(_selectedDay, selectedDay)) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        }
                      },
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
                  )
                      .animate()
                      ,
                  
                  // Schedule list
                  Expanded(
                    child: _buildScheduleList(petService)
                        .animate()
                        ),
                ],
              ),

            ],
          ),
        );
      },
    );
  }

  List<String> _getEventsForDay(DateTime day, PetService petService) {
    final events = <String>[];
    
    // Lấy các lịch hẹn từ PetService
    final schedules = petService.getSchedulesForDay(day);
    for (final schedule in schedules) {
      events.add(schedule.title);
    }
    
    // Thêm các sự kiện từ vaccination due dates
    for (final pet in petService.pets) {
      for (final vaccination in pet.vaccinationHistory) {
        if (vaccination.nextDueDate != null &&
            isSameDay(vaccination.nextDueDate!, day)) {
          events.add('Tiêm chủng ${pet.name}');
        }
      }
    }
    
    return events;
  }

  Widget _buildScheduleList(PetService petService) {
    if (_selectedDay == null) return const SizedBox.shrink();
    
    final events = _getEventsForDay(_selectedDay!, petService);
    final filteredEvents = _filterEvents(events);
    
    if (filteredEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_available, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'no_schedule'.tr(),
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'tap_to_add'.tr(),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredEvents.length,
      itemBuilder: (context, index) {
        final event = filteredEvents[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getEventColor(event),
              child: Icon(
                _getEventIcon(event),
                color: Colors.white,
              ),
            ),
            title: Text(event),
            subtitle: Text('${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year} ${_getEventTime(event, petService)}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteEvent(event, petService),
            ),
          ),
        )
            ;
      },
    );
  }

  List<String> _filterEvents(List<String> events) {
    switch (_selectedScheduleType) {
      case 'care':
        return events.where((e) => e.contains('Khám') || e.contains('Chăm sóc')).toList();
      case 'vaccination':
        return events.where((e) => e.contains('Tiêm chủng')).toList();
      case 'play':
        return events.where((e) => e.contains('Đi chơi')).toList();
      default:
        return events;
    }
  }

  Color _getEventColor(String event) {
    if (event.contains('Tiêm chủng')) return Colors.red;
    if (event.contains('Khám')) return Colors.blue;
    if (event.contains('Đi chơi')) return Colors.green;
    return Colors.teal;
  }

  IconData _getEventIcon(String event) {
    if (event.contains('Tiêm chủng')) return Icons.medical_services;
    if (event.contains('Khám')) return Icons.healing;
    if (event.contains('Đi chơi')) return Icons.pets;
    return Icons.event;
  }

  String _getEventTime(String event, PetService petService) {
    // Tìm lịch hẹn trong PetService
    final schedules = petService.getSchedulesForDay(_selectedDay!);
    final schedule = schedules.firstWhere(
      (s) => s.title == event,
      orElse: () => ScheduleRecord(
        id: '',
        petId: '',
        title: '',
        type: '',
        date: DateTime.now(),
      ),
    );
    
    return schedule.time ?? '';
  }

  void _deleteEvent(String event, PetService petService) {
    final schedules = petService.getSchedulesForDay(_selectedDay!);
    final schedule = schedules.firstWhere(
      (s) => s.title == event,
      orElse: () => ScheduleRecord(
        id: '',
        petId: '',
        title: '',
        type: '',
        date: DateTime.now(),
      ),
    );
    
    if (schedule.id.isNotEmpty) {
      petService.deleteSchedule(schedule.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${'delete'.tr()}: $event')),
      );
    }
  }

  void _showAddScheduleDialog(BuildContext context, PetService petService) {
    String? selectedType;
    String? selectedPetId;
    final titleController = TextEditingController();
    final notesController = TextEditingController();
    TimeOfDay? selectedTime = TimeOfDay.now();
    DateTime selectedDate = _selectedDay ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: Text('add_schedule'.tr()),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'schedule_type'.tr()),
                items: [
                  DropdownMenuItem(value: 'care', child: Text('routine_checkup'.tr())),
                  DropdownMenuItem(value: 'vaccination', child: Text('vaccination'.tr())),
                  DropdownMenuItem(value: 'play', child: Text('play_time'.tr())),
                ],
                onChanged: (value) {
                  selectedType = value;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'pet'.tr()),
                items: petService.pets.map((pet) => DropdownMenuItem(
                  value: pet.id,
                  child: Text(pet.name),
                )).toList(),
                onChanged: (value) {
                  selectedPetId = value;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề',
                  hintText: 'Để trống để tự động tạo tiêu đề',
                ),
              ),
              const SizedBox(height: 16),
              // Chọn ngày (hiển thị ngày đã chọn trên calendar)
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (date != null) {
                    setDialogState(() {
                      selectedDate = date;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Ngày: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime ?? TimeOfDay.now(),
                  );
                  if (time != null) {
                    setDialogState(() {
                      selectedTime = time;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time),
                      const SizedBox(width: 12),
                      Text(
                        selectedTime != null 
                            ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                            : 'Chọn thời gian',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: InputDecoration(labelText: 'notes'.tr()),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedType == null || selectedPetId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('please_select_pet'.tr())),
                );
                return;
              }

              final pet = petService.getPetById(selectedPetId!);
              if (pet != null) {
                final scheduleDateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime!.hour,
                  selectedTime!.minute,
                );

                // Tạo tiêu đề mặc định nếu không nhập
                String finalTitle = titleController.text.trim();
                if (finalTitle.isEmpty) {
                  String typeName = '';
                  switch (selectedType) {
                    case 'care':
                      typeName = 'khám định kỳ';
                      break;
                    case 'vaccination':
                      typeName = 'tiêm chủng';
                      break;
                    case 'play':
                      typeName = 'đi chơi';
                      break;
                  }
                  finalTitle = '${pet.name} $typeName';
                }

                // Thêm lịch hẹn vào PetService
                petService.addSchedule(
                  selectedPetId!,
                  finalTitle,
                  selectedType!,
                  scheduleDateTime,
                  time: '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}',
                  notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                );

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('export_success'.tr())),
                );
              }
            },
            child: Text('add'.tr()),
          ),
        ],
          );
        },
      ),
    );
  }
}




