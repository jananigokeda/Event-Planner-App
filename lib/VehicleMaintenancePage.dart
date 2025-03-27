import 'package:flutter/material.dart';
import 'database.dart';
import 'vehicle_item.dart';
import 'vehicle_dao.dart';

class VehicleMaintenancePage extends StatefulWidget {
  final AppDatabase database;
  const VehicleMaintenancePage({Key? key, required this.database}) : super(key: key);

  @override
  _VehicleMaintenancePageState createState() => _VehicleMaintenancePageState();
}

class _VehicleMaintenancePageState extends State<VehicleMaintenancePage> {
  late VehicleDao myDAO;
  final List<VehicleItem> _items = [];
  final TextEditingController _vehicleNameController = TextEditingController();
  final TextEditingController _vehicleTypeController = TextEditingController();
  VehicleItem? _selectedItem;
  bool _isEditing = false; // Track if we're editing

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    myDAO = widget.database.vehicleDao;
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await myDAO.getAllItems();
    setState(() {
      _items.clear();
      _items.addAll(items);
    });
  }

  Future<void> _addItem() async {
    String vehicleName = _vehicleNameController.text.trim();
    String vehicleType = _vehicleTypeController.text.trim();
    if (vehicleName.isNotEmpty && vehicleType.isNotEmpty) {
      final newItem = VehicleItem(vehicleName: vehicleName, vehicleType: vehicleType);
      await myDAO.insertItem(newItem);
      _vehicleNameController.clear();
      _vehicleTypeController.clear();
      _loadItems();
    }
  }

  Future<void> _updateItem(VehicleItem item) async {
    String vehicleName = _vehicleNameController.text.trim();
    String vehicleType = _vehicleTypeController.text.trim();
    if (vehicleName.isNotEmpty && vehicleType.isNotEmpty) {
      final updatedItem = VehicleItem(
        vehicleId: item.vehicleId, // Keep the original ID
        vehicleName: vehicleName,
        vehicleType: vehicleType,
      );
      await myDAO.updateItem(updatedItem);
      _vehicleNameController.clear();
      _vehicleTypeController.clear();
      _loadItems();
      _setEditing(false); // Exit editing mode
      _closeDetails();
    }
  }


  Future<void> _removeItem(int index) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Item"),
          content: const Text("Are you sure you want to delete this item?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () async {
                await myDAO.deleteItem(_items[index]);
                _loadItems();
                Navigator.of(context).pop();
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  void _showDetails(VehicleItem item) {
    setState(() {
      _selectedItem = item;
      _vehicleNameController.text = item.vehicleName; // Populate text fields
      _vehicleTypeController.text = item.vehicleType;
    });
  }

  void _closeDetails() {
    setState(() {
      _selectedItem = null;
      _vehicleNameController.clear();
      _vehicleTypeController.clear();
      _setEditing(false); // Ensure not in editing mode
    });
  }

  void _setEditing(bool editing) {
    setState(() {
      _isEditing = editing;
    });
  }

  Widget _listPage() {
    return Column(
      children: [
        Column( // Stack inputs vertically
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(  // Vehicle Name Input
              controller: _vehicleNameController,
              decoration: const InputDecoration(
                hintText: "Vehicle Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10), // Space between fields
            TextField( // Vehicle Type Input
              controller: _vehicleTypeController,
              decoration: const InputDecoration(
                hintText: "Vehicle Type",
                border: OutlineInputBorder(),
              ),
            ),


            const SizedBox(height: 30),
            Align(  // Center the button
              alignment: Alignment.center,
              child: ElevatedButton(  // Save Button
                onPressed: _isEditing ? () => _updateItem(_selectedItem!) : _addItem, // Conditional save
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.lightBlueAccent,
                  padding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Text(_isEditing ? "UPDATE" : "SAVE"), // Change button text
              ),
            )
          ],
        ),
        const SizedBox(height: 50),
        const Divider( // Add the Divider widget
            color: Colors.grey, // Color of the line
            thickness: 1.0), // Thickness of the line
        Expanded(
          child: _items.isEmpty
              ? const Center(child: Text("There are no items in the list."))
              : ListView.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) {
              return Container( // Wrap each ListTile with Container
                margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0), // Add margin for spacing between blocks
                decoration: BoxDecoration( // Add background, border, and rounded corners
                  color: Colors.white, // Background color for the block
                 // border: Border.all(color: Colors.grey, width: 1.0), // Border
                  //borderRadius: BorderRadius.circular(8.0), // Rounded corners
                ),
                child: GestureDetector(
                  onTap: () {
                    _showDetails(_items[index]);
                  },
                  child: ListTile(
                    title: Center(
                      child: Text(
                        "${index + 1}: ${_items[index].vehicleName} - vehicleType: ${_items[index].vehicleType}",
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),


      ],
    );
  }

  Widget _detailsPage() {
    if (_selectedItem == null) {
      return const Center(child: Text("There is no item selected for detail."));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text("Vehicle Name: ${_selectedItem!.vehicleName}",
            style: const TextStyle(fontSize: 18)),
        Text("Vehicle Type: ${_selectedItem!.vehicleType}",
            style: const TextStyle(fontSize: 18)),
        Text("Vehicle Id: ${_selectedItem!.vehicleId}",
            style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 73),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon( // Delete button with Icon
              onPressed: () {
                _removeItem(_items.indexOf(_selectedItem!));
                _closeDetails();
              },
              icon: const Icon(Icons.delete, color: Colors.white), // Icon
              label: const Text("Delete", style: TextStyle(color: Colors.white)), // Text
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red), // Background color
            ),
            const SizedBox(width: 10), // Add space between buttons
            ElevatedButton.icon( // Edit button with Icon
              onPressed: () {
                _setEditing(true);
              },
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text("Edit", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
            const SizedBox(width: 10), // Add space between buttons
            ElevatedButton.icon( // Close button with Icon
              onPressed: _closeDetails,
              icon: const Icon(Icons.close, color: Colors.white),
              label: const Text("Close", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _reactiveLayout(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var width = size.width;
    var height = size.height;

    if ((width > height) && (width > 720)) {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: _listPage(),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: _detailsPage(),
            ),
          ),
        ],
      );
    } else {
      if (_selectedItem == null) {
        return _listPage();
      } else {
        return _detailsPage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("V E H I C L E - M A I N T E N A N C E - P A G E  |  வாகன பராமரிப்பு பக்கம்"),
        backgroundColor: Colors.lightBlueAccent[200],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _reactiveLayout(context),
      ),
    );
  }
}
