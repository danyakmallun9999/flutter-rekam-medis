import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dashboard_dokter.dart'; // Mengimpor file DashboardDokter

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late final AnimationController _animationController = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  )..repeat();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final url = Uri.parse('http://192.168.233.186:3000/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': _usernameController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Login successful: Welcome ${data['user']['username']}!'),
        backgroundColor: Colors.green,
      ));

      // Navigasi ke Dashboard Dokter setelah login sukses
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardDokter()),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Invalid credentials'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // title: const Text('SRME'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Section with Animation
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(3.14159 * _animationController.value * 2),
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 130,
                        width: 130,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),

                // Title Section
                const Text(
                  'Sistem Rekam Medis Elektronik',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // Subtitle Section
                const Text(
                  'Silahkan masuk dengan akun Anda',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF3949AB),
                  ),
                ),
                const SizedBox(height: 40),

                // Username Input Field
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    prefixIcon:
                        const Icon(Icons.person, color: Color(0xFF3949AB)),
                    hintText: 'Masukkan username',
                    labelText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF1A237E)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Password Input Field
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    prefixIcon:
                        const Icon(Icons.lock, color: Color(0xFF3949AB)),
                    hintText: 'Masukkan password',
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF1A237E)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 30),

                // Login Button
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Masuk',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),

                const SizedBox(height: 20),

                // Sign Up Link
              ],
            ),
          ),
        ),
      ),
    );
  }
}
