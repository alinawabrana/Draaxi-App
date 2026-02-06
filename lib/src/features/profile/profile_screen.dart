import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:draaxi/src/common/widgets/back_button.dart';
import 'package:draaxi/src/common/widgets/dropdown_form_field.dart';
import 'package:draaxi/src/common/widgets/phone_form_field.dart';
import 'package:draaxi/src/common/widgets/primary_button.dart';
import 'package:draaxi/src/common/widgets/primary_text_form_field.dart';
import 'package:draaxi/src/features/authentication/providers/auth_providers.dart';
import 'package:draaxi/src/features/authentication/repository/auth_repository.dart';
import 'package:draaxi/src/router/router.dart';
import 'package:draaxi/utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _cityController = TextEditingController();
  final _streetController = TextEditingController();
  final _districtController = TextEditingController();

  bool _isLoading = false;
  bool _isUpdating = false;
  bool _isLoggingOut = false;
  CountryCode _selectedCountryCode = CountryCode.fromDialCode('+234');
  String? _selectedGender;
  String? _profileImageUrl;
  File? _selectedImageFile;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    final authRepository = ref.read(authRepositoryProvider);

    try {
      final response = await authRepository.getUserProfile();
      
      // Response can be either direct user object or wrapped in 'user' key
      Map<String, dynamic>? user;
      if (response.containsKey('user')) {
        user = response['user'] as Map<String, dynamic>?;
      } else if (response.containsKey('id')) {
        // Response is directly the user object
        user = response;
      }

      if (user != null) {
        _nameController.text = user['name'] as String? ?? '';
        _emailController.text = user['email'] as String? ?? '';

        // Parse phone number to extract country code and number
        final phone = user['phone'] as String? ?? '';
        if (phone.isNotEmpty) {
          final phoneParts = _parsePhoneNumber(phone);
          _selectedCountryCode = CountryCode.fromDialCode(phoneParts['countryCode'] ?? '+234');
          _phoneNumberController.text = phoneParts['number'] ?? '';
        }

        // Load rider profile data
        final riderProfile = user['rider_profile'] as Map<String, dynamic>?;
        if (riderProfile != null) {
          _cityController.text = riderProfile['city'] as String? ?? '';
          _streetController.text = riderProfile['street'] as String? ?? '';
          _districtController.text = riderProfile['district'] as String? ?? '';
          _profileImageUrl = riderProfile['profile_image'] as String?;
        }
      }
    } on ApiException catch (e) {
      if (mounted) {
        _showSnackBar(e.message);
      }
    } catch (_) {
      if (mounted) {
        _showSnackBar('Failed to load profile. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Map<String, String> _parsePhoneNumber(String phone) {
    // Phone format: +923336300707
    // Extract country code (e.g., +92) and number (e.g., 3336300707)
    if (phone.startsWith('+')) {
      // Try to match common country codes
      final countryCodes = [
        '+1', '+20', '+27', '+91', '+92', '+213', '+212', '+216', '+218',
        '+233', '+234', '+237', '+244', '+249', '+251', '+254', '+255',
        '+256', '+258', '+260', '+263'
      ];

      for (final code in countryCodes) {
        if (phone.startsWith(code)) {
          return {
            'countryCode': code,
            'number': phone.substring(code.length),
          };
        }
      }

      // Fallback: assume first 3-4 digits are country code
      if (phone.length > 4) {
        final code = phone.substring(0, 3);
        return {
          'countryCode': code,
          'number': phone.substring(3),
        };
      }
    }

    return {'countryCode': '+234', 'number': phone};
  }

  Future<void> _handleUpdate() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    final authRepository = ref.read(authRepositoryProvider);

    try {
      // Combine country code and phone number
      final fullPhone = '${_selectedCountryCode.dialCode}${_phoneNumberController.text.trim()}';

      final response = await authRepository.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: fullPhone,
        city: _cityController.text.trim().isNotEmpty ? _cityController.text.trim() : null,
        street: _streetController.text.trim().isNotEmpty ? _streetController.text.trim() : null,
        district: _districtController.text.trim().isNotEmpty ? _districtController.text.trim() : null,
        profileImage: _selectedImageFile,
      );

      // Update profile image URL from response if image was uploaded
      if (_selectedImageFile != null && response.containsKey('user')) {
        final user = response['user'] as Map<String, dynamic>?;
        if (user != null) {
          final riderProfile = user['rider_profile'] as Map<String, dynamic>?;
          if (riderProfile != null) {
            setState(() {
              _profileImageUrl = riderProfile['profile_image'] as String?;
              _selectedImageFile = null; // Clear selected file after successful upload
            });
          }
        }
      }

      if (mounted) {
        _showSnackBar('Profile updated successfully');
        // Reload profile to get updated data
        _loadProfile();
      }
    } on ApiException catch (e) {
      if (mounted) {
        _showSnackBar(e.message);
      }
    } catch (_) {
      if (mounted) {
        _showSnackBar('Failed to update profile. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _showImagePickerOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              if (_selectedImageFile != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedImageFile = null;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
        });
        // Image will be uploaded when user clicks Update button
      }
    } on PlatformException catch (e) {
      String errorMessage = 'Failed to pick image';
      if (e.code == 'photo_access_denied' || e.code == 'camera_access_denied') {
        errorMessage = 'Permission denied. Please grant camera/photo access in settings.';
      } else if (e.code == 'photo_picker_error') {
        errorMessage = 'Photo picker error. Please try again.';
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      if (mounted) {
        _showSnackBar(errorMessage);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to pick image: ${e.toString()}');
      }
    }
  }

  Future<void> _handleLogout() async {
    setState(() {
      _isLoggingOut = true;
    });

    final authRepository = ref.read(authRepositoryProvider);

    try {
      // TODO: Uncomment when backend logout API is fixed
      // await authRepository.logout();
      
      // Clear auth token from SharedPreferences (local storage) and memory
      await authRepository.clearAuthToken();
      // Clear cookies
      authRepository.clearCookies();
      
      // Reset all providers after logout
      ref.read(otpVerificationProvider.notifier).reset();
      ref.read(forgotPasswordProvider.notifier).reset();
      
      // Navigate to welcome screen
      if (mounted) {
        context.goNamed(ARouter.welcome);
      }
    } catch (_) {
      if (mounted) {
        _showSnackBar('Failed to logout. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ABackButton(),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Title
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Edit Profile',
                          style: textTheme.headlineMedium?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Profile Image
                      Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFFEC400),
                                width: 3,
                              ),
                              color: const Color(0xFFE3F2FD),
                            ),
                            child: _selectedImageFile != null
                                ? ClipOval(
                                    child: Image.file(
                                      _selectedImageFile!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                                    ? ClipOval(
                                        child: Image.network(
                                          AHelperFunction.getImageUrl(_profileImageUrl),
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(
                                              Icons.person,
                                              size: 60,
                                              color: const Color(0xFFFEC400),
                                            );
                                          },
                                        ),
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: 60,
                                        color: const Color(0xFFFEC400),
                                      ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _isUpdating ? null : _showImagePickerOptions,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFFEC400),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: _isUpdating
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.edit,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Name Field
                      PrimaryTextFormField(
                        hintText: 'Name',
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        validator: _validateName,
                      ),
                      const SizedBox(height: 20),
                      // Email Field
                      PrimaryTextFormField(
                        hintText: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 20),
                      // Phone Field
                      PhoneFormField(
                        phoneNumberController: _phoneNumberController,
                        phoneNumberValidator: _validatePhoneNumber,
                        selectedCountryCode: _selectedCountryCode,
                        onCountryChanged: (countryCode) {
                          setState(() {
                            _selectedCountryCode = countryCode;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      // Gender Field (Optional)
                      DropdownFormField(
                        hintText: 'Gender',
                        value: _selectedGender,
                        items: const [
                          DropdownMenuItem<String>(
                            value: 'male',
                            child: Text('Male'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'female',
                            child: Text('Female'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'other',
                            child: Text('Other'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      // Address Field (Optional)
                      PrimaryTextFormField(
                        hintText: 'Address',
                        controller: _streetController,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 20),
                      // City Field (Optional)
                      PrimaryTextFormField(
                        hintText: 'City',
                        controller: _cityController,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 20),
                      // District Field (Optional)
                      PrimaryTextFormField(
                        hintText: 'District',
                        controller: _districtController,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 40),
                      // Update Button
                      PrimaryButton(
                        text: 'Update',
                        isLoading: _isUpdating,
                        enabled: !_isUpdating,
                        onPressed: _handleUpdate,
                      ),
                      const SizedBox(height: 20),
                      // Logout Button
                      OutlinedButton(
                        onPressed: (_isUpdating || _isLoggingOut) ? null : _handleLogout,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'The name field is required.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'The email field is required.';
    }
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'The email field must be a valid email address.';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'The phone field is required.';
    }
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.isEmpty) {
      return 'The phone field format is invalid.';
    }
    return null;
  }
}
