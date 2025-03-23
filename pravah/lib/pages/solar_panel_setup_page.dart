import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pravah/components/custom_snackbar.dart';

class SolarPanelSetupPage extends StatefulWidget {
  const SolarPanelSetupPage({Key? key}) : super(key: key);

  @override
  State<SolarPanelSetupPage> createState() => _SolarPanelSetupPageState();
}

class _SolarPanelSetupPageState extends State<SolarPanelSetupPage> {
  final TextEditingController _squareFeetController = TextEditingController();
  final TextEditingController _roofAngleController = TextEditingController();
  final TextEditingController _sunlightHoursController = TextEditingController();

  // Default values in INR
  final double _costPerSquareFoot = 2000.0; // Cost in rupees per square foot
  final double _installationBaseCost = 125000.0; // Base installation cost in rupees
  double _totalCost = 0.0;
  double _estimatedOutput = 0.0;
  double _annualSavings = 0.0;
  double _paybackPeriod = 0.0;
  bool _showResults = false;

  // Constants for calculation
  final double _wattsPerSquareFoot = 15.0; // Average watts per square foot
  final double _electricityCostPerKWh = 8.0; // Average cost per kWh in rupees
  final double _efficiencyLoss = 0.20; // Efficiency loss factor

  @override
  void dispose() {
    _squareFeetController.dispose();
    _roofAngleController.dispose();
    _sunlightHoursController.dispose();
    super.dispose();
  }

  void _calculateCost() {
    // Validate inputs
    if (_squareFeetController.text.isEmpty) {
      showCustomSnackbar(
        context,
        "Please enter the square footage",
        backgroundColor: const Color.fromARGB(255, 57, 2, 2),
      );
      return;
    }

    // Parse inputs
    double squareFeet = double.tryParse(_squareFeetController.text) ?? 0.0;
    double roofAngle = double.tryParse(_roofAngleController.text) ?? 20.0; // Default 20 degrees
    double sunlightHours = double.tryParse(_sunlightHoursController.text) ?? 5.0; // Default 5 hours

    // Validate values
    if (squareFeet <= 0) {
      showCustomSnackbar(
        context,
        "Square footage must be greater than zero",
        backgroundColor: const Color.fromARGB(255, 57, 2, 2),
      );
      return;
    }

    // Calculate panel cost
    double panelCost = squareFeet * _costPerSquareFoot;

    // Calculate installation cost - varies by size
    double installationCost = _installationBaseCost + (squareFeet * 400);

    // Calculate total cost
    double totalCost = panelCost + installationCost;

    // Calculate estimated output
    // Adjust for roof angle (optimal is around 30-40 degrees)
    double angleEfficiency = 1.0;
    if (roofAngle < 15 || roofAngle > 45) {
      angleEfficiency = 0.85; // 15% less efficient if angle is not optimal
    }

    // Calculate power output
    double totalWatts = squareFeet * _wattsPerSquareFoot * angleEfficiency;
    double dailyKWh = totalWatts * sunlightHours / 1000 * (1 - _efficiencyLoss);
    double annualKWh = dailyKWh * 365;

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
        title: const Text('Solar Panel Setup'),
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
                  'Solar Panel',
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

                    // Square Feet Input
                    _buildInputField(
                      label: 'Roof Area (square feet)*',
                      hint: 'e.g., 500',
                      controller: _squareFeetController,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),

                    // Roof Angle Input
                    _buildInputField(
                      label: 'Roof Angle (degrees)',
                      hint: 'e.g., 30',
                      controller: _roofAngleController,
                    ),
                    const SizedBox(height: 16),

                    // Sunlight Hours Input
                    _buildInputField(
                      label: 'Average Daily Sunlight Hours',
                      hint: 'e.g., 5',
                      controller: _sunlightHoursController,
                    ),
                    const SizedBox(height: 24),

                    // Calculate Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _calculateCost,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B2732),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Calculate Cost'),
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
                        value: '₹${_totalCost.toStringAsFixed(2)}',
                        icon: Icons.attach_money,
                        iconColor: Colors.green,
                      ),
                      const SizedBox(height: 12),

                      // Annual Energy Production
                      _buildResultRow(
                        label: 'Annual Energy Production:',
                        value: '${_estimatedOutput.toStringAsFixed(2)} kWh',
                        icon: Icons.bolt,
                        iconColor: Colors.amber,
                      ),
                      const SizedBox(height: 12),

                      // Annual Savings
                      _buildResultRow(
                        label: 'Annual Savings:',
                        value: '₹${_annualSavings.toStringAsFixed(2)}',
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

                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Additional Info Section
                      const Text(
                        'Need installation help?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B2732),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Contact a local solar installer for a detailed quote and to discuss available incentives in your area.',
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
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Color(0xFF0B2732)),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
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
        Column(
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
      ],
    );
  }
}