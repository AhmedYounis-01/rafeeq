import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafeeq/core/extensions/theme_extension.dart';
import 'package:easy_localization/easy_localization.dart';

class LocationPickerDialog extends StatefulWidget {
  const LocationPickerDialog({super.key});

  @override
  State<LocationPickerDialog> createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<LocationPickerDialog> {
  LatLng _selectedLocation = const LatLng(30.0444, 31.2357); // Default Cairo
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  String _cityName = "";
  String _countryName = "";
  bool _isLoading = false;
  bool _addressLoading = false;

  Future<void> _searchCity(String query) async {
    if (query.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final newLatLng = LatLng(loc.latitude, loc.longitude);
        _selectedLocation = newLatLng;
        _mapController.move(newLatLng, 12);
        await _updateAddressInfo(loc.latitude, loc.longitude);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("errors.geocodingError".tr())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateAddressInfo(double lat, double lon) async {
    setState(() => _addressLoading = true);
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        setState(() {
          _cityName =
              p.locality ??
              p.subAdministrativeArea ??
              p.administrativeArea ??
              "errors.unknownCity".tr();
          _countryName = p.country ?? "";
        });
      }
    } catch (_) {
      setState(() {
        _cityName = "home.chosen_location".tr();
        _countryName = "";
      });
    } finally {
      if (mounted) setState(() => _addressLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 40.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search Bar Header
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 16.h),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.colorScheme.surfaceContainerHighest
                          .withValues(alpha:0.5),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: context.textTheme.bodyMedium,
                      decoration: InputDecoration(
                        hintText: "home.search_city_hint".tr(),
                        hintStyle: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant
                              .withValues(alpha:0.7),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: context.colorScheme.primary,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12.h,
                          horizontal: 16.w,
                        ),
                        suffixIcon: _isLoading
                            ? SizedBox(
                                width: 20.w,
                                height: 20.w,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      onSubmitted: _searchCity,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                IconButton.filled(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        context.colorScheme.surfaceContainerHighest,
                    foregroundColor: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Map Section (OpenStreetMap)
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedLocation,
                    initialZoom: 10,
                    onTap: (tapPosition, latLng) async {
                      setState(() => _selectedLocation = latLng);
                      await _updateAddressInfo(
                        latLng.latitude,
                        latLng.longitude,
                      );
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.rafeeq',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedLocation,
                          width: 40.w,
                          height: 40.w,
                          child: Icon(
                            Icons.location_on,
                            color: context.colorScheme.primary,
                            size: 40.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  bottom: 20.h,
                  right: 16.w,
                  child: Column(
                    children: [
                      FloatingActionButton.small(
                        heroTag: "zoom_in",
                        onPressed: () {
                          _mapController.move(
                            _mapController.camera.center,
                            _mapController.camera.zoom + 1,
                          );
                        },
                        child: const Icon(Icons.add),
                      ),
                      SizedBox(height: 8.h),
                      FloatingActionButton.small(
                        heroTag: "zoom_out",
                        onPressed: () {
                          _mapController.move(
                            _mapController.camera.center,
                            _mapController.camera.zoom - 1,
                          );
                        },
                        child: const Icon(Icons.remove),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Footer with Selected Location and Confirm Button
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: context.colorScheme.primary,
                      size: 24.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "home.chosen_location".tr(),
                            style: context.textTheme.labelSmall?.copyWith(
                              color: context.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_addressLoading)
                            _buildAddressLoading()
                          else
                            Text(
                              _cityName.isNotEmpty
                                  ? "$_cityName, $_countryName"
                                  : "home.click_map_hint".tr(),
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  height: 54.h,
                  child: ElevatedButton(
                    onPressed: (_cityName.isEmpty || _addressLoading)
                        ? null
                        : () {
                            Navigator.pop(context, {
                              'lat': _selectedLocation.latitude,
                              'lon': _selectedLocation.longitude,
                              'city': _cityName,
                              'country': _countryName,
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colorScheme.primary,
                      foregroundColor: context.colorScheme.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: Text(
                      "home.confirm_choice".tr(),
                      style: context.textTheme.titleMedium?.copyWith(
                        color: context.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressLoading() {
    return Container(
      width: 100.w,
      height: 14.h,
      margin: EdgeInsets.only(top: 4.h),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }
}
