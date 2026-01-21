import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../constants/constants.dart';
import '../models/item.dart';
import '../providers/item_provider.dart';

class EditReportScreen extends StatefulWidget {
  final Item item;

  const EditReportScreen({Key? key, required this.item}) : super(key: key);

  @override
  State<EditReportScreen> createState() => _EditReportScreenState();
}

class _EditReportScreenState extends State<EditReportScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationDetailController;
  late TextEditingController _reporterNameController;
  late TextEditingController _reporterPhoneController;

  String? _selectedCategory;
  String? _selectedLocation;
  DateTime? _selectedDate;
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.title);
    _descriptionController = TextEditingController(text: widget.item.description);
    _locationDetailController = TextEditingController(text: widget.item.locationDetail);
    _reporterNameController = TextEditingController(text: widget.item.reporterName);
    _reporterPhoneController = TextEditingController(text: widget.item.reporterPhone);
    _selectedCategory = widget.item.category;
    _selectedLocation = widget.item.location;
    _selectedDate = widget.item.type == ItemType.lost ? widget.item.dateLost : widget.item.dateReported;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationDetailController.dispose();
    _reporterNameController.dispose();
    _reporterPhoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _updateReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final itemProvider = Provider.of<ItemProvider>(context, listen: false);
      
      final updatedItem = widget.item.copyWith(
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory!,
        location: _selectedLocation!,
        locationDetail: _locationDetailController.text,
        reporterName: _reporterNameController.text,
        reporterPhone: _reporterPhoneController.text,
        dateLost: widget.item.type == ItemType.lost ? _selectedDate : null,
      );

      await itemProvider.updateItem(widget.item.id, updatedItem);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Laporan berhasil diperbarui!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui laporan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Laporan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Informasi Barang'),
              _buildTextField(
                controller: _titleController,
                label: 'Nama Barang',
                hint: 'Contoh: iPhone 13 Pro Max',
                icon: Icons.title,
                validator: (value) => value?.isEmpty ?? true ? 'Judul harus diisi' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildDropdown(
                label: 'Kategori',
                value: _selectedCategory,
                items: categories,
                icon: Icons.category,
                onChanged: (val) => setState(() => _selectedCategory = val),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildTextField(
                controller: _descriptionController,
                label: 'Deskripsi',
                hint: 'Ciri-ciri khusus, warna, dll',
                icon: Icons.description,
                maxLines: 4,
                validator: (value) => value?.isEmpty ?? true ? 'Deskripsi harus diisi' : null,
              ),
              
              const SizedBox(height: AppSpacing.xl),
              _buildSectionTitle('Lokasi & Waktu'),
              _buildDropdown(
                label: 'Lokasi',
                value: _selectedLocation,
                items: locations,
                icon: Icons.location_on,
                onChanged: (val) => setState(() => _selectedLocation = val),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildTextField(
                controller: _locationDetailController,
                label: 'Detail Lokasi',
                hint: 'Contoh: Dekat lift lantai 2',
                icon: Icons.map_outlined,
              ),

              const SizedBox(height: AppSpacing.xl),
              _buildSectionTitle('Informasi Kontak'),
              _buildTextField(
                controller: _reporterNameController,
                label: 'Nama Anda',
                icon: Icons.person,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildTextField(
                controller: _reporterPhoneController,
                label: 'Nomor WhatsApp',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      items: items.map((String item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }
}
