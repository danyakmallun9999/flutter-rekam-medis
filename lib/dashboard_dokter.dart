import 'package:flutter/material.dart';
import 'daftar_pasien_page.dart'; // Pastikan Anda membuat halaman Daftar Pasien
import 'tambah_pasien_page.dart'; // Pastikan Anda membuat halaman Tambah Pasien
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardDokter extends StatefulWidget {
  const DashboardDokter({super.key});
  @override
  DashboardDokterState createState() => DashboardDokterState();
}

class DashboardDokterState extends State<DashboardDokter> {
  int _selectedIndex = 0;
  List<dynamic> _patients = []; // Menyimpan data pasien

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

  // Fungsi untuk menangani item yang dipilih pada navbar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Membuat widget untuk halaman Home yang lebih modern
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header with solid color
          Container(
            height: 280,
            decoration: const BoxDecoration(
              color: Color(0xFF1A237E), // Solid blue color
            ),
            child: Stack(
              children: [
                // Bubble decorations
                Positioned(
                  top: 20,
                  left: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -40,
                  right: -20,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Profile content
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/doctor_profile.png',
                            width: 96,
                            height: 96,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.person,
                                  size: 50, color: Colors.grey[400]);
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Dr. Dany Akmallun Niam',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Spesialis Umum',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStatItem('Pasien', '145+'),
                        Container(
                          height: 24,
                          width: 1,
                          color: Colors.white.withOpacity(0.5),
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        _buildStatItem('Pengalaman', '5 Tahun'),
                        Container(
                          height: 24,
                          width: 1,
                          color: Colors.white.withOpacity(0.5),
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        _buildStatItem('Rating', '4.9'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Cards Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                _buildModernInfoCard(
                  'Jadwal Hari Ini',
                  '${_patients.length} Pasien',
                  Icons.calendar_today_rounded,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF1A237E),
                      Color(0xFF3949AB),
                      Color(0xFF42A5F5),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildModernInfoCard(
                  'Total Pasien',
                  '${_patients.length} Pasien',
                  Icons.people_rounded,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF3949AB),
                      Color(0xFF42A5F5),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildModernInfoCard(
                  'Riwayat Konsultasi',
                  '23 Minggu Ini',
                  Icons.history_rounded,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF42A5F5),
                      Color(0xFF90CAF9),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildModernInfoCard(String title, String value, IconData icon,
      {required Gradient gradient}) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  final List<Widget> _pages = [
    Container(), // Placeholder widget instead of null
    DaftarPasienPage(),
    const TambahPasienPage(),
  ];

  Future<void> fetchPatients() async {
    const String url =
        'http://192.168.233.186:3000/patients'; // Sesuaikan dengan URL API Anda
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          _patients = json.decode(response.body); // Mengambil data pasien
        });
      } else {
        print('Failed to load patients: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching patients: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF1A237E),
      statusBarIconBrightness: Brightness.light,
    ));
    _pages[0] = _buildHomeContent();

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: const Color(0xFF1A237E).withOpacity(0.9),
              ),
              child: BottomNavigationBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_rounded),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.people_rounded),
                    label: 'Daftar Pasien',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_add_rounded),
                    label: 'Tambah Pasien',
                  ),
                ],
                currentIndex: _selectedIndex,
                selectedItemColor: const Color.fromARGB(255, 255, 255, 255),
                unselectedItemColor: const Color.fromARGB(255, 161, 200, 255),
                onTap: _onItemTapped,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
