import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import 'student_summary_page.dart';

class StudentRegisterPage extends StatefulWidget {
  final int userId;

  const StudentRegisterPage({super.key, required this.userId});

  @override
  State<StudentRegisterPage> createState() => _StudentRegisterPageState();
}

class _StudentRegisterPageState extends State<StudentRegisterPage> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _courseValueController = TextEditingController(text: '1500');
  final TextEditingController _initialFeeController = TextEditingController();
  final TextEditingController _monthlyFeeController = TextEditingController();
  
  String? _selectedCountry;
  String? _selectedCity;
  
  final List<String> _countries = ['Ecuador', 'Colombia', 'Perú', 'Chile'];
  final Map<String, List<String>> _citiesByCountry = {
    'Ecuador': ['Quito', 'Guayaquil', 'Cuenca', 'Manta'],
    'Colombia': ['Bogotá', 'Medellín', 'Cali', 'Barranquilla'],
    'Perú': ['Lima', 'Arequipa', 'Trujillo', 'Cusco'],
    'Chile': ['Santiago', 'Valparaíso', 'Concepción', 'Antofagasta'],
  };

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _selectedCountry = _countries.first;
    _selectedCity = _citiesByCountry[_selectedCountry]?.first;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _calculateMonthlyFee() {
    if (_courseValueController.text.isEmpty || _initialFeeController.text.isEmpty) {
      _showSnackBar('Ingrese el valor del curso y la cuota inicial');
      return;
    }

    try {
      final courseValue = double.parse(_courseValueController.text);
      final initialFee = double.parse(_initialFeeController.text);
      
      if (initialFee >= courseValue) {
        _showSnackBar('La cuota inicial no puede ser mayor o igual al valor del curso');
        return;
      }

      final monthlyFee = (courseValue - initialFee) / 4;
      final monthlyFeewithRecharge = monthlyFee * 1.05; // 5% de recargo
      setState(() {
        _monthlyFeeController.text = monthlyFeewithRecharge.toStringAsFixed(2);
      });
    } catch (e) {
      _showSnackBar('Ingrese valores numéricos válidos');
    }
  }

  Future<void> _saveStudent() async {
    if (_dateController.text.isEmpty ||
        _selectedCountry == null ||
        _selectedCity == null ||
        _courseValueController.text.isEmpty ||
        _initialFeeController.text.isEmpty ||
        _monthlyFeeController.text.isEmpty) {
      _showSnackBar('Complete todos los campos');
      return;
    }

    try {
      await _dbHelper.insertStudent({
        DatabaseHelper.columnDate: _dateController.text,
        DatabaseHelper.columnCountry: _selectedCountry,
        DatabaseHelper.columnCity: _selectedCity,
        DatabaseHelper.columnCourseValue: double.parse(_courseValueController.text),
        DatabaseHelper.columnInitialFee: double.parse(_initialFeeController.text),
        DatabaseHelper.columnMonthlyFee: double.parse(_monthlyFeeController.text),
        DatabaseHelper.columnUserRef: widget.userId,
      });

      // Navegar a la página de resumen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StudentSummaryPage(userId: widget.userId),
        ),
      );
    } catch (e) {
      _showSnackBar('Error al guardar: ${e.toString()}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Estudiantes'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Registro de estudiantes',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blue,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Fecha',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedCountry,
              decoration: const InputDecoration(
                labelText: 'País',
                border: OutlineInputBorder(),
              ),
              items: _countries.map((String country) {
                return DropdownMenuItem<String>(
                  value: country,
                  child: Text(country),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCountry = newValue;
                  _selectedCity = _citiesByCountry[newValue]?.first;
                });
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedCity,
              decoration: const InputDecoration(
                labelText: 'Ciudad',
                border: OutlineInputBorder(),
              ),
              items: _citiesByCountry[_selectedCountry]?.map((String city) {
                return DropdownMenuItem<String>(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCity = newValue;
                });
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _courseValueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Valor del curso (\$)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _initialFeeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cuota inicial (\$)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateMonthlyFee,
              child: const Text('Calcular Cuota Mensual'),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _monthlyFeeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cuota mensual (\$)',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveStudent,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Guardar Estudiante'),
            ),
          ],
        ),
      ),
    );
  }
}