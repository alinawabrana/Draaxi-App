import 'package:draaxi/src/common/widgets/app_drawer.dart';
import 'package:draaxi/src/common/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Static address data
  final List<Map<String, String>> _addresses = [
    {
      'name': 'Office',
      'address': '2972 Westheimer Rd. Santa Ana, Illinois 85486',
    },
    {
      'name': 'Office',
      'address': '2972 Westheimer Rd. Santa Ana, Illinois 85486',
    },
    {
      'name': 'Office',
      'address': '2972 Westheimer Rd. Santa Ana, Illinois 85486',
    },
    {
      'name': 'Office',
      'address': '2972 Westheimer Rd. Santa Ana, Illinois 85486',
    },
    {
      'name': 'Office',
      'address': '2972 Westheimer Rd. Santa Ana, Illinois 85486',
    },
    {
      'name': 'Office',
      'address': '2972 Westheimer Rd. Santa Ana, Illinois 85486',
    },
    {
      'name': 'Office',
      'address': '2972 Westheimer Rd. Santa Ana, Illinois 85486',
    },
  ];

  void _showAddAddressSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddAddressSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top navigation bar
              _buildTopBar(isDark),
              
              const SizedBox(height: 30),
              
              // Address cards list
              Expanded(
                child: ListView.separated(
                  itemCount: _addresses.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 15),
                  itemBuilder: (context, index) {
                    return _buildAddressCard(_addresses[index], isDark);
                  },
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Add New Address button
              PrimaryButton(
                text: 'Add New Address',
                onPressed: _showAddAddressSheet,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Menu icon
        _buildIconButton(
          icon: Icons.menu,
          onTap: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          isDark: isDark,
        ),
        
        // Title
        Text(
          'Address',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            height: 25 / 18,
            color: isDark ? Colors.white : const Color(0xFF2A2A2A),
            fontFamily: 'Poppins',
          ),
        ),
        
        // Spacer to balance
        const SizedBox(width: 34),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1B1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          icon,
          size: 16,
          color: const Color(0xFF414141),
        ),
      ),
    );
  }

  Widget _buildAddressCard(Map<String, String> address, bool isDark) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF35383F) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0A000000),
            blurRadius: 17,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      padding: const EdgeInsets.all(11),
      child: Row(
        children: [
          // Location icon
          Icon(
            Icons.location_on,
            size: 24,
            color: isDark ? Colors.white : const Color(0xFF5A5A5A),
          ),
          
          const SizedBox(width: 6),
          
          // Address details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Name
                Text(
                  address['name'] ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 23 / 16,
                    color: isDark ? Colors.white : const Color(0xFF414141),
                    fontFamily: 'Poppins',
                  ),
                ),
                
                const SizedBox(height: 2),
                
                // Address detail
                Text(
                  address['address'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 18 / 12,
                    color: const Color(0xFFB8B8B8),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          
          // Edit icon
          Icon(
            Icons.edit_outlined,
            size: 20,
            color: isDark ? const Color(0xFFE57373) : const Color(0xFFB7083C),
          ),
        ],
      ),
    );
  }
}

class AddAddressSheet extends StatefulWidget {
  const AddAddressSheet({super.key});

  @override
  State<AddAddressSheet> createState() => _AddAddressSheetState();
}

class _AddAddressSheetState extends State<AddAddressSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _handleAddAddress() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement add address functionality
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.6,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF35383F) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: 134,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white : const Color(0xFF141414),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
          
          // Close button
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: Icon(
                Icons.close,
                color: isDark ? Colors.white : const Color(0xFF2A2A2A),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 28),
                    
                    // Title
                    Text(
                      'Address Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        height: 26 / 20,
                        color: isDark ? Colors.white : const Color(0xFF2A2A2A),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Divider
                    Container(
                      height: 1,
                      color: isDark ? const Color(0xFFDDDDDD) : const Color(0xFFDDDDDD),
                    ),
                    
                    const SizedBox(height: 31),
                    
                    // Name of Address field
                    SizedBox(
                      height: 60,
                      child: TextFormField(
                        controller: _nameController,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : const Color(0xFF121212),
                          fontFamily: 'Poppins',
                        ),
                        decoration: InputDecoration(
                        hintText: 'Name of Address',
                        hintStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark ? const Color(0xFFD0D0D0) : const Color(0xFF5A5A5A),
                          fontFamily: 'Poppins',
                        ),
                        prefixIcon: Icon(
                          Icons.add,
                          size: 24,
                          color: isDark ? const Color(0xFFD0D0D0) : const Color(0xFF5A5A5A),
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter address name';
                        }
                        return null;
                      },
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Address Details field
                    TextFormField(
                      controller: _addressController,
                      maxLines: null,
                      minLines: 4,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : const Color(0xFF121212),
                        fontFamily: 'Poppins',
                      ),
                      decoration: InputDecoration(
                        hintText: 'Address Details',
                        hintStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark ? const Color(0xFFD0D0D0) : const Color(0xFF5A5A5A),
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
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter address details';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Add Address button
                    PrimaryButton(
                      text: 'Add Address',
                      onPressed: _handleAddAddress,
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
