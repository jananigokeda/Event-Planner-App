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

class _EventPlannerPageState extends State<EventPlannerPage> {
  //late event_planner_dao myDAO;
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _date = TextEditingController();
  final _time = TextEditingController();
  final _venue = TextEditingController();
  final _description = TextEditingController();
  int? _selectedId;
 // late final _dao = widget.database.eventPlannerDao;
  late EventPlannerDao myDAO;
  late AppDatabase _database;
  List<EventPlannerItem> _events = [];


  @override
  void initState() {
    super.initState();
    // Build the Floor database and get the DAO.
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
          // Telugu
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


  void _clearFields() {
    _name.clear();
    _date.clear();
    _time.clear();
    _venue.clear();
    _description.clear();
    _selectedId = null;
  }

  Future<void> _loadEvents() async {
    final items = await myDAO.getAllItems();
    setState(() {
      _events = items;
    });
  }

  Future<void> _submitEvent() async {
    if (_formKey.currentState!.validate()) {
      final newEvent = EventPlannerItem(
        id: _selectedId,
        name: _name.text.trim(),
        date: _date.text.trim(),
        time: _time.text.trim(),
        venue: _venue.text.trim(),
        description: _description.text.trim(),
      );

      if (_selectedId == null) {
        await myDAO.insertItem(newEvent);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Event added.")));
      } else {
        await myDAO.updateItem(newEvent);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Event updated.")));
      }

      await saveLastEvent(newEvent);
      _clearFields();
      await _loadEvents();
    }
  }

  Future<void> _deleteEvent(EventPlannerItem e) async {
    await myDAO.deleteItem(e);
    _clearFields();
    await _loadEvents();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Event deleted.")));
  }

  Future<void> _copyPrevious() async {
    final saved = await getLastEventData();
    _name.text = saved['name'] ?? '';
    _date.text = saved['date'] ?? '';
    _time.text = saved['time'] ?? '';
    _venue.text = saved['location'] ?? '';
    _description.text = saved['description'] ?? '';
  }

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
                content: Text(translate(
                    "Create and manage events using this planner. Add new events on the left, view their details on the right."
                        "You can also save all events for reporting.",
                  ),
                  //actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
                ),
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
      body: Padding(
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
                        _buildInput(_name, translate('event.Event Name')),
                        _buildInput(_date, translate('event.Date')),
                        _buildInput(_time, translate('event.Time')),
                        _buildInput(_venue, translate('event.Venue')),
                        _buildInput(_description, translate('event.Description')),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ElevatedButton(
                                onPressed: _submitEvent,
                                child: Text(_selectedId == null
                                    ? translate('event.Create Event')
                                    : translate('event.Save Changes')),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton.icon(
                                onPressed: _copyPrevious,
                                icon: const Icon(Icons.copy),
                                label: Text(translate('event.Copy Last Event')),
                              ),
                              const SizedBox(width: 10),
                              OutlinedButton(
                                onPressed: _clearFields,
                                child: Text(translate('event.Clear Form')),
                              ),
                              const SizedBox(width: 10),
                              if (_selectedId != null)
                                ElevatedButton(
                                  onPressed: () => _deleteEvent(
                                    EventPlannerItem(
                                      id: _selectedId,
                                      name: _name.text,
                                      date: _date.text,
                                      time: _time.text,
                                      venue: _venue.text,
                                      description: _description.text,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: Text(translate('event.Delete Event')),
                                ),
                            ],
                          ),
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
                                _name.text = e.name;
                                _date.text = e.date;
                                _time.text = e.time;
                                _venue.text = e.venue;
                                _description.text = e.description;
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

            /// Right side - Event details
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
                    Text("Name: ${_name.text}"),
                    Text("Date: ${_date.text}"),
                    Text("Time: ${_time.text}"),
                    Text("Venue: ${_venue.text}"),
                    Text("Description: ${_description.text}"),
                    Text("Database ID: $_selectedId"),
                    const SizedBox(height: 20),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
