import 'package:cst2335_final/event_planner_dao.dart';
import 'package:flutter/material.dart';
import '../database.dart';
import 'event_planner_item.dart';
import 'encrypted_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_translate/flutter_translate.dart';

class EventPlannerPage extends StatefulWidget {
  const EventPlannerPage({Key? key}) : super(key: key);
  // final AppDatabase database;

  @override
  State<EventPlannerPage> createState() => _EventPlannerPageState();
}
/// Controllers for form fields
class _EventPlannerPageState extends State<EventPlannerPage> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDateController = TextEditingController();
  final TextEditingController _eventTimeController = TextEditingController();
  final TextEditingController _eventvenueController = TextEditingController();
  final TextEditingController _eventDescriptionController = TextEditingController();
  int? _selectedId;
  late EventPlannerDao myDAO;
  late AppDatabase _database;
  List<EventPlannerItem> _events = [];

  @override
  void initState() {
    super.initState();
    /// Initialize the Floor database and DAO
    $FloorAppDatabase.databaseBuilder('app_database.db').build().then((database) {
      _database = database;
      myDAO = database.eventPlannerDao;
      _loadEvents();
    });
  }
  void showDemoActionSheet(
      {required BuildContext context, required Widget child}) {
    showCupertinoModalPopup<String>(
        context: context,
        builder: (BuildContext context) => child).then((String? value) {
      if (value != null) changeLocale(context, value);
    });
  }
  /// Called when language icon is pressed
  void _onActionsheetPress(BuildContext context) {
    showDemoActionSheet(
      context: context,
      child: CupertinoActionSheet(
        title: Text(translate('language.selection.title')),
        message: Text(translate('language.selection.message')),
        actions: <Widget>[
          // English
          CupertinoActionSheetAction(
            child: Text(translate('language.name.en')),
            onPressed: () async {
              Navigator.pop(context);
              await changeLocale(context, 'en');
            },
          ),
          /// Telugu
          CupertinoActionSheetAction(
            child: Text(translate('language.name.te')),
            onPressed: () async {
              Navigator.pop(context);
              await changeLocale(context, 'te');
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(translate('event.Close')),
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  /// Clear all form fields
  void _clearFields() {
    _eventNameController.clear();
    _eventDateController.clear();
    _eventTimeController.clear();
    _eventvenueController.clear();
    _eventDescriptionController.clear();
    _selectedId = null;
  }
/// Load events from the database
  Future<void> _loadEvents() async {
    final items = await myDAO.getAllItems();
    setState(() {
      _events = items;
    });
  }
/// Submit new or updated event to the database
  Future<void> _submitEvent() async {
    if (_formKey.currentState!.validate()) {
      final newEvent = EventPlannerItem(
        id: _selectedId,
        name: _eventNameController.text.trim(),
        date: _eventDateController.text.trim(),
        time: _eventTimeController.text.trim(),
        venue: _eventvenueController.text.trim(),
        description: _eventDescriptionController.text.trim(),
      );

      if (_selectedId == null) {
        await myDAO.insertItem(newEvent);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Event added.")));
      } else {
        await myDAO.updateItem(newEvent);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Event updated.")));
      }
/// Save the last entered event
      await saveLastEvent(newEvent);
      _clearFields();
      await _loadEvents();
    }
  }
/// Delete selected event with confirmation dialog
  Future<void> _deleteEvent(EventPlannerItem e) async {
    await myDAO.deleteItem(e);
    _clearFields();
    await _loadEvents();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Event deleted.")));
  }
  /// Copy last saved event using EncryptedSharedPreferences
  Future<void> _copyPrevious() async {
    final saved = await getLastEventData();
    _eventNameController.text = saved['name'] ?? '';
    _eventDateController.text = saved['date'] ?? '';
    _eventTimeController.text = saved['time'] ?? '';
    _eventvenueController.text = saved['venue'] ?? '';
    _eventDescriptionController.text = saved['description'] ?? '';
  }
/// Reusable input field builder
  Widget _buildInput(TextEditingController controller, String label, {TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: type ?? TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (val) => val == null || val.trim().isEmpty ? "Enter $label" : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translate('event.Event Planner')),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(translate("event.HowToUseTitle")),

                content: Text(translate( "event.instructions_content")),
                    actions: [
                    TextButton(
                    onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                  )
                  ] ,
                //actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
                ),

              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: "Change Language",
            onPressed: () => _onActionsheetPress(context),
          ),

        ],
      ),
      body: Stack(
          children: [
      /// Background image layer
   //   Container(
    //  decoration: BoxDecoration(
    //  image: DecorationImage(
     //     image: AssetImage("images/EventPlanner.jpeg"),
   //   fit: BoxFit.cover,
   // ),
   // ),
   // ),
    /// Main content over background
    Padding(
    padding: const EdgeInsets.all(12.0),
    child: Row(
    children: [
            /// Left side - Form and event list
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildInput(_eventNameController, translate('event.Event Name')),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: TextFormField(
                            controller: _eventDateController,
                            readOnly: true,
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                _eventDateController.text = picked.toIso8601String().split('T')[0]; // Formats as YYYY-MM-DD
                              }
                            },
                            decoration: InputDecoration(
                              labelText: translate('event.Date'),
                              border: OutlineInputBorder(),
                            ),
                            validator: (val) => val == null || val.trim().isEmpty ? "Enter Date" : null,
                          ),
                        ),

                        _buildInput(_eventTimeController, translate('event.Time')),
                        _buildInput(_eventvenueController, translate('event.venue')),
                        _buildInput(_eventDescriptionController, translate('event.Description')),
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            ElevatedButton(
                              onPressed: _submitEvent,
                              child: Text(_selectedId == null
                                  ? translate('event.Create Event')
                                  : translate('event.Save Changes')),
                            ),
                            ElevatedButton.icon(
                              onPressed: _copyPrevious,
                              icon: const Icon(Icons.copy),
                              label: Text(translate('event.Copy Last Event')),
                            ),
                            OutlinedButton(
                              onPressed: _clearFields,
                              child: Text(translate('event.Clear Form')),
                            ),
                            if (_selectedId != null)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: Text("Confirm Deletion"),
                                      content: Text("Are you sure you want to delete this event?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _deleteEvent(
                                              EventPlannerItem(
                                                id: _selectedId,
                                                name: _eventNameController.text,
                                                date: _eventDateController.text,
                                                time: _eventTimeController.text,
                                                venue: _eventvenueController.text,
                                                description: _eventDescriptionController.text,
                                              ),
                                            );
                                          },
                                          child: const Text("Delete"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Text(translate('event.Delete Event')),
                              ),

                          ],
                        ),

                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _events.length,
                      itemBuilder: (_, index) {
                        final e = _events[index];
                        return Card(
                          child: ListTile(
                            title: Text(e.name),
                            subtitle: Text("\u{1F4C5} ${e.date} at ${e.time}\n\u{1F4CD} ${e.venue}"),
                            onTap: () {
                              setState(() {
                                _selectedId = e.id;
                                _eventNameController.text = e.name;
                                _eventDateController.text = e.date;
                                _eventTimeController.text = e.time;
                                _eventvenueController.text = e.venue;
                                _eventDescriptionController.text = e.description;
                              });
                            },
                            tileColor: _selectedId == e.id ? Colors.blue[50] : null,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            ///  Right side - selected event details
            Expanded(
              flex: 1,
              child: _selectedId == null
                  ? Center(child: Text(translate('event.No Event Selected')))
                  : Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(translate('event.Event Detail'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text("${translate('event.Event Name')}: ${_eventNameController.text}"),
                    Text("${translate('event.Date')}: ${_eventDateController.text}"),
                    Text("${translate('event.Time')}: ${_eventTimeController.text}"),
                    Text("${translate('event.Venue')}: ${_eventvenueController.text}"),
                    Text("${translate('event.Description')}: ${_eventDescriptionController.text}"),
                    Text("Database ID: $_selectedId"),
                    const SizedBox(height: 20),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ]
    ),
    );
  }
}
