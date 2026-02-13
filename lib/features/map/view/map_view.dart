import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../viewmodel/map_view_model.dart';

class MapView extends StatelessWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MapViewModel()..init(),
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

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MapViewModel>(context);

    if (viewModel.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (!viewModel.isServiceActive) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bus_alert, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                "Servis saatleri dışındasınız\nveya servis hareket etmiyor",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // Konum geldiğinde ve harita hazır olduğunda kamerayı taşı
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
              target: viewModel.busLocation ??
                  const LatLng(41.0082, 28.9784), // Default Istanbul
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
          // Waiting indicator if location is null
          if (viewModel.busLocation == null)
            Positioned(
              top: 100,
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
                    Text("Servis konumu bekleniyor..."),
                  ],
                ),
              ),
            ),
          // Custom Buttons Example
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
