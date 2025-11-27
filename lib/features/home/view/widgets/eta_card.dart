import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class EtaCard extends StatelessWidget {
  final int? minutesLeft;
  final bool isInactive;

  const EtaCard({
    Key? key,
    this.minutesLeft,
    this.isInactive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            isInactive ? Icons.bus_alert : Icons.directions_bus,
            size: size.width * 0.12,
            color: isInactive ? Colors.grey : AppColors.accent,
          ),
          SizedBox(height: size.height * 0.02),
          Text(
            isInactive ? "Servis şu an aktif değil" : "Tahmini Varış",
            style: TextStyle(
              fontSize: size.width * 0.04,
              color: AppColors.textSecondary,
            ),
          ),
          if (!isInactive && minutesLeft != null) ...[
            SizedBox(height: size.height * 0.01),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "$minutesLeft",
                    style: TextStyle(
                      fontSize: size.width * 0.1,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  TextSpan(
                    text: " Dakika",
                    style: TextStyle(
                      fontSize: size.width * 0.05,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
