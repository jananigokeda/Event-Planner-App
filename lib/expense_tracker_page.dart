import 'package:flutter/material.dart';
import 'expense_item.dart';
import 'expense_repository.dart';

class ExpenseTrackerPage extends StatefulWidget {
  const ExpenseTrackerPage({super.key});

  @override
  State<ExpenseTrackerPage> createState() => _ExpenseTrackerPageState();
}

class _ExpenseTrackerPageState extends State<ExpenseTrackerPage> {
  final ExpenseRepository _expenseRepository = ExpenseRepository();
  List<ExpenseItem> _expenses = [];
  ExpenseItem? _selectedExpense;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _paymentMethodController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExpenseList();
    _loadPreviousFormData();
  }

  Future<void> _loadExpenseList() async {
    final expenses = await _expenseRepository.getAllExpenses();
    setState(() {
      _expenses = expenses;
      if (_expenses.isNotEmpty && _selectedExpense == null) {
        _selectedExpense = _expenses[0];
      }
    });
  }

  Future<void> _saveExpenseList() async {
    await _expenseRepository.saveExpenseList(_expenses);
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
      DateTime.now().millisecondsSinceEpoch,
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
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense added.')));

    _nameController.clear();
    _categoryController.clear();
    _amountController.clear();
    _dateController.clear();
    _paymentMethodController.clear();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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

  @override
  Widget build(BuildContext context) {
    bool isWideScreen = MediaQuery.of(context).size.width >= 600;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
      ),
      body: isWideScreen ? _buildWideLayout() : _buildMobileLayout(),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        Expanded(flex: 1, child: _buildInputForm()),
        const VerticalDivider(width: 1),
        Expanded(flex: 1, child: _buildListView()),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildInputForm(),
        const Divider(),
        Expanded(child: _buildListView()),
      ],
    );
  }

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
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _paymentMethodController,
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
            onTap: () => _navigateToExpenseDetail(expense),
          ),
        );
      },
    );
  }
}

class ExpenseDetailPage extends StatelessWidget {
  final ExpenseItem expense;

  const ExpenseDetailPage({Key? key, required this.expense}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _nameController = TextEditingController(text: expense.name);
    final TextEditingController _categoryController = TextEditingController(text: expense.category);
    final TextEditingController _amountController = TextEditingController(text: expense.amount);
    final TextEditingController _dateController = TextEditingController(text: expense.date);
    final TextEditingController _paymentMethodController = TextEditingController(text: expense.paymentMethod);

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
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
