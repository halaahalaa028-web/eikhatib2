import 'dart:io';
import 'package:eikhatib/core/theme/colors.dart';
import 'package:eikhatib/features/auth/logic/user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/routes/routes.dart';

class DriverDocsUploadScreen extends StatefulWidget {
  const DriverDocsUploadScreen({super.key});

  @override
  State<DriverDocsUploadScreen> createState() => _DriverDocsUploadScreenState();
}

class _DriverDocsUploadScreenState extends State<DriverDocsUploadScreen> {
  File? _idFront;
  File? _idBack;
  File? _licenseFront;
  File? _licenseBack;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(String type) async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() {
        switch (type) {
          case 'id_front': _idFront = File(pickedFile.path); break;
          case 'id_back': _idBack = File(pickedFile.path); break;
          case 'license_front': _licenseFront = File(pickedFile.path); break;
          case 'license_back': _licenseBack = File(pickedFile.path); break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, UserState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }
        if (state.status == 'pending_approval' || (state.user != null && !state.user!.isApproved)) {
          Navigator.pushNamedAndRemoveUntil(
            context, 
            Routes.waitingApproval, 
            (route) => false,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text('توثيق بيانات السائق', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'خطوة أخيرة لتفعيل حسابك',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Text(
                  'يرجى رفع صور واضحة لوجه وظهر كل من البطاقة الشخصية ورخصة القيادة.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 32),
                
                _buildSectionTitle('البطاقة الشخصية'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildUploadBox(
                        title: 'الوجه الأمامي',
                        image: _idFront,
                        onTap: () => _pickImage('id_front'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildUploadBox(
                        title: 'الوجه الخلفي',
                        image: _idBack,
                        onTap: () => _pickImage('id_back'),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                _buildSectionTitle('رخصة القيادة'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildUploadBox(
                        title: 'الوجه الأمامي',
                        image: _licenseFront,
                        onTap: () => _pickImage('license_front'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildUploadBox(
                        title: 'الوجه الخلفي',
                        image: _licenseBack,
                        onTap: () => _pickImage('license_back'),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 48),
                
                ElevatedButton(
                  onPressed: (_idFront != null && _idBack != null && _licenseFront != null && _licenseBack != null && !state.isLoading)
                      ? () {
                          context.read<UserCubit>().uploadDriverDocuments(
                            idFront: _idFront!,
                            idBack: _idBack!,
                            licenseFront: _licenseFront!,
                            licenseBack: _licenseBack!,
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: state.isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'إرسال للمراجعة',
                        style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.primary),
    );
  }

  Widget _buildUploadBox({required String title, File? image, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200, width: 2),
            ),
            child: image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(image, fit: BoxFit.cover, width: double.infinity),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, size: 30, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text('رفع الصورة', style: GoogleFonts.tajawal(color: Colors.grey.shade400, fontSize: 12)),
                      ],
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(title, style: GoogleFonts.tajawal(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black54)),
      ],
    );
  }
}
