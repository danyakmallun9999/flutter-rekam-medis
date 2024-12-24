import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TambahPasienPage extends StatefulWidget {
  final bool isEditing;
  final Map<String, dynamic>? patientData;

  const TambahPasienPage({
    Key? key,
    this.isEditing = false,
    this.patientData,
  }) : super(key: key);

  @override
  TambahPasienPageState createState() => TambahPasienPageState();
}

class TambahPasienPageState extends State<TambahPasienPage> {
  final _formKey = GlobalKey<FormState>();
  final String url =
      'http://192.168.233.186:3000/patients'; // Ganti dengan endpoint API Anda

  // Tambahkan TextEditingController
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _conditionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Jika mode edit, isi TextEditingController dengan data pasien
    if (widget.isEditing && widget.patientData != null) {
      _nameController.text = widget.patientData!['name'] ?? '';
      _dobController.text = widget.patientData!['dob'] ?? '';
      _addressController.text = widget.patientData!['address'] ?? '';
      _phoneController.text = widget.patientData!['phone'] ?? '';
      _conditionController.text = widget.patientData!['diagnosis'] ?? '';
    }

    // Atur status bar
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF1A237E),
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _conditionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        // Format tanggal menjadi YYYY-MM-DD
        _dobController.text =
            "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> submitPatientData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final patientData = {
      "name": _nameController.text,
      "dob": _dobController.text,
      "address": _addressController.text,
      "phone": _phoneController.text,
      "diagnosis": _conditionController.text,
    };

    try {
      final response = await (widget.isEditing
          ? http.put(
              Uri.parse(url),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(patientData),
            )
          : http.post(
              Uri.parse(url),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(patientData),
            ));

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditing
                ? 'Data pasien berhasil diperbarui'
                : 'Data pasien berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );

        // Kosongkan semua input
        _nameController.clear();
        _dobController.clear();
        _addressController.clear();
        _phoneController.clear();
        _conditionController.clear();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengirim data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Pasien' : 'Tambah Pasien',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A237E),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildTextField(
                  label: 'Nama Lengkap',
                  icon: Icons.person_outline,
                  controller: _nameController,
                ),
                _buildTextField(
                  label: 'Tanggal Lahir (YYYY-MM-DD)',
                  icon: Icons.calendar_today,
                  controller: _dobController,
                  keyboardType: TextInputType.none,
                  onTap: () => _selectDate(context),
                ),
                _buildTextField(
                  label: 'Alamat',
                  icon: Icons.location_on_outlined,
                  maxLines: 3,
                  controller: _addressController,
                ),
                _buildTextField(
                  label: 'Nomor Telepon',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  controller: _phoneController,
                ),
                _buildTextField(
                  label: 'Riwayat Penyakit',
                  icon: Icons.medical_services_outlined,
                  maxLines: 3,
                  controller: _conditionController,
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: submitPatientData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3949AB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Simpan',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    TextEditingController? controller,
    int maxLines = 1,
    TextInputType? keyboardType,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        readOnly: onTap != null,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Color(0xFF3949AB)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF42A5F5)),
          ),
          labelStyle: TextStyle(color: Color(0xFF3949AB)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label tidak boleh kosong';
          }
          return null;
        },
      ),
    );
  }
}
