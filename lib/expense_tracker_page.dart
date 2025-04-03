import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'expense_dao.dart';
import 'expense_item.dart';
import 'expense_repository.dart';
import 'package:cst2335_final/database.dart';



class ExpenseTrackerPage extends StatefulWidget {
  const ExpenseTrackerPage({super.key});

  @override
  State<ExpenseTrackerPage> createState() => _ExpenseTrackerPageState();
}

class _ExpenseTrackerPageState extends State<ExpenseTrackerPage> {
  late AppDatabase _database;
  late ExpenseDao _expenseDao;
  final EncryptedSharedPreferences _esp = EncryptedSharedPreferences();
  final ExpenseRepository _expenseRepository = ExpenseRepository();
  final String _expenseCountKey = 'expense_count';

  List<ExpenseItem> _expenses = [];
  ExpenseItem? _selectedExpense;
  String _currentLanguage = 'en';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _paymentMethodController = TextEditingController();

  @override
  void initState() {
    super.initState();
    $FloorAppDatabase.databaseBuilder('app_database.db').build().then((database) {
      _database = database;
      _expenseDao = database.expenseDao;
    _loadExpenseList();
    }
    );
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

  void _onActionsheetPress(BuildContext context) {
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
            child: Text(translate('language.name.ta')),
            onPressed: () => Navigator.pop(context, 'ta'),
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
  /*Future<void> _loadExpenseList() async {
    final list = await _expenseDao.getAllItems();
    setState(() {
      _expenses = list;
      if (_expenses.isNotEmpty && _selectedExpense == null) {
        _selectedExpense = _expenses[0];
      }
    });
  }*/

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
    final list = await _expenseDao.getAllItems();

    setState(() {
      _expenses = expenses;
      if (_expenses.isNotEmpty && _selectedExpense == null) {
        _selectedExpense = _expenses[0];
      }
    });
  }

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

  }

  Future<void> _loadPreviousFormData() async {
    final data = await _expenseRepository.loadData();
    _nameController.text = data["name"] ?? '';
    _categoryController.text = data["category"] ?? '';
    _amountController.text = data["amount"] ?? '';
    _dateController.text = data["date"] ?? '';
    _paymentMethodController.text = data["paymentMethod"] ?? '';
  }

  Future<void> _saveFormData() async {
    await _expenseRepository.saveData(
      _nameController.text,
      _categoryController.text,
      _amountController.text,
      _dateController.text,
      _paymentMethodController.text,
    );
  }

  Future<void> _handleSubmit() async {
    if (_nameController.text.isEmpty ||
        _categoryController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _paymentMethodController.text.isEmpty) {
      _showErrorDialog('All fields are required.');
      return;
    }

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

    setState(() {
      _expenses.add(newExpense);
      if (_selectedExpense == null) {
        _selectedExpense = newExpense;
      }
    });

    await _saveExpenseList();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense added.')));

    _nameController.clear();
    _categoryController.clear();
    _amountController.clear();
    _dateController.clear();
    _paymentMethodController.clear();
  }

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

  Future<void> _navigateToExpenseDetail(ExpenseItem expense) async {
    final updatedExpense = await Navigator.push<ExpenseItem>(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseDetailPage(expense: expense),
      ),
    );

    if (updatedExpense == null) {
      setState(() {
        _expenses.removeWhere((e) => e.id == expense.id);
      });
      await _saveExpenseList();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense deleted.')));
    } else {
      setState(() {
        int index = _expenses.indexWhere((e) => e.id == updatedExpense.id);
        if (index != -1) {
          _expenses[index] = updatedExpense;
        }
      });
      await _saveExpenseList();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense updated.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isWideScreen = MediaQuery
        .of(context)
        .size
        .width >= 600;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
          actions: [
      IconButton(
      icon: const Icon(Icons.language),
      onPressed: () => _onActionsheetPress(context),
    ),
  ]
      ),
      body: isWideScreen ? _buildWideLayout() : _buildMobileLayout(),
    );
  }

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

  Widget _buildLeftPane() {
    return Column(
      children: [
        _buildInputForm(),
        const Divider(),
        Expanded(child: _buildListView()),
      ],
    );
  }

  //bool _showList = false;

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
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Expense Name"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: "Category"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: "Amount"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _dateController,
              readOnly: true,
              decoration: const InputDecoration(labelText: "Date",  suffixIcon: Icon(Icons.calendar_today),),

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
            TextField(
              controller: _paymentMethodController,
              decoration: const InputDecoration(labelText: "Payment Method"),
            ),
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
                      _buildPaymentOption("MasterCard", "assets/images/mastercard.jpg"),
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
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _handleSubmit,
                  icon: const Icon(Icons.check),
                  label: const Text('Add Expense'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await _loadPreviousFormData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Previous data loaded.')),
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy Last Entry'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _nameController.clear();
                    _categoryController.clear();
                    _amountController.clear();
                    _dateController.clear();
                    _paymentMethodController.clear();
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Undo'),
                ),
              ],
            ),

     ]),
    ));
  }
  /*Widget _buildPaymentOption(String label, String assetPath) {
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
  }*/

  Widget _buildListView() {
    return _expenses.isEmpty
        ? const Center(child: Text('There is no expenses in the list'))
        : ListView.builder(
    //return ListView.builder(
      //shrinkWrap: true,
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

  Widget _buildExpenseDetail() {
    if (_selectedExpense == null) {
      return const Center(child: Text("No expense selected."));
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _navigateToExpenseDetail(expense); // Go to edit page
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit"),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _expenses.remove(expense);
                      _selectedExpense = null;
                    });
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text("Delete"),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedExpense = null;
                    });
                  },
                  icon: const Icon(Icons.close),
                  label: const Text("Close"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



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
          title: const Text('Expense Detail'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Expense Name"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: "Category"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: "Amount"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: "Date"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _paymentMethodController,
                decoration: const InputDecoration(labelText: "Payment Method"),
              ),
              const SizedBox(height: 16),
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
                    child: const Text('Update'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, null);
                    },
                    child: const Text('Delete'),
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
