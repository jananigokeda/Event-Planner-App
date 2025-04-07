
import 'package:cst2335_final/database.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'edit_vehicle_page.dart';
import 'vehicle_item.dart';
import 'vehicle_dao.dart';

class VehicleMaintenancePage extends StatefulWidget {
  const VehicleMaintenancePage({Key? key}) : super(key: key);

  @override
  _VehicleMaintenancePageState createState() =>
      _VehicleMaintenancePageState();
}
//declare All Controllers
class _VehicleMaintenancePageState extends State<VehicleMaintenancePage> {
  late VehicleDao myDAO;
  final List<VehicleItem> _items = [];
  final TextEditingController _vehicleNameController = TextEditingController();
  final TextEditingController _vehicleTypeController = TextEditingController();
  final TextEditingController _serviceTypeController = TextEditingController();
  final TextEditingController _serviceDateController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  VehicleItem? _selectedItem;
  bool _isEditing = false; // Track if we're editing
  late AppDatabase _database;

  // Constructor it will get call when the app is loaded
  @override
  void initState() {
    super.initState();
    loadData(); //loading the previous data when the form is loaded.

    // Build the Floor database and get the DAO.
    $FloorAppDatabase.databaseBuilder('app_database.db').build().then((database) {
      _database = database;
      myDAO = database.vehicleDao;
      _loadItems(); // Loading the list
    });
  }

  /// Show Cupertino-style language selection popup
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
            child:
            Text(translate('language.name.en')),
            onPressed: () async {
              Navigator.pop(context);
              await changeLocale(context, 'en');
            },
          ),

          // Tamil
          CupertinoActionSheetAction(
            child: Text(translate('language.name.ta')),
            onPressed: () async {
              Navigator.pop(context);
              await changeLocale(context, 'ta');
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(translate('vehicle.Close')),
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  // This method will use the getAllItems method to load the data from the database.
  Future<void> _loadItems() async {
    final items = await myDAO.getAllItems();
    setState(() {
      _items.clear();
      _items.addAll(items);
    });
  }

  // This method is responsible for loading the data back from the EncryptedSharedPreferences
  void loadData() async {
    // Calling EncryptedSharedPreferences build in class and creating documents
    EncryptedSharedPreferences prefs = EncryptedSharedPreferences();

    //Retrieving the form details using getString method
    final savedVehicleName =  await prefs.getString('Vehicle Name');
    final savedVehicleType = await prefs.getString('Vehicle Type');
    final savedServiceType = await prefs.getString('Service Type');
    final savedServiceDate = await prefs.getString('Service Date');
    final savedMileage = await prefs.getString('Mileage');
    final savedCost = await prefs.getString('Cost');

    setState(() {
    if (savedVehicleName != null && savedVehicleType != null && savedServiceType != null
        && savedServiceDate != null && savedMileage != null && savedCost!=null) {

      _vehicleNameController.text = savedVehicleName;
      _vehicleTypeController.text = savedVehicleType;
      _serviceTypeController.text = savedServiceType;
      _serviceDateController.text = savedServiceDate;
      _mileageController.text = savedMileage;
      _costController.text = savedCost;
     }

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Latest Vehicle Information has been loaded!!.')));
    });

  }
  // This function is responsible for adding the vehicle information to the database.
  // it will collect all the information in  newItem object and use myDAO.insertItem(newItem) to add to the database
  Future<void> _addItem() async {
    String vehicleName = _vehicleNameController.text.trim();
    String vehicleType = _vehicleTypeController.text.trim();
    String serviceType = _serviceTypeController.text.trim();
    String serviceDate = _serviceDateController.text.trim();
    String mileage = _mileageController.text.trim();
    String cost = _costController.text.trim();
    if (vehicleName.isNotEmpty && vehicleType.isNotEmpty) {
      final newItem = VehicleItem(vehicleName: vehicleName, vehicleType: vehicleType, serviceType: serviceType, serviceDate: serviceDate, mileage: mileage, cost: cost);
      await myDAO.insertItem(newItem);

      // Saving the vehicle data using EncryptedSharedPreferences
      final prefs = EncryptedSharedPreferences();
      await prefs.setString('Vehicle Name', _vehicleNameController.text);
      await prefs.setString('Vehicle Type', _vehicleTypeController.text);
      await prefs.setString('Service Type', _serviceTypeController.text);
      await prefs.setString('Service Date', _serviceDateController.text);
      await prefs.setString('Mileage', _mileageController.text);
      await prefs.setString('Cost', _costController.text);

      _loadItems(); // Refresh the list

      //Dialog box
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Success!"),
          content: const Text("Vehicle info saved successfully."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      //showSnackBar
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle Information has been successfully saved!!.')));
    } else {
      // Show validation error dialog
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle information required!! Please input vehicle info.')));
    }
  }

  // Deleting the item from the list
  // This will use the deleteItem() function to delete the selected item
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


  // show vehicle detail from the database
  void _showDetails(VehicleItem item) {
    setState(() {
      _selectedItem = item;
      _vehicleNameController.text = item.vehicleName; // Populate text fields
      _vehicleTypeController.text = item.vehicleType;
      _serviceTypeController.text = item.serviceType; // Populate text fields
      _serviceDateController.text = item.serviceDate;
      _mileageController.text = item.mileage; // Populate text fields
      _costController.text = item.cost;
    });
  }
// Closing details
  void _closeDetails() {
    setState(() {
      _selectedItem = null;
      _vehicleNameController.clear();
      _vehicleTypeController.clear();
      _serviceTypeController.clear();
      _serviceDateController.clear();
      _mileageController.clear();
      _costController.clear();
      _setEditing(false); // Ensure not in editing mode
    });
  }

  void _setEditing(bool editing) {
    setState(() {
      _isEditing = editing;
    });
  }

  // Picking the date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _serviceDateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  // FORM IMPLEMENTATION SECTION

  Widget _listPage() {
    return Column(
      children: [
        Column( // Stack inputs vertically
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            TextField(
              controller: _vehicleNameController,
              decoration: InputDecoration(
                labelText: translate('vehicle.Vehicle Name'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0), // Rounded corners
                  borderSide: BorderSide(color: Colors.blue.shade300), // Border color
                ),
              ),
            ),

            const SizedBox(height: 10), // Space between fields

            TextField( // Vehicle Type Input
              controller: _vehicleTypeController,
              decoration: InputDecoration(
                labelText: translate('vehicle.Vehicle Type'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0), // Rounded corners
                  borderSide: BorderSide(color: Colors.blue.shade300), // Border color
                ),
              ),
            ),

            //serviceType
            const SizedBox(height: 10), // Space between fields
            TextField( // Service Type Input
              controller: _serviceTypeController,
              decoration: InputDecoration(
                labelText: translate('vehicle.Service Type'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0), // Rounded corners
                  borderSide: BorderSide(color: Colors.blue.shade300), // Border color
                ),
              ),
            ),

            // Service Date
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextField(
                  controller: _serviceDateController,
                  decoration: InputDecoration(
                    labelText: translate('vehicle.Service Date'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: BorderSide(color: Colors.blue.shade300),
                    ),
                  ),
                ),
              ),
            ),

            //mileage
            const SizedBox(height: 10), // Space between fields
            TextField( // Mileage Input
              controller: _mileageController,
              decoration:  InputDecoration(
                labelText: translate('vehicle.Mileage'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0), // Rounded corners
                  borderSide: BorderSide(color: Colors.blue.shade300), // Border color
                ),
              ),
            ),

            //Cost
            const SizedBox(height: 10), // Space between fields
            TextField( // Cost Input
              controller: _costController,
              decoration:  InputDecoration(
                labelText: translate('vehicle.Cost'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0), // Rounded corners
                  borderSide: BorderSide(color: Colors.blue.shade300), // Border color
                ),
              ),
            ),
// DONE FORM IMPLEMENTATION

            // SAVE button
            // Implementation of the SAVE button and COPY PREVIOUS BUTTON SECTION
            // Once the save button is clicked, it will call the _addItem function
            // _addItem will then access the insertItem function to insert the information
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      await _addItem(); // This method will add the vehicle info when save button is pressed
                    },
                    style: ElevatedButton.styleFrom(  // Styling the button
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.lightBlueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Text(translate('vehicle.SAVE'))

                ),

                // Copy Previous button which will call the loadData function to load the previous data back.
                const SizedBox(width: 20),
                ElevatedButton(

                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.lightBlueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {
                    loadData(); // Loading the previous data whe the copy previous button presssed
                  },
                  child: Text(translate('vehicle.COPY PREVIOUS')),
                ),

                // UNDO button which will call the _closeDetails function to clear the form
                const SizedBox(width: 20),
                ElevatedButton(

                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.lightBlueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {
                    _vehicleNameController.clear();
                    _vehicleTypeController.clear();
                    _serviceTypeController.clear();
                    _serviceDateController.clear();
                    _mileageController.clear();
                    _costController.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Form data has been cleared')));
                  },
                  child: Text(translate('vehicle.UNDO')),
                ),

              ],
            )
          ],
        ),

        // This is the bottom part of the form which display the information from the database by calling the _showDetails
        // If the database is empty, it will dispaly, There are no items in the list
        //Wrap each ListTile with Container
        const SizedBox(height: 25),
        const Divider( // Add the Divider widget
            color: Colors.grey, // Color of the line
            thickness: 1.0), // Thickness of the line
        Expanded(
          child: _items.isEmpty
              ? Center(child: Text("There are no items in the list."))
              : ListView.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) {

              return Container( // Wrap each ListTile with Container
                margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0), // Add margin for spacing between blocks
                decoration: BoxDecoration( // Add background, border, and rounded corners
                  color: Colors.white, // Background color for the block
                ),
                child: GestureDetector(
                  onTap: () {
                    _showDetails(_items[index]);
                  },
                  child: ListTile(
                    title: Center(
                      child: Text(
                          "${index + 1}: ${_items[index].vehicleName} - vehicleType: ${_items[index].vehicleType} -serviceType: ${_items[index].serviceType} -serviceDate: ${_items[index].serviceDate } -mileage: ${_items[index].mileage } -cost: ${_items[index].cost }"
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

  //DETAIL PAGE
  // This detail page will show on the right side of the screen
  // If the there is noi selection, it will say the There is no item selected for detail
  Widget _detailsPage() {
    if (_selectedItem == null) {
      return Center(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Text("There is no item selected for detail"),
        ),
      );
    }
    // ADDING rectangle container
    // _buildUnderlinedField - special function i created to handle the disply of the detail page
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text("VEHICLE NAME: ${_selectedItem!.vehicleName}"),
          const SizedBox(height: 12),
          Text("VEHICLE TYPE: ${_selectedItem!.vehicleType}"),
          const SizedBox(height: 12),
          Text("SERVICE TYPE: ${_selectedItem!.serviceType}"),
          const SizedBox(height: 12),
          Text("SERVICE DATE: ${_selectedItem!.serviceDate}"),
          const SizedBox(height: 12),
          Text("MILEAGE: ${_selectedItem!.mileage}"),
          const SizedBox(height: 12),
          Text("COST: ${_selectedItem!.cost}"),
          const SizedBox(height: 40),

          // Add the Row as another child of the Column
          // DELETE button which will delete the record when we click the button
          // Once clicked, it will call the _removeItem function
          //_remove will call the myDAO.deleteItem method to delete the information.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  _removeItem(_items.indexOf(_selectedItem!));
                  _closeDetails();
                },
                icon: const Icon(Icons.delete, color: Colors.white),
                label: Text(
                    (translate('vehicle.Delete')), // Localized text
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),

              // EDIT button. Once clicked, it goes to edit_vehicle_page.dart
              // and user will have the ability to edit the existing data
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditVehiclePage(
                            item: _selectedItem!,
                            dao: myDAO,
                            onUpdate: (updatedItem) {
                              setState(() {
                                _selectedItem = updatedItem;
                                _loadItems();
                              });
                            },
                          ),
                    ),
                  );
                },
                icon: const Icon(Icons.edit, color: Colors.white),
                label: Text(
                    translate('vehicle.Edit'),  // Localized text
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),

              // CLOSE button for closing the detail page
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: _closeDetails,
                icon: const Icon(Icons.close, color: Colors.white),
                label: Text(
                   (translate('vehicle.Close')), // Localized text
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              ),
            ],
          ),
        ],
      ), //
    );
  }

  // Layout for screens
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

  /// Displays an AlertDialog with instructions.
  void _showInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translate('vehicle.Instructions_title')),
        content: Text(translate('vehicle.Instructions_content')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  //Heading section
  // Question icon for help to use the app
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translate('vehicle.MainTitle')),
        centerTitle: true,
        actions: [
          SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.question_mark),
            onPressed: _showInstructions,
          ),
      IconButton(
          icon: const Icon(Icons.language),
          onPressed: () => _onActionsheetPress(context),
         ),
      ]
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _reactiveLayout(context),
      ),
    );
  }

}

