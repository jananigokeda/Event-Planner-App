import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:intl/intl.dart';
import 'expense_item.dart';
import 'expense_repository.dart';

class ExpenseTrackerPage extends StatefulWidget {
  const ExpenseTrackerPage({super.key});

  @override
  State<ExpenseTrackerPage> createState() => _ExpenseTrackerPageState();
}

class _ExpenseTrackerPageState extends State<ExpenseTrackerPage> {
  final EncryptedSharedPreferences _esp = EncryptedSharedPreferences();
  final ExpenseRepository _expenseRepository = ExpenseRepository();
  final String _expenseCountKey = 'expense_count';

  List<ExpenseItem> _expenses = [];
  ExpenseItem? _selectedExpense; // For wide-screen layout.
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String _selectedPaymentMethod = 'Visa'; // Default payment method

  final List<String> _paymentMethods = ['Visa', 'Mastercard', 'Debit', 'Cash', 'Other'];

  @override
  void initState() {
    super.initState();
    _loadExpenseList();
    _loadPreviousFormData();
  }

  /// Loads the expense list from EncryptedSharedPreferences.
  Future<void> _loadExpenseList() async {
    String? countStr = await _esp.getString(_expenseCountKey);
    int count = countStr != null && countStr.isNotEmpty ? int.tryParse(countStr) ?? 0 : 0;
    List<ExpenseItem> expenses = [];
    for (int i = 0; i < count; i++) {
      String? idStr = await _esp.getString("expense_${i}_id");
      String? name = await _esp.getString("expense_${i}_name");
      String? category = await _esp.getString("expense_${i}_category");
      String? amount = await _esp.getString("expense_${i}_amount");
      String? date = await _esp.getString("expense_${i}_date");
      String? paymentMethod = await _esp.getString("expense_${i}_paymentMethod");
      if (idStr != null && name != null && category != null && amount != null && date != null && paymentMethod != null) {
        int id = int.tryParse(idStr) ?? 0;
        expenses.add(ExpenseItem(id, name, category, amount, date, paymentMethod));
      }
    }
    setState(() {
      _expenses = expenses;
      if (_expenses.isNotEmpty && _selectedExpense == null) {
        _selectedExpense = _expenses[0];
      }
    });
  }

  /// Saves the current expense list into EncryptedSharedPreferences.
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

  /// Loads previous form data via ExpenseRepository.
  Future<void> _loadPreviousFormData() async {
    final data = await _expenseRepository.loadData();
    _nameController.text = data["name"] ?? '';
    _categoryController.text = data["category"] ?? '';
    _amountController.text = data["amount"] ?? '';
    _dateController.text = data["date"] ?? '';
    _selectedPaymentMethod = data["paymentMethod"] ?? 'Visa';
  }

  /// Saves current form data via ExpenseRepository.
  Future<void> _saveFormData() async {
    await _expenseRepository.saveData(
      _nameController.text,
      _categoryController.text,
      _amountController.text,
      _dateController.text,
      _selectedPaymentMethod,
    );
  }

  /// Displays an AlertDialog with instructions.
  void _showInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Instructions'),
        content: const Text('Please fill out all fields to add an expense.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Opens a date picker for selecting the date.
  Future<void> _selectDate() async {
    DateTime initialDate = DateTime.now();
    try {
      if (_dateController.text.isNotEmpty) {
        initialDate = DateFormat('yyyy-MM-dd').parse(_dateController.text);
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
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  /// Handles form submission to add a new expense.
  Future<void> _handleSubmit() async {
    if (_nameController.text.isEmpty ||
        _categoryController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _dateController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('All fields are required.'),
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
    bool duplicate = _expenses.any((expense) =>
    expense.name == _nameController.text &&
        expense.category == _categoryController.text &&
        expense.amount == _amountController.text &&
        expense.date == _dateController.text &&
        expense.paymentMethod == _selectedPaymentMethod);
    if (duplicate) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Duplicate Expense'),
          content: const Text('An expense with the same details already exists.'),
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
    final newExpense = ExpenseItem(
      DateTime.now().millisecondsSinceEpoch,
      _nameController.text,
      _categoryController.text,
      _amountController.text,
      _dateController.text,
      _selectedPaymentMethod,
    );
    setState(() {
      _expenses.add(newExpense);
      if (_selectedExpense == null) {
        _selectedExpense = newExpense;
      }
    });
    await _saveExpenseList();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense added.')));
    _nameController.clear();
    _categoryController.clear();
    _amountController.clear();
    _dateController.clear();
    _selectedPaymentMethod = 'Visa'; // Reset payment method
  }

  /// For mobile layouts: navigates to the detail page.
  Future<void> _navigateToDetail(ExpenseItem expense) async {
    final updatedExpense = await Navigator.push<ExpenseItem>(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseDetailPage(expense: expense),
      ),
    );
    if (updatedExpense == null) {
      // Deletion was requested.
      setState(() {
        _expenses.removeWhere((e) => e.id == expense.id);
      });
      await _saveExpenseList();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense deleted.')));
    } else {
      setState(() {
        int index = _expenses.indexWhere((e) => e.id == updatedExpense.id);
        if (index != -1) {
          _expenses[index] = updatedExpense;
        }
      });
      await _saveExpenseList();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense updated.')));
    }
  }

  /// Builds the left pane: input form on top and expense list below.
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
              readOnly: true,
              onTap: _selectDate,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedPaymentMethod,
              items: _paymentMethods.map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Text(method),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
              decoration: const InputDecoration(labelText: "Payment Method"),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the expense list view for the left pane.
  Widget _buildListView() {
    return _expenses.isEmpty
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

  /// Builds the wide layout with two panes:
  /// Left: input form above expense list.
  /// Right: detail view of the selected expense.
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
          child: _selectedExpense == null
              ? const Center(child: Text('Select an expense'))
              : _buildDetailView(),
        ),
      ],
    );
  }

  /// Builds the detail view for the selected expense (for wide screens).
  Widget _buildDetailView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ListView(
        children: [
          TextField(
            controller: TextEditingController(text: _selectedExpense!.name),
            decoration: const InputDecoration(labelText: "Expense Name"),
            readOnly: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: TextEditingController(text: _selectedExpense!.category),
            decoration: const InputDecoration(labelText: "Category"),
            readOnly: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: TextEditingController(text: _selectedExpense!.amount),
            decoration: const InputDecoration(labelText: "Amount"),
            readOnly: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: TextEditingController(text: _selectedExpense!.date),
            decoration: const InputDecoration(labelText: "Date"),
            readOnly: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: TextEditingController(text: _selectedExpense!.paymentMethod),
            decoration: const InputDecoration(labelText: "Payment Method"),
            readOnly: true,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final updatedExpense = await Navigator.push<ExpenseItem>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExpenseDetailPage(expense: _selectedExpense!),
                    ),
                  );
                  if (updatedExpense == null) {
                    setState(() {
                      _expenses.removeWhere((e) => e.id == _selectedExpense!.id);
                      _selectedExpense = _expenses.isNotEmpty ? _expenses[0] : null;
                    });
                    await _saveExpenseList();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense deleted.')));
                  } else {
                    setState(() {
                      int index = _expenses.indexWhere((e) => e.id == updatedExpense.id);
                      if (index != -1) {
                        _expenses[index] = updatedExpense;
                        _selectedExpense = updatedExpense;
                      }
                    });
                    await _saveExpenseList();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense updated.')));
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Expense'),
                      content: const Text('Are you sure you want to delete this expense?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            setState(() {
                              _expenses.removeWhere((e) => e.id == _selectedExpense!.id);
                              _selectedExpense = _expenses.isNotEmpty ? _expenses[0] : null;
                            });
                            await _saveExpenseList();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense deleted.')));
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.delete),
                label: const Text('Delete'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedExpense = null;
                });
              },
              icon: const Icon(Icons.close),
              label: const Text('Close Detail'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the mobile layout with input form on top and list below.
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
                  onTap: () => _navigateToDetail(expense),
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
    bool isWideScreen = MediaQuery.of(context).size.width >= 600;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
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

/// ExpenseDetailPage is used in mobile layouts to allow editing or deletion