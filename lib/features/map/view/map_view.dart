import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/state/selected_student_state.dart';
import '../../home/data/models/home_status_model.dart';
import '../viewmodel/map_view_model.dart';

class MapView extends StatelessWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MapViewModel(
        selectedStudentState: context.read<SelectedStudentState>(),
      )..init(),
      child: const _MapViewContent(),
    );
  }
}

class _MapViewContent extends StatefulWidget {
  const _MapViewContent({Key? key}) : super(key: key);

  @override
  State<_MapViewContent> createState() => _MapViewContentState();
}

class _MapViewContentState extends State<_MapViewContent> {
  GoogleMapController? _mapController;
  bool _hasMovedToInitialLocation = false;
  String? _lastSelectedStudentId;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MapViewModel>(context);
    final safeTop = MediaQuery.of(context).padding.top + 12;

    if (_lastSelectedStudentId != viewModel.selectedStudentId) {
      _lastSelectedStudentId = viewModel.selectedStudentId;
      _hasMovedToInitialLocation = false;
    }

    if (viewModel.isLoading) {
      return Scaffold(
        body: Stack(
          children: [
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            _StudentSelectorOverlay(
              top: safeTop,
              students: viewModel.students,
              selectedStudentId: viewModel.selectedStudentId,
              onStudentChanged: viewModel.selectStudent,
            ),
          ],
        ),
      );
    }

    if (!viewModel.isServiceActive) {
      return Scaffold(
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bus_alert, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'Servis saatleri dışındasınız\nveya servis hareket etmiyor',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            _StudentSelectorOverlay(
              top: safeTop,
              students: viewModel.students,
              selectedStudentId: viewModel.selectedStudentId,
              onStudentChanged: viewModel.selectStudent,
            ),
          ],
        ),
      );
    }

    if (!_hasMovedToInitialLocation &&
        viewModel.busLocation != null &&
        _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(viewModel.busLocation!),
      );
      _hasMovedToInitialLocation = true;
    }

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: viewModel.busLocation ?? const LatLng(41.0082, 28.9784),
              zoom: 15,
            ),
            markers: viewModel.markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
              if (viewModel.busLocation != null) {
                controller.animateCamera(
                  CameraUpdate.newLatLng(viewModel.busLocation!),
                );
                _hasMovedToInitialLocation = true;
              }
            },
          ),
          if (viewModel.busLocation == null)
            Positioned(
              top: safeTop + 70,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Servis konumu bekleniyor...'),
                  ],
                ),
              ),
            ),
          _StudentSelectorOverlay(
            top: safeTop,
            students: viewModel.students,
            selectedStudentId: viewModel.selectedStudentId,
            onStudentChanged: viewModel.selectStudent,
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: () {
                if (viewModel.busLocation != null && _mapController != null) {
                  _mapController!.animateCamera(
                    CameraUpdate.newLatLng(viewModel.busLocation!),
                  );
                }
              },
              child: const Icon(Icons.center_focus_strong, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentSelectorOverlay extends StatelessWidget {
  const _StudentSelectorOverlay({
    required this.top,
    required this.students,
    required this.selectedStudentId,
    required this.onStudentChanged,
  });

  final double top;
  final List<Student> students;
  final String? selectedStudentId;
  final void Function(String studentId) onStudentChanged;

  @override
  Widget build(BuildContext context) {
    if (students.length <= 1) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: top,
      left: 16,
      right: 16,
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedStudentId,
              isExpanded: true,
              hint: const Text('Öğrenci seçin'),
              items: students
                  .map(
                    (student) => DropdownMenuItem<String>(
                      value: student.id,
                      child: Text(
                        student.fullName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (studentId) {
                if (studentId == null) {
                  return;
                }
                onStudentChanged(studentId);
              },
            ),
          ),
        ),
      ),
    );
  }
}
