import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../viewmodel/home_view_model.dart';
import 'widgets/eta_card.dart';
import 'widgets/driver_info_card.dart';
import 'widgets/student_info_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.fetchHomeData();
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'to_school':
        return 'Okula Gidiliyor';
      case 'to_home':
        return 'Eve Dönülüyor';
      case 'inactive':
      default:
        return 'Servis Beklemede';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, child) {
          if (_viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (_viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  SizedBox(height: size.height * 0.02),
                  Text(_viewModel.errorMessage!),
                  SizedBox(height: size.height * 0.02),
                  ElevatedButton(
                    onPressed: _viewModel.fetchHomeData,
                    child: const Text("Tekrar Dene"),
                  ),
                ],
              ),
            );
          }

          final data = _viewModel.homeStatus;
          if (data == null) {
            return const Center(child: Text("Veri bulunamadı"));
          }

          final isInactive = data.tripStatus == 'inactive';

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 20,
                    bottom: 40,
                    left: 20,
                    right: 20,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Güncel Durum",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: size.width * 0.04,
                        ),
                      ),
                      SizedBox(height: size.height * 0.01),
                      Text(
                        _getStatusText(data.tripStatus),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width * 0.07,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                  child: Column(
                    children: [
                      // Overlap the card with the header
                      Transform.translate(
                        offset: const Offset(0, -30),
                        child: EtaCard(
                          minutesLeft: data.minutesLeft,
                          isInactive: isInactive,
                        ),
                      ),

                      // Student Info
                      if (_viewModel.currentStudent != null) ...[
                        SizedBox(height: size.height * 0.02),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Öğrenci Bilgileri",
                            style: TextStyle(
                              fontSize: size.width * 0.045,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.015),
                        StudentInfoCard(
                          student: _viewModel.currentStudent!,
                        ),
                      ],

                      // Driver Info
                      if (data.driverName != null ||
                          data.plateNumber != null) ...[
                        SizedBox(height: size.height * 0.02),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Sürücü ve Araç Bilgileri",
                            style: TextStyle(
                              fontSize: size.width * 0.045,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.015),
                        DriverInfoCard(
                          driverName: data.driverName,
                          driverPhone: data.driverPhone,
                          plateNumber: data.plateNumber,
                          onCallPressed: data.driverPhone == null
                              ? null
                              : () async {
                                  final error = await _viewModel.callDriver(
                                    data.driverPhone,
                                  );
                                  if (!context.mounted || error == null) {
                                    return;
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(error)),
                                  );
                                },
                        ),
                      ],

                      SizedBox(height: size.height * 0.05),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
