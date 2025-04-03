import 'package:flutter/material.dart';
import '../database.dart';
import 'event_planner_item.dart';
import 'encrypted_storage.dart';

class EventPlannerPage extends StatefulWidget {
  final AppDatabase database;
  const EventPlannerPage({super.key, required this.database});

  @override
  State<EventPlannerPage> createState() => _EventPlannerPageState();
}

class _EventPlannerPageState extends State<EventPlannerPage> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _date = TextEditingController();
  final _time = TextEditingController();
  final _location = TextEditingController();
  final _description = TextEditingController();

  int? _selectedId;
  late final _dao = widget.database.eventPlannerDao;
  List<EventPlannerItem> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _clearFields() {
    _name.clear();
    _date.clear();
    _time.clear();
    _location.clear();
    _description.clear();
    _selectedId = null;
  }

  Future<void> _loadEvents() async {
    final items = await _dao.getAllItems();
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
        location: _location.text.trim(),
        description: _description.text.trim(),
      );

      if (_selectedId == null) {
        await _dao.insertItem(newEvent);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Event added.")));
      } else {
        await _dao.updateItem(newEvent);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Event updated.")));
      }

      await saveLastEvent(newEvent);
      _clearFields();
      await _loadEvents();
    }
  }

  void _selectEvent(EventPlannerItem e) {
    _selectedId = e.id;
    _name.text = e.name;
    _date.text = e.date;
    _time.text = e.time;
    _location.text = e.location;
    _description.text = e.description;
  }

  Future<void> _deleteEvent(EventPlannerItem e) async {
    await _dao.deleteItem(e);
    _clearFields();
    await _loadEvents();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Event deleted.")));
  }

  Future<void> _copyPrevious() async {
    final saved = await getLastEventData();
    _name.text = saved['name'] ?? '';
    _date.text = saved['date'] ?? '';
    _time.text = saved['time'] ?? '';
    _location.text = saved['location'] ?? '';
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
        title: const Text("Event Planner"),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("How to Use"),
                  content: const Text(
                    "Fill out the fields below to add an event.\n\n"
                        "Tap an event to edit it.\n"
                        "Long-press to delete.\n"
                        "Tap the copy icon to reuse the last added event.",
                  ),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
                ),
              );
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _copyPrevious,
        tooltip: "Copy Last Event",
        child: const Icon(Icons.copy),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildInput(_name, "Event Name"),
                  _buildInput(_date, "Date (YYYY-MM-DD)"),
                  _buildInput(_time, "Time (HH:MM)"),
                  _buildInput(_location, "Location"),
                  _buildInput(_description, "Description"),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _submitEvent,
                        child: Text(_selectedId == null ? "Add Event" : "Update Event"),
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
                              location: _location.text,
                              description: _description.text,
                            ),
                          ),
                          child: const Text("Delete"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _events.isEmpty
                  ? const Center(child: Text("No events available."))
                  : ListView.builder(
                itemCount: _events.length,
                itemBuilder: (_, index) {
                  final e = _events[index];
                  return Card(
                    child: ListTile(
                      title: Text(e.name),
                      subtitle: Text("${e.date} at ${e.time}\n📍 ${e.location}"),
                      onTap: () => _selectEvent(e),
                      onLongPress: () => _deleteEvent(e),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
