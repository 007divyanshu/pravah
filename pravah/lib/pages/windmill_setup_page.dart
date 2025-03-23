import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pravah/components/custom_snackbar.dart';

class WindmillSetupPage extends StatefulWidget {
  const WindmillSetupPage({Key? key}) : super(key: key);

  @override
  State<WindmillSetupPage> createState() => _WindmillSetupPageState();
}

class _WindmillSetupPageState extends State<WindmillSetupPage> {
  final TextEditingController _turbineSizeController = TextEditingController();
  final TextEditingController _windSpeedController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // Default values in INR
  final double _costPerKW = 75000.0; // Cost in INR per kW of turbine capacity
  final double _installationBaseCost = 100000.0; // Base installation cost in INR
  double _totalCost = 0.0;
  double _estimatedOutput = 0.0;
  double _annualSavings = 0.0;
  double _paybackPeriod = 0.0;
  bool _showResults = false;

  // Constants for calculation
  final double _electricityCostPerKWh = 7.5; // Average cost per kWh in INR
  final double _efficiencyLoss = 0.25; // Efficiency loss factor
  final double _capacityFactor = 0.30; // Average capacity factor for wind turbines
  final double _kmhToMsConversion = 0.277778; // Conversion factor from km/h to m/s (1 km/h = 0.277778 m/s)

  @override
  void dispose() {
    _turbineSizeController.dispose();
    _windSpeedController.dispose();
    _heightController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _calculateOutput() {
    // Validate inputs
    if (_turbineSizeController.text.isEmpty) {
      showCustomSnackbar(
        context,
        "Please enter the turbine size in kW",
        backgroundColor: const Color.fromARGB(255, 57, 2, 2),
      );
      return;
    }

    // Parse inputs
    double turbineSize = double.tryParse(_turbineSizeController.text) ?? 0.0;
    double windSpeedKmh = double.tryParse(_windSpeedController.text) ?? 18.0; // Default 18 km/h (5 m/s)
    double height = double.tryParse(_heightController.text) ?? 30.0; // Default 30 meters
    String location = _locationController.text;

    // Convert wind speed from km/h to m/s
    double avgWindSpeedMs = windSpeedKmh * _kmhToMsConversion;

    // Validate values
    if (turbineSize <= 0) {
      showCustomSnackbar(
        context,
        "Turbine size must be greater than zero",
        backgroundColor: const Color.fromARGB(255, 57, 2, 2),
      );
      return;
    }

    // Adjust capacity factor based on wind speed (still using m/s for calculation)
    double adjustedCapacityFactor = _capacityFactor;
    if (avgWindSpeedMs < 4.0) {
      adjustedCapacityFactor = 0.15; // Low wind areas
    } else if (avgWindSpeedMs > 7.0) {
      adjustedCapacityFactor = 0.40; // High wind areas
    }

    // Adjust for height (taller installations are more efficient)
    double heightFactor = 1.0;
    if (height < 20) {
      heightFactor = 0.8; // Lower efficiency at lower heights
    } else if (height > 50) {
      heightFactor = 1.2; // Higher efficiency at greater heights
    }

    // Calculate turbine cost
    double turbineCost = turbineSize * _costPerKW;

    // Calculate installation cost - varies by size
    double installationCost = _installationBaseCost + (turbineSize * 10000);

    // Calculate total cost
    double totalCost = turbineCost + installationCost;

    // Calculate power output
    // Formula: Turbine Size (kW) × Hours in a Year (8760) × Capacity Factor × Height Factor × (1 - Efficiency Loss)
    double annualKWh = turbineSize * 8760 * adjustedCapacityFactor * heightFactor * (1 - _efficiencyLoss);

    // Calculate annual savings
    double annualSavings = annualKWh * _electricityCostPerKWh;

    // Calculate payback period
    double paybackPeriod = totalCost / annualSavings;

    setState(() {
      _totalCost = totalCost;
      _estimatedOutput = annualKWh;
      _annualSavings = annualSavings;
      _paybackPeriod = paybackPeriod;
      _showResults = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B2732),
      appBar: AppBar(
        title: const Text('Wind Turbine Setup'),
        backgroundColor: const Color(0xFFF5F5DC),
        foregroundColor: const Color(0xFF0B2732),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title Card
            Card(
              color: const Color(0xFFF5F5DC),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Wind Energy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B2732),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Input Card
            Card(
              color: const Color(0xFFF5F5DC),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter Your Requirements',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0B2732),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Turbine Size Input
                    _buildInputField(
                      label: 'Turbine Size (kW)*',
                      hint: 'e.g., 10',
                      controller: _turbineSizeController,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),

                    // Wind Speed Input (now in km/h)
                    _buildInputField(
                      label: 'Average Wind Speed (km/h)',
                      hint: 'e.g., 18',
                      controller: _windSpeedController,
                    ),
                    const SizedBox(height: 16),

                    // Height Input
                    _buildInputField(
                      label: 'Installation Height (meters)',
                      hint: 'e.g., 30',
                      controller: _heightController,
                    ),
                    const SizedBox(height: 16),

                    // Location Input (for reference only)
                    _buildInputField(
                      label: 'Location (optional)',
                      hint: 'e.g., Coastal Area',
                      controller: _locationController,
                      isNumeric: false,
                    ),
                    const SizedBox(height: 24),

                    // Calculate Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _calculateOutput,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B2732),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Calculate Output'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Results Card - Only shown after calculation
            if (_showResults)
              Card(
                color: const Color(0xFFF5F5DC),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Estimated Costs & Benefits',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B2732),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Setup Cost
                      _buildResultRow(
                        label: 'Total Setup Cost:',
                        value: '₹${_totalCost.toStringAsFixed(0)}',
                        icon: Icons.currency_rupee,
                        iconColor: Colors.green,
                      ),
                      const SizedBox(height: 12),

                      // Annual Energy Production
                      _buildResultRow(
                        label: 'Annual Energy Production:',
                        value: '${_estimatedOutput.toStringAsFixed(0)} kWh',
                        icon: Icons.bolt,
                        iconColor: Colors.amber,
                      ),
                      const SizedBox(height: 12),

                      // Annual Savings
                      _buildResultRow(
                        label: 'Annual Savings:',
                        value: '₹${_annualSavings.toStringAsFixed(0)}',
                        icon: Icons.savings,
                        iconColor: Colors.blue,
                      ),
                      const SizedBox(height: 12),

                      // Payback Period
                      _buildResultRow(
                        label: 'Payback Period:',
                        value: '${_paybackPeriod.toStringAsFixed(1)} years',
                        icon: Icons.timelapse,
                        iconColor: Colors.purple,
                      ),

                      // Wind Speed Conversion Information
                      const SizedBox(height: 12),
                      _buildResultRow(
                        label: 'Wind Speed (converted):',
                        value: '${(double.tryParse(_windSpeedController.text) ?? 18.0) * _kmhToMsConversion} m/s',
                        icon: Icons.speed,
                        iconColor: Colors.orange,
                      ),

                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Additional Info Section
                      const Text(
                        'Important Notes:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B2732),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• Wind turbine installation may require permits from local authorities\n'
                            '• Actual power generation depends on local wind conditions\n'
                            '• Consider consulting with a wind energy specialist for detailed assessment',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF0B2732),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Need assistance with installation?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B2732),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Contact a wind energy specialist to discuss site-specific details and available government incentives in your area.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF0B2732),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper widget for input fields
  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isRequired = false,
    bool isNumeric = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0B2732),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: controller,
            keyboardType: isNumeric
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
            style: const TextStyle(color: Color(0xFF0B2732)),
            inputFormatters: isNumeric
                ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))]
                : [],
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade500),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: InputBorder.none,
            ),
          ),
        ),
        if (isRequired)
          const Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: Text(
              '* Required field',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  // Helper widget for result rows
  Widget _buildResultRow({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF0B2732),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B2732),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}