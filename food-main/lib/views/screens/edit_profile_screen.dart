import 'dart:io';
import 'package:flutter/material.dart';
import 'package:healthy_food/views/screens/custom_text_field.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:healthy_food/config/constants.dart';
import 'package:healthy_food/services/firebase_service.dart';
import 'package:healthy_food/views/components/custom_text_field.dart'; // استيراد CustomTextField
import 'package:healthy_food/config/navigator.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String? _imagePath;
  String? _imageUrl;
  final ImagePicker _picker = ImagePicker();
  final FirebaseService _firebaseService = FirebaseService();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final ageController = TextEditingController();
  final birthdayController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final genderController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = await _firebaseService.getUserProfile();
      if (user != null) {
        nameController.text = user.name;
        emailController.text = user.email;
        phoneController.text = user.phoneNumber ?? '';
        ageController.text = user.age.toString();
        birthdayController.text = user.birthday != null
            ? DateFormat('yyyy-MM-dd').format(user.birthday!)
            : '';
        heightController.text = user.height.toString();
        weightController.text = user.weight.toString();
        genderController.text = user.gender;
        _imageUrl = user.imageUrl;
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _imagePath = image.path);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      String? finalImageUrl = _imageUrl;
      if (_imagePath != null) {
        finalImageUrl = await _firebaseService.uploadImage(_imagePath!);
      }
      await _firebaseService.updateUserProfile(
        userId: FirebaseService.userId,
        name: nameController.text,
        email: emailController.text,
        phoneNumber: phoneController.text,
        age: int.tryParse(ageController.text),
        birthday: birthdayController.text.isNotEmpty
            ? DateTime.tryParse(birthdayController.text)
            : null,
        height: double.tryParse(heightController.text),
        weight: double.tryParse(weightController.text),
        gender: genderController.text,
        imageUrl: finalImageUrl,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error saving profile: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      birthdayController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _showGenderOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.male),
              title: Text("Male"),
              onTap: () {
                setState(() {
                  genderController.text = "Male";
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.female),
              title: Text("Female"),
              onTap: () {
                setState(() {
                  genderController.text = "Female";
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    ageController.dispose();
    birthdayController.dispose();
    heightController.dispose();
    weightController.dispose();
    genderController.dispose();
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
        title: Text("Edit Profile", style: TextStyle(color: Colors.black)),
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
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 65,
                            backgroundColor: Colors.white,
                            backgroundImage: _imagePath != null
                                ? FileImage(File(_imagePath!))
                                : (_imageUrl != null && _imageUrl!.isNotEmpty)
                                    ? NetworkImage(_imageUrl!) as ImageProvider
                                    : AssetImage("assets/images/avatar.png"),
                            child: _imagePath == null && (_imageUrl == null || _imageUrl!.isEmpty)
                                ? Icon(Icons.person, size: 70, color: Colors.grey[400])
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Icon(Icons.edit, color: Colors.white, size: 16),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      controller: nameController,
                      hintText: "Full Name",
                      prefixIcon: Icons.person_outline, keyboardType: 
                      TextInputType.name,
                    ),
                    SizedBox(height: 15),
                    CustomTextField(
                      controller: emailController,
                      hintText: "Email",
                      prefixIcon: Icons.email_outlined,
                      enabled: false, keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 15),
                    CustomTextField(
                      controller: phoneController,
                      hintText: "Phone Number",
                      prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: ageController,
                            hintText: "Age",
                            prefixIcon: Icons.calendar_today_outlined, keyboardType:  TextInputType.number,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            controller: birthdayController,
                            hintText: "Birthday",
                            prefixIcon: Icons.cake_outlined,
                            readOnly: true,
                            onTap: () => _selectDate(context), keyboardType: TextInputType.datetime,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: heightController,
                            hintText: "Height (cm)",
                            prefixIcon: Icons.height, keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            controller: weightController,
                            hintText: "Weight (kg)",
                            prefixIcon: Icons.monitor_weight, keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    CustomTextField(
                      controller: genderController,
                      hintText: "Gender",
                      prefixIcon: Icons.person_search,
                      readOnly: true,
                      onTap: () => _showGenderOptions(context), keyboardType: TextInputType.text,
                    ),
                    SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      icon: Icon(Icons.save),
                      label: Text("Save Changes", style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}