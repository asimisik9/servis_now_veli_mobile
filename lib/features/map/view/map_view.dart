import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/map_config.dart';
import '../../../core/state/selected_student_state.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/surface_card.dart';
import '../../home/data/models/home_status_model.dart';
import '../../main_wrapper/viewmodel/main_wrapper_view_model.dart';
import '../viewmodel/map_view_model.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MapViewModel(
        selectedStudentState: context.read<SelectedStudentState>(),
      ),
      child: const _MapViewContent(),
    );
  }
}

class _MapViewContent extends StatefulWidget {
  const _MapViewContent();

  @override
  State<_MapViewContent> createState() => _MapViewContentState();
}

class _MapViewContentState extends State<_MapViewContent> {
  final MapController _mapController = MapController();
  bool _hasMovedToInitialLocation = false;
  String? _lastSelectedStudentId;
  MainWrapperViewModel? _mainWrapperViewModel;
  bool _viewModelInitialized = false;

  static const LatLng _kIstanbul = LatLng(41.0082, 28.9784);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mainWrapperViewModel?.removeListener(_onTabChanged);
    _mainWrapperViewModel = context.read<MainWrapperViewModel>();
    _mainWrapperViewModel?.addListener(_onTabChanged);
    if (!_viewModelInitialized) {
      _viewModelInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<MapViewModel>().init(),
      );
    }
  }

  void _onTabChanged() {
    final mapVm = context.read<MapViewModel>();
    if (_mainWrapperViewModel?.currentIndex ==
        MainWrapperViewModel.mapTabIndex) {
      mapVm.onTabActivated();
    } else {
      mapVm.onTabDeactivated();
    }
  }

  @override
  void dispose() {
    _mainWrapperViewModel?.removeListener(_onTabChanged);
    _mapController.dispose();
    super.dispose();
  }

  void _centerOnBus(MapViewModel viewModel) {
    if (viewModel.busLocation != null) {
      _mapController.move(viewModel.busLocation!, 15.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MapViewModel>();
    final safeTop = MediaQuery.of(context).padding.top + AppSpacing.xs;

    if (_lastSelectedStudentId != viewModel.selectedStudentId) {
      _lastSelectedStudentId = viewModel.selectedStudentId;
      _hasMovedToInitialLocation = false;
    }

    if (!_hasMovedToInitialLocation && viewModel.busLocation != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(viewModel.busLocation!, 15.0);
        _hasMovedToInitialLocation = true;
      });
    }

    final bottomCardOffset = viewModel.isServiceActive ? 36.0 : 52.0;

    final busMarkers = viewModel.busLocation != null
        ? [
            Marker(
              point: viewModel.busLocation!,
              width: 48,
              height: 48,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.directions_bus_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ]
        : <Marker>[];

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: viewModel.busLocation ?? _kIstanbul,
              initialZoom: 14.6,
            ),
            children: [
              TileLayer(
                urlTemplate: MapConfig.tileUrlTemplate,
                userAgentPackageName: 'com.servisnow.parent',
                maxNativeZoom: 20,
              ),
              MarkerLayer(markers: busMarkers),
            ],
          ),
          Positioned(
            top: safeTop,
            left: AppSpacing.screenHorizontal,
            right: AppSpacing.screenHorizontal,
            child: _MapTopOverlay(viewModel: viewModel),
          ),
          if (viewModel.isLoading)
            const Center(
              child: SurfaceCard(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Konum verisi yükleniyor...',
                      style: AppTextStyles.bodySm,
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            right: AppSpacing.screenHorizontal,
            bottom: bottomCardOffset + 112,
            child: FloatingActionButton.small(
              heroTag: 'centerBus',
              onPressed: () => _centerOnBus(viewModel),
              child: const Icon(Icons.center_focus_strong_rounded),
            ),
          ),
          Positioned(
            left: AppSpacing.screenHorizontal,
            right: AppSpacing.screenHorizontal,
            bottom: bottomCardOffset,
            child: _MapStatusSheet(viewModel: viewModel),
          ),
        ],
      ),
    );
  }
}

class _MapTopOverlay extends StatelessWidget {
  const _MapTopOverlay({required this.viewModel});

  final MapViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: const Icon(
                  Icons.map_rounded,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Harita', style: AppTextStyles.titleLg),
                    const SizedBox(height: AppSpacing.xxxs),
                    Text(
                      viewModel.isServiceActive
                          ? 'Servis aracı canlı olarak izleniyor'
                          : 'Servis şu anda aktif değil',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.primaryDark.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxxs,
                ),
                decoration: BoxDecoration(
                  color: viewModel.isServiceActive
                      ? AppColors.primaryDark.withValues(alpha: 0.12)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  viewModel.isServiceActive ? 'Canlı' : 'Beklemede',
                  style: AppTextStyles.labelSm.copyWith(
                    color: viewModel.isServiceActive
                        ? AppColors.primaryDark
                        : const Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (viewModel.hasMultipleStudents) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: viewModel.selectedStudentId,
                  isExpanded: true,
                  hint: const Text('Öğrenci seçin'),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  items: viewModel.students
                      .map(
                        (Student student) => DropdownMenuItem<String>(
                          value: student.id,
                          child: Text(
                            student.fullName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (studentId) {
                    if (studentId != null) viewModel.selectStudent(studentId);
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MapStatusSheet extends StatelessWidget {
  const _MapStatusSheet({required this.viewModel});

  final MapViewModel viewModel;

  Future<void> _callDriver(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    final uri = Uri.parse('tel:$cleaned');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (viewModel.isServiceActive) {
      return _ActiveServiceCard(
        viewModel: viewModel,
        onCallDriver: viewModel.driverPhone != null
            ? () => _callDriver(viewModel.driverPhone!)
            : null,
      );
    }
    return _InactiveServiceCard(viewModel: viewModel);
  }
}

class _ActiveServiceCard extends StatelessWidget {
  const _ActiveServiceCard({
    required this.viewModel,
    required this.onCallDriver,
  });

  final MapViewModel viewModel;
  final VoidCallback? onCallDriver;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      borderRadius: BorderRadius.circular(AppRadius.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Canlı Konum Paylaşımı', style: AppTextStyles.titleMd),
              ),
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF16A34A),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                'Canlı',
                style: AppTextStyles.labelSm.copyWith(
                  color: const Color(0xFF16A34A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.primaryDark,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      viewModel.driverName ?? 'Sürücü Bilgisi',
                      style: AppTextStyles.titleMd.copyWith(
                        color: AppColors.primaryDark,
                      ),
                    ),
                    if (viewModel.driverPhone != null)
                      Text(
                        viewModel.driverPhone!,
                        style: AppTextStyles.labelSm.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                  ],
                ),
              ),
              if (viewModel.plateNumber != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxs,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.directions_bus_rounded,
                        size: 12,
                        color: AppColors.primaryDark,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        viewModel.plateNumber!,
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xxs),
              ],
              if (onCallDriver != null)
                GestureDetector(
                  onTap: onCallDriver,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: const Icon(
                      Icons.phone_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InactiveServiceCard extends StatelessWidget {
  const _InactiveServiceCard({required this.viewModel});

  final MapViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      borderRadius: BorderRadius.circular(AppRadius.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Servis Saatleri Dışında', style: AppTextStyles.titleMd),
              ),
              const Icon(Icons.bus_alert_rounded, color: Color(0xFF9CA3AF), size: 20),
            ],
          ),
          const SizedBox(height: AppSpacing.xxxs),
          Text(
            'Servis hareket ettiğinde canlı konum burada görünür.',
            style: AppTextStyles.bodySm.copyWith(color: const Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _MapMetric(
                  label: 'Öğrenci',
                  value: viewModel.students
                          .where((s) => s.id == viewModel.selectedStudentId)
                          .firstOrNull
                          ?.fullName ??
                      'Seçili değil',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Expanded(child: _MapMetric(label: 'Durum', value: 'Bekliyor')),
            ],
          ),
        ],
      ),
    );
  }
}

class _MapMetric extends StatelessWidget {
  const _MapMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(color: const Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: AppSpacing.xxxs),
          Text(
            value,
            style: AppTextStyles.titleMd.copyWith(color: AppColors.primaryDark),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

extension on Iterable<Student> {
  Student? get firstOrNull => isEmpty ? null : first;
}
