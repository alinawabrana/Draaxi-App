import 'package:draaxi/src/features/authentication/providers/auth_providers.dart';
import 'package:draaxi/src/router/router.dart';
import 'package:draaxi/utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends ConsumerStatefulWidget {
  const AppDrawer({super.key});

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {
  String? _profileImageUrl;
  String? _userName;
  String? _userEmail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
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

      if (user != null && mounted) {
        final userName = user['name'] as String? ?? '';
        final userEmail = user['email'] as String? ?? '';
        final riderProfile = user['rider_profile'] as Map<String, dynamic>?;
        final profileImageUrl = riderProfile?['profile_image'] as String?;

        setState(() {
          _userName = userName;
          _userEmail = userEmail;
          _profileImageUrl = profileImageUrl;
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleLogout() async {
    final authRepository = ref.read(authRepositoryProvider);

    try {
      await authRepository.clearAuthToken();
      authRepository.clearCookies();

      // Reset all providers after logout
      ref.read(otpVerificationProvider.notifier).reset();
      ref.read(forgotPasswordProvider.notifier).reset();

      // Navigate to welcome screen
      if (mounted) {
        Navigator.pop(context); // Close drawer first
        context.goNamed(ARouter.welcome);
      }
    } catch (_) {
      // Handle error silently or show snackbar
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      width: 250,
      backgroundColor: isDark ? const Color(0xFF1F212A) : Colors.white,
      elevation: isDark ? 21 : 0,
      shadowColor: isDark ? Colors.white.withOpacity(0.25) : null,
      child: Container(
        decoration: isDark
            ? BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.25),
                    offset: const Offset(0, 4),
                    blurRadius: 21,
                    spreadRadius: 0,
                  ),
                ],
              )
            : null,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 15),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_back_ios,
                        size: 14.4,
                        color: isDark ? Colors.white : const Color(0xFF414141),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: isDark ? Colors.white : const Color(0xFF414141),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 27),

              // Profile picture
              Center(
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFD9D9D9),
                    border: Border.all(
                      color: const Color(0xFFFEC400),
                      width: 1,
                    ),
                  ),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
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
                                    size: 40,
                                    color: isDark ? Colors.white : const Color(0xFF414141),
                                  );
                                },
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 40,
                              color: isDark ? Colors.white : const Color(0xFF414141),
                            ),
                ),
              ),

              const SizedBox(height: 18),

              // Name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  _userName ?? 'User',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    height: 25 / 18,
                    color: isDark ? Colors.white : const Color(0xFF414141),
                    fontFamily: 'Poppins',
                  ),
                ),
              ),

              // Email
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  _userEmail ?? 'email@example.com',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 18 / 12,
                    color: isDark ? Colors.white : const Color(0xFF414141),
                    fontFamily: 'Poppins',
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Menu items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.person_outline,
                      title: 'Edit Profile',
                      onTap: () {
                        Navigator.pop(context);
                        context.pushNamed(ARouter.profile);
                      },
                      isDark: isDark,
                    ),
                    _buildDivider(isDark),
                    _buildMenuItem(
                      context,
                      icon: Icons.location_on_outlined,
                      title: 'Address',
                      onTap: () {
                        Navigator.pop(context);
                        context.pushNamed(ARouter.address);
                      },
                      isDark: isDark,
                    ),
                    _buildDivider(isDark),
                    _buildMenuItem(
                      context,
                      icon: Icons.history,
                      title: 'History',
                      onTap: () {
                        Navigator.pop(context);
                        context.pushNamed(ARouter.history);
                      },
                      isDark: isDark,
                    ),
                    _buildDivider(isDark),
                    _buildMenuItem(
                      context,
                      icon: Icons.info_outline,
                      title: 'Complaints',
                      onTap: () {
                        Navigator.pop(context);
                        context.pushNamed(ARouter.complaints);
                      },
                      isDark: isDark,
                    ),
                    _buildDivider(isDark),
                    _buildMenuItem(
                      context,
                      icon: Icons.people_outline,
                      title: 'Referral',
                      onTap: () {
                        Navigator.pop(context);
                        context.pushNamed(ARouter.referral);
                      },
                      isDark: isDark,
                    ),
                    _buildDivider(isDark),
                    _buildMenuItem(
                      context,
                      icon: Icons.info_outline,
                      title: 'About Us',
                      onTap: () {
                        Navigator.pop(context);
                        context.pushNamed(ARouter.aboutUs);
                      },
                      isDark: isDark,
                    ),
                    _buildDivider(isDark),
                    _buildMenuItem(
                      context,
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Navigate to settings screen
                      },
                      isDark: isDark,
                    ),
                    _buildDivider(isDark),
                    _buildMenuItem(
                      context,
                      icon: Icons.help_outline,
                      title: 'Help and Support',
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Navigate to help screen
                      },
                      isDark: isDark,
                    ),
                    _buildDivider(isDark),
                    _buildMenuItem(
                      context,
                      icon: Icons.logout,
                      title: 'Logout',
                      onTap: _handleLogout,
                      isDark: isDark,
                    ),
                    // No divider after logout
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      leading: Icon(
        icon,
        size: 16,
        color: isDark ? Colors.white : const Color(0xFF414141),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 16 / 12,
          color: isDark ? Colors.white : const Color(0xFF414141),
          fontFamily: 'Poppins',
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? const Color(0xFFF7F7F7) : const Color(0xFFE8E8E8),
      indent: 15,
      endIndent: 15,
    );
  }
}

