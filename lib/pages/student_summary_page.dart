import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class StudentSummaryPage extends StatefulWidget {
  final int userId;

  const StudentSummaryPage({super.key, required this.userId});

  @override
  State<StudentSummaryPage> createState() => _StudentSummaryPageState();
}

class _StudentSummaryPageState extends State<StudentSummaryPage> {
  Map<String, dynamic>? _studentData;
  bool _isLoading = true;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    try {
      final student = await _dbHelper.getLatestStudentByUser(widget.userId);
      
      setState(() {
        _studentData = student;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: ${e.toString()}')),
      );
    }
  }

  double _calculateFinalValue() {
    if (_studentData == null) return 0.0;
    final initial = _studentData![DatabaseHelper.columnInitialFee] ?? 0.0;
    final monthly = _studentData![DatabaseHelper.columnMonthlyFee] ?? 0.0;
    return initial + (monthly * 4); // 4 meses
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen del Estudiante'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _studentData == null
              ? const Center(child: Text('No hay datos disponibles'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resumen del Estudiante',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildSummaryItem('Fecha:', _studentData![DatabaseHelper.columnDate] ?? 'No disponible'),
                      _buildDivider(),
                      _buildSummaryItem('Ciudad:', _studentData![DatabaseHelper.columnCity] ?? 'No disponible'),
                      _buildDivider(),
                      _buildSummaryItem('País:', _studentData![DatabaseHelper.columnCountry] ?? 'No disponible'),
                      _buildDivider(),
                      _buildSummaryItem(
                        'Valor del curso:',
                        '\$${(_studentData![DatabaseHelper.columnCourseValue] ?? 0.0).toStringAsFixed(2)}',
                      ),
                      _buildDivider(),
                      _buildSummaryItem(
                        'Cuota inicial:',
                        '\$${(_studentData![DatabaseHelper.columnInitialFee] ?? 0.0).toStringAsFixed(2)}',
                      ),
                      _buildDivider(),
                      _buildSummaryItem(
                        'Cuota mensual:',
                        '\$${(_studentData![DatabaseHelper.columnMonthlyFee] ?? 0.0).toStringAsFixed(2)} x 4 meses',
                      ),
                      _buildDivider(),
                      _buildSummaryItem(
                        'Valor final:',
                        '\$${_calculateFinalValue().toStringAsFixed(2)}',
                        isTotal: true,
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Este resumen es de solo lectura',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryItem(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Colors.blue : Colors.black,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.blue : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey,
    );
  }
}