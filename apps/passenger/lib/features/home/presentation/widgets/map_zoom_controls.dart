import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxigo_core/taxigo_core.dart';

class MapZoomControls extends StatelessWidget {
  const MapZoomControls({super.key, required this.controller});

  final GoogleMapController? controller;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.glass,
      borderRadius: BorderRadius.circular(14),
      elevation: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Yakınlaştır',
            onPressed: controller == null
                ? null
                : () => controller!.animateCamera(CameraUpdate.zoomIn()),
            icon: const Icon(Icons.add, color: AppColors.ink),
          ),
          const SizedBox(
            width: 28,
            child: Divider(height: 1),
          ),
          IconButton(
            tooltip: 'Uzaklaştır',
            onPressed: controller == null
                ? null
                : () => controller!.animateCamera(CameraUpdate.zoomOut()),
            icon: const Icon(Icons.remove, color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}
