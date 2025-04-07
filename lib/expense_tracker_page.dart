// Importing required Flutter and third-party packages
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Import local project files
import 'expense_dao.dart';
import 'expense_item.dart';
import 'expense_repository.dart';
import 'package:cst2335_final/database.dart';


/// ExpenseTrackerPage is the main page for managing and viewing expenses.
/// It supports localization, form persistence, and encrypted local storage.
class ExpenseTrackerPage extends StatefulWidget {
  const ExpenseTrackerPage({super.key});

  @override
  State<ExpenseTrackerPage> createState() => _ExpenseTrackerPageState();
}

class _ExpenseTrackerPageState extends State<ExpenseTrackerPage> {
  //Database and data access objects
  late AppDatabase _database;
  late ExpenseDao _expenseDao;


  //Encrypted shared preferences for secure local storage
  final EncryptedSharedPreferences _esp = EncryptedSharedPreferences();
  // Repository to handle expense form data storage
  final ExpenseRepository _expenseRepository = ExpenseRepository();
  final String _expenseCountKey = 'expense_count';

  // List of all expenses
  List<ExpenseItem> _expenses = [];

  // Currently selected expense (for details view)
  ExpenseItem? _selectedExpense;

  // Current language selected for UI
  String _currentLanguage = 'en';

  // Controllers for each input field
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _paymentMethodController = TextEditingController();

  /*@override
  void initState() {
    super.initState();
    _loadExpenseList(); // Load saved expenses from secure storage
    _loadPreviousFormData(); // Load last entered form data
    }*/
  @override
  void initState() {
    super.initState();

    // Build the Floor database and get the DAO for Expense.
    $FloorAppDatabase.databaseBuilder('app_database.db').build().then((database) {
      _database = database;
      _expenseDao = database.expenseDao;
      _loadExpenseList();
    });

    _loadPreviousFormData(); // Load shared preference data
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
          child: Text(translate('button.cancel')),
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  /// Load expenses from the Database
  Future<void> _loadExpenseList() async {
    final list = await _expenseDao.getAllItems();
    setState(() {
      _expenses = list;
      if (_expenses.isNotEmpty && _selectedExpense == null) {
        _selectedExpense = _expenses[0];
      }
    });
  }

  /*/// Load expenses from EncryptedSharedPreferences
  Future<void> _loadExpenseList() async {
    String? countStr = await _esp.getString(_expenseCountKey);
    int count = countStr != null && countStr.isNotEmpty ? int.tryParse(
        countStr) ?? 0 : 0;
    List<ExpenseItem> expenses = [];

    for (int i = 0; i < count; i++) {
      String? idStr = await _esp.getString("expense_${i}_id");
      String? name = await _esp.getString("expense_${i}_name");
      String? category = await _esp.getString("expense_${i}_category");
      String? amount = await _esp.getString("expense_${i}_amount");
      String? date = await _esp.getString("expense_${i}_date");
      String? paymentMethod = await _esp.getString(
          "expense_${i}_paymentMethod");


      if (idStr != null && name != null && category != null && amount != null &&
          date != null && paymentMethod != null) {
        int id = int.tryParse(idStr) ?? 0;
        expenses.add(
            ExpenseItem(id, name, category, amount, date, paymentMethod));
      }
    }
    //final list = await _expenseDao.getAllItems();

    setState(() {
      _expenses = expenses;
      if (_expenses.isNotEmpty && _selectedExpense == null) {
        _selectedExpense = _expenses[0];
      }
    });
  }*/


  /*/// Saves the current list of expenses to EncryptedSharedPreferences.
  Future<void> _saveExpenseList() async {
    int count = _expenses.length;
    await _esp.setString(_expenseCountKey, count.toString());

    for (int i = 0; i < count; i++) {
      ExpenseItem expense = _expenses[i];
      await _esp.setString("expense_${i}_id", expense.id.toString());
      await _esp.setString("expense_${i}_name", expense.name);
      await _esp.setString("expense_${i}_category", expense.category);
      await _esp.setString("expense_${i}_amount", expense.amount);
      await _esp.setString("expense_${i}_date", expense.date);
      await _esp.setString("expense_${i}_paymentMethod", expense.paymentMethod);
    }

  }*/

  /// Load last saved form data for convenience
  Future<void> _loadPreviousFormData() async {
    final data = await _expenseRepository.loadData();
    _nameController.text = data["name"] ?? '';
    _categoryController.text = data["category"] ?? '';
    _amountController.text = data["amount"] ?? '';
    _dateController.text = data["date"] ?? '';
    _paymentMethodController.text = data["paymentMethod"] ?? '';
  }

  /// Save current form data for future reuse
  Future<void> _saveFormData() async {
    await _expenseRepository.saveData(
      _nameController.text,
      _categoryController.text,
      _amountController.text,
      _dateController.text,
      _paymentMethodController.text,
    );
  }


  /// Handles validation and creation of a new expense entry.
  /// Displays appropriate dialogs or snack bar messages for success and error cases.
  Future<void> _handleSubmit() async {
    // Validate that all fields are filled
    if (_nameController.text.isEmpty ||
        _categoryController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _paymentMethodController.text.isEmpty) {
      _showErrorDialog ('All fields are required.');
      return;
    }

    // Check for duplicates
    bool duplicate = _expenses.any((expense) =>
    expense.name == _nameController.text &&
        expense.category == _categoryController.text &&
        expense.amount == _amountController.text &&
        expense.date == _dateController.text &&
        expense.paymentMethod == _paymentMethodController.text);

    if (duplicate) {
      _showErrorDialog('An expense with the same details already exists.');
      return;
    }

    await _saveFormData();

    // Create a new ExpenseItem
    final newExpense = ExpenseItem(
      DateTime
          .now()
          .millisecondsSinceEpoch,
      _nameController.text,
      _categoryController.text,
      _amountController.text,
      _dateController.text,
      _paymentMethodController.text,
    );

    // Add to UI and update selected
    setState(() {
      _expenses.add(newExpense);
      if (_selectedExpense == null) {
        _selectedExpense = newExpense;
      }
    });

    //await _saveExpenseList();
    await _expenseDao.insertItem(newExpense);
    _loadExpenseList();
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense added.')));

    // Clear form
    _nameController.clear();
    _categoryController.clear();
    _amountController.clear();
    _dateController.clear();
    _paymentMethodController.clear();
  }

  /// Display an alert dialog for errors
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }


  /// Navigate to the detail screen for viewing or editing expense
  Future<void> _navigateToExpenseDetail(ExpenseItem expense) async {
    final updatedExpense = await Navigator.push<ExpenseItem>(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseDetailPage(expense: expense),
      ),
    );


     // If null, it was deleted
    if (updatedExpense == null) {
      setState(() {
        _expenses.removeWhere((e) => e.id == expense.id);
      });
      //await _saveExpenseList();
      await _expenseDao.deleteItem(expense);
      _loadExpenseList();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense deleted.')));
    } else {
      // Otherwise update the existing item
      setState(() {
        int index = _expenses.indexWhere((e) => e.id == updatedExpense.id);
        if (index != -1) {
          _expenses[index] = updatedExpense;
        }
      });
      //await _saveExpenseList();
      await _expenseDao.updateItem(updatedExpense);
      _loadExpenseList();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense updated.')));
    }
  }

  /// Builds the main UI, switching layout based on screen size
  @override
  Widget build(BuildContext context) {
    bool isWideScreen = MediaQuery
        .of(context)
        .size
        .width >= 600;
    return Scaffold(
      appBar: AppBar(
        title:  Text(translate('expense.Expense Tracker'),),
          actions: [
      IconButton(
        // Language change button
      icon: const Icon(Icons.language),
      onPressed: () => _onActionsheetPress(context),
    ),
            // New Help/Instructions button
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(translate('expense.instruction_title')),
                    content: Text(translate('expense.instruction_content')),
                    actions: [
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
      ),


      body: isWideScreen ? _buildWideLayout() : _buildMobileLayout(),
    );
  }


  /// Builds wide screen layout with left and right panes
  Widget _buildWideLayout() {
    return Row(
      children: [
        Expanded(flex: 1, child:
                  _buildLeftPane(),
        ),
        const VerticalDivider(width: 1),
        Expanded(flex: 1, child: _buildExpenseDetail(),
        ),
      ],
    );
  }

  /// Builds vertical layout for smaller screens (mobile)
  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildInputForm(),
        const Divider(),
        Expanded(
          child: _expenses.isEmpty
              ? const Center(child: Text('No expenses recorded.'))
              : ListView.builder(
            itemCount: _expenses.length,
            itemBuilder: (context, index) {
              final expense = _expenses[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  title: Text(expense.name),
                  subtitle: Text("Category: ${expense.category}"),
                  onTap: () => _navigateToExpenseDetail(expense),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Builds left side of wide layout (form + list)
  Widget _buildLeftPane() {
    return Column(
      children: [
        _buildInputForm(),
        const Divider(),
        Expanded(child: _buildListView()),
      ],
    );
  }


  /// Input form for entering expense details
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

            // Expense Name
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
            labelText: translate('expense.Expense Name'),)
            ),
            const SizedBox(height: 8),

            // Category
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                  labelText:translate('expense.Category'),)
            ),
            const SizedBox(height: 8),

            // Amount
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText:translate('expense.Amount'),),
            ),
            const SizedBox(height: 8),

            // Date Picker
            TextField(
              controller: _dateController,
              readOnly: true,
              decoration:  InputDecoration(

                labelText: translate('expense.Date'),  suffixIcon: Icon(Icons.calendar_today),),

          onTap: () async {
            FocusScope.of(context).requestFocus(FocusNode());
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000), //
              lastDate: DateTime(2100),  //
            );

            if (pickedDate != null) {
              setState(() {
                // Format as YYYY-MM-DD
                _dateController.text =
                "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
              });
            }
          },
      ),
            const SizedBox(height: 8),

            //updated payment Method
            DropdownButtonFormField<String>(
              value: _paymentMethodController.text.isNotEmpty
                  ? _paymentMethodController.text
                  : null,
              decoration: InputDecoration(
                labelText: translate('expense.Payment Method'),
                border: const OutlineInputBorder(),
              ),
              items: [
                {
                  'label': 'Visa',
                  'image': 'assets/images/visa.jpg',
                },
                {
                  'label': 'MasterCard',
                  'image': 'assets/images/mastercard.jpg',
                },
                {
                  'label': 'Debit',
                  'image': 'assets/images/debit.jpg',
                },
              ].map((item) {
                return DropdownMenuItem<String>(
                  value: item['label'],
                  child: Row(
                    children: [
                      Image.asset(
                        item['image']!,
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 10),
                      Text(item['label']!),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _paymentMethodController.text = value!;
                });
              },
            ),


            // Payment Method
            /*TextField(
              controller: _paymentMethodController,
              decoration: InputDecoration(
                  labelText: translate('expense.Payment Method')),
            ),*/
            /*Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select Payment Method",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPaymentOption("Visa", "assets/images/visa.jpg"),
                      const SizedBox(width: 12),
                     _buildPaymentOption("MasterCard", "assets/images/mastercard.jpg"),
                      const SizedBox(width: 12),
                      _buildPaymentOption("Debit", "assets/images/debit.jpg"),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Selected: ${_paymentMethodController.text.isEmpty ? 'None' : _paymentMethodController.text}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),*/

            const SizedBox(height: 16),
            //Row(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,

            // Action Buttons: Add, Copy Last, Undo
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _handleSubmit,
                  icon: const Icon(Icons.check),
                  label: Text(translate('expense.Add Expense'),)
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await _loadPreviousFormData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(translate('expense.Previous data loaded')),
                        )
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: Text(translate('expense.Copy Last Entry'),)
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Clear all form fields
                    _nameController.clear();
                    _categoryController.clear();
                    _amountController.clear();
                    _dateController.clear();
                    _paymentMethodController.clear();
                  },
                  icon: const Icon(Icons.clear_all),
                  label:Text(translate('expense.Undo'),)
                ),
              ],
            ),

     ]),
    ));
  }
  Widget _buildPaymentOption(String label, String assetPath) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _paymentMethodController.text = label;
        });
      },
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(
                color: _paymentMethodController.text == label
                    ? Colors.blue
                    : Colors.grey,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(assetPath, fit: BoxFit.contain),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  /// Builds the expense list view (used in wide layout)
  Widget _buildListView() {
    return _expenses.isEmpty
        ? Center(child: Text(translate('expense.There is no expenses in the list')))
        : ListView.builder(
      itemCount: _expenses.length,
      itemBuilder: (context, index) {
        final expense = _expenses[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 3,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            title: Text(expense.name),
            subtitle: Text("Category: ${expense.category}"),
            onTap: () {
              setState(() {
                _selectedExpense = expense;
              });
            },
          ),
        );
      },

    );
  }

  /// Shows detail card of selected expense in wide screen
  Widget _buildExpenseDetail() {
    if (_selectedExpense == null) {
      return Center(child: Text(translate('expense.no_expense_selected')));
    }

    final expense = _selectedExpense!;


    return Card(
      margin: const EdgeInsets.all(12),
      color: Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${expense.name}"),
            Text("Category: ${expense.category}"),
            Text("Amount: ${expense.amount}"),
            Text("Date: ${expense.date}"),
            Text("Payment Method: ${expense.paymentMethod}"),
            const SizedBox(height: 12),

            // Action buttons for Edit, Delete, and Close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _navigateToExpenseDetail(expense); // Go to edit page
                  },
                  icon: const Icon(Icons.edit),
                  label: Text (translate('expense.Edit'),)
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _expenses.remove(expense);
                      _selectedExpense = null;
                    });
                  },
                  icon: const Icon(Icons.delete),
                  label: Text(translate('expense.Delete'),)
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedExpense = null;
                    });
                  },
                  icon: const Icon(Icons.close),
                  label: Text(translate('expense.Close'),)
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


/// A standalone page to view and edit an existing expense
  class ExpenseDetailPage extends StatelessWidget {
    final ExpenseItem expense;

    const ExpenseDetailPage({Key? key, required this.expense})
        : super(key: key);

    @override
    Widget build(BuildContext context) {
      final TextEditingController _nameController = TextEditingController(
          text: expense.name);
      final TextEditingController _categoryController = TextEditingController(
          text: expense.category);
      final TextEditingController _amountController = TextEditingController(
          text: expense.amount);
      final TextEditingController _dateController = TextEditingController(
          text: expense.date);
      final TextEditingController _paymentMethodController = TextEditingController(
          text: expense.paymentMethod);

      return Scaffold(
        appBar: AppBar(
          title: Text(translate('expense.Expense Detail'),),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: translate('expense.Expense Name'),)
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: translate('expense.Category'),)
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                decoration: InputDecoration(labelText:  translate('expense.Amount'),)
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _dateController,
                decoration: InputDecoration(labelText:  translate('expense.Date'),)
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _paymentMethodController,
                decoration:InputDecoration(labelText:  translate('Payment Method'),)
              ),
              const SizedBox(height: 16),

              // Update and Delete buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      final updatedExpense = ExpenseItem(
                        expense.id,
                        _nameController.text,
                        _categoryController.text,
                        _amountController.text,
                        _dateController.text,
                        _paymentMethodController.text,
                      );
                      Navigator.pop(context, updatedExpense);
                    },
                    child: Text(translate('expense.Update'),)
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, null);// delete
                    },
                    child: Text(translate('expense.Delete'),),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }


  }
