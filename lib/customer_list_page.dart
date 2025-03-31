import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cst2335_final/customer_item.dart';
import 'package:cst2335_final/customer_repository.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:cst2335_final/database.dart'; // Floor database file
import 'package:cst2335_final/customer_dao.dart'; // DAO for CustomerItem

/// CustomerListPage displays a two-pane layout on wide screens:
/// • Left pane: an input form on top with a customer list below.
/// • Right pane: detail view of the currently selected customer.
/// On mobile screens, tapping an item navigates to a separate detail page.
class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});
  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  // Floor database instance and DAO.
  late AppDatabase _database;
  late CustomerDao _customerDao;

  // Repository for storing previous form data.
  final CustomerRepository _customerRepository = CustomerRepository();

  // Controllers for the input form.
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();

  // In-memory list of customers loaded from the DB.
  List<CustomerItem> _customers = [];
  CustomerItem? _selectedCustomer; // For wide-screen layout.

  // Current language for localization; default is English.
  String _currentLanguage = 'en';

  @override
  void initState() {
    super.initState();
    // Build the Floor database and get the DAO.
    $FloorAppDatabase.databaseBuilder('app_database.db').build().then((database) {
      _database = database;
      _customerDao = database.customerDao;
      _loadCustomerList();
    });
    _loadPreviousFormData();
  }
  void showDemoActionSheet(
      {required BuildContext context, required Widget child}) {
    showCupertinoModalPopup<String>(
        context: context,
        builder: (BuildContext context) => child).then((String? value) {
      if (value != null) changeLocale(context, value);
    });
  }

  void _onActionSheetPress(BuildContext context) {
    showDemoActionSheet(
      context: context,
      child: CupertinoActionSheet(
        title: Text(translate('language.selection.title')),
        message: Text(translate('language.selection.message')),
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(translate('language.name.en')),
            onPressed: () => Navigator.pop(context, 'en'),
          ),
          CupertinoActionSheetAction(
            child: Text(translate('language.name.ko')),
            onPressed: () => Navigator.pop(context, 'ko'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(translate('button.cancel')),
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context, null),
        ),
      ),
    );
  }
  /// Loads the customer list from the database.
  Future<void> _loadCustomerList() async {
    final list = await _customerDao.getAllItem();
    setState(() {
      _customers = list;
      if (_customers.isNotEmpty && _selectedCustomer == null) {
        _selectedCustomer = _customers[0];
      }
    });
  }

  /// Loads previous form data via CustomerRepository.
  Future<void> _loadPreviousFormData() async {
    final data = await _customerRepository.loadData();
    _firstNameController.text = data["firstName"]! ;
    _lastNameController.text = data["lastName"]! ;
    _addressController.text = data["address"]! ;
    _birthdayController.text = data["birthday"]! ;
  }

  /// Saves current form data via CustomerRepository.
  Future<void> _saveFormData() async {
    await _customerRepository.saveData(
      _firstNameController.text,
      _lastNameController.text,
      _addressController.text,
      _birthdayController.text,
    );
  }

  /// Displays an AlertDialog with instructions.
  void _showInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translate('customer.instructions_title') ),
        content: Text(translate('customer.instructions_content') ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Opens a date picker for selecting the birthday.
  Future<void> _selectBirthday() async {
    DateTime initialDate = DateTime.now();
    try {
      if (_birthdayController.text.isNotEmpty) {
        initialDate = DateFormat('yyyy-MM-dd').parse(_birthdayController.text);
      }
    } catch (_) {}
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthdayController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  /// Handles form submission to add a new customer.
  Future<void> _handleSubmit() async {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _birthdayController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(translate('customer.error_title') ),
          content: Text(translate('customer.error_all_fields_required') ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    // Check for duplicate entry.
    bool duplicate = _customers.any((customer) =>
    customer.firstName == _firstNameController.text &&
        customer.lastName == _lastNameController.text &&
        customer.address == _addressController.text &&
        customer.birthday == _birthdayController.text);
    if (duplicate) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(translate('customer.duplicate_title') ),
          content: Text(translate('customer.duplicate_content') ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    await _saveFormData();
    final newCustomer = CustomerItem(
      DateTime.now().millisecondsSinceEpoch,
      _firstNameController.text,
      _lastNameController.text,
      _addressController.text,
      _birthdayController.text,
    );
    await _customerDao.insertItem(newCustomer);
    _loadCustomerList();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(translate('customer.customer_added') )),
    );
    _firstNameController.clear();
    _lastNameController.clear();
    _addressController.clear();
    _birthdayController.clear();
  }

  /// For mobile layouts: navigates to the detail page.
  Future<void> _navigateToDetail(CustomerItem customer) async {
    final updatedCustomer = await Navigator.push<CustomerItem>(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerDetailPage(
          customer: customer,
          currentLanguage: _currentLanguage,
        ),
      ),
    );
    if (updatedCustomer == null) {
      // Deletion was requested.
      await _customerDao.deleteItem(customer);
      _loadCustomerList();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(translate('customer.customer_deleted') )),
      );
    } else {
      await _customerDao.updateItem(updatedCustomer);
      _loadCustomerList();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(translate('customer.customer_updated') )),
      );
    }
  }

  /// Builds the left pane: input form on top and customer list below.
  Widget _buildLeftPane() {
    return Column(
      children: [
        _buildInputForm(),
        const Divider(),
        Expanded(child: _buildListView()),
      ],
    );
  }

  /// Builds the input form.
  Widget _buildInputForm() {
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          shrinkWrap: true,
          children: [
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: translate('customer.first_name') ,
                border: const OutlineInputBorder(),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: translate('customer.last_name') ,
                border: const OutlineInputBorder(),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: translate('customer.address') ,
                border: const OutlineInputBorder(),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _birthdayController,
              decoration: InputDecoration(
                labelText: translate('customer.birthday') ,
                border: const OutlineInputBorder(),
                filled: true,
              ),
              readOnly: true,
              onTap: _selectBirthday,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                ElevatedButton.icon(
                  onPressed: _handleSubmit,
                  icon: const Icon(Icons.check),
                  label: Text(translate('customer.submit') ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await _loadPreviousFormData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(translate('customer.copy_previous') )),
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: Text(translate('customer.copy_previous') ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _firstNameController.clear();
                    _lastNameController.clear();
                    _addressController.clear();
                    _birthdayController.clear();
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the customer list view for the left pane.
  Widget _buildListView() {
    return _customers.isEmpty
        ? Center(child: Text(translate('customer.no_customers') ))
        : ListView.builder(
      itemCount: _customers.length,
      itemBuilder: (context, index) {
        final customer = _customers[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            title: Text('${customer.firstName} ${customer.lastName}'),
            subtitle: Text('${customer.address}\n${customer.birthday}'),
            isThreeLine: true,
            onTap: () {
              setState(() {
                _selectedCustomer = customer;
              });
            },
          ),
        );
      },
    );
  }

  /// Builds the wide layout with two panes: left for input and list, right for detail.
  Widget _buildWideLayout() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _buildLeftPane(),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 1,
          child: _selectedCustomer == null
              ? Center(child: Text(translate('customer.select_customer') ))
              : _buildDetailView(),
        ),
      ],
    );
  }

  /// Builds the detail view for the selected customer (for wide screens).
  Widget _buildDetailView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ListView(
        children: [
          TextField(
            controller: TextEditingController(text: _selectedCustomer!.firstName),
            decoration: InputDecoration(
              labelText: translate('customer.first_name') ,
              border: const OutlineInputBorder(),
              filled: true,
            ),
            readOnly: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: TextEditingController(text: _selectedCustomer!.lastName),
            decoration: InputDecoration(
              labelText: translate('customer.last_name') ,
              border: const OutlineInputBorder(),
              filled: true,
            ),
            readOnly: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: TextEditingController(text: _selectedCustomer!.address),
            decoration: InputDecoration(
              labelText: translate('customer.address') ,
              border: const OutlineInputBorder(),
              filled: true,
            ),
            readOnly: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: TextEditingController(text: _selectedCustomer!.birthday),
            decoration: InputDecoration(
              labelText: translate('customer.birthday') ,
              border: const OutlineInputBorder(),
              filled: true,
            ),
            readOnly: true,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final updatedCustomer = await Navigator.push<CustomerItem>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomerDetailPage(
                        customer: _selectedCustomer!,
                        currentLanguage: _currentLanguage,
                      ),
                    ),
                  );
                  if (updatedCustomer == null) {
                    await _customerDao.deleteItem(_selectedCustomer!);
                    _loadCustomerList();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(translate('customer.customer_deleted') )),
                    );
                  } else {
                    await _customerDao.updateItem(updatedCustomer);
                    _loadCustomerList();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(translate('customer.customer_updated') )),
                    );
                  }
                },
                icon: const Icon(Icons.edit),
                label: Text(translate('customer.edit') ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('${translate('customer.delete') } ${translate('customer.customer') }'),
                      content: Text('${translate('customer.delete') }?\n${translate('customer.delete_confirmation') }'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(translate('button.cancel') ),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await _customerDao.deleteItem(_selectedCustomer!);
                            _loadCustomerList();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(translate('customer.customer_deleted') )),
                            );
                          },
                          child: Text(translate('customer.delete') ),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.delete),
                label: Text(translate('customer.delete') ),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedCustomer = null;
                });
              },
              icon: const Icon(Icons.close),
              label: Text(translate('customer.close_detail') ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the mobile layout with input form on top and customer list below.
  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildInputForm(),
        const Divider(),
        Expanded(
          child: _customers.isEmpty
              ? Center(child: Text(translate('customer.no_customers') ))
              : ListView.builder(
            itemCount: _customers.length,
            itemBuilder: (context, index) {
              final customer = _customers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  title: Text('${customer.firstName} ${customer.lastName}'),
                  subtitle: Text('${customer.address}\n${customer.birthday}'),
                  isThreeLine: true,
                  onTap: () => _navigateToDetail(customer),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Add a language selection option in the AppBar.
    bool isWideScreen = MediaQuery.of(context).size.width >= 600;
    return Scaffold(
      appBar: AppBar(
        title: Text(translate('customer.title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => _onActionSheetPress(context),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInstructions,
          ),
        ],
      ),
      body: isWideScreen ? _buildWideLayout() : _buildMobileLayout(),
    );
  }
}

/// CustomerDetailPage is used in mobile layouts to allow editing or deletion of a customer.
/// It uses WillPopScope so that navigating back returns the original customer data.
class CustomerDetailPage extends StatefulWidget {
  final CustomerItem customer;
  final String currentLanguage;
  const CustomerDetailPage({Key? key, required this.customer, required this.currentLanguage})
      : super(key: key);

  @override
  _CustomerDetailPageState createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.customer.firstName;
    _lastNameController.text = widget.customer.lastName;
    _addressController.text = widget.customer.address;
    _birthdayController.text = widget.customer.birthday;
  }

  Future<void> _selectBirthday() async {
    DateTime initialDate = DateTime.now();
    try {
      if (_birthdayController.text.isNotEmpty) {
        initialDate = DateFormat('yyyy-MM-dd').parse(_birthdayController.text);
      }
    } catch (_) {}
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthdayController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _handleUpdate() {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _birthdayController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(translate('customer.error_title') ),
          content: Text(translate('customer.error_all_fields_required') ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    final updatedCustomer = CustomerItem(
      widget.customer.id,
      _firstNameController.text,
      _lastNameController.text,
      _addressController.text,
      _birthdayController.text,
    );
    Navigator.pop(context, updatedCustomer);
  }

  void _handleDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translate('customer.delete') +
            ' ' +
            translate('customer.customer') ),
        content: Text(translate('customer.delete') +
            '?\n' +
            translate('customer.delete_confirmation') ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(translate('button.cancel') ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, null);
            },
            child: Text(translate('customer.delete') ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, widget.customer);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(translate('customer.title_detail') ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(translate('customer.instructions_title') ),
                    content: Text(translate('customer.instructions_content') ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ListView(
            children: [
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: translate('customer.first_name') ,
                  border: const OutlineInputBorder(),
                  filled: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: translate('customer.last_name') ,
                  border: const OutlineInputBorder(),
                  filled: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: translate('customer.address') ,
                  border: const OutlineInputBorder(),
                  filled: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _birthdayController,
                decoration: InputDecoration(
                  labelText: translate('customer.birthday') ,
                  border: const OutlineInputBorder(),
                  filled: true,
                ),
                readOnly: true,
                onTap: _selectBirthday,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _handleUpdate,
                    icon: const Icon(Icons.check),
                    label: Text(translate('customer.edit') ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _handleDelete,
                    icon: const Icon(Icons.delete),
                    label: Text(translate('customer.delete') ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
