import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/transaction_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/category_chip.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedType = 'expense';
  String _selectedCategory = 'Food';

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final transactionProvider =
          Provider.of<TransactionProvider>(context, listen: false);

      final transaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: authProvider.user!.uid,
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        type: _selectedType,
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        date: _selectedDate,
        createdAt: DateTime.now(),
      );

      final success = await transactionProvider.addTransaction(transaction);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction added successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(transactionProvider.error ?? 'Failed to add')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = _selectedType == 'income'
        ? AppConstants.incomeCategories
        : AppConstants.expenseCategories;

    // Update selected category if it's not in the new list
    if (!categories.contains(_selectedCategory)) {
      _selectedCategory = categories.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type toggle
              Row(
                children: [
                  Expanded(
                    child: _buildTypeButton('Expense', 'expense'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeButton('Income', 'income'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Title',
                hint: 'e.g., Grocery shopping',
                icon: Icons.title,
                controller: _titleController,
                validator: Validators.name,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Amount',
                hint: '0.00',
                icon: Icons.attach_money,
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Amount is required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Amount must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Category selection
              const Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((cat) {
                  return CategoryChip(
                    category: cat,
                    selected: _selectedCategory == cat,
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              // Date picker
              Row(
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _pickDate,
                    child: Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Description (optional)',
                hint: 'Add a note',
                icon: Icons.notes,
                controller: _descriptionController,
                maxLines: 3,
              ),
              const SizedBox(height: 30),
              CustomButton(
                text: 'Save Transaction',
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(String label, String value) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = value;
          // Reset category if switching type and current category not in list
          final newCategories = value == 'income'
              ? AppConstants.incomeCategories
              : AppConstants.expenseCategories;
          if (!newCategories.contains(_selectedCategory)) {
            _selectedCategory = newCategories.first;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: _selectedType == value ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedType == value
                ? AppColors.primary
                : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color:
                _selectedType == value ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
