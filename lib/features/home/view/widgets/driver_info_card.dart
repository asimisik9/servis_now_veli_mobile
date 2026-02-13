import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DriverInfoCard extends StatelessWidget {
  final String? driverName;
  final String? driverPhone;
  final String? plateNumber;
  final Future<void> Function()? onCallPressed;

  const DriverInfoCard({
    Key? key,
    this.driverName,
    this.driverPhone,
    this.plateNumber,
    this.onCallPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
              SizedBox(width: size.width * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Şoför",
                      style: TextStyle(
                        fontSize: size.width * 0.03,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      driverName ?? "Bilinmiyor",
                      style: TextStyle(
                        fontSize: size.width * 0.04,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (driverPhone != null)
                ElevatedButton.icon(
                  onPressed:
                      onCallPressed == null ? null : () => onCallPressed!(),
                  icon: const Icon(Icons.phone, size: 18),
                  label: const Text("Ara"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: TextStyle(fontSize: size.width * 0.035),
                  ),
                ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Araç Plakası",
                    style: TextStyle(
                      fontSize: size.width * 0.03,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    plateNumber ?? "---",
                    style: TextStyle(
                      fontSize: size.width * 0.04,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.directions_car, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}
