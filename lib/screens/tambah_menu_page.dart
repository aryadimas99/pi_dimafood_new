import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:another_flushbar/flushbar.dart';

class TambahMenuPage extends StatefulWidget {
  const TambahMenuPage({super.key});

  @override
  State<TambahMenuPage> createState() => _TambahMenuPageState();
}

class _TambahMenuPageState extends State<TambahMenuPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _jenisController = TextEditingController();
  final _hargaController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ratingController = TextEditingController();
  Uint8List? _selectedImage;

  String? _selectedKategori;
  String? _selectedStatus = 'Tersedia';
  bool _isPopuler = false;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null) {
      final path = result.files.single.path;
      if (path != null) {
        final file = File(path);
        setState(() => _selectedImage = file.readAsBytesSync());
      }
    }
  }

  Future<String?> _uploadToCloudinary(Uint8List fileBytes) async {
    const uploadUrl = 'https://api.cloudinary.com/v1_1/dgbnshaee/image/upload';
    final request =
        http.MultipartRequest('POST', Uri.parse(uploadUrl))
          ..fields['upload_preset'] = 'dimafood_unsigned'
          ..files.add(
            http.MultipartFile.fromBytes(
              'file',
              fileBytes,
              filename: '${DateTime.now().millisecondsSinceEpoch}.jpg',
            ),
          );

    final response = await request.send();
    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final jsonResp = json.decode(respStr);
      return jsonResp['secure_url'];
    } else {
      debugPrint('Upload gagal: ${response.statusCode}');
      return null;
    }
  }

  Future<void> _simpanMenu() async {
    if (!_formKey.currentState!.validate() ||
        _selectedImage == null ||
        _selectedKategori == null) {
      if (!mounted) return;
      Flushbar(
        message: 'Harap lengkapi semua data & pilih gambar',
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(15),
        borderRadius: BorderRadius.circular(10),
        backgroundColor: Colors.red,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final imageUrl = await _uploadToCloudinary(_selectedImage!);
      if (imageUrl == null) throw 'Upload Cloudinary gagal';

      await FirebaseFirestore.instance.collection('menu').add({
        'nama': _namaController.text,
        'jenis': _jenisController.text,
        'harga': int.tryParse(_hargaController.text) ?? 0,
        'kategori': _selectedKategori,
        'description': _descriptionController.text,
        'rating':
            _ratingController.text.isEmpty ? '4.5' : _ratingController.text,
        'status': _selectedStatus ?? 'Tersedia',
        'isPopuler': _isPopuler,
        'imageUrl': imageUrl,
      });

      if (!mounted) return;
      Flushbar(
        message: 'Menu berhasil ditambahkan!',
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(15),
        borderRadius: BorderRadius.circular(10),
        backgroundColor: Colors.green,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        flushbarPosition: FlushbarPosition.TOP,
        onStatusChanged: (status) {
          if (status == FlushbarStatus.DISMISSED && mounted) {
            Future.microtask(() {
              Navigator.pop(context, true);
            });
          }
        },
      ).show(context);
    } catch (e) {
      debugPrint('❌ Gagal simpan: $e');
      if (!mounted) return;
      Flushbar(
        message: 'Gagal menyimpan menu',
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(15),
        borderRadius: BorderRadius.circular(10),
        backgroundColor: Colors.red,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _jenisController.dispose();
    _hargaController.dispose();
    _descriptionController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF007FFE)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Form(
          key: _formKey,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Colors.grey[300],
                  child: Text(
                    'Tambah Menu Baru',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildField(
                        _namaController,
                        'Nama Menu:',
                        'Contoh: Ayam Bakar',
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        _jenisController,
                        'Jenis Masakan:',
                        'Contoh: Indonesian',
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        _hargaController,
                        'Harga (Rp):',
                        'Contoh: 25000',
                        isNumber: true,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            ['Makanan', 'Minuman', 'Dessert']
                                .map(
                                  (kat) => DropdownMenuItem(
                                    value: kat,
                                    child: Text(kat),
                                  ),
                                )
                                .toList(),
                        value: _selectedKategori,
                        onChanged:
                            (val) => setState(() => _selectedKategori = val),
                        validator:
                            (val) => val == null ? 'Pilih kategori' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        _descriptionController,
                        'Deskripsi:',
                        'Contoh: Ayam bakar enak banget',
                      ),
                      const SizedBox(height: 12),
                      _buildField(_ratingController, 'Rating:', 'Contoh: 4.5'),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            ['Tersedia', 'Habis']
                                .map(
                                  (status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(status),
                                  ),
                                )
                                .toList(),
                        value: _selectedStatus,
                        onChanged:
                            (val) => setState(() => _selectedStatus = val),
                        validator: (val) => val == null ? 'Pilih status' : null,
                      ),
                      const SizedBox(height: 12),
                      CheckboxListTile(
                        title: const Text('Tandai sebagai Menu Populer'),
                        value: _isPopuler,
                        onChanged:
                            (val) => setState(() => _isPopuler = val ?? false),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child:
                              _selectedImage != null
                                  ? Image.memory(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  )
                                  : Text(
                                    'Upload Foto',
                                    style: GoogleFonts.inter(
                                      color: Colors.blue,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _simpanMenu,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007FFE),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child:
                              _isLoading
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : const Text(
                                    'Simpan',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    String hint, {
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (v) => v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
    );
  }
}
