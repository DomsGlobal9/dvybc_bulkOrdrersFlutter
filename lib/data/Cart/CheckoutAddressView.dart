import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CheckoutAddressView extends StatefulWidget {
  @override
  _CheckoutAddressViewState createState() => _CheckoutAddressViewState();
}

class _CheckoutAddressViewState extends State<CheckoutAddressView> {
  int selectedAddressIndex = 1; // Work address is pre-selected as shown in screenshot

  final List<Map<String, dynamic>> addresses = [
    {
      'type': 'Default',
      'name': 'Ravikumar',
      'address': '92-145/1A, Madura Nagar, Hyderabad, Telangana, 500054.',
      'isDefault': true,
    },
    {
      'type': 'Work',
      'name': 'Ravikumar',
      'address': '92-145/1A, Madura Nagar, Hyderabad, Telangana, 500054.',
      'isDefault': false,
    },
    {
      'type': 'Other',
      'name': 'Ravikumar',
      'address': '92-145/1A, Madura Nagar, Hyderabad, Telangana, 500054.',
      'isDefault': false,
    },
    {
      'type': 'Home',
      'name': 'Ravikumar',
      'address': '92-145/1A, Madura Nagar, Hyderabad, Telangana, 500054.',
      'isDefault': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black87,
            size: 24,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Checkout',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress Indicator with dashed lines
          _buildProgressIndicator(),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Default Address Section
                  if (addresses.isNotEmpty && addresses[0]['isDefault'])
                    _buildDefaultAddressSection(),

                  SizedBox(height: 24),

                  // Address List
                  ...addresses.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> address = entry.value;

                    if (address['isDefault']) return SizedBox.shrink();

                    return _buildAddressCard(address, index);
                  }).toList(),

                  SizedBox(height: 20),

                  // Add New Address Button
                  _buildAddNewAddressButton(),

                  SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),

          // Bottom Continue Button
          _buildBottomContinueButton(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
          _buildProgressStep(Icons.receipt_long, 'Review', false, true),
          _buildDashedLine(true),
          _buildProgressStep(Icons.location_on, 'Address', true, false),
          _buildDashedLine(false),
          _buildProgressStep(Icons.payment, 'Payment', false, false),
        ],
      ),
    );
  }

  Widget _buildProgressStep(IconData icon, String label, bool isActive, bool isCompleted) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? Color(0xFF094D77) : (isCompleted ? Color(0xFF094D77) : Colors.grey[300]),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: (isActive || isCompleted) ? Colors.white : Colors.grey[600],
            size: 20,
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? Color(0xFF094D77) : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDashedLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: EdgeInsets.only(bottom: 30),
        child: CustomPaint(
          painter: DashedLinePainter(
            color: isActive ? Color(0xFF094D77) : Colors.grey[300]!,
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAddressSection() {
    final defaultAddress = addresses.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Default Address',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),

        SizedBox(height: 16),

        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on,
                color: Color(0xFF094D77),
                size: 24,
              ),

              SizedBox(width: 12),

              Expanded(
                child: Text(
                  '${defaultAddress['name']} ${defaultAddress['address']}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),

              TextButton(
                onPressed: () {
                  // Edit address functionality
                },
                child: Text(
                  'Edit',
                  style: TextStyle(
                    color: Color(0xFF094D77),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> address, int index) {
    bool isSelected = selectedAddressIndex == index;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedAddressIndex = index;
          });
        },
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Color(0xFF094D77) : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Radio Button
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Color(0xFF094D77) : Colors.grey[400]!,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Color(0xFF094D77),
                      shape: BoxShape.circle,
                    ),
                  ),
                )
                    : null,
              ),

              SizedBox(width: 16),

              // Address Icon and Type
              Column(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Color(0xFF094D77),
                    size: 24,
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getAddressTypeColor(address['type']),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      address['type'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(width: 16),

              // Address Details
              Expanded(
                child: Text(
                  '${address['name']} ${address['address']}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getAddressTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'work':
        return Color(0xFF87CEEB); // Sky blue
      case 'home':
        return Color(0xFF87CEEB); // Sky blue
      case 'other':
        return Color(0xFF87CEEB); // Sky blue
      default:
        return Color(0xFF87CEEB);
    }
  }

  Widget _buildAddNewAddressButton() {
    return GestureDetector(
      onTap: () {
        // Add new address functionality
        _showAddAddressDialog();
      },
      child: Row(
        children: [
          Icon(
            Icons.add,
            color: Color(0xFF094D77),
            size: 24,
          ),
          SizedBox(width: 12),
          Text(
            'Add New Address',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF094D77),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAddressDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    String selectedType = 'Home';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Add New Address',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: addressController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: InputDecoration(
                  labelText: 'Address Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: ['Home', 'Work', 'Other'].map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setDialogState(() {
                    selectedType = newValue!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && addressController.text.isNotEmpty) {
                  setState(() {
                    addresses.add({
                      'type': selectedType,
                      'name': nameController.text,
                      'address': addressController.text,
                      'isDefault': false,
                    });
                  });
                  Navigator.of(context).pop();
                  Get.snackbar(
                    'Success',
                    'Address added successfully',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                }
              },
              child: Text(
                'Add',
                style: TextStyle(
                  color: Color(0xFF094D77),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomContinueButton() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Container(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            Get.toNamed('/checkout-payment');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF094D77),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'Continue',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter for dashed lines
class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;

    const dashWidth = 5;
    const dashSpace = 3;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}