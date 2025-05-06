import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'register_page.dart';
import 'student_register_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isRegistering = false;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  void _toggleRegister() {
    setState(() {
      _isRegistering = !_isRegistering;
      _errorMessage = '';
      _userController.clear();
      _passwordController.clear();
    });
  }

Future<void> _validateCredentials() async {
  final username = _userController.text.trim();
  final password = _passwordController.text.trim();
  
  if (username.isEmpty || password.isEmpty) {
    setState(() {
      _errorMessage = 'Usuario y contraseña son requeridos';
    });
    return;
  }

  try {
    // Verificar primero si el usuario existe
    final userExists = await _dbHelper.usernameExists(username);
    
    if (!userExists) {
      setState(() {
        _errorMessage = 'Usuario no encontrado';
      });
      return;
    }

    // Obtener el usuario con las credenciales correctas
    final user = await _dbHelper.getUser(username, password);
    
    if (user == null) {
      setState(() {
        _errorMessage = 'Contraseña incorrecta';
      });
    } else {
      // Limpiar campos y mensajes de error
      _userController.clear();
      _passwordController.clear();
      setState(() {
        _errorMessage = '';
      });
      
      // Navegar a la página de registro de estudiante
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StudentRegisterPage(userId: user['user_id']),
        ),
      );
    }
  } catch (e) {
    setState(() {
      _errorMessage = 'Error al validar credenciales';
    });
    debugPrint('Error en _validateCredentials: $e');
  }
}

  Future<void> _registerUser() async {
    final username = _userController.text.trim();
    final password = _passwordController.text.trim();
    
    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Usuario y contraseña son requeridos';
      });
      return;
    }

    if (await _dbHelper.usernameExists(username)) {
      setState(() {
        _errorMessage = 'El usuario ya existe';
      });
      return;
    }

    try {
      await _dbHelper.insertUser(username, password);
      setState(() {
        _errorMessage = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario registrado exitosamente')),
      );
      _toggleRegister();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al registrar usuario';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Autenticación"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Image(
                image: const AssetImage("assets/logo_empresa.png"),
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 20),
              const Text(
                "Inicio de Sesión",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  controller: _userController,
                  decoration: const InputDecoration(
                    labelText: 'Usuario',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isRegistering ? _registerUser : _validateCredentials,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text(
                  _isRegistering ? 'Registrar' : 'Ingresar',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegisterPage(
                        onRegisterSuccess: () {
                          Navigator.pop(context);
                          setState(() {
                            _errorMessage = '';
                          });
                        },
                      ),
                    ),
                  );
                },
                child: const Text(
                  '¿No tienes cuenta? Regístrate',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}