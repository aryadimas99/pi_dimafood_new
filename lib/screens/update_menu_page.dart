import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateMenuPage extends StatefulWidget {
  final String menuId;
  final String title;
  final String category;
  final String price;
  final String status;

  const UpdateMenuPage({
    super.key,
    required this.menuId,
    required this.title,
    required this.category,
    required this.price,
    required this.status,
  });

  @override
  State<UpdateMenuPage> createState() => _UpdateMenuPageState();
}

class _UpdateMenuPageState extends State<UpdateMenuPage> {
  late TextEditingController _titleController;
  late TextEditingController _categoryController;
  late TextEditingController _priceController;
  String selectedStatus = 'Tersedia';

  late String initialTitle;
  late String initialCategory;
  late String initialPrice;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _categoryController = TextEditingController(text: widget.category);
    _priceController = TextEditingController(text: widget.price);
    selectedStatus = widget.status;

    initialTitle = widget.title;
    initialCategory = widget.category;
    initialPrice = widget.price;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _updateStatus(String status) {
    setState(() {
      selectedStatus = status;
    });
  }

  Future<void> _handleUpdate() async {
    final newTitle = _titleController.text.trim();
    final newCategory = _categoryController.text.trim();
    final newPrice = _priceController.text.trim();
    final newPriceInt = int.tryParse(newPrice);

    if (newTitle.isEmpty || newCategory.isEmpty || newPriceInt == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi semua data dengan benar!')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('menu')
          .doc(widget.menuId)
          .update({
            'nama': newTitle,
            'jenis': newCategory,
            'harga': newPriceInt,
            'status': selectedStatus,
          });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menu berhasil diperbarui!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    }
  }

  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Hapus Menu?'),
            content: const Text(
              'Menu akan dihapus dari database dan tidak bisa dikembalikan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Ya, Hapus'),
              ),
            ],
          ),
    );

    if (confirm != true || !mounted) return;

    try {
      await FirebaseFirestore.instance
          .collection('menu')
          .doc(widget.menuId)
          .delete();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Menu berhasil dihapus!')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
    }
  }

  void _handleCancel() {
    bool hasChanged =
        _titleController.text != initialTitle ||
        _categoryController.text != initialCategory ||
        _priceController.text != initialPrice ||
        selectedStatus != widget.status;

    if (!hasChanged) {
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Batal Mengedit?'),
            content: const Text(
              'Perubahan belum disimpan. Yakin ingin keluar?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Tidak'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Ya'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset('lib/assets/icons/arrow-circle-left.svg'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Text(
                    'Update Menu',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildLabel('Nama Menu:'),
              TextField(
                controller: _titleController,
                decoration: _inputDecoration(),
              ),
              const SizedBox(height: 12),
              _buildLabel('Jenis Masakan:'),
              TextField(
                controller: _categoryController,
                decoration: _inputDecoration(),
              ),
              const SizedBox(height: 12),
              _buildLabel('Harga (Rp):'),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(),
              ),
              const SizedBox(height: 12),
              _buildLabel('Status:'),
              const SizedBox(height: 6),
              Row(
                children: [
                  _statusChip('Tersedia'),
                  const SizedBox(width: 10),
                  _statusChip('Habis'),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _actionButton(
                    'Hapus',
                    Colors.red,
                    Colors.white,
                    _handleDelete,
                  ),
                  _actionButton(
                    'Batal',
                    Colors.grey,
                    Colors.white,
                    _handleCancel,
                  ),
                  _actionButton(
                    'Simpan',
                    Colors.blue,
                    Colors.white,
                    _handleUpdate,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Text _buildLabel(String text) => Text(text, style: GoogleFonts.poppins());

  InputDecoration _inputDecoration() {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: const OutlineInputBorder(),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue, width: 2),
      ),
    );
  }

  Widget _statusChip(String label) {
    final isSelected = selectedStatus == label;
    return GestureDetector(
      onTap: () => _updateStatus(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: isSelected ? Colors.white : Colors.blue,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _actionButton(
    String label,
    Color bgColor,
    Color textColor,
    VoidCallback onTap,
  ) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
