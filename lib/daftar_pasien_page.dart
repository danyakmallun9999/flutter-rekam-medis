import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert'; // Untuk parsing JSON
import 'package:http/http.dart' as http;

class DaftarPasienPage extends StatefulWidget {
  @override
  _DaftarPasienPageState createState() => _DaftarPasienPageState();
}

class _DaftarPasienPageState extends State<DaftarPasienPage> {
  late List<Map<String, dynamic>> patients = [];
  final TextEditingController _dobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Atur status bar
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF1A237E),
      statusBarIconBrightness: Brightness.light,
    ));
    fetchPatients();
  }

  Future<void> fetchPatients() async {
    const String url = 'http://192.168.233.186:3000/patients';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          patients = data.map((patient) {
            // Ekstraksi tahun dari string 'dob'
            final dobYear = int.parse(patient['dob'].split('-')[0]);
            final age = DateTime.now().year - dobYear;

            return {
              'id': patient['_id'],
              'name': patient['name'],
              'dob': patient['dob'], // Tanggal Lahir
              'age': age,
              'diagnosis': patient['diagnosis'],
              'address': patient['address'],
              'phone': patient['phone'],
            };
          }).toList();
        });
      } else {
        print('Failed to load patients: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching patients: $e');
    }
  }

  Future<void> _deletePatient(BuildContext context, int index) async {
    final patientId = patients[index]['id'];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus data pasien ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final response = await http.delete(Uri.parse(
                      'http://192.168.233.186:3000/patients/$patientId'));
                  if (response.statusCode == 200) {
                    setState(() {
                      patients.removeAt(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Data pasien berhasil dihapus'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    print('Failed to delete patient: ${response.statusCode}');
                  }
                } catch (e) {
                  print('Error deleting patient: $e');
                }
                Navigator.pop(context);
              },
              child: Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editPatient(
      BuildContext context, Map<String, dynamic> patient) async {
    final TextEditingController nameController =
        TextEditingController(text: patient['name']);
    final TextEditingController conditionController =
        TextEditingController(text: patient['diagnosis']);
    final TextEditingController addressController =
        TextEditingController(text: patient['address']);
    final TextEditingController phoneController =
        TextEditingController(text: patient['phone']);

    // Inisialisasi controller tanggal lahir
    _dobController.text = patient['dob']; // Tanggal lahir dari data pasien

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Edit Data Pasien'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Nama'),
                ),
                TextField(
                  controller: conditionController,
                  decoration: InputDecoration(labelText: 'Diagnosa'),
                ),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(labelText: 'Alamat'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: 'Nomor Telepon'),
                  keyboardType: TextInputType.phone,
                ),
                // TextField untuk memilih tanggal lahir
                TextField(
                  controller: _dobController,
                  decoration: InputDecoration(
                    labelText: 'Tanggal Lahir',
                    hintText: 'Pilih Tanggal Lahir',
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                // Siapkan data yang diperbarui
                final updatedData = {
                  'id': patient['id'],
                  'name': nameController.text,
                  'dob': _dobController
                      .text, // Menggunakan tanggal lahir yang dipilih
                  'diagnosis': conditionController.text,
                  'address': addressController.text,
                  'phone': phoneController.text,
                };

                try {
                  final response = await http.put(
                    Uri.parse(
                        'http://192.168.233.186:3000/patients/${updatedData['id']}'),
                    headers: {'Content-Type': 'application/json'},
                    body: json.encode(updatedData),
                  );
                  if (response.statusCode == 200) {
                    setState(() {
                      final index = patients
                          .indexWhere((p) => p['id'] == updatedData['id']);
                      if (index != -1) {
                        patients[index] = updatedData;
                      }
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Data pasien berhasil diperbarui'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    print('Failed to update patient: ${response.statusCode}');
                  }
                } catch (e) {
                  print('Error updating patient: $e');
                }
                Navigator.pop(context);
              },
              child: Text('Simpan', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk memilih tanggal lahir
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: true,
            pinned: true,
            backgroundColor: Color(0xFF1A237E),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Daftar Pasien',
                style: TextStyle(color: Colors.white),
              ),
              background: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF1A237E),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF1A237E),
                      Color(0xFF1A237E).withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final patient = patients[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 217, 221, 232),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Text(
                          patient['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text('Umur: ${patient['age']} tahun'),
                            Text('Diagnosa: ${patient['diagnosis']}'),
                            Text('Nomor Telepon: ${patient['phone']}'),
                            Text('Alamat: ${patient['address']}'),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          icon: Icon(Icons.more_vert),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: ListTile(
                                leading: Icon(Icons.edit, color: Colors.blue),
                                title: Text('Edit'),
                                contentPadding: EdgeInsets.zero,
                              ),
                              onTap: () {
                                _editPatient(context, patient);
                              },
                            ),
                            PopupMenuItem(
                              child: ListTile(
                                leading: Icon(Icons.delete, color: Colors.red),
                                title: Text('Hapus'),
                                contentPadding: EdgeInsets.zero,
                              ),
                              onTap: () {
                                _deletePatient(context, index);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: patients.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
