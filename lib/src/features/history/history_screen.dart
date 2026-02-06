import 'package:draaxi/utils/constant/texts.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedCategory = 0; // 0: Upcoming, 1: Completed, 2: Cancelled

  // Static history data
  final List<Map<String, dynamic>> _upcomingHistory = [
    {'name': 'Nate', 'location': 'Mustang Shelby GT', 'date': 'Today at 09:20 am'},
    {'name': 'Henry', 'location': 'Mustang Shelby GT', 'date': 'Today at 10:20 am'},
    {'name': 'Willam', 'location': 'Mustang Shelby GT', 'date': 'Tomorrow at 09:20 am'},
    {'name': 'Nate', 'location': 'Mustang Shelby GT', 'date': 'Today at 09:20 am'},
    {'name': 'Henry', 'location': 'Mustang Shelby GT', 'date': 'Today at 10:20 am'},
    {'name': 'Willam', 'location': 'Mustang Shelby GT', 'date': 'Tomorrow at 09:20 am'},
    {'name': 'Henry', 'location': 'Mustang Shelby GT', 'date': 'Today at 10:20 am'},
    {'name': 'Willam', 'location': 'Mustang Shelby GT', 'date': 'Tomorrow at 09:20 am'},
  ];

  final List<Map<String, dynamic>> _completedHistory = [
    {'name': 'Nate', 'location': 'Mustang Shelby GT'},
    {'name': 'Henry', 'location': 'Mustang Shelby GT'},
    {'name': 'Willam', 'location': 'Mustang Shelby GT'},
    {'name': 'Nate', 'location': 'Mustang Shelby GT'},
    {'name': 'Henry', 'location': 'Mustang Shelby GT'},
  ];

  final List<Map<String, dynamic>> _cancelledHistory = [
    {'name': 'Nate', 'location': 'Mustang Shelby GT'},
    {'name': 'Henry', 'location': 'Mustang Shelby GT'},
    {'name': 'Willam', 'location': 'Mustang Shelby GT'},
    {'name': 'Nate', 'location': 'Mustang Shelby GT'},
  ];

  List<Map<String, dynamic>> get _currentHistory {
    switch (_selectedCategory) {
      case 0:
        return _upcomingHistory;
      case 1:
        return _completedHistory;
      case 2:
        return _cancelledHistory;
      default:
        return _upcomingHistory;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top navigation bar
              _buildTopBar(isDark),
              
              const SizedBox(height: 30),
              
              // Category selection badges
              _buildCategoryBadges(isDark),
              
              const SizedBox(height: 30),
              
              // History cards list
              Expanded(
                child: ListView.separated(
                  itemCount: _currentHistory.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return _buildHistoryCard(
                      _currentHistory[index],
                      isDark,
                      _selectedCategory,
                    );
                  },
                ),
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
          'History',
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

  Widget _buildCategoryBadges(bool isDark) {
    final categories = ['Upcoming', 'Completed', 'Cancelled'];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        categories.length,
        (index) {
          final isSelected = _selectedCategory == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = index;
                });
              },
              child: Container(
                width: 115,
                height: 48,
                margin: EdgeInsets.only(
                  right: index < categories.length - 1 ? 12 : 0,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFEC400)
                      : (isDark ? const Color(0xFF35383F) : const Color(0xFFFFFBE7)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    categories[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white : const Color(0xFF5A5A5A)),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(
    Map<String, dynamic> history,
    bool isDark,
    int category,
  ) {
    String statusText;
    Color statusColor;
    
    if (category == 0) {
      // Upcoming
      statusText = history['date'] as String;
      statusColor = isDark ? const Color(0xFFD0D0D0) : const Color(0xFF414141);
    } else if (category == 1) {
      // Completed
      statusText = 'Done';
      statusColor = isDark ? const Color(0xFFD0D0D0) : const Color(0xFF43A048);
    } else {
      // Cancelled
      statusText = 'Cancel';
      statusColor = isDark ? const Color(0xFFD0D0D0) : const Color(0xFFD32F2F);
    }

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFFEC400),
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          // Name and location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Name
                Text(
                  history['name'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : const Color(0xFF414141),
                    fontFamily: 'Poppins',
                  ),
                ),
                
                const SizedBox(height: 2),
                
                // Location
                Text(
                  history['location'] as String,
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
          
          // Status text (date/time, Done, or Cancel)
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 18 / 12,
              color: statusColor,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

