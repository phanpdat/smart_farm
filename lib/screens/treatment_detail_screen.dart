import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../models/tomato_status.dart';

class TreatmentDetailScreen extends StatelessWidget {
  final TomatoStatus status;
  final String sectorName;

  const TreatmentDetailScreen({
    super.key,
    required this.status,
    required this.sectorName,
  });

  @override
  Widget build(BuildContext context) {
    final isNoneDisease = status.diseaseName.toLowerCase() == 'none';

    final steps = status.treatmentStepByStep.toLowerCase().trim() == 'none'
        ? <String>[]
        : status.treatmentStepByStep
              .split('\n')
              .where(
                (s) => s.trim().isNotEmpty && s.toLowerCase().trim() != 'none',
              )
              .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textMain),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Treatment Details',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isNoneDisease ? 'Healthy Crops' : status.diseaseName,
              style: GoogleFonts.outfit(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ),

            const SizedBox(height: 24),
            Text(
              'Recommended Protocol',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 16),
            if (steps.isEmpty)
              const Text(
                'Crops are healthy. No active treatment plan is required at this time.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: steps.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final step = steps[index];
                  final cleanStep = step
                      .replaceFirst(RegExp(r'^(\d+\.\s*|-\s*|•\s*)'), '')
                      .trim();

                  return Text(
                    cleanStep,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: AppColors.textMain,
                    ),
                  );
                },
              ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(LucideIcons.checkCircle, size: 20),
              label: const Text(
                'Complete Treatment',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Treatment protocol acknowledged & scheduled!',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
