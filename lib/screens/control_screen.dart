import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
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
}
