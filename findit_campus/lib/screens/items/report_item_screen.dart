import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/item_provider.dart';
import '../../models/item_model.dart';
import '../../config/theme.dart';

class ReportItemScreen extends StatefulWidget {
  const ReportItemScreen({super.key});

  @override
  State<ReportItemScreen> createState() => _ReportItemScreenState();
}

class _ReportItemScreenState extends State<ReportItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _securityQuestionController = TextEditingController();
  final _securityAnswerController = TextEditingController();

  String _type = 'lost';
  String _category = '';
  List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  final List<String> _categories = [
    'Wallet',
    'ID Card',
    'Phone',
    'Bottle',
    'Earphones',
    'Bag',
    'Keys',
    'Electronics',
    'Clothing',
    'Documents',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _securityQuestionController.dispose();
    _securityAnswerController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage(
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _images.addAll(pickedFiles.map((f) => File(f.path)));
        if (_images.length > 3) _images = _images.sublist(0, 3);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final location = ItemLocation(
      building: '',
      floor: '',
      room: '',
      description: _locationController.text.trim(),
    );

    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    final success = await itemProvider.reportItem(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category.isEmpty ? 'Other' : _category,
      type: _type,
      date: DateTime.now(),
      location: location,
      tags: [],
      color: '',
      brand: '',
      securityQuestion: _type == 'found' ? _securityQuestionController.text.trim() : null,
      securityAnswer: _type == 'found' ? _securityAnswerController.text.trim() : null,
      images: _images,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_type == 'lost' ? 'Lost' : 'Found'} item reported successfully!',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            itemProvider.error ?? 'Failed to report item',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Report Item',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // TYPE TOGGLE
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        _ToggleOption(
                          label: 'Lost Item',
                          isSelected: _type == 'lost',
                          onTap: () => setState(() => _type = 'lost'),
                        ),
                        _ToggleOption(
                          label: 'Found Item',
                          isSelected: _type == 'found',
                          onTap: () => setState(() => _type = 'found'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  _buildLabel('ITEM TITLE'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _titleController,
                    hint: 'e.g. Silver Water Bottle',
                    validator: (val) => val == null || val.isEmpty ? 'Title is required' : null,
                  ),

                  const SizedBox(height: 20),

                  _buildLabel('CATEGORY'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _category.isEmpty ? null : _category,
                        isExpanded: true,
                        hint: const Text('Select a category', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                        dropdownColor: AppColors.surface,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                        items: _categories.map((cat) {
                          return DropdownMenuItem(value: cat, child: Text(cat));
                        }).toList(),
                        onChanged: (val) => setState(() => _category = val!),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildLabel('LOCATION'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _locationController,
                    hint: 'e.g. Main Library, 2nd Floor',
                    prefixIcon: Icons.location_on_rounded,
                  ),

                  const SizedBox(height: 20),

                  _buildLabel('DESCRIPTION'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _descriptionController,
                    hint: 'Color, brand, unique marks...',
                    maxLines: 4,
                    validator: (val) => val == null || val.isEmpty ? 'Description is required' : null,
                  ),

                  if (_type == 'found') ...[
                    const SizedBox(height: 24),
                    // SECURITY VERIFICATION SECTION
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Security Verification',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'This helps verify the real owner. It will never be shown publicly.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('YOUR QUESTION'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _securityQuestionController,
                            hint: 'e.g. What color is the phone case?',
                            validator: (val) => _type == 'found' && (val == null || val.isEmpty) ? 'Question is required' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('EXPECTED ANSWER'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _securityAnswerController,
                            hint: 'e.g. Dark Blue',
                            validator: (val) => _type == 'found' && (val == null || val.isEmpty) ? 'Answer is required' : null,
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  _buildLabel('IMAGES (Max 3)'),
                  const SizedBox(height: 8),
                  _buildUploadArea(),

                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: Provider.of<ItemProvider>(context).isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 54),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Provider.of<ItemProvider>(context).isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('Submit ${_type.toUpperCase()} Report'),
                  ),

                  const SizedBox(height: 32),

                // ── Community Safety Tip ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFBBDEFB)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.shield_outlined,
                          color: Color(0xFF1976D2), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Community Safety Tip',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1976D2),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Meet in a public, well-lit place for the handover. Never share sensitive personal info. Use the in-app QR system for secure verification.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF1976D2).withOpacity(0.8),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    IconData? prefixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.primary, size: 20) : null,
      ),
    );
  }

  Widget _buildUploadArea() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ..._images.asMap().entries.map((entry) {
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(entry.value, width: 80, height: 80, fit: BoxFit.cover),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => setState(() => _images.removeAt(entry.key)),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                    child: const Icon(Icons.close, size: 12, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        }),
        if (_images.length < 3)
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5, style: BorderStyle.solid),
              ),
              child: const Icon(Icons.add_a_photo_rounded, color: AppColors.primary),
            ),
          ),
      ],
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleOption({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
