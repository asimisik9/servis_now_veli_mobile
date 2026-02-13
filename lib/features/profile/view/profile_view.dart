import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../auth/view/login_view.dart';
import '../viewmodel/profile_view_model.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel()..init(),
      child: const _ProfileViewContent(),
    );
  }
}

class _ProfileViewContent extends StatelessWidget {
  const _ProfileViewContent({Key? key}) : super(key: key);

  void _showLogoutDialog(BuildContext context, ProfileViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Çıkış Yap"),
        content:
            const Text("Uygulamadan çıkış yapmak istediğinize emin misiniz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          TextButton(
            onPressed: () async {
              final success = await viewModel.logout();
              if (!context.mounted) {
                return;
              }
              Navigator.pop(context); // Close dialog
              if (success) {
                Navigator.of(context, rootNavigator: true).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginView()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Çıkış yapılırken bir hata oluştu."),
                  ),
                );
              }
            },
            child: const Text("Çıkış Yap", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAbsenceChange(
      BuildContext context, bool value, ProfileViewModel viewModel) async {
    if (!value) {
      // User is trying to set "Not Coming"
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Emin misiniz?"),
          content: const Text(
              "Öğrencinin bugün okula gelmeyeceğini bildirmek üzeresiniz. Servis rotası buna göre güncellenecektir."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("İptal"),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () => Navigator.pop(context, true),
              child:
                  const Text("Onayla", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await viewModel.toggleAbsence(false);
      }
    } else {
      // User is setting back to "Going"
      await viewModel.toggleAbsence(true);
    }
  }

  Future<void> _showAddressChangeDialog(
      BuildContext context, ProfileViewModel viewModel) async {
    final TextEditingController addressController = TextEditingController(
      text: viewModel.currentStudent?.address ?? "",
    );

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Adres Değişikliği"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Lütfen yeni açık adresinizi giriniz:"),
            const SizedBox(height: 10),
            TextField(
              controller: addressController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Açık adres...",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(context, addressController.text),
            child: const Text("Kaydet", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final success = await viewModel.updateAddress(result);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Adres başarıyla güncellendi.")),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Adres güncellenirken bir hata oluştu.")),
        );
      }
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ProfileViewModel>(context);
    final size = MediaQuery.of(context).size;

    if (viewModel.isLoading && viewModel.currentStudent == null) {
      return const Scaffold(
        body:
            Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                bottom: 30,
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
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person,
                        size: 40, color: Colors.grey.shade400),
                  ),
                  SizedBox(height: size.height * 0.02),
                  const Text(
                    "Sayın Veli", // We could fetch parent name too
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (viewModel.currentStudent != null) ...[
                    SizedBox(height: size.height * 0.01),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        viewModel.currentStudent!.fullName,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(size.width * 0.05),
              child: Column(
                children: [
                  // Absence Card
                  Container(
                    padding: const EdgeInsets.all(20),
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
                      border: viewModel.isAbsent
                          ? Border.all(color: Colors.orange, width: 2)
                          : null,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: viewModel.isAbsent
                                        ? Colors.orange.withValues(alpha: 0.1)
                                        : AppColors.primary
                                            .withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    viewModel.isAbsent
                                        ? Icons.warning_amber_rounded
                                        : Icons.school,
                                    color: viewModel.isAbsent
                                        ? Colors.orange
                                        : AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Okul Durumu",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      viewModel.isAbsent
                                          ? "Gelmeyecek"
                                          : "Gidiyor",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: viewModel.isAbsent
                                            ? Colors.orange
                                            : Colors.green,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Switch(
                              value: !viewModel.isAbsent,
                              activeThumbColor: AppColors.accent,
                              onChanged: (val) =>
                                  _handleAbsenceChange(context, val, viewModel),
                            ),
                          ],
                        ),
                        if (viewModel.isAbsent) ...[
                          const Divider(height: 30),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline,
                                    color: Colors.orange, size: 20),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "Bugün izinli olarak işaretlendi.",
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.03),

                  // Student Info Card
                  if (viewModel.currentStudent != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Öğrenci Bilgileri",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildInfoRow(Icons.person, "Ad Soyad",
                              viewModel.currentStudent!.fullName),
                          const Divider(height: 30),
                          _buildInfoRow(
                            Icons.school,
                            "Okul",
                            viewModel.currentStudent!.schoolName ??
                                viewModel.currentStudent!.schoolId ??
                                "Okul bilgisi yok",
                          ),
                          const Divider(height: 30),
                          _buildInfoRow(
                              Icons.location_on,
                              "Adres",
                              viewModel.currentStudent!.address ??
                                  "Adres girilmemiş"),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _showAddressChangeDialog(context, viewModel),
                              icon: const Icon(Icons.edit_location_alt,
                                  color: Colors.white),
                              label: const Text("Adres Değişikliği",
                                  style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                  ],

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: viewModel.isLoggingOut
                          ? null
                          : () => _showLogoutDialog(context, viewModel),
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text("Çıkış Yap",
                          style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
