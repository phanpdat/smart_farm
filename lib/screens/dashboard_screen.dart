import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/sensor_card.dart';
import '../providers/farm_provider.dart';
import '../models/tomato_status.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final farmProvider = Provider.of<FarmProvider>(context);
    final sensorData = farmProvider.sensorData;
    final tomatoStatus = farmProvider.tomatoStatus;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),
          _buildHeader(),
          const SizedBox(height: 20),
          _buildEstimatedHarvestCard(tomatoStatus),
          const SizedBox(height: 24),
          _buildSensorGrid(sensorData),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildEstimatedHarvestCard(TomatoStatus status) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(LucideIcons.leaf, color: Colors.white70, size: 18),
              SizedBox(width: 8),
              Text(
                'HARVEST RECOMMENDATION',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            status.harvestRecommendation.isEmpty
                ? 'Waiting for harvest recommendation data...'
                : status.harvestRecommendation,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Smart Farm System',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSensorGrid(dynamic sensorData) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SensorCard(
                icon: LucideIcons.thermometer,
                label: 'Temperature',
                value: '${sensorData.temperature.toStringAsFixed(1)}°C',
                status: sensorData.temperature >= 32.0
                    ? 'Hot (Fan ON)'
                    : (sensorData.temperature <= 24.0 ? 'Cool' : 'Optimal'),
                statusColor: sensorData.temperature >= 32.0
                    ? Colors.red
                    : (sensorData.temperature <= 24.0
                          ? Colors.blue
                          : AppColors.accent),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: SensorCard(
                icon: LucideIcons.sun,
                label: 'Light Intensity',
                value: '${sensorData.lightIntensity}%',
                status: sensorData.lightIntensity < 30
                    ? 'Low (LED ON)'
                    : 'Optimal',
                statusColor: sensorData.lightIntensity < 30
                    ? Colors.orange
                    : AppColors.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SensorCard(
                icon: LucideIcons.flame,
                label: 'Gas Level',
                value: '${sensorData.gas} ppm',
                status: sensorData.gas >= 690 ? 'Toxic (Fan ON)' : 'Safe',
                statusColor: sensorData.gas >= 690
                    ? Colors.red
                    : AppColors.accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SensorCard(
                icon: LucideIcons.cloudRain,
                label: 'Rainfall',
                value: '${sensorData.rain}%',
                status: sensorData.rain >= 30
                    ? 'Heavy Rain'
                    : (sensorData.rain >= 15 ? 'Light Rain' : 'No Rain'),
                statusColor: sensorData.rain >= 30
                    ? Colors.blue
                    : (sensorData.rain >= 15
                          ? Colors.lightBlue
                          : Colors.orange),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SensorCard(
                icon: LucideIcons.mountain,
                label: 'Soil Moisture',
                value: '${sensorData.soil}%',
                status: sensorData.soil <= 30
                    ? 'Dry (Watering)'
                    : (sensorData.soil >= 60 ? 'Wet (Optimal)' : 'Moist'),
                statusColor: sensorData.soil <= 30
                    ? Colors.red
                    : (sensorData.soil >= 60
                          ? AppColors.accent
                          : Colors.orange),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SensorCard(
                icon: LucideIcons.waves,
                label: 'Water Level',
                value: '${sensorData.water}%',
                status: sensorData.water < 10
                    ? 'Low (Forced Off)'
                    : (sensorData.water >= 75 ? 'Full' : 'Medium'),
                statusColor: sensorData.water < 10
                    ? Colors.red
                    : (sensorData.water >= 75
                          ? AppColors.accent
                          : Colors.orange),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
