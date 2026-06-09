import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../providers/farm_provider.dart';
import '../models/tomato_status.dart';
import 'treatment_detail_screen.dart';

class DoctorScreen extends StatefulWidget {
  const DoctorScreen({super.key});

  @override
  State<DoctorScreen> createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> {
  @override
  Widget build(BuildContext context) {
    final farmProvider = Provider.of<FarmProvider>(context);
    final scans = farmProvider.savedScans;
    final selectedIndex = farmProvider.selectedScanIndex;

    final TomatoStatus displayStatus;
    if (scans.isNotEmpty && selectedIndex < scans.length) {
      final record = scans[selectedIndex];
      displayStatus = TomatoStatus(
        diseaseName: record.diseaseName,
        diseaseStatus: record.diseaseStatus,
        imageUrl: record.imageUrl,
        lastUpdate: record.lastUpdate,
        treatmentStepByStep: record.treatmentStepByStep,
        ripenessLevel: record.ripenessLevel,
        ripenessStage: record.ripenessStage,
        harvestRecommendation: record.harvestRecommendation,
      );
    } else {
      displayStatus = farmProvider.tomatoStatus;
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),
          _buildTopBar(displayStatus),
          const SizedBox(height: 24),
          _buildSectorSelector(farmProvider),
          if (displayStatus.lastUpdate > 0) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.clock,
                    size: 14,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Last scanned: ${_formatTimestamp(displayStatus.lastUpdate)}',
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          _buildCameraView(displayStatus),
          const SizedBox(height: 24),
          _buildDiagnosticResult(displayStatus),
          const SizedBox(height: 24),
          _buildTreatmentPlan(displayStatus),
          const SizedBox(height: 24),
          _buildHistoryList(context, farmProvider),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTopBar(TomatoStatus status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(
              LucideIcons.heartPulse,
              color: AppColors.primary,
              size: 28,
            ),
            _buildOnlineBadge(status),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'AI Plant Doctor',
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
        const Text(
          'Real-time tomato disease detection & diagnostics',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildOnlineBadge(TomatoStatus status) {
    final hasData = status.lastUpdate > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: hasData
            ? AppColors.lightGreen.withValues(alpha: 0.5)
            : AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: hasData ? AppColors.accent : AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            hasData ? 'Active' : 'Offline',
            style: TextStyle(
              color: hasData ? AppColors.accent : AppColors.error,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectorSelector(FarmProvider farmProvider) {
    final scans = farmProvider.savedScans;
    if (scans.isEmpty) {
      return Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.lightGreen.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'Sector 01 (Live scan...)',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.lightGreen.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: scans.length,
        itemBuilder: (context, index) {
          final isSelected = farmProvider.selectedScanIndex == index;
          return GestureDetector(
            onTap: () => farmProvider.setSelectedScanIndex(index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Sector 0${index + 1}',
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCameraView(TomatoStatus status) {
    final bool hasDisease =
        status.diseaseStatus.toLowerCase() != 'none' &&
        status.diseaseStatus.isNotEmpty;
    final String imageUrl = status.imageUrl.isNotEmpty
        ? status.imageUrl
        : 'https://images.unsplash.com/photo-1592419044706-39796d40f98c?q=80&w=1000&auto=format&fit=crop';

    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                border: Border.all(
                  color: hasDisease ? Colors.red : Colors.green,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    color: hasDisease ? Colors.red : Colors.green,
                    child: Text(
                      hasDisease ? 'DISEASE DETECTED' : 'HEALTHY',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  Icon(LucideIcons.video, size: 14, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'AI ANALYSIS FEED',
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
        ],
      ),
    );
  }

  Widget _buildDiagnosticResult(TomatoStatus status) {
    final bool hasDisease =
        status.diseaseStatus.toLowerCase() != 'none' &&
        status.diseaseStatus.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border(
          left: BorderSide(
            color: hasDisease ? AppColors.error : AppColors.accent,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'DIAGNOSTIC RESULT',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textTertiary,
                  letterSpacing: 1.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: (hasDisease ? AppColors.error : AppColors.accent)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status.diseaseStatus.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: hasDisease ? AppColors.error : AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            status.diseaseName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: hasDisease ? AppColors.error : AppColors.textMain,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                hasDisease
                    ? LucideIcons.alertTriangle
                    : LucideIcons.checkCircle,
                color: hasDisease ? AppColors.error : AppColors.accent,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hasDisease
                      ? 'AI warning: Attention required for disease control.'
                      : 'Crops appear normal and healthy. No action needed.',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textMain,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentPlan(TomatoStatus status) {
    final bool hasTreatment = status.treatmentStepByStep.isNotEmpty;
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);
    final sectorName = farmProvider.savedScans.isNotEmpty
        ? 'Sector 0${farmProvider.selectedScanIndex + 1}'
        : 'Sector 01';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(LucideIcons.activity, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text(
                'Treatment Plan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            hasTreatment
                ? status.treatmentStepByStep
                : 'Crops are healthy. No active treatment plan is required at this time.',
            maxLines: hasTreatment ? 2 : 5,
            overflow: hasTreatment
                ? TextOverflow.ellipsis
                : TextOverflow.visible,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (hasTreatment) ...[
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TreatmentDetailScreen(
                      status: status,
                      sectorName: sectorName,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightGreen,
                foregroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(LucideIcons.eye, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Xem phác đồ chi tiết',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTimestamp(int timestamp) {
    if (timestamp == 0) return 'Never';
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(dt);
  }

  Widget _buildHistoryList(BuildContext context, FarmProvider farmProvider) {
    final records = farmProvider.savedScans;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Diagnostic Logs (All Sectors)',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            if (records.isNotEmpty)
              Text(
                '${records.length} saved',
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (records.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: const [
                Icon(
                  LucideIcons.folderOpen,
                  color: AppColors.textTertiary,
                  size: 36,
                ),
                SizedBox(height: 12),
                Text(
                  'No diagnostic logs found. Waiting for AI scan...',
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: records.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final record = records[index];
              final dateStr = DateFormat(
                'dd/MM/yyyy HH:mm:ss',
              ).format(DateTime.fromMillisecondsSinceEpoch(record.lastUpdate));
              final hasDisease = record.diseaseStatus.toLowerCase() != 'none';
              final isSelected = farmProvider.selectedScanIndex == index;

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: isSelected
                      ? Border.all(color: AppColors.primary, width: 1.5)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  clipBehavior: Clip.antiAlias,
                  borderRadius: BorderRadius.circular(16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: record.imageUrl.isNotEmpty
                          ? Image.network(
                              record.imageUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: AppColors.lightGreen,
                                    width: 48,
                                    height: 48,
                                    child: const Icon(
                                      LucideIcons.image,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                            )
                          : Container(
                              color: AppColors.lightGreen,
                              width: 48,
                              height: 48,
                              child: const Icon(
                                LucideIcons.image,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                    ),
                    title: Text(
                      'Sector 0${index + 1}: ${record.diseaseName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status: ${record.diseaseStatus}',
                          style: TextStyle(
                            color: hasDisease
                                ? AppColors.error
                                : AppColors.accent,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          dateStr,
                          style: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            LucideIcons.trash2,
                            color: AppColors.error,
                            size: 20,
                          ),
                          onPressed: () {
                            farmProvider.deleteDiagnostic(record.lastUpdate);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Log deleted successfully.'),
                              ),
                            );
                          },
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.textTertiary,
                        ),
                      ],
                    ),
                    onTap: () => farmProvider.setSelectedScanIndex(index),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
