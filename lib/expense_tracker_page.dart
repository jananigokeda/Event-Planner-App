import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'expense_item.dart';

class ExpenseDetailPage extends StatefulWidget {
  final ExpenseItem expense;

  const ExpenseDetailPage({Key? key, required this.expense}) : super(key: key);

  @override
  _ExpenseDetailPageState createState() => _ExpenseDetailPageState();
}

class _ExpenseDetailPageState extends State<ExpenseDetailPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String _selectedPaymentMethod = 'Visa'; // Default payment method

  final List<String> _paymentMethods = ['Visa', 'Mastercard', 'Debit', 'Cash', 'Other'];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.expense.name;
    _categoryController.text = widget.expense.category;
    _amountController.text = widget.expense.amount;
    _dateController.text = widget.expense.date;
    _selectedPaymentMethod = widget.expense.paymentMethod;
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

  /// Handles updating the expense.
  void _handleUpdate() {
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

    final updatedExpense = ExpenseItem(
      widget.expense.id,
      _nameController.text,
      _categoryController.text,
      _amountController.text,
      _dateController.text,
      _selectedPaymentMethod,
    );

    Navigator.pop(context, updatedExpense);
  }

  /// Handles deleting the expense.
  void _handleDelete() {
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
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, null); // Return null to indicate deletion
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, widget.expense); // Return the original expense
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Expense Detail'),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Instructions'),
                    content: const Text('Edit or delete the expense details.'),
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
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Expense Name"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: "Category"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: "Amount"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: "Date"),
                readOnly: true,
                onTap: _selectDate,
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _handleUpdate,
                    icon: const Icon(Icons.check),
                    label: const Text('Update'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _handleDelete,
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
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