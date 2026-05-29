import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/sensor_card.dart';
import '../widgets/action_toggle.dart';
import '../providers/farm_provider.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final farmProvider = Provider.of<FarmProvider>(context);
    final sensorData = farmProvider.sensorData;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),
          _buildHeader(),
          const SizedBox(height: 24),
          _buildHeroCard(context, farmProvider),
          const SizedBox(height: 20),
          _buildGrowthVelocityChart(),
          const SizedBox(height: 20),
          _buildQuickActionGrid(farmProvider),
          const SizedBox(height: 24),
          _buildSensorGrid(sensorData),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 18,
          backgroundImage: NetworkImage('https://i.pravatar.cc/100?u=farmer'),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Digital Agrarian',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const Text(
              'Smart Farm System',
              style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
            ),
          ],
        ),
        const Spacer(),
        _buildOnlineBadge(),
      ],
    );
  }

  Widget _buildOnlineBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightGreen.withAlpha(50),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Online',
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, FarmProvider provider) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Mjpeg(
              isLive: true,
              error: (context, error, stack) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        LucideIcons.wifiOff,
                        color: Colors.white24,
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'CAMERA OFFLINE',
                        style: TextStyle(
                          color: Colors.white24,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        provider.cameraUrl,
                        style: const TextStyle(
                          color: Colors.white10,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                );
              },
              stream: provider.cameraUrl,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withAlpha(80)],
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: () => _showCameraUrlDialog(context, provider),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(50),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Icon(LucideIcons.video, size: 16, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'REC',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'LIVE FEED',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.white70,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'ESP32-CAM-01',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Cabbage Growth Project',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthVelocityChart() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.lightGreen.withAlpha(40),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PROJECTED VS ACTUAL',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textTertiary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Growth Velocity',
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildLegendItem(AppColors.primary, 'Actual'),
              const SizedBox(width: 16),
              _buildLegendItem(Colors.grey.withAlpha(30), 'Projected'),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceBetween,
                maxY: 12,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(show: false),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeBarGroup(0, 3, 2),
                  _makeBarGroup(1, 4, 3.5),
                  _makeBarGroup(2, 5.5, 5),
                  _makeBarGroup(3, 7, 6.5),
                  _makeBarGroup(4, 9, 8.5),
                  _makeBarGroup(5, 11, 10.5),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              children: [
                const TextSpan(text: 'Expected maturity in '),
                TextSpan(
                  text: '14 days',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double yProjected, double yActual) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: yProjected,
          color: Colors.grey.withAlpha(20),
          width: 36,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
          rodStackItems: [
            BarChartRodStackItem(0, yActual, AppColors.primary.withAlpha(60)),
            BarChartRodStackItem(
              yActual,
              yProjected,
              Colors.grey.withAlpha(10),
            ),
          ],
        ),
      ],
      showingTooltipIndicators: [],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionGrid(FarmProvider provider) {
    final status = provider.deviceStatus;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ActionToggle(
                icon: LucideIcons.droplet,
                label: 'PUMP',
                status: status.pump ? 'ON' : 'OFF',
                isActive: status.pump,
                onTap: () => provider.toggleDevice('pump', status.pump),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ActionToggle(
                icon: LucideIcons.fan,
                label: 'FAN',
                status: status.fan ? 'ON' : 'OFF',
                isActive: status.fan,
                onTap: () => provider.toggleDevice('fan', status.fan),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ActionToggle(
                icon: LucideIcons.sun,
                label: 'LIGHT',
                status: status.light ? 'ON' : 'OFF',
                isActive: status.light,
                onTap: () => provider.toggleDevice('light', status.light),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ActionToggle(
                icon: LucideIcons.home,
                label: 'ROOF',
                status: status.roof ? 'OPEN' : 'CLOSED',
                isActive: status.roof,
                onTap: () => provider.toggleDevice('roof', status.roof),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ActionToggle(
                icon: LucideIcons.lightbulb,
                label: 'LED',
                status: status.led ? 'ON' : 'OFF',
                isActive: status.led,
                onTap: () => provider.toggleDevice('led', status.led),
              ),
            ),
            const Spacer(), // Placeholder to keep grid aligned if odd number
          ],
        ),
      ],
    );
  }

  Widget _buildSensorGrid(dynamic sensorData) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SensorCard(
                icon: LucideIcons.thermometer,
                label: 'Temperature',
                value: '${sensorData.temperature}°C',
                status: 'Optimal',
                statusColor: AppColors.accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SensorCard(
                icon: LucideIcons.droplets,
                label: 'Soil Moisture',
                value: '${sensorData.humidity}%',
                status: 'Moist',
                statusColor: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SensorCard(
                icon: LucideIcons.sun,
                label: 'Light Intensity',
                value: '${sensorData.lightIntensity}%',
                status: 'Moderate',
                statusColor: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SensorCard(
                icon: LucideIcons.wind,
                label: 'Air Quality',
                value: sensorData.airQuality,
                status: 'Clean',
                statusColor: AppColors.accent,
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
                status: sensorData.gas < 1000 ? 'Safe' : 'Warning',
                statusColor: sensorData.gas < 1000 ? AppColors.accent : Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SensorCard(
                icon: LucideIcons.cloudRain,
                label: 'Rainfall',
                value: sensorData.rain < 2000 ? 'Raining' : 'Dry',
                status: 'Analog: ${sensorData.rain}',
                statusColor: sensorData.rain < 2000 ? Colors.blue : Colors.orange,
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
                label: 'Soil Sensor',
                value: sensorData.soil < 2000 ? 'Wet' : 'Dry',
                status: 'Value: ${sensorData.soil}',
                statusColor: sensorData.soil < 2000 ? Colors.blue : Colors.brown,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SensorCard(
                icon: LucideIcons.waves,
                label: 'Water Level',
                value: sensorData.water > 500 ? 'Full' : 'Low',
                status: 'Value: ${sensorData.water}',
                statusColor: sensorData.water > 500 ? AppColors.accent : Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showCameraUrlDialog(BuildContext context, FarmProvider provider) {
    final TextEditingController controller = TextEditingController(
      text: provider.cameraUrl,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configure Camera URL'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g., http://192.168.1.39:81/stream',
            labelText: 'Camera Stream URL',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.setCameraUrl(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
