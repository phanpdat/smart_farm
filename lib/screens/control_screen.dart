import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/sensor_card.dart';
import '../providers/farm_provider.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  @override
  Widget build(BuildContext context) {
    final farmProvider = Provider.of<FarmProvider>(context);
    final sensorData = farmProvider.sensorData;
    final isAuto = farmProvider.isAuto;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),
          _buildTopBar(),
          const SizedBox(height: 24),
          _buildModeToggle(farmProvider),
          const SizedBox(height: 24),
          _buildActuatorsHeader(isAuto),
          const SizedBox(height: 16),
          _buildActuatorList(farmProvider),
          const SizedBox(height: 24),
          _buildAIDiagnosticCard(farmProvider),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SensorCard(
                  icon: LucideIcons.thermometer,
                  label: 'INTERNAL',
                  value: '${sensorData.temperature}°C',
                  status: 'STABLE',
                  statusColor: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SensorCard(
                  icon: LucideIcons.droplets,
                  label: 'MOISTURE',
                  value: '${sensorData.humidity}%',
                  status: 'TARGET',
                  statusColor: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SYSTEM CONFIGURATION',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.textTertiary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Control Center',
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
      ],
    );
  }

  Widget _buildModeToggle(FarmProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGreen.withAlpha(50),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildToggleItem(provider, true, 'AUTO'),
          _buildToggleItem(provider, false, 'MANUAL'),
        ],
      ),
    );
  }

  Widget _buildToggleItem(FarmProvider provider, bool mode, String label) {
    bool isSelected = provider.isAuto == mode;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          debugPrint('Tapping mode: $label');
          provider.setAutoMode(mode);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(30),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActuatorsHeader(bool isAuto) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: const [
            Icon(LucideIcons.cog, size: 20, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'Active Actuators',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Icon(
              isAuto ? LucideIcons.lock : LucideIcons.unlock,
              size: 14,
              color: AppColors.textTertiary,
            ),
            const SizedBox(width: 4),
            Text(
              isAuto ? 'LOCKED (AUTO)' : 'MANUAL MODE',
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActuatorList(FarmProvider provider) {
    final status = provider.deviceStatus;
    final isAuto = provider.isAuto;
    return Column(
      children: [
        _buildActuatorCard(
          LucideIcons.droplet,
          'Water Pump',
          'PUMP-01 • Subsurface Irrigation',
          status.pump,
          (val) => provider.setDevice('pump', val),
          isAuto,
        ),
        _buildActuatorCard(
          LucideIcons.wind,
          'Cooling Fan',
          'FAN-04 • Zone B Ventilation',
          status.fan,
          (val) => provider.setDevice('fan', val),
          isAuto,
        ),
        _buildActuatorCard(
          LucideIcons.sun,
          'Grow Light',
          'LED-09 • Full Spectrum Array',
          status.light,
          (val) => provider.setDevice('light', val),
          isAuto,
        ),
        _buildActuatorCard(
          LucideIcons.home,
          'Servo Roof',
          'SRV-02 • Retractable Ceiling',
          status.roof,
          (val) => provider.setDevice('roof', val),
          isAuto,
        ),
        _buildActuatorCard(
          LucideIcons.lightbulb,
          'Control LED',
          'LED-05 • Status Indicator',
          status.led,
          (val) => provider.setDevice('led', val),
          isAuto,
        ),
      ],
    );
  }

  Widget _buildActuatorCard(
    IconData icon,
    String title,
    String subtitle,
    bool isActive,
    Function(bool) onChanged,
    bool isAuto,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGreen.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isActive,
            onChanged: isAuto ? null : onChanged,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withAlpha(30),
          ),
        ],
      ),
    );
  }

  Widget _buildAIDiagnosticCard(FarmProvider provider) {
    final sensorData = provider.sensorData;
    final isAuto = provider.isAuto;

    double score = 100.0;
    if (sensorData.temperature > 30 || sensorData.temperature < 20) score -= 5;
    if (sensorData.humidity > 80 || sensorData.humidity < 40) score -= 5;
    if (sensorData.airQuality == 'Bad' || sensorData.gas > 1000) score -= 10;
    if (!isAuto) score -= 15;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border(
          left: BorderSide(
            color: isAuto ? AppColors.primary : Colors.orange,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isAuto ? LucideIcons.checkCircle : LucideIcons.alertTriangle,
                color: isAuto ? AppColors.accent : Colors.orange,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'AI DIAGNOSTIC',
                style: TextStyle(
                  color: isAuto ? AppColors.accent : Colors.orange,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isAuto ? 'Optimal Growth Cycle' : 'Manual Override Active',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            isAuto
                ? 'System is managing hydration and lumen levels based on current sensor data. Efficiency is maximized.'
                : 'Precision and efficiency may decrease during manual override. AI tracking remains active.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  (isAuto ? AppColors.lightGreen : Colors.orange.withAlpha(10))
                      .withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Precision Score',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${score.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: isAuto ? AppColors.primary : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
