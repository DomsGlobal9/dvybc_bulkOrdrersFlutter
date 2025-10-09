import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../views/Widgets/CustomDVYBAppBarWithBack.dart';

class Address {
  String type;
  String fullName;
  String mobileNumber;
  String pinCode;
  String addressLine;
  String city;
  String state;
  String? landmark;
  Address({required this.type, required this.fullName, required this.mobileNumber, required this.pinCode, required this.addressLine, required this.city, required this.state, this.landmark});
}

class CheckoutAddressView extends StatefulWidget {
  @override
  _CheckoutAddressViewState createState() => _CheckoutAddressViewState();
}

class _CheckoutAddressViewState extends State<CheckoutAddressView> {
  int? selectedAddressIndex = 0;
  List<Address> addresses = [
    Address(type: 'Work', fullName: 'Ravikumar', mobileNumber: '9876543210', pinCode: '500054', addressLine: '92-145/1A, Madura Nagar', city: 'Hyderabad', state: 'Telangana', landmark: 'Near Apollo Hospital'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomDVYBAppBar(
      ),
      body: Column(
        children: [
          // STICKY Progress Indicator
          _buildProgressIndicator(),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Address', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  SizedBox(height: 20),
                  ...addresses.asMap().entries.map((entry) => _buildAddressCard(entry.value, entry.key)),
                  SizedBox(height: 16),
                  _buildAddNewAddressButton(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomContinueButton(),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      color: Colors.white,
      child: Row(
        children: [
          _buildProgressStep('Review', true, true),
          _buildDashedLine(true),
          _buildProgressStep('Address', true, false),
          _buildDashedLine(false),
          _buildProgressStep('Payment', false, false),
        ],
      ),
    );
  }

  void _updateAddress(Address address, int index) {
    setState(() => addresses[index] = address);
    Get.back(); // Close dialog
  }

  void _addAddress(Address address) {
    setState(() {
      addresses.add(address);
      selectedAddressIndex = addresses.length - 1;
    });
    Get.back(); // Close dialog
  }

  void _deleteAddress(int index) {
    setState(() {
      addresses.removeAt(index);
      if (selectedAddressIndex == index) {
        selectedAddressIndex = addresses.isNotEmpty ? 0 : null;
      } else if (selectedAddressIndex != null && selectedAddressIndex! > index) {
        selectedAddressIndex = selectedAddressIndex! - 1;
      }
    });
    Get.back(); // Close dialog
  }

  Widget _buildAddressCard(Address address, int index) {
    bool isSelected = selectedAddressIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedAddressIndex = index),
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Color(0xFF187DBD) : Color(0xFFE0E0E0), width: isSelected ? 2 : 1),
        ),
        child: Column(
          children: [
            Row(children: [
              Radio<int>(value: index, groupValue: selectedAddressIndex, onChanged: (v) => setState(() => selectedAddressIndex = v), activeColor: Color(0xFF187DBD)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Color(0xFFD5EFFF), borderRadius: BorderRadius.circular(6)),
                child: Text(address.type, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF187DBD))),
              ),
              Spacer(),
              TextButton(
                onPressed: () => _showAddressDialog(address: address, index: index),
                child: Text('Edit', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF187DBD))),
              ),
            ]),
            SizedBox(height: 12),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(address.fullName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    SizedBox(height: 4),
                    Text('${address.addressLine}, ${address.city}, ${address.state} - ${address.pinCode}.', style: TextStyle(color: Colors.grey[700], height: 1.5)),
                    if (address.landmark != null && address.landmark!.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Text('Landmark: ${address.landmark}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ],
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildAddNewAddressButton() {
    return GestureDetector(
      onTap: () => _showAddressDialog(),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFF187DBD), width: 1.5),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.add, color: Color(0xFF187DBD), size: 24),
          SizedBox(width: 8),
          Text('Add New Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF187DBD))),
        ]),
      ),
    );
  }

  void _showAddressDialog({Address? address, int? index}) {
    showDialog(context: context, builder: (context) => AddressFormDialog(
      address: address,
      onSave: (newAddress) {
        if (index != null) {
          _updateAddress(newAddress, index);
        } else {
          _addAddress(newAddress);
        }
      },
      onDelete: index != null ? () => _deleteAddress(index) : null,
    ));
  }

  Widget _buildBottomContinueButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 10, offset: Offset(0, -5))
        ],
      ),
      child: Container(
        width: 333,
        height: 44,
        child: ElevatedButton(
          onPressed: selectedAddressIndex != null ? () => Get.toNamed('/checkout-payment') : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF187DBD),
            disabledBackgroundColor: Colors.grey[400],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: Text('Continue', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _buildProgressStep(String label, bool isActive, bool isCompleted) {
    IconData icon = Icons.location_on;
    if (label == 'Review') icon = Icons.receipt_long;
    if (label == 'Payment') icon = Icons.payment;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? Color(0xFF187DBD) : Color(0xFFD9D9D9),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 14, fontWeight: isActive ? FontWeight.w600 : FontWeight.normal, color: isActive ? Color(0xFF187DBD) : Color(0xFF666666))),
      ],
    );
  }

  Widget _buildDashedLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: EdgeInsets.only(bottom: 30, left: 4, right: 4),
        color: isActive ? Color(0xFF187DBD) : Color(0xFFD9D9D9),
      ),
    );
  }
}


// DIALOG FOR ADDING/EDITING ADDRESS
class AddressFormDialog extends StatefulWidget {
  final Address? address;
  final Function(Address) onSave;
  final VoidCallback? onDelete;

  AddressFormDialog({this.address, required this.onSave, this.onDelete});

  @override
  _AddressFormDialogState createState() => _AddressFormDialogState();
}

class _AddressFormDialogState extends State<AddressFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  late TextEditingController _fullName, _mobile, _pincode, _addressLine, _city, _state, _landmark;

  @override
  void initState() {
    super.initState();
    _type = widget.address?.type ?? 'Home';
    _fullName = TextEditingController(text: widget.address?.fullName);
    _mobile = TextEditingController(text: widget.address?.mobileNumber);
    _pincode = TextEditingController(text: widget.address?.pinCode);
    _addressLine = TextEditingController(text: widget.address?.addressLine);
    _city = TextEditingController(text: widget.address?.city);
    _state = TextEditingController(text: widget.address?.state);
    _landmark = TextEditingController(text: widget.address?.landmark);
  }

  @override
  void dispose() {
    _fullName.dispose(); _mobile.dispose(); _pincode.dispose(); _addressLine.dispose(); _city.dispose(); _state.dispose(); _landmark.dispose();
    super.dispose();
  }

  void _onSavePressed() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(Address(
        type: _type,
        fullName: _fullName.text,
        mobileNumber: _mobile.text,
        pinCode: _pincode.text,
        addressLine: _addressLine.text,
        city: _city.text,
        state: _state.text,
        landmark: _landmark.text,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.address == null ? 'Add New Address' : 'Edit Address', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                    if (widget.onDelete != null)
                      IconButton(icon: Icon(Icons.delete_outline, color: Colors.red), onPressed: widget.onDelete),
                  ],
                ),
                SizedBox(height: 20),
                Text('Address Type'),
                SizedBox(height: 8),
                Row(children: ['Home', 'Work', 'Other'].map((t) => Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _type = t),
                    child: Container(
                      margin: EdgeInsets.only(right: t == 'Other' ? 0 : 8),
                      padding: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _type == t ? Color(0xFF187DBD) : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(t, textAlign: TextAlign.center, style: TextStyle(color: _type == t ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
                    ),
                  ),
                )).toList()),
                SizedBox(height: 16),
                _buildTextFormField(_fullName, 'Full Name *', validator: (v) => v!.isEmpty ? 'Required' : null),
                SizedBox(height: 16),
                _buildTextFormField(_mobile, 'Mobile Number *', keyboardType: TextInputType.phone, maxLength: 10, validator: (v) => v!.length != 10 ? 'Enter valid number' : null),
                SizedBox(height: 16),
                _buildTextFormField(_pincode, 'Pin Code *', keyboardType: TextInputType.number, maxLength: 6, validator: (v) => v!.length != 6 ? 'Enter valid pin code' : null),
                SizedBox(height: 16),
                _buildTextFormField(_addressLine, 'Address (House No, Building, Street) *', maxLines: 2, validator: (v) => v!.isEmpty ? 'Required' : null),
                SizedBox(height: 16),
                _buildTextFormField(_city, 'City / Town *', validator: (v) => v!.isEmpty ? 'Required' : null),
                SizedBox(height: 16),
                _buildTextFormField(_state, 'State *', validator: (v) => v!.isEmpty ? 'Required' : null),
                SizedBox(height: 16),
                _buildTextFormField(_landmark, 'Landmark (Nearby location)'),
                SizedBox(height: 24),
                Row(children: [
                  Expanded(child: TextButton(onPressed: () => Get.back(), child: Text('Cancel'))),
                  SizedBox(width: 12),
                  Expanded(child: ElevatedButton(onPressed: _onSavePressed, child: Text('Save'), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF187DBD), foregroundColor: Colors.white))),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String label, {int? maxLength, int? maxLines = 1, TextInputType? keyboardType, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), counterText: ''),
      maxLength: maxLength, maxLines: maxLines, keyboardType: keyboardType, validator: validator,
    );
  }
}