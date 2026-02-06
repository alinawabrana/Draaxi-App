import 'package:draaxi/src/common/widgets/primary_button.dart';
import 'package:draaxi/utils/constant/texts.dart';
import 'package:flutter/material.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _complaintDescriptionController = TextEditingController();
  String? _selectedComplaintType;

  final List<String> _complaintTypes = [
    'Vehicle not clean',
    'Driver behavior',
    'Late arrival',
    'Wrong route',
    'Payment issue',
    'Other',
  ];

  @override
  void dispose() {
    _complaintDescriptionController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedComplaintType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a complaint type'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      // Show success dialog
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            height: 355,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF35383F) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success icon
                Container(
                  width: 124,
                  height: 124,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8E6C9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 80,
                    color: Color(0xFF388E3C),
                  ),
                ),
                
                const SizedBox(height: 23),
                
                // Success title
                Text(
                  'Send successful',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    height: 28 / 22,
                    color: isDark ? Colors.white : const Color(0xFF2A2A2A),
                    fontFamily: 'Poppins',
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Success message
                Text(
                  'Your complain has been send successful',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 18 / 12,
                    color: isDark ? const Color(0xFFD0D0D0) : const Color(0xFF898989),
                    fontFamily: 'Poppins',
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Back Home button
                PrimaryButton(
                  text: 'Back Home',
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Go back to previous screen
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top navigation bar
                _buildTopBar(isDark),
                
                const SizedBox(height: 30),
                
                // Complaint type dropdown
                _buildComplaintTypeDropdown(isDark),
                
                const SizedBox(height: 16),
                
                // Complaint description text field
                Expanded(
                  child: _buildComplaintDescriptionField(isDark),
                ),
                
                const SizedBox(height: 32),
                
                // Submit button
                PrimaryButton(
                  text: 'Submit',
                  onPressed: _handleSubmit,
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back button
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: [
              SizedBox(
                width: 8.5,
                height: 15.5,
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 8.5,
                  color: isDark ? const Color(0xFFD0D0D0) : const Color(0xFF2A2A2A),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                ATexts.back,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: isDark ? const Color(0xFFD0D0D0) : const Color(0xFF414141),
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
        
        // Title
        Text(
          'Complaints',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : const Color(0xFF2A2A2A),
            fontFamily: 'Poppins',
          ),
        ),
        
        // Spacer to balance
        const SizedBox(width: 80),
      ],
    );
  }

  Widget _buildComplaintTypeDropdown(bool isDark) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF35383F) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFB8B8B8),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedComplaintType,
          isExpanded: true,
          hint: Text(
            'Select complaint type',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 23 / 16,
              color: isDark ? const Color(0xFFD0D0D0) : const Color(0xFF414141),
              fontFamily: 'Poppins',
            ),
          ),
          icon: Icon(
            Icons.arrow_drop_down,
            size: 24,
            color: isDark ? const Color(0xFFD0D0D0) : const Color(0xFF414141),
          ),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 23 / 16,
            color: isDark ? const Color(0xFFD0D0D0) : const Color(0xFF414141),
            fontFamily: 'Poppins',
          ),
          dropdownColor: isDark ? const Color(0xFF35383F) : Colors.white,
          items: _complaintTypes.map((String type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedComplaintType = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildComplaintDescriptionField(bool isDark) {
    return TextFormField(
      controller: _complaintDescriptionController,
      expands: true,
      textAlignVertical: TextAlignVertical.top,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.white : const Color(0xFF121212),
        fontFamily: 'Poppins',
      ),
      decoration: InputDecoration(
        hintText: 'Write your complain here (minimum 10 characters)',
        hintStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFD0D0D0),
          fontFamily: 'Poppins',
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF35383F) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color(0xFFB8B8B8),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color(0xFFB8B8B8),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color(0xFFB8B8B8),
            width: 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your complaint';
        }
        if (value.trim().length < 10) {
          return 'Complaint must be at least 10 characters';
        }
        return null;
      },
    );
  }
}

