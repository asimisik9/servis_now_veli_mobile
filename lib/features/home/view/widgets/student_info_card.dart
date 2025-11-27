import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/home_status_model.dart';

class StudentInfoCard extends StatelessWidget {
  final Student student;

  const StudentInfoCard({
    Key? key,
    required this.student,
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
                child: const Icon(Icons.school, color: AppColors.primary),
              ),
              SizedBox(width: size.width * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Öğrenci",
                      style: TextStyle(
                        fontSize: size.width * 0.03,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      student.fullName,
                      style: TextStyle(
                        fontSize: size.width * 0.04,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
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
                    "Öğrenci No",
                    style: TextStyle(
                      fontSize: size.width * 0.03,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    student.studentNumber,
                    style: TextStyle(
                      fontSize: size.width * 0.04,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.badge, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}
