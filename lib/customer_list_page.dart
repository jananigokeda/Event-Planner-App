/*
import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:intl/intl.dart';
import 'customer_item.dart';
import 'customer_repository.dart';
import 'data.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final EncryptedSharedPreferences _esp = EncryptedSharedPreferences();
  final CustomerRepository _customerRepository = CustomerRepository();
  final String _customerCountKey = 'customer_count';

  List<CustomerItem> _customers = [];
  CustomerItem? _selectedCustomer; // For wide-screen: the currently selected customer.
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomerList();
    _loadPreviousFormData();
  }

  /// Loads the customer list from EncryptedSharedPreferences.
  Future<void> _loadCustomerList() async {
    String? countStr = await _esp.getString(_customerCountKey);
    int count = countStr != null && countStr.isNotEmpty ? int.tryParse(countStr) ?? 0 : 0;
    List<CustomerItem> customers = [];
    for (int i = 0; i < count; i++) {
      String? idStr = await _esp.getString("customer_${i}_id");
      String? firstName = await _esp.getString("customer_${i}_firstName");
      String? lastName = await _esp.getString("customer_${i}_lastName");
      String? address = await _esp.getString("customer_${i}_address");
      String? birthday = await _esp.getString("customer_${i}_birthday");
      if (idStr != null &&
          firstName != null &&
          lastName != null &&
          address != null &&
          birthday != null) {
        int id = int.tryParse(idStr) ?? 0;
        customers.add(CustomerItem(id, firstName, lastName, address, birthday));
      }
    }
    setState(() {
      _customers = customers;
      // For wide screens, auto-select the first customer if none is selected.
      if (_customers.isNotEmpty && _selectedCustomer == null) {
        _selectedCustomer = _customers[0];
      }
    });
  }

  /// Saves the current customer list into EncryptedSharedPreferences.
  Future<void> _saveCustomerList() async {
    int count = _customers.length;
    await _esp.setString(_customerCountKey, count.toString());
    for (int i = 0; i < count; i++) {
      CustomerItem customer = _customers[i];
      await _esp.setString("customer_${i}_id", customer.id.toString());
      await _esp.setString("customer_${i}_firstName", customer.firstName);
      await _esp.setString("customer_${i}_lastName", customer.lastName);
      await _esp.setString("customer_${i}_address", customer.address);
      await _esp.setString("customer_${i}_birthday", customer.birthday);
    }
  }

  /// Loads previous form data via CustomerRepository.
  Future<void> _loadPreviousFormData() async {
    final data = await _customerRepository.loadData();
    _firstNameController.text = data["firstName"] ?? '';
    _lastNameController.text = data["lastName"] ?? '';
    _addressController.text = data["address"] ?? '';
    _birthdayController.text = data["birthday"] ?? '';
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
        title: const Text('Instructions / 사용 안내'),
        content: const Text(
          'Enter all required fields to add a customer.\n'
              '모든 필드는 필수 입력입니다.\n'
              'Tap "Copy Previous" to load the last input data.\n'
              'On phone, tap a customer to view details on a new page.\n'
              'On tablet/desktop, the right pane shows the detail view.',
        ),
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
          title: const Text('Error / 오류'),
          content: const Text('All fields are required. / 모든 필드를 입력하세요.'),
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
    // Duplicate check: if a customer with the same details exists, show an error.
    bool duplicate = _customers.any((customer) =>
    customer.firstName == _firstNameController.text &&
        customer.lastName == _lastNameController.text &&
        customer.address == _addressController.text &&
        customer.birthday == _birthdayController.text);
    if (duplicate) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Duplicate Entry / 중복 데이터'),
          content: const Text(
            'A customer with the same details already exists.\n'
                '동일한 이름, 주소, 생년월일을 가진 고객이 이미 존재합니다.',
          ),
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
    setState(() {
      _customers.add(newCustomer);
      if (_selectedCustomer == null) {
        _selectedCustomer = newCustomer;
      }
    });
    await _saveCustomerList();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Customer added / 고객이 추가되었습니다.')),
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
        builder: (context) => CustomerDetailPage(customer: customer),
      ),
    );
    if (updatedCustomer == null) {
      // Deletion was requested.
      setState(() {
        _customers.removeWhere((c) => c.id == customer.id);
      });
      await _saveCustomerList();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer deleted / 고객이 삭제되었습니다.')),
      );
    } else {
      setState(() {
        int index = _customers.indexWhere((c) => c.id == customer.id);
        if (index != -1) {
          _customers[index] = updatedCustomer;
        }
      });
      await _saveCustomerList();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer updated / 고객이 수정되었습니다.')),
      );
    }
  }

  /// Builds the left pane: a Column with the input form on top and customer list below.
  Widget _buildLeftPane() {
    return Column(
      children: [
        _buildInputForm(),
        const Divider(),
        Expanded(child: _buildListView()),
      ],
    );
  }

  /// Builds the input form (with Submit and Copy Previous buttons).
  Widget _buildInputForm() {
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          shrinkWrap: true,
          // Using ListView with shrinkWrap allows scrolling if needed.
          children: [
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name / 이름',
                border: OutlineInputBorder(),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name / 성',
                border: OutlineInputBorder(),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address / 주소',
                border: OutlineInputBorder(),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _birthdayController,
              decoration: const InputDecoration(
                labelText: 'Birthday (YYYY-MM-DD) / 생년월일',
                border: OutlineInputBorder(),
                filled: true,
              ),
              readOnly: true,
              onTap: _selectBirthday,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _handleSubmit,
                  icon: const Icon(Icons.check),
                  label: const Text('Submit / 제출'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await _loadPreviousFormData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Previous data loaded / 이전 데이터가 로드되었습니다.')),
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy Previous / 이전 데이터 복사'),
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
        ? const Center(child: Text('No customers available. / 고객이 없습니다.'))
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

  /// Builds the wide layout with two panes:
  /// Left: input form above customer list.
  /// Right: detail view of the selected customer.
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
              ? const Center(child: Text('Select a customer to view details / 고객을 선택하여 세부 정보를 확인하세요.'))
              : _buildDetailView(),
        ),
      ],
    );
  }

  /// Builds the detail view for the selected customer (for wide screens).
  /// This view shows the customer's details with Update and Delete buttons.
  Widget _buildDetailView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ListView(
        children: [
          TextField(
            controller: TextEditingController(text: _selectedCustomer!.firstName),
            decoration: const InputDecoration(
              labelText: 'First Name / 이름',
              border: OutlineInputBorder(),
              filled: true,
            ),
            readOnly: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: TextEditingController(text: _selectedCustomer!.lastName),
            decoration: const InputDecoration(
              labelText: 'Last Name / 성',
              border: OutlineInputBorder(),
              filled: true,
            ),
            readOnly: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: TextEditingController(text: _selectedCustomer!.address),
            decoration: const InputDecoration(
              labelText: 'Address / 주소',
              border: OutlineInputBorder(),
              filled: true,
            ),
            readOnly: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: TextEditingController(text: _selectedCustomer!.birthday),
            decoration: const InputDecoration(
              labelText: 'Birthday (YYYY-MM-DD) / 생년월일',
              border: OutlineInputBorder(),
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
                  // Navigate to a detail editing page and update selection accordingly.
                  final updatedCustomer = await Navigator.push<CustomerItem>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomerDetailPage(customer: _selectedCustomer!),
                    ),
                  );
                  if (updatedCustomer == null) {
                    // Deletion was requested.
                    setState(() {
                      _customers.removeWhere((c) => c.id == _selectedCustomer!.id);
                      _selectedCustomer = _customers.isNotEmpty ? _customers[0] : null;
                    });
                    await _saveCustomerList();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Customer deleted / 고객이 삭제되었습니다.')),
                    );
                  } else {
                    setState(() {
                      int index = _customers.indexWhere((c) => c.id == updatedCustomer.id);
                      if (index != -1) {
                        _customers[index] = updatedCustomer;
                        _selectedCustomer = updatedCustomer;
                      }
                    });
                    await _saveCustomerList();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Customer updated / 고객이 수정되었습니다.')),
                    );
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit / 수정'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  // Confirm deletion.
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Customer / 고객 삭제'),
                      content: const Text(
                        'Are you sure you want to delete this customer?\n해당 고객을 삭제하시겠습니까?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel / 취소'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            setState(() {
                              _customers.removeWhere((c) => c.id == _selectedCustomer!.id);
                              _selectedCustomer = _customers.isNotEmpty ? _customers[0] : null;
                            });
                            await _saveCustomerList();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Customer deleted / 고객이 삭제되었습니다.')),
                            );
                          },
                          child: const Text('Delete / 삭제'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.delete),
                label: const Text('Delete / 삭제'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
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
          child: _customers.isEmpty
              ? const Center(child: Text('No customers available. / 고객이 없습니다.'))
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
    bool isWideScreen = MediaQuery.of(context).size.width >= 600;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer List / 고객 목록'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInstructions,
          ),
        ],
      ),
      body: isWideScreen ? _buildWideLayout() : _buildMobileLayout(),
      // No FloatingActionButton is provided.
    );
  }
}

/// CustomerDetailPage is used in mobile layouts to allow editing or deletion of a customer.
/// It uses WillPopScope to ensure that navigating back returns the original customer data.
class CustomerDetailPage extends StatefulWidget {
  final CustomerItem customer;
  const CustomerDetailPage({Key? key, required this.customer}) : super(key: key);

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
          title: const Text('Error / 오류'),
          content: const Text('All fields are required. / 모든 필드를 입력하세요.'),
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
        title: const Text('Delete Customer / 고객 삭제'),
        content: const Text('Are you sure you want to delete this customer?\n해당 고객을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel / 취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, null);
            },
            child: const Text('Delete / 삭제'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, widget.customer);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Customer Detail / 고객 세부 정보'),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Instructions / 사용 안내'),
                    content: const Text(
                      'Edit the customer details and press "Update" to save changes.\n'
                          '수정 후 "Update / 수정" 버튼을 눌러 변경사항을 저장하세요.\n'
                          'Press "Delete / 삭제" to remove the customer.',
                    ),
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
                decoration: const InputDecoration(
                  labelText: 'First Name / 이름',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name / 성',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address / 주소',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _birthdayController,
                decoration: const InputDecoration(
                  labelText: 'Birthday (YYYY-MM-DD) / 생년월일',
                  border: OutlineInputBorder(),
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
                    label: const Text('Update / 수정'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _handleDelete,
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete / 삭제'),
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
*/
import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:intl/intl.dart';
import 'customer_item.dart';
import 'customer_repository.dart';

/// A simple localization map.
/// Keys are text identifiers; each language has its own mapping.
final Map<String, Map<String, String>> localizedValues = {
  'en': {
    'instructions_title': 'Instructions',
    'instructions_content':
    'Enter all required fields to add a customer.\nTap "Copy Previous" to load the last input data.\nOn phone, tap a customer to view details on a new page.\nOn tablet/desktop, the right pane shows the detail view.',
    'error_title': 'Error',
    'error_all_fields_required': 'All fields are required.',
    'duplicate_title': 'Duplicate Entry',
    'duplicate_content': 'A customer with the same details already exists.',
    'submit': 'Submit',
    'copy_previous': 'Copy Previous',
    'customer_added': 'Customer added.',
    'customer_deleted': 'Customer deleted.',
    'customer_updated': 'Customer updated.',
    'first_name': 'First Name',
    'last_name': 'Last Name',
    'address': 'Address',
    'birthday': 'Birthday (YYYY-MM-DD)',
    'no_customers': 'No customers available.',
    'select_customer': 'Select a customer to view details.',
    'edit': 'Edit',
    'delete': 'Delete',
    'close_detail': 'Close Detail',
  },
  'ko': {
    'instructions_title': '사용 안내',
    'instructions_content':
    '고객을 추가하려면 모든 필드를 입력하세요.\n이전 데이터를 불러오려면 "Copy Previous" 버튼을 누르세요.\n전화 화면에서는 고객을 선택하면 상세 정보를 새로운 페이지로 보여줍니다.\n태블릿/데스크탑에서는 오른쪽 창에 상세 정보가 표시됩니다.',
    'error_title': '오류',
    'error_all_fields_required': '모든 필드를 입력하세요.',
    'duplicate_title': '중복 데이터',
    'duplicate_content': '동일한 고객 정보가 이미 존재합니다.',
    'submit': '제출',
    'copy_previous': '이전 데이터 복사',
    'customer_added': '고객이 추가되었습니다.',
    'customer_deleted': '고객이 삭제되었습니다.',
    'customer_updated': '고객이 수정되었습니다.',
    'first_name': '이름',
    'last_name': '성',
    'address': '주소',
    'birthday': '생년월일 (YYYY-MM-DD)',
    'no_customers': '고객이 없습니다.',
    'select_customer': '세부 정보를 확인할 고객을 선택하세요.',
    'edit': '수정',
    'delete': '삭제',
    'close_detail': '세부 정보 닫기',
  },
};

/// Returns the localized string for the given key.
String getText(String key, String currentLanguage) {
  return localizedValues[currentLanguage]?[key] ?? key;
}

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
  final EncryptedSharedPreferences _esp = EncryptedSharedPreferences();
  final CustomerRepository _customerRepository = CustomerRepository();
  final String _customerCountKey = 'customer_count';

  List<CustomerItem> _customers = [];
  CustomerItem? _selectedCustomer; // For wide-screen layout.
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();

  // Current selected language; default is English.
  String _currentLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadCustomerList();
    _loadPreviousFormData();
  }

  /// Loads the customer list from EncryptedSharedPreferences.
  Future<void> _loadCustomerList() async {
    String? countStr = await _esp.getString(_customerCountKey);
    int count = countStr != null && countStr.isNotEmpty ? int.tryParse(countStr) ?? 0 : 0;
    List<CustomerItem> customers = [];
    for (int i = 0; i < count; i++) {
      String? idStr = await _esp.getString("customer_${i}_id");
      String? firstName = await _esp.getString("customer_${i}_firstName");
      String? lastName = await _esp.getString("customer_${i}_lastName");
      String? address = await _esp.getString("customer_${i}_address");
      String? birthday = await _esp.getString("customer_${i}_birthday");
      if (idStr != null &&
          firstName != null &&
          lastName != null &&
          address != null &&
          birthday != null) {
        int id = int.tryParse(idStr) ?? 0;
        customers.add(CustomerItem(id, firstName, lastName, address, birthday));
      }
    }
    setState(() {
      _customers = customers;
      if (_customers.isNotEmpty && _selectedCustomer == null) {
        _selectedCustomer = _customers[0];
      }
    });
  }

  /// Saves the current customer list into EncryptedSharedPreferences.
  Future<void> _saveCustomerList() async {
    int count = _customers.length;
    await _esp.setString(_customerCountKey, count.toString());
    for (int i = 0; i < count; i++) {
      CustomerItem customer = _customers[i];
      await _esp.setString("customer_${i}_id", customer.id.toString());
      await _esp.setString("customer_${i}_firstName", customer.firstName);
      await _esp.setString("customer_${i}_lastName", customer.lastName);
      await _esp.setString("customer_${i}_address", customer.address);
      await _esp.setString("customer_${i}_birthday", customer.birthday);
    }
  }

  /// Loads previous form data via CustomerRepository.
  Future<void> _loadPreviousFormData() async {
    final data = await _customerRepository.loadData();
    _firstNameController.text = data["firstName"] ?? '';
    _lastNameController.text = data["lastName"] ?? '';
    _addressController.text = data["address"] ?? '';
    _birthdayController.text = data["birthday"] ?? '';
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
        title: Text(getText('instructions_title', _currentLanguage)),
        content: Text(getText('instructions_content', _currentLanguage)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
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
          title: Text(getText('error_title', _currentLanguage)),
          content: Text(getText('error_all_fields_required', _currentLanguage)),
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
          title: Text(getText('duplicate_title', _currentLanguage)),
          content: Text(getText('duplicate_content', _currentLanguage)),
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
    setState(() {
      _customers.add(newCustomer);
      if (_selectedCustomer == null) {
        _selectedCustomer = newCustomer;
      }
    });
    await _saveCustomerList();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(getText('customer_added', _currentLanguage))),
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
        builder: (context) => CustomerDetailPage(customer: customer, currentLanguage: _currentLanguage),
      ),
    );
    if (updatedCustomer == null) {
      // Deletion was requested.
      setState(() {
        _customers.removeWhere((c) => c.id == customer.id);
      });
      await _saveCustomerList();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(getText('customer_deleted', _currentLanguage))),
      );
    } else {
      setState(() {
        int index = _customers.indexWhere((c) => c.id == customer.id);
        if (index != -1) {
          _customers[index] = updatedCustomer;
        }
      });
      await _saveCustomerList();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(getText('customer_updated', _currentLanguage))),
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
                labelText: getText('first_name', _currentLanguage),
                border: const OutlineInputBorder(),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: getText('last_name', _currentLanguage),
                border: const OutlineInputBorder(),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: getText('address', _currentLanguage),
                border: const OutlineInputBorder(),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _birthdayController,
              decoration: InputDecoration(
                labelText: getText('birthday', _currentLanguage),
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
                  label: Text(getText('submit', _currentLanguage)),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await _loadPreviousFormData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(getText('copy_previous', _currentLanguage))),
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: Text(getText('copy_previous', _currentLanguage)),
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
        ? Center(child: Text(getText('no_customers', _currentLanguage)))
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

  /// Builds the wide layout with two panes:
  /// Left: input form above customer list.
  /// Right: detail view of the selected customer.
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
              ? Center(child: Text(getText('select_customer', _currentLanguage)))
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
              labelText: getText('first_name', _currentLanguage),
              border: const OutlineInputBorder(),
              filled: true,
            ),
            readOnly: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: TextEditingController(text: _selectedCustomer!.lastName),
            decoration: InputDecoration(
              labelText: getText('last_name', _currentLanguage),
              border: const OutlineInputBorder(),
              filled: true,
            ),
            readOnly: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: TextEditingController(text: _selectedCustomer!.address),
            decoration: InputDecoration(
              labelText: getText('address', _currentLanguage),
              border: const OutlineInputBorder(),
              filled: true,
            ),
            readOnly: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: TextEditingController(text: _selectedCustomer!.birthday),
            decoration: InputDecoration(
              labelText: getText('birthday', _currentLanguage),
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
                      builder: (context) => CustomerDetailPage(customer: _selectedCustomer!, currentLanguage: _currentLanguage),
                    ),
                  );
                  if (updatedCustomer == null) {
                    setState(() {
                      _customers.removeWhere((c) => c.id == _selectedCustomer!.id);
                      _selectedCustomer = _customers.isNotEmpty ? _customers[0] : null;
                    });
                    await _saveCustomerList();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(getText('customer_deleted', _currentLanguage))),
                    );
                  } else {
                    setState(() {
                      int index = _customers.indexWhere((c) => c.id == updatedCustomer.id);
                      if (index != -1) {
                        _customers[index] = updatedCustomer;
                        _selectedCustomer = updatedCustomer;
                      }
                    });
                    await _saveCustomerList();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(getText('customer_updated', _currentLanguage))),
                    );
                  }
                },
                icon: const Icon(Icons.edit),
                label: Text(getText('edit', _currentLanguage)),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(getText('delete', _currentLanguage) + ' ' + getText('customer', _currentLanguage)),
                      content: Text(getText('delete', _currentLanguage) +
                          '?\n' +
                          getText('delete_confirmation', _currentLanguage)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(getText('cancel', _currentLanguage)),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            setState(() {
                              _customers.removeWhere((c) => c.id == _selectedCustomer!.id);
                              _selectedCustomer = _customers.isNotEmpty ? _customers[0] : null;
                            });
                            await _saveCustomerList();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(getText('customer_deleted', _currentLanguage))),
                            );
                          },
                          child: Text(getText('delete', _currentLanguage)),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.delete),
                label: Text(getText('delete', _currentLanguage)),
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
              label: Text(getText('close_detail', _currentLanguage)),
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
          child: _customers.isEmpty
              ? Center(child: Text(getText('no_customers', _currentLanguage)))
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
        title: const Text('Customer List / 고객 목록'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: (value) {
              setState(() {
                _currentLanguage = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'en', child: Text('English')),
              const PopupMenuItem(value: 'ko', child: Text('한국어')),
            ],
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
  const CustomerDetailPage({Key? key, required this.customer, required this.currentLanguage}) : super(key: key);

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
          title: Text(getText('error_title', widget.currentLanguage)),
          content: Text(getText('error_all_fields_required', widget.currentLanguage)),
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
        title: Text(getText('delete', widget.currentLanguage) + ' ' + getText('customer', widget.currentLanguage)),
        content: Text(getText('delete', widget.currentLanguage) +
            '?\n' +
            getText('delete_confirmation', widget.currentLanguage)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(getText('cancel', widget.currentLanguage)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, null);
            },
            child: Text(getText('delete', widget.currentLanguage)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, widget.customer);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Customer Detail / 고객 세부 정보'),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(getText('instructions_title', widget.currentLanguage)),
                    content: Text(getText('instructions_content', widget.currentLanguage)),
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
                  labelText: getText('first_name', widget.currentLanguage),
                  border: const OutlineInputBorder(),
                  filled: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: getText('last_name', widget.currentLanguage),
                  border: const OutlineInputBorder(),
                  filled: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: getText('address', widget.currentLanguage),
                  border: const OutlineInputBorder(),
                  filled: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _birthdayController,
                decoration: InputDecoration(
                  labelText: getText('birthday', widget.currentLanguage),
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
                    label: Text(getText('edit', widget.currentLanguage)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _handleDelete,
                    icon: const Icon(Icons.delete),
                    label: Text(getText('delete', widget.currentLanguage)),
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
