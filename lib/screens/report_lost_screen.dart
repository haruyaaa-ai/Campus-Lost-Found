import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../constants/constants.dart';
import '../models/item.dart';
import '../providers/item_provider.dart';
import '../widgets/buttons.dart';

class ReportLostScreen extends StatefulWidget {
  const ReportLostScreen({Key? key}) : super(key: key);

  @override
  State<ReportLostScreen> createState() => _ReportLostScreenState();
}

class _ReportLostScreenState extends State<ReportLostScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _reporterNameController;
  late TextEditingController _reporterEmailController;
  late TextEditingController _reporterPhoneController;
  late TextEditingController _locationDetailController;

  String? _selectedCategory;
  String? _selectedLocation;
  DateTime? _selectedDate;
  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _reporterNameController = TextEditingController();
    _reporterEmailController = TextEditingController();
    _reporterPhoneController = TextEditingController();
    _locationDetailController = TextEditingController();
    
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      _reporterEmailController.text = user.email!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _reporterNameController.dispose();
    _reporterEmailController.dispose();
    _reporterPhoneController.dispose();
    _locationDetailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        title: const Text(
          'Laporkan Barang Hilang',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Input
                  _buildTextField(
                  controller: _titleController,
                  label: 'Nama Barang',
                  hint: 'Contoh: Laptop Asus VivoBook',
                  icon: Icons.shopping_bag,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Nama barang harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Image Picker
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.borderColor),
                      image: _selectedImage != null
                          ? DecorationImage(
                              image: FileImage(_selectedImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _selectedImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.add_a_photo,
                                size: 48,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(height: AppSpacing.sm),
                              Text(
                                'Tambah Foto Barang',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '(Maksimal 800KB)',
                                style: TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
                if (_selectedImage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: TextButton.icon(
                      onPressed: () => setState(() => _selectedImage = null),
                      icon: const Icon(Icons.delete, color: AppColors.errorColor),
                      label: const Text(
                        'Hapus Foto',
                        style: TextStyle(color: AppColors.errorColor),
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),

                // Category Dropdown
                _buildDropdown(
                  label: 'Kategori',
                  value: _selectedCategory,
                  items: categories,
                  icon: Icons.category,
                  onChanged: (value) {
                    setState(() => _selectedCategory = value);
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Kategori harus dipilih';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Location Dropdown
                _buildDropdown(
                  label: 'Lokasi Terakhir Dilihat',
                  value: _selectedLocation,
                  items: locations,
                  icon: Icons.location_on,
                  onChanged: (value) {
                    setState(() => _selectedLocation = value);
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Lokasi harus dipilih';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Location Detail
                _buildTextField(
                  controller: _locationDetailController,
                  label: 'Detail Lokasi',
                  hint: 'Contoh: Di meja pojok lantai 2 atau dekat pot bunga',
                  icon: Icons.map_outlined,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Detail lokasi harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Date Picker
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(Duration(days: 30)),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _selectedDate = date);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderColor),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: AppColors.primaryColor,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tanggal Hilang',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                              Text(
                                _selectedDate != null
                                    ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                    : 'Pilih tanggal',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Description
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Deskripsi Detail',
                  hint: 'Jelaskan ciri-ciri barang, warna, kondisi, dll',
                  icon: Icons.description,
                  maxLines: 4,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Deskripsi harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Divider
                const Divider(color: AppColors.borderColor),
                const SizedBox(height: AppSpacing.lg),

                // Reporter Info Section
                const Text(
                  'Informasi Pelapor',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                _buildTextField(
                  controller: _reporterNameController,
                  label: 'Nama Lengkap',
                  hint: 'Masukkan nama Anda',
                  icon: Icons.person,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Nama harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                _buildTextField(
                  controller: _reporterEmailController,
                  label: 'Email',
                  hint: 'Contoh: anda@email.com',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Email harus diisi';
                    }
                    if (!value!.contains('@')) {
                      return 'Email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                _buildTextField(
                  controller: _reporterPhoneController,
                  label: 'Nomor Telepon',
                  hint: '08xxxxxxxxxx',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Nomor telepon harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.xl),

                // Submit Button
                PrimaryButton(
                  label: 'Laporkan Barang Hilang',
                  isLoading: _isLoading,
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      if (_selectedDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tanggal hilang harus dipilih'),
                          ),
                        );
                        return;
                      }

                      setState(() => _isLoading = true);

                      try {
                        final newItem = Item(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: _titleController.text,
                          description: _descriptionController.text,
                          type: ItemType.lost,
                          status: ItemStatus.open,
                          category: _selectedCategory!,
                          dateReported: DateTime.now(),
                          dateLost: _selectedDate,
                          location: _selectedLocation!,
                          reporterName: _reporterNameController.text,
                          reporterEmail: _reporterEmailController.text,
                          reporterPhone: _reporterPhoneController.text,
                          locationDetail: _locationDetailController.text,
                          imageUrls: _selectedImage != null
                              ? [_selectedImage!.path]
                              : [],
                        );

                        await Provider.of<ItemProvider>(
                          context,
                          listen: false,
                        ).addItem(newItem, _selectedImage);

                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Barang hilang berhasil dilaporkan!'),
                            backgroundColor: AppColors.successColor,
                          ),
                        );

                        _resetForm();
                        Navigator.of(context).pop(); // Go back to Home
                      } catch (e) {
                         if (!mounted) return;
                         ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gagal melaporkan: $e'),
                            backgroundColor: AppColors.errorColor,
                          ),
                        );
                      } finally {
                        if (mounted) {
                          setState(() => _isLoading = false);
                        }
                      }
                    }
                  },
                ),

                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _descriptionController.clear();
    _reporterNameController.clear();
    _reporterEmailController.clear();
    _reporterPhoneController.clear();
    _locationDetailController.clear();
    setState(() {
      _selectedCategory = null;
      _selectedLocation = null;
      _selectedDate = null;
      _selectedImage = null;
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          minLines: maxLines == 1 ? 1 : maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(
                color: AppColors.primaryColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.arrow_drop_down,
            color: AppColors.primaryColor,
          ),
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(
                color: AppColors.primaryColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
