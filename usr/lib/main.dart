import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculateur de Cuve',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const TankCalculatorPage(),
    );
  }
}

class TankCalculatorPage extends StatefulWidget {
  const TankCalculatorPage({super.key});

  @override
  State<TankCalculatorPage> createState() => _TankCalculatorPageState();
}

class _TankCalculatorPageState extends State<TankCalculatorPage> {
  final _cylinderHeightController = TextEditingController();
  final _cylinderDiameterController = TextEditingController();
  final _coneHeightController = TextEditingController();
  final _liquidHeightController = TextEditingController();

  double _liquidVolume = 0.0;
  double _totalVolume = 0.0;
  double _fillPercentage = 0.0;

  void _calculateVolume() {
    final double cylinderHeight = double.tryParse(_cylinderHeightController.text) ?? 0.0;
    final double cylinderDiameter = double.tryParse(_cylinderDiameterController.text) ?? 0.0;
    final double coneHeight = double.tryParse(_coneHeightController.text) ?? 0.0;
    final double liquidHeight = double.tryParse(_liquidHeightController.text) ?? 0.0;

    if (cylinderDiameter <= 0) return;

    final double radius = cylinderDiameter / 2;

    // Calculate total volume
    final double cylinderVolume = pi * pow(radius, 2) * cylinderHeight;
    final double coneVolume = (1/3) * pi * pow(radius, 2) * coneHeight;
    final double totalTankVolume = cylinderVolume + coneVolume;

    // Calculate liquid volume
    double currentLiquidVolume = 0.0;
    if (liquidHeight > 0) {
      if (liquidHeight <= coneHeight) {
        // Liquid is only in the cone
        final double liquidRadius = (radius * liquidHeight) / coneHeight;
        currentLiquidVolume = (1/3) * pi * pow(liquidRadius, 2) * liquidHeight;
      } else if (liquidHeight <= coneHeight + cylinderHeight) {
        // Liquid is in the cone and cylinder
        final double heightInCylinder = liquidHeight - coneHeight;
        final double volumeInCylinder = pi * pow(radius, 2) * heightInCylinder;
        currentLiquidVolume = coneVolume + volumeInCylinder;
      } else {
        // Tank is full
        currentLiquidVolume = totalTankVolume;
      }
    }
    
    final double percentage = totalTankVolume > 0 ? (currentLiquidVolume / totalTankVolume) * 100 : 0.0;

    setState(() {
      _totalVolume = totalTankVolume;
      _liquidVolume = currentLiquidVolume;
      _fillPercentage = percentage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculateur de Niveau de Cuve'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Entrez les dimensions de la cuve (en mètres)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildTextField(_cylinderDiameterController, 'Diamètre du cylindre (D)'),
              const SizedBox(height: 12),
              _buildTextField(_cylinderHeightController, 'Hauteur du cylindre (Hc)'),
              const SizedBox(height: 12),
              _buildTextField(_coneHeightController, 'Hauteur du cône (Hk)'),
              const SizedBox(height: 20),
              const Text(
                'Entrez le niveau du liquide (en mètres)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildTextField(_liquidHeightController, 'Hauteur du liquide (Hl)'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _calculateVolume,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Calculer', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              _buildResultCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Résultats',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const SizedBox(height: 16),
            _buildResultRow('Volume du liquide:', '${_liquidVolume.toStringAsFixed(3)} m³'),
            const SizedBox(height: 8),
            _buildResultRow('Volume total de la cuve:', '${_totalVolume.toStringAsFixed(3)} m³'),
            const SizedBox(height: 8),
            _buildResultRow('Pourcentage de remplissage:', '${_fillPercentage.toStringAsFixed(2)} %'),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _fillPercentage / 100,
              minHeight: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  void dispose() {
    _cylinderHeightController.dispose();
    _cylinderDiameterController.dispose();
    _coneHeightController.dispose();
    _liquidHeightController.dispose();
    super.dispose();
  }
}
