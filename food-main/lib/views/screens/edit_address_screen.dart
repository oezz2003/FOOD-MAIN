import 'package:flutter/material.dart';
import 'package:healthy_food/config/constants.dart';
import 'package:healthy_food/services/firebase_service.dart';
import 'package:healthy_food/models/address.dart' as address_model;
import 'package:healthy_food/views/components/custom_text_field.dart';
import 'package:healthy_food/views/screens/custom_text_field.dart';

class EditAddressScreen extends StatefulWidget {
  final address_model.Address? address;
  const EditAddressScreen({super.key, this.address});

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  final FirebaseService _firebaseService = FirebaseService();

  final streetController = TextEditingController();
  final apartmentController = TextEditingController();
  final cityController = TextEditingController();
  final zipCodeController = TextEditingController();

  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));
    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));
    _controller.forward();
    _loadAddressData();
  }

  void _loadAddressData() {
    if (widget.address != null) {
      streetController.text = widget.address!.street;
      apartmentController.text = widget.address!.apartmentSuiteEtc;
      cityController.text = widget.address!.city;
      zipCodeController.text = widget.address!.zipCode;
      _isDefault = widget.address!.isDefault ?? false;
    }
  }

  Future<void> _saveAddress() async {
    setState(() => _isLoading = true);
    try {
      if (widget.address == null) {
        // Add new address
        final newAddress = address_model.Address(
          id: '', // Firestore will generate ID
          userId: FirebaseService.userId,
          street: streetController.text,
          apartmentSuiteEtc: apartmentController.text,
          city: cityController.text,
          zipCode: zipCodeController.text,
          isDefault: _isDefault,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(), apartmentSuiteEtptc: ' ',
        );
        await _firebaseService.addAddress(newAddress);
      } else {
        // Update existing address
        final updatedAddress = widget.address!.copyWith(
          street: streetController.text,
          apartmentSuiteEtc: apartmentController.text,
          city: cityController.text,
          zipCode: zipCodeController.text,
          isDefault: _isDefault,
          updatedAt: DateTime.now(),
        );
        await _firebaseService.updateAddress(updatedAddress.id, updatedAddress);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address saved successfully!')),
      );
      Navigator.pop(context, true); // Go back and indicate success
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error saving address: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    streetController.dispose();
    apartmentController.dispose();
    cityController.dispose();
    zipCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.address == null ? "Add New Address" : "Edit Address", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              kGradientStart.withOpacity(0.3),
              kGradientEnd.withOpacity(0.1),
            ],
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    CustomTextField(
                      controller: streetController,
                      hintText: "Street Address",
                      prefixIcon: Icons.location_on_outlined, keyboardType: TextInputType.streetAddress,
                    ),
                    SizedBox(height: 15),
                    CustomTextField(
                      controller: apartmentController,
                      hintText: "Apartment, Suite, etc.",
                      prefixIcon: Icons.apartment, keyboardType: TextInputType.text,
                    ),
                    SizedBox(height: 15),
                    CustomTextField(
                      controller: cityController,
                      hintText: "City",
                      prefixIcon: Icons.location_city, keyboardType: TextInputType.text,
                    ),
                    SizedBox(height: 15),
                    CustomTextField(
                      controller: zipCodeController,
                      hintText: "Zip / Postal Code",
                      prefixIcon: Icons.markunread_mailbox,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 20),
                    SwitchListTile(
                      title: Text(
                        'Set as Default Address',
                        style: TextStyle(color: Colors.black87, fontSize: 16),
                      ),
                      value: _isDefault,
                      onChanged: (bool value) {
                        setState(() {
                          _isDefault = value;
                        });
                      },
                      activeColor: Colors.green,
                    ),
                    SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveAddress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      icon: Icon(Icons.save),
                      label: Text(
                        widget.address == null ? 'Add Address' : 'Save Changes',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}