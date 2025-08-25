import 'package:flutter/material.dart';
import 'app_colors.dart';

class ThemeDemo extends StatefulWidget {
  const ThemeDemo({super.key});

  @override
  State<ThemeDemo> createState() => _ThemeDemoState();
}

class _ThemeDemoState extends State<ThemeDemo> {
  bool _isDarkMode = false;
  double _sliderValue = 0.5;
  bool _switchValue = false;
  bool _checkboxValue = false;
  String _selectedRadio = 'option1';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Noyo - Modern Theme Demo'),
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    const BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.local_taxi,
                      size: 48,
                      color: AppColors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome to Noyo',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your modern ride-hailing experience',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.white.withValues(alpha: 0.9),
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Buttons Section
              Text(
                'Buttons',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Primary'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('Secondary'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Text Button'),
                ),
              ),

              const SizedBox(height: 24),

              // Cards Section
              Text(
                'Cards',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: AppColors.accentGradient,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.star,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Premium Ride',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(
                                  'Luxury vehicle with professional driver',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$25.00',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text('Book Now'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Stats',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              context,
                              Icons.timer,
                              '5 min',
                              'Wait Time',
                              AppColors.info,
                            ),
                          ),
                          Expanded(
                            child: _buildStatItem(
                              context,
                              Icons.star,
                              '4.8',
                              'Rating',
                              AppColors.warning,
                            ),
                          ),
                          Expanded(
                            child: _buildStatItem(
                              context,
                              Icons.location_on,
                              '2.1 km',
                              'Distance',
                              AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Form Elements Section
              Text(
                'Form Elements',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),

              const TextField(
                decoration: InputDecoration(
                  labelText: 'Destination',
                  hintText: 'Where would you like to go?',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),

              const SizedBox(height: 16),

              const TextField(
                decoration: InputDecoration(
                  labelText: 'Special Instructions',
                  hintText: 'Any special requests?',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 24),

              // Interactive Elements Section
              Text(
                'Interactive Elements',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),

              // Switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Enable Notifications',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Switch(
                    value: _switchValue,
                    onChanged: (value) {
                      setState(() {
                        _switchValue = value;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _checkboxValue,
                    onChanged: (value) {
                      setState(() {
                        _checkboxValue = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      'I agree to the terms and conditions',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Radio Buttons
              Text(
                'Payment Method:',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),

              RadioListTile<String>(
                title: const Text('Credit Card'),
                value: 'option1',
                groupValue: _selectedRadio,
                onChanged: (value) {
                  setState(() {
                    _selectedRadio = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('PayPal'),
                value: 'option2',
                groupValue: _selectedRadio,
                onChanged: (value) {
                  setState(() {
                    _selectedRadio = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('Cash'),
                value: 'option3',
                groupValue: _selectedRadio,
                onChanged: (value) {
                  setState(() {
                    _selectedRadio = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Slider
              Text(
                'Fare Estimate: \$${(_sliderValue * 50).toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Slider(
                value: _sliderValue,
                onChanged: (value) {
                  setState(() {
                    _sliderValue = value;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Chips Section
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Home'),
                    selected: false,
                    onSelected: (bool selected) {},
                    avatar: const Icon(Icons.home, size: 16),
                  ),
                  FilterChip(
                    label: const Text('Work'),
                    selected: true,
                    onSelected: (bool selected) {},
                    avatar: const Icon(Icons.work, size: 16),
                  ),
                  FilterChip(
                    label: const Text('Airport'),
                    selected: false,
                    onSelected: (bool selected) {},
                    avatar: const Icon(Icons.flight, size: 16),
                  ),
                  FilterChip(
                    label: const Text('Hospital'),
                    selected: false,
                    onSelected: (bool selected) {},
                    avatar: const Icon(Icons.local_hospital, size: 16),
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Book Ride'),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withValues(alpha: 0.7),
              ),
        ),
      ],
    );
  }
}
