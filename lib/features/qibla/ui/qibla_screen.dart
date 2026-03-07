// import 'dart:async';
// import 'dart:math' as math;

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_qiblah/flutter_qiblah.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:easy_localization/easy_localization.dart' hide TextDirection;

// class QiblaScreen extends StatefulWidget {
//   const QiblaScreen({super.key});

//   @override
//   State<QiblaScreen> createState() => _QiblaScreenState();
// }

// class _QiblaScreenState extends State<QiblaScreen> {
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     SystemChrome.setSystemUIOverlayStyle(
//       const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
//     );
//   }

//   // sensor support future (runs once)
//   final Future<bool?> _sensorSupportFuture =
//       FlutterQiblah.androidDeviceSensorSupport();

//   // location status emitted into a StreamController so we can re-check
//   final _locationStreamController =
//       StreamController<LocationStatus>.broadcast();
//   Stream<LocationStatus> get _locationStream =>
//       _locationStreamController.stream;

//   @override
//   void initState() {
//     super.initState();
//     _checkLocationStatus();
//   }

//   @override
//   void dispose() {
//     _locationStreamController.close();
//     FlutterQiblah().dispose();
//     super.dispose();
//   }

//   // ── location status ───────────────────────────────────────────
//   Future<void> _checkLocationStatus() async {
//     final locationStatus = await FlutterQiblah.checkLocationStatus();
//     if (locationStatus.enabled &&
//         locationStatus.status == LocationPermission.denied) {
//       await FlutterQiblah.requestPermissions();
//       final updated = await FlutterQiblah.checkLocationStatus();
//       _locationStreamController.sink.add(updated);
//     } else {
//       _locationStreamController.sink.add(locationStatus);
//     }
//   }

//   // Opens the OS location-settings screen, then re-checks when resumed
//   Future<void> _openLocationSettings() async {
//     await Geolocator.openLocationSettings();
//     // small delay to let the OS return properly
//     await Future.delayed(const Duration(milliseconds: 500));
//     _checkLocationStatus();
//   }

//   // ── build ─────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Theme.of(context).scaffoldBackgroundColor,
//         gradient: LinearGradient(
//           colors: [
//             const Color(0xFF0A1F17),
//             const Color(0xFF081812),
//             const Color(0xFF05100C),
//           ],
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//         ),
//       ),
//       child: Column(
//         children: [
//           // Header with Image and Info Button
//           Stack(
//             children: [
//               Image.asset(
//                 'assets/images/mosque2.jpg',
//                 width: double.infinity,
//                 height: 180.h,
//                 fit: BoxFit.cover,
//                 color: Colors.black.withOpacity(0.3),
//                 colorBlendMode: BlendMode.darken,
//               ),
//               Positioned(
//                 top: 0,
//                 left: 0,
//                 right: 0,
//                 child: SafeArea(
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 16.w,
//                       vertical: 8.h,
//                     ),
//                     child: Align(
//                       alignment: Alignment.centerRight,
//                       child: IconButton(
//                         onPressed: () => _showInstructions(context),
//                         icon: Icon(
//                           Icons.info_outline_rounded,
//                           color: Colors.white,
//                           size: 24.sp,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           // Main content
//           Expanded(child: _buildBody()),
//         ],
//       ),
//     );
//   }

//   Widget _buildBody() {
//     return _buildCompassSection();
//   }

//   // ── compass section ───────────────────────────────────────────
//   Widget _buildCompassSection() {
//     // Step 1: check sensor support (Android only; iOS always true)
//     return FutureBuilder<bool?>(
//       future: _sensorSupportFuture,
//       builder: (context, sensorSnapshot) {
//         if (sensorSnapshot.connectionState == ConnectionState.waiting) {
//           return _loadingIndicator();
//         }

//         // On iOS, androidDeviceSensorSupport() returns null → treat as supported
//         final hasSensor = sensorSnapshot.data ?? true;

//         if (!hasSensor) {
//           return _NoSensorView();
//         }

//         // Step 2: check location
//         return StreamBuilder<LocationStatus>(
//           stream: _locationStream,
//           builder: (context, locSnapshot) {
//             if (locSnapshot.connectionState == ConnectionState.waiting) {
//               return _loadingIndicator();
//             }

//             final locStatus = locSnapshot.data;

//             // Location service disabled
//             if (locStatus == null || !locStatus.enabled) {
//               return _LocationErrorView(
//                 message: "qibla.activate_location".tr(),
//                 onEnable: _openLocationSettings,
//               );
//             }

//             // Permission denied
//             if (locStatus.status == LocationPermission.denied ||
//                 locStatus.status == LocationPermission.deniedForever) {
//               return _LocationErrorView(
//                 message: locStatus.status == LocationPermission.deniedForever
//                     ? "qibla.permission_denied_forever".tr()
//                     : "qibla.activate_location".tr(),
//                 onEnable: locStatus.status == LocationPermission.deniedForever
//                     ? () async {
//                         await Geolocator.openAppSettings();
//                         await Future.delayed(const Duration(milliseconds: 500));
//                         _checkLocationStatus();
//                       }
//                     : _checkLocationStatus,
//               );
//             }

//             // All good → show compass
//             return const _QiblaCompassWidget();
//           },
//         );
//       },
//     );
//   }

//   void _showInstructions(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         padding: EdgeInsets.all(24.r),
//         decoration: BoxDecoration(
//           color: const Color(0xFF081812),
//           borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
//           border: Border(
//             top: BorderSide(color: const Color(0xFFC9A24D), width: 2),
//           ),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 40.w,
//               height: 4.h,
//               decoration: BoxDecoration(
//                 color: Colors.white24,
//                 borderRadius: BorderRadius.circular(2.r),
//               ),
//             ),
//             SizedBox(height: 24.h),
//             Icon(
//               Icons.screen_rotation_rounded,
//               color: const Color(0xFFC9A24D),
//               size: 48.sp,
//             ),
//             SizedBox(height: 16.h),
//             Text(
//               "qibla.instructions_title".tr(),
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 20.sp,
//                 fontWeight: FontWeight.bold,
//                 fontFamily: 'Tajawal',
//               ),
//             ),
//             SizedBox(height: 16.h),
//             Text(
//               "qibla.activate_location_message".tr(),
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.white70,
//                 fontSize: 16.sp,
//                 fontFamily: 'Tajawal',
//                 height: 1.5,
//               ),
//             ),
//             SizedBox(height: 32.h),
//             ElevatedButton(
//               onPressed: () => Navigator.pop(context),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF029E50),
//                 foregroundColor: Colors.white,
//                 minimumSize: Size(double.infinity, 50.h),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15.r),
//                 ),
//                 elevation: 0,
//               ),
//               child: Text(
//                 "qibla.understand".tr(),
//                 style: TextStyle(
//                   fontSize: 16.sp,
//                   fontWeight: FontWeight.bold,
//                   fontFamily: 'Tajawal',
//                 ),
//               ),
//             ),
//             SizedBox(height: 16.h),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _loadingIndicator() {
//     return const Center(
//       child: CircularProgressIndicator(
//         color: Color(0xFF029E50),
//         strokeWidth: 3,
//       ),
//     );
//   }
// }

// // ─── Compass Widget ───────────────────────────────────────────
// class _QiblaCompassWidget extends StatelessWidget {
//   const _QiblaCompassWidget();

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QiblahDirection>(
//       stream: FlutterQiblah.qiblahStream,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(
//             child: CircularProgressIndicator(
//               color: Color(0xFF029E50),
//               strokeWidth: 3,
//             ),
//           );
//         }

//         if (snapshot.hasError || !snapshot.hasData) {
//           return _NoSensorView();
//         }

//         final qiblahDirection = snapshot.data!;
//         // compassAngle: rotation for the compass face (N,E,S,W) to point North relative to phone
//         final compassAngle = qiblahDirection.direction * (math.pi / 180) * -1;
//         // qiblaAngle: rotation for the marker relative to device top
//         final qiblaAngle = (qiblahDirection.qiblah) * (math.pi / 180) * -1;
//         return LayoutBuilder(
//           builder: (context, constraints) {
//             return Column(
//               children: [
//                 SizedBox(height: 24.h),
//                 // Kaaba Icon (Professional white mosque icon)
//                 Icon(
//                   Icons.mosque_outlined,
//                   color: Colors.white.withOpacity(0.95),
//                   size: 52.sp,
//                 ),
//                 SizedBox(height: 4.h),
//                 // Premium Green Indicator Arrow
//                 TweenAnimationBuilder<double>(
//                   tween: Tween(begin: 0, end: 1),
//                   duration: const Duration(seconds: 1),
//                   builder: (context, value, child) {
//                     return Opacity(
//                       opacity: value,
//                       child: Icon(
//                         Icons.keyboard_arrow_up_rounded,
//                         color: const Color(0xFF029E50),
//                         size: 44.sp,
//                       ),
//                     );
//                   },
//                 ),
//                 SizedBox(height: 12.h),
//                 // Compass Section with fixed sizing and smooth movement
//                 Expanded(
//                   child: Center(
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 20.w),
//                       child: AspectRatio(
//                         aspectRatio: 1,
//                         child: Stack(
//                           alignment: Alignment.center,
//                           children: [
//                             // 1. Static Ornamental Mandala (Background)
//                             CustomPaint(
//                               size: Size.infinite,
//                               painter: _OrnamentalRingPainter(isDark: true),
//                             ),
//                             // 2. Rotating Compass Disk (N, S, E, W and Ticks)
//                             Transform.rotate(
//                               angle: compassAngle,
//                               child: LayoutBuilder(
//                                 builder: (context, constraints) {
//                                   final outerSize = constraints.maxWidth;
//                                   final innerDiskSize = outerSize * 0.82;
//                                   return Stack(
//                                     alignment: Alignment.center,
//                                     children: [
//                                       // Compass Face Disk (Layered Look)
//                                       Container(
//                                         width: innerDiskSize,
//                                         height: innerDiskSize,
//                                         decoration: BoxDecoration(
//                                           shape: BoxShape.circle,
//                                           gradient: const RadialGradient(
//                                             colors: [
//                                               Color(0xFF1E583A),
//                                               Color(0xFF0F2D1E),
//                                               Color(0xFF0D2519),
//                                               Color(0xFF081A12),
//                                             ],
//                                             stops: [0.0, 0.4, 0.8, 1.0],
//                                           ),
//                                           border: Border.all(
//                                             color: const Color(
//                                               0xFFC9A24D,
//                                             ).withOpacity(0.3),
//                                             width: 1.5,
//                                           ),
//                                           boxShadow: [
//                                             BoxShadow(
//                                               color: Colors.black54,
//                                               blurRadius: 10,
//                                               spreadRadius: 1,
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       // Tick marks & Labels (Rotates with Disk)
//                                       CustomPaint(
//                                         size: Size(
//                                           innerDiskSize,
//                                           innerDiskSize,
//                                         ),
//                                         painter: _CompassTicksPainter(
//                                           isDark: true,
//                                         ),
//                                       ),
//                                       // Labels positioned relative to outer size for more distance
//                                       _buildDirectionLabels(true, outerSize),
//                                       // North Pointer (Center Star)
//                                       CustomPaint(
//                                         size: Size(
//                                           innerDiskSize * 0.72,
//                                           innerDiskSize * 0.72,
//                                         ),
//                                         painter: _CompassNeedlePainter(
//                                           isDark: true,
//                                         ),
//                                       ),
//                                     ],
//                                   );
//                                 },
//                               ),
//                             ),
//                             // 3. Absolute Qibla Indicator (Mosque Marker)
//                             // This must rotate around the center of the STACK
//                             SizedBox.expand(
//                               child: Transform.rotate(
//                                 angle: qiblaAngle,
//                                 child: Align(
//                                   alignment: Alignment.topCenter,
//                                   child: Container(
//                                     width: 46.w,
//                                     height: 46.w,
//                                     // Slight offset to sit on the ornamental ring
//                                     margin: EdgeInsets.only(top: 8.h),
//                                     decoration: BoxDecoration(
//                                       shape: BoxShape.circle,
//                                       color: Colors.white,
//                                       border: Border.all(
//                                         color: const Color(0xFFC9A24D),
//                                         width: 2.5,
//                                       ),
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: Colors.black.withOpacity(0.6),
//                                           blurRadius: 10,
//                                           offset: const Offset(0, 4),
//                                         ),
//                                       ],
//                                     ),
//                                     child: Container(
//                                       margin: EdgeInsets.all(3.r),
//                                       decoration: const BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: Color(0xFF014D28),
//                                       ),
//                                       child: Icon(
//                                         Icons.mosque_rounded,
//                                         size: 22.sp,
//                                         color: const Color(0xFFC9A24D),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 // Numerical Direction
//                 Padding(
//                   padding: EdgeInsets.symmetric(vertical: 20.h),
//                   child: Container(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 16.w,
//                       vertical: 8.h,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.05),
//                       borderRadius: BorderRadius.circular(20.r),
//                       border: Border.all(color: Colors.white10),
//                     ),
//                     child: Text(
//                       "${qiblahDirection.offset.toStringAsFixed(1)}°",
//                       style: TextStyle(
//                         color: const Color(0xFFC9A24D),
//                         fontSize: 22.sp,
//                         fontFamily: 'Tajawal',
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 1.2,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   static Widget _buildDirectionLabels(bool isDark, double size) {
//     final style = TextStyle(
//       color: isDark ? Colors.white : const Color(0xFF014D28),
//       fontWeight: FontWeight.bold,
//       fontSize: (size * 0.055).clamp(13.0, 18.0).sp,
//       letterSpacing: 1.2,
//     );
//     // Labels are placed within the inner disk area but far enough from center
//     return SizedBox(
//       width: size,
//       height: size,
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           Align(
//             alignment: const Alignment(0, -0.68),
//             child: Text(
//               "N",
//               style: style.copyWith(
//                 color: const Color(0xFF029E50),
//                 fontSize: style.fontSize! + 2,
//               ),
//             ),
//           ),
//           Align(
//             alignment: const Alignment(0.68, 0),
//             child: Text("E", style: style),
//           ),
//           Align(
//             alignment: const Alignment(0, 0.68),
//             child: Text("S", style: style),
//           ),
//           Align(
//             alignment: const Alignment(-0.68, 0),
//             child: Text("W", style: style),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─── No Sensor Fallback ──────────────────────────────────────
// class _NoSensorView extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.all(30.w),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               Icons.sensors_off_rounded,
//               size: 80.sp,
//               color: const Color(0xFFC9A24D),
//             ),
//             SizedBox(height: 24.h),
//             Text(
//               "qibla.no_sensor".tr(),
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: isDark ? Colors.white : Colors.black87,
//                 fontSize: 18.sp,
//                 fontWeight: FontWeight.w600,
//                 fontFamily: 'Tajawal',
//                 height: 1.6,
//               ),
//             ),
//             SizedBox(height: 12.h),
//             Text(
//               "qibla.no_sensor_details".tr(),
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: isDark ? Colors.white54 : Colors.black54,
//                 fontSize: 14.sp,
//                 fontFamily: 'Tajawal',
//                 height: 1.5,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─── Location Error View ─────────────────────────────────────
// class _LocationErrorView extends StatelessWidget {
//   final String message;
//   final VoidCallback? onEnable;

//   const _LocationErrorView({required this.message, this.onEnable});

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 30.w),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Spacer(),
//           // Location illustration
//           SizedBox(
//             width: 200.w,
//             height: 200.w,
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 // Buildings
//                 Icon(
//                   Icons.location_city_rounded,
//                   size: 100.sp,
//                   color: const Color(0xFF1B7A4A).withValues(alpha: 0.4),
//                 ),
//                 // Pin
//                 Positioned(
//                   top: 20.h,
//                   child: Container(
//                     width: 60.w,
//                     height: 80.h,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFC9A24D),
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(30.r),
//                         topRight: Radius.circular(30.r),
//                         bottomLeft: Radius.circular(4.r),
//                         bottomRight: Radius.circular(30.r),
//                       ),
//                     ),
//                     child: Icon(
//                       Icons.location_on_rounded,
//                       size: 40.sp,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//                 // Clouds
//                 Positioned(
//                   top: 10.h,
//                   right: 20.w,
//                   child: Icon(
//                     Icons.cloud,
//                     size: 30.sp,
//                     color: isDark
//                         ? Colors.white12
//                         : Colors.grey.withValues(alpha: 0.1),
//                   ),
//                 ),
//                 Positioned(
//                   top: 30.h,
//                   left: 10.w,
//                   child: Icon(
//                     Icons.cloud,
//                     size: 24.sp,
//                     color: isDark
//                         ? Colors.white10
//                         : Colors.grey.withValues(alpha: 0.05),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 30.h),
//           Text(
//             message,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: isDark ? Colors.white : Colors.black87,
//               fontSize: 18.sp,
//               fontWeight: FontWeight.w600,
//               fontFamily: 'Tajawal',
//               height: 1.6,
//             ),
//           ),
//           const Spacer(),
//           // Enable button
//           SizedBox(
//             width: double.infinity,
//             height: 52.h,
//             child: ElevatedButton(
//               onPressed: onEnable,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF014D28),
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(14.r),
//                 ),
//                 elevation: 0,
//               ),
//               child: Text(
//                 "qibla.activate".tr(),
//                 style: TextStyle(
//                   fontSize: 17.sp,
//                   fontWeight: FontWeight.bold,
//                   fontFamily: 'Tajawal',
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(height: 30.h),
//         ],
//       ),
//     );
//   }
// }

// // ─── Custom Painters ─────────────────────────────────────────

// /// Ornamental ring (mandala-like) around the compass
// class _OrnamentalRingPainter extends CustomPainter {
//   final bool isDark;
//   _OrnamentalRingPainter({required this.isDark});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final outerRadius = size.width / 2;
//     final innerRadius = outerRadius * 0.84;

//     final baseColor = isDark
//         ? const Color(0xFF1B7A4A)
//         : const Color(0xFF014D28);

//     // Outer glow circle
//     final glowPaint = Paint()
//       ..color = baseColor.withOpacity(0.15)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2;
//     canvas.drawCircle(center, outerRadius, glowPaint);

//     // Ornamental mandala petals
//     final petalPaint = Paint()
//       ..color = baseColor.withOpacity(0.4)
//       ..style = PaintingStyle.fill;

//     const int petalCount = 16;
//     for (int i = 0; i < petalCount; i++) {
//       final angle = (i * (360 / petalCount)) * (math.pi / 180);
//       final p1 = Offset(
//         center.dx + math.cos(angle - 0.1) * (innerRadius * 1.05),
//         center.dy + math.sin(angle - 0.1) * (innerRadius * 1.05),
//       );
//       final p2 = Offset(
//         center.dx + math.cos(angle + 0.1) * (innerRadius * 1.05),
//         center.dy + math.sin(angle + 0.1) * (innerRadius * 1.05),
//       );
//       final pTip = Offset(
//         center.dx + math.cos(angle) * outerRadius,
//         center.dy + math.sin(angle) * outerRadius,
//       );

//       final path = Path()
//         ..moveTo(p1.dx, p1.dy)
//         ..quadraticBezierTo(
//           center.dx + math.cos(angle) * (outerRadius * 0.9),
//           center.dy + math.sin(angle) * (outerRadius * 0.9),
//           pTip.dx,
//           pTip.dy,
//         )
//         ..quadraticBezierTo(
//           center.dx + math.cos(angle) * (outerRadius * 0.9),
//           center.dy + math.sin(angle) * (outerRadius * 0.9),
//           p2.dx,
//           p2.dy,
//         )
//         ..close();
//       canvas.drawPath(path, petalPaint);
//     }

//     // Decorative arcs between tick marks
//     final arcPaint = Paint()
//       ..color = baseColor.withOpacity(0.2)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.5;

//     for (int i = 0; i < 12; i++) {
//       final startAngle = (i * 30 - 15) * (math.pi / 180);
//       canvas.drawArc(
//         Rect.fromCircle(center: center, radius: outerRadius * 0.95),
//         startAngle,
//         30 * (math.pi / 180),
//         false,
//         arcPaint,
//       );
//     }

//     // Outer dots pattern
//     final dotPaint = Paint()
//       ..color = baseColor.withOpacity(0.4)
//       ..style = PaintingStyle.fill;

//     for (int i = 0; i < 72; i++) {
//       final angle = (i * 5) * (math.pi / 180);
//       final pt = Offset(
//         center.dx + math.cos(angle) * (outerRadius * 0.92),
//         center.dy + math.sin(angle) * (outerRadius * 0.92),
//       );
//       final r = (i % 6 == 0) ? 2.5 : 1.2;
//       canvas.drawCircle(pt, r, dotPaint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// /// Tick marks around the compass face
// class _CompassTicksPainter extends CustomPainter {
//   final bool isDark;
//   _CompassTicksPainter({required this.isDark});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = size.width / 2;

//     final tickColor = isDark ? Colors.white : const Color(0xFF014D28);

//     for (int i = 0; i < 360; i += 5) {
//       final angle = i * (math.pi / 180);
//       final isMajor = i % 90 == 0;
//       final isMinor = i % 30 == 0;

//       final outerR = radius;
//       final innerR = isMajor
//           ? radius - 12
//           : (isMinor ? radius - 8 : radius - 5);

//       final paint = Paint()
//         ..color = isMajor
//             ? tickColor.withOpacity(0.8)
//             : (isMinor
//                   ? tickColor.withOpacity(0.4)
//                   : tickColor.withOpacity(0.15))
//         ..strokeWidth = isMajor ? 2.0 : (isMinor ? 1.2 : 0.5)
//         ..strokeCap = StrokeCap.round;

//       canvas.drawLine(
//         Offset(
//           center.dx + math.cos(angle) * innerR,
//           center.dy + math.sin(angle) * innerR,
//         ),
//         Offset(
//           center.dx + math.cos(angle) * outerR,
//           center.dy + math.sin(angle) * outerR,
//         ),
//         paint,
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// /// Star-shaped compass needle
// class _CompassNeedlePainter extends CustomPainter {
//   final bool isDark;
//   _CompassNeedlePainter({required this.isDark});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final halfW = size.width * 0.06;
//     final len = size.height * 0.42;

//     final Color primaryGreen = const Color(0xFF029E50);
//     final Color secondaryGreen = isDark
//         ? const Color(0xFF1B7A4A)
//         : const Color(0xFF014D28);
//     final Color darkGreen = isDark
//         ? const Color(0xFF0F2D1E)
//         : const Color(0xFF0A2619);

//     // North needle (green)
//     final northPath = Path()
//       ..moveTo(center.dx, center.dy - len)
//       ..lineTo(center.dx - halfW, center.dy)
//       ..lineTo(center.dx + halfW, center.dy)
//       ..close();

//     final northPaint = Paint()
//       ..shader =
//           LinearGradient(
//             colors: [primaryGreen, secondaryGreen],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ).createShader(
//             Rect.fromPoints(
//               Offset(center.dx, center.dy - len),
//               Offset(center.dx, center.dy),
//             ),
//           );
//     canvas.drawPath(northPath, northPaint);

//     // South needle (darker green)
//     final southPath = Path()
//       ..moveTo(center.dx, center.dy + len)
//       ..lineTo(center.dx - halfW, center.dy)
//       ..lineTo(center.dx + halfW, center.dy)
//       ..close();

//     final southPaint = Paint()
//       ..shader =
//           LinearGradient(
//             colors: [darkGreen, secondaryGreen],
//             begin: Alignment.bottomCenter,
//             end: Alignment.topCenter,
//           ).createShader(
//             Rect.fromPoints(
//               Offset(center.dx, center.dy),
//               Offset(center.dx, center.dy + len),
//             ),
//           );
//     canvas.drawPath(southPath, southPaint);

//     // East needle (green)
//     final eastPath = Path()
//       ..moveTo(center.dx + len, center.dy)
//       ..lineTo(center.dx, center.dy - halfW)
//       ..lineTo(center.dx, center.dy + halfW)
//       ..close();
//     canvas.drawPath(eastPath, northPaint);

//     // West needle (darker green)
//     final westPath = Path()
//       ..moveTo(center.dx - len, center.dy)
//       ..lineTo(center.dx, center.dy - halfW)
//       ..lineTo(center.dx, center.dy + halfW)
//       ..close();
//     canvas.drawPath(westPath, southPaint);

//     // Diagonal needles (thinner)
//     final diagLen = len * 0.65;
//     final diagW = halfW * 0.6;
//     final diagPaint = Paint()
//       ..color = secondaryGreen.withOpacity(0.6)
//       ..style = PaintingStyle.fill;

//     for (int i = 0; i < 4; i++) {
//       final angle = (45 + i * 90) * (math.pi / 180);
//       final tipX = center.dx + math.cos(angle) * diagLen;
//       final tipY = center.dy + math.sin(angle) * diagLen;
//       final perpAngle = angle + math.pi / 2;

//       final p = Path()
//         ..moveTo(tipX, tipY)
//         ..lineTo(
//           center.dx + math.cos(perpAngle) * diagW,
//           center.dy + math.sin(perpAngle) * diagW,
//         )
//         ..lineTo(
//           center.dx - math.cos(perpAngle) * diagW,
//           center.dy - math.sin(perpAngle) * diagW,
//         )
//         ..close();

//       canvas.drawPath(p, diagPaint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1111
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//! الكود هنا البوصله مش بتتحرك صح بس الشكل كويس

// import 'dart:async';
// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_qiblah/flutter_qiblah.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:easy_localization/easy_localization.dart' hide TextDirection;

// enum _AccuracyLevel { far, close, accurate, locked }

// double _normalizeOffset(double raw) {
//   double off = raw % 360;
//   if (off > 180) off -= 360;
//   if (off < -180) off += 360;
//   return off;
// }

// _AccuracyLevel _getAccuracyLevel(double rawOffset) {
//   final abs = _normalizeOffset(rawOffset).abs();
//   if (abs <= 3) return _AccuracyLevel.locked;
//   if (abs <= 10) return _AccuracyLevel.accurate;
//   if (abs <= 25) return _AccuracyLevel.close;
//   return _AccuracyLevel.far;
// }

// Color _accuracyColor(_AccuracyLevel level) {
//   switch (level) {
//     case _AccuracyLevel.far:
//       return const Color(0xFFE53935);
//     case _AccuracyLevel.close:
//       return const Color(0xFFFF8F00);
//     case _AccuracyLevel.accurate:
//       return const Color(0xFF029E50);
//     case _AccuracyLevel.locked:
//       return const Color(0xFFC9A24D);
//   }
// }

// // ─── QiblaScreen ─────────────────────────────────────────────────────────────
// class QiblaScreen extends StatefulWidget {
//   const QiblaScreen({super.key});
//   @override
//   State<QiblaScreen> createState() => _QiblaScreenState();
// }

// class _QiblaScreenState extends State<QiblaScreen> {
//   final Future<bool?> _sensorSupportFuture =
//       FlutterQiblah.androidDeviceSensorSupport();
//   final _locationCtrl = StreamController<LocationStatus>.broadcast();
//   Stream<LocationStatus> get _locationStream => _locationCtrl.stream;
//   final _calibNotifier = ValueNotifier<bool>(false);

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     SystemChrome.setSystemUIOverlayStyle(
//       const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     _checkLocationStatus();
//   }

//   @override
//   void dispose() {
//     _locationCtrl.close();
//     _calibNotifier.dispose();
//     FlutterQiblah().dispose();
//     super.dispose();
//   }

//   Future<void> _checkLocationStatus() async {
//     final s = await FlutterQiblah.checkLocationStatus();
//     if (s.enabled && s.status == LocationPermission.denied) {
//       await FlutterQiblah.requestPermissions();
//       _locationCtrl.sink.add(await FlutterQiblah.checkLocationStatus());
//     } else {
//       _locationCtrl.sink.add(s);
//     }
//   }

//   Future<void> _openLocationSettings() async {
//     await Geolocator.openLocationSettings();
//     await Future.delayed(const Duration(milliseconds: 500));
//     _checkLocationStatus();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Color(0xFF0A1F17), Color(0xFF081812), Color(0xFF05100C)],
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//         ),
//       ),
//       child: Column(
//         children: [
//           Stack(
//             children: [
//               Image.asset(
//                 'assets/images/mosque2.jpg',
//                 width: double.infinity,
//                 height: 180.h,
//                 fit: BoxFit.cover,
//                 color: Colors.black.withOpacity(0.35),
//                 colorBlendMode: BlendMode.darken,
//               ),
//               Positioned(
//                 top: 0,
//                 left: 0,
//                 right: 0,
//                 child: SafeArea(
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 16.w,
//                       vertical: 8.h,
//                     ),
//                     child: Align(
//                       alignment: Alignment.centerRight,
//                       child: IconButton(
//                         onPressed: () => _showInstructions(context),
//                         icon: Icon(
//                           Icons.info_outline_rounded,
//                           color: Colors.white,
//                           size: 24.sp,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               // بانر المعايرة فوق الصورة في الاسفل
//               Positioned(
//                 bottom: 0,
//                 left: 0,
//                 right: 0,
//                 child: ValueListenableBuilder<bool>(
//                   valueListenable: _calibNotifier,
//                   builder: (_, isUnstable, __) => AnimatedSlide(
//                     duration: const Duration(milliseconds: 400),
//                     curve: Curves.easeOut,
//                     offset: isUnstable ? Offset.zero : const Offset(0, 1.5),
//                     child: AnimatedOpacity(
//                       duration: const Duration(milliseconds: 400),
//                       opacity: isUnstable ? 1.0 : 0.0,
//                       child: Container(
//                         margin: EdgeInsets.symmetric(
//                           horizontal: 16.w,
//                           vertical: 10.h,
//                         ),
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 14.w,
//                           vertical: 10.h,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.black.withOpacity(0.6),
//                           borderRadius: BorderRadius.circular(14.r),
//                           border: Border.all(
//                             color: const Color(0xFFFF8F00).withOpacity(0.8),
//                             width: 1.2,
//                           ),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.rotate_90_degrees_ccw_outlined,
//                               color: const Color(0xFFFF8F00),
//                               size: 18.sp,
//                             ),
//                             SizedBox(width: 8.w),
//                             Text(
//                               "حرّك الهاتف على شكل 8 لمعايرة البوصلة",
//                               style: TextStyle(
//                                 color: const Color(0xFFFF8F00),
//                                 fontSize: 12.sp,
//                                 fontFamily: 'Tajawal',
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           Expanded(child: _buildCompassSection()),
//         ],
//       ),
//     );
//   }

//   Widget _buildCompassSection() {
//     return FutureBuilder<bool?>(
//       future: _sensorSupportFuture,
//       builder: (context, snap) {
//         if (snap.connectionState == ConnectionState.waiting) return _loading();
//         if (!(snap.data ?? true)) return const _NoSensorView();
//         return StreamBuilder<LocationStatus>(
//           stream: _locationStream,
//           builder: (context, locSnap) {
//             if (locSnap.connectionState == ConnectionState.waiting)
//               return _loading();
//             final s = locSnap.data;
//             if (s == null || !s.enabled) {
//               return _LocationErrorView(
//                 message: "qibla.activate_location".tr(),
//                 onEnable: _openLocationSettings,
//               );
//             }
//             if (s.status == LocationPermission.denied ||
//                 s.status == LocationPermission.deniedForever) {
//               return _LocationErrorView(
//                 message: s.status == LocationPermission.deniedForever
//                     ? "qibla.permission_denied_forever".tr()
//                     : "qibla.activate_location".tr(),
//                 onEnable: s.status == LocationPermission.deniedForever
//                     ? () async {
//                         await Geolocator.openAppSettings();
//                         await Future.delayed(const Duration(milliseconds: 500));
//                         _checkLocationStatus();
//                       }
//                     : _checkLocationStatus,
//               );
//             }
//             return _QiblaCompassWidget(calibNotifier: _calibNotifier);
//           },
//         );
//       },
//     );
//   }

//   void _showInstructions(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (_) => Container(
//         padding: EdgeInsets.all(24.r),
//         decoration: BoxDecoration(
//           color: const Color(0xFF081812),
//           borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
//           border: const Border(
//             top: BorderSide(color: Color(0xFFC9A24D), width: 2),
//           ),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 40.w,
//               height: 4.h,
//               decoration: BoxDecoration(
//                 color: Colors.white24,
//                 borderRadius: BorderRadius.circular(2.r),
//               ),
//             ),
//             SizedBox(height: 24.h),
//             Icon(
//               Icons.screen_rotation_rounded,
//               color: const Color(0xFFC9A24D),
//               size: 48.sp,
//             ),
//             SizedBox(height: 16.h),
//             Text(
//               "qibla.instructions_title".tr(),
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 20.sp,
//                 fontWeight: FontWeight.bold,
//                 fontFamily: 'Tajawal',
//               ),
//             ),
//             SizedBox(height: 16.h),
//             Text(
//               "qibla.activate_location_message".tr(),
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.white70,
//                 fontSize: 16.sp,
//                 fontFamily: 'Tajawal',
//                 height: 1.5,
//               ),
//             ),
//             SizedBox(height: 32.h),
//             ElevatedButton(
//               onPressed: () => Navigator.pop(context),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF029E50),
//                 foregroundColor: Colors.white,
//                 minimumSize: Size(double.infinity, 50.h),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15.r),
//                 ),
//                 elevation: 0,
//               ),
//               child: Text(
//                 "qibla.understand".tr(),
//                 style: TextStyle(
//                   fontSize: 16.sp,
//                   fontWeight: FontWeight.bold,
//                   fontFamily: 'Tajawal',
//                 ),
//               ),
//             ),
//             SizedBox(height: 16.h),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _loading() => const Center(
//     child: CircularProgressIndicator(color: Color(0xFF029E50), strokeWidth: 3),
//   );
// }

// // ─── Compass Widget ───────────────────────────────────────────────────────────
// class _QiblaCompassWidget extends StatefulWidget {
//   final ValueNotifier<bool> calibNotifier;
//   const _QiblaCompassWidget({required this.calibNotifier});
//   @override
//   State<_QiblaCompassWidget> createState() => _QiblaCompassWidgetState();
// }

// class _QiblaCompassWidgetState extends State<_QiblaCompassWidget>
//     with TickerProviderStateMixin {
//   late final AnimationController _pulseCtrl;
//   late final Animation<double> _pulseAnim;
//   late final AnimationController _glowCtrl;
//   late final Animation<double> _glowAnim;

//   bool _isLocked = false;
//   final List<double> _recentDirs = [];
//   Timer? _calibTimer;
//   DateTime? _lastVib;

//   @override
//   void initState() {
//     super.initState();
//     _pulseCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     );
//     _pulseAnim = Tween<double>(
//       begin: 1.0,
//       end: 1.14,
//     ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
//     _glowCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     );
//     _glowAnim = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
//   }

//   @override
//   void dispose() {
//     _pulseCtrl.dispose();
//     _glowCtrl.dispose();
//     _calibTimer?.cancel();
//     super.dispose();
//   }

//   // يُجدوَل بعد كل frame عبر addPostFrameCallback — آمن تماماً
//   void _sideEffects(QiblahDirection qd) {
//     if (!mounted) return;
//     final normOff = _normalizeOffset(qd.offset);
//     final absOff = normOff.abs();
//     final level = _getAccuracyLevel(qd.offset);

//     // Calibration
//     _recentDirs.add(qd.direction);
//     if (_recentDirs.length > 15) _recentDirs.removeAt(0);
//     if (_recentDirs.length == 15) {
//       final span =
//           _recentDirs.reduce((a, b) => a > b ? a : b) -
//           _recentDirs.reduce((a, b) => a < b ? a : b);
//       final unstable = span > 35;
//       if (unstable != widget.calibNotifier.value) {
//         widget.calibNotifier.value = unstable;
//         if (unstable) {
//           _calibTimer?.cancel();
//           _calibTimer = Timer(const Duration(seconds: 5), () {
//             if (mounted) widget.calibNotifier.value = false;
//           });
//         }
//       }
//     }

//     // Pulse
//     if (absOff <= 15) {
//       if (!_pulseCtrl.isAnimating) _pulseCtrl.repeat(reverse: true);
//     } else {
//       if (_pulseCtrl.isAnimating) {
//         _pulseCtrl.stop();
//         _pulseCtrl.reset();
//       }
//     }

//     // Lock
//     final nowLocked = (level == _AccuracyLevel.locked);
//     if (nowLocked != _isLocked) {
//       setState(() => _isLocked = nowLocked);
//       if (nowLocked) {
//         _glowCtrl.repeat(reverse: true);
//         HapticFeedback.heavyImpact();
//         Future.delayed(
//           const Duration(milliseconds: 200),
//           HapticFeedback.heavyImpact,
//         );
//       } else {
//         _glowCtrl.stop();
//         _glowCtrl.reset();
//       }
//     }

//     // Smart vibration
//     if (!nowLocked) {
//       final now = DateTime.now();
//       final gap = _lastVib == null
//           ? const Duration(seconds: 999)
//           : now.difference(_lastVib!);
//       if (absOff <= 15 && absOff > 5 && gap.inMilliseconds > 1200) {
//         HapticFeedback.selectionClick();
//         _lastVib = now;
//       } else if (absOff <= 5 && gap.inMilliseconds > 700) {
//         HapticFeedback.mediumImpact();
//         _lastVib = now;
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QiblahDirection>(
//       stream: FlutterQiblah.qiblahStream,
//       builder: (context, snap) {
//         if (!snap.hasData) {
//           return const Center(
//             child: CircularProgressIndicator(
//               color: Color(0xFF029E50),
//               strokeWidth: 3,
//             ),
//           );
//         }
//         if (snap.hasError) return const _NoSensorView();

//         final qd = snap.data!;

//         // جدول side effects بعد نهاية الـ frame
//         WidgetsBinding.instance.addPostFrameCallback((_) => _sideEffects(qd));

//         // ── الزوايا ────────────────────────────────────────────────────────
//         // compassAngle: يعوّض دوران الجهاز → الشمال يفضل فوق دايماً
//         final compassAngle = qd.direction * (math.pi / 180) * -1;

//         // qiblaAngle: offset من [-180,+180] → يدور المؤشر ناحية مكة
//         // لو offset=0: مكة أمامك مباشرة → المؤشر فوق ✓
//         // لو offset=90: مكة على يمينك → المؤشر يمين ✓
//         // لو offset=-90: مكة على يسارك → المؤشر يسار ✓
//         final normOff = _normalizeOffset(qd.offset);
//         final qiblaAngle = normOff * (math.pi / 180);
//         final absOff = normOff.abs();
//         final level = _getAccuracyLevel(qd.offset);
//         final accent = _accuracyColor(level);
//         final progress = 1.0 - (absOff / 90).clamp(0.0, 1.0);

//         return LayoutBuilder(
//           builder: (_, __) {
//             return Column(
//               children: [
//                 SizedBox(height: 20.h),
//                 Icon(
//                   Icons.mosque_outlined,
//                   color: Colors.white.withOpacity(0.95),
//                   size: 52.sp,
//                 ),
//                 SizedBox(height: 4.h),
//                 TweenAnimationBuilder<double>(
//                   tween: Tween(begin: 0, end: 1),
//                   duration: const Duration(seconds: 1),
//                   builder: (_, v, __) => Opacity(
//                     opacity: v,
//                     child: Icon(
//                       Icons.keyboard_arrow_up_rounded,
//                       color: accent,
//                       size: 44.sp,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 8.h),
//                 Expanded(
//                   child: Center(
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 20.w),
//                       child: AspectRatio(
//                         aspectRatio: 1,
//                         child: Stack(
//                           alignment: Alignment.center,
//                           children: [
//                             // 5. Progress arc
//                             CustomPaint(
//                               size: Size.infinite,
//                               painter: _ProgressArcPainter(
//                                 progress: progress,
//                                 color: accent,
//                               ),
//                             ),
//                             // Ornamental ring
//                             CustomPaint(
//                               size: Size.infinite,
//                               painter: _OrnamentalRingPainter(isDark: true),
//                             ),
//                             // 6. Lock glow
//                             if (_isLocked)
//                               AnimatedBuilder(
//                                 animation: _glowAnim,
//                                 builder: (_, __) => CustomPaint(
//                                   size: Size.infinite,
//                                   painter: _LockGlowPainter(
//                                     intensity: _glowAnim.value,
//                                   ),
//                                 ),
//                               ),
//                             // Compass disk يدور مع الجهاز
//                             Transform.rotate(
//                               angle: compassAngle,
//                               child: LayoutBuilder(
//                                 builder: (_, cs) {
//                                   final outer = cs.maxWidth;
//                                   final disk = outer * 0.82;
//                                   return Stack(
//                                     alignment: Alignment.center,
//                                     children: [
//                                       Container(
//                                         width: disk,
//                                         height: disk,
//                                         decoration: BoxDecoration(
//                                           shape: BoxShape.circle,
//                                           gradient: const RadialGradient(
//                                             colors: [
//                                               Color(0xFF1E583A),
//                                               Color(0xFF0F2D1E),
//                                               Color(0xFF0D2519),
//                                               Color(0xFF081A12),
//                                             ],
//                                             stops: [0.0, 0.4, 0.8, 1.0],
//                                           ),
//                                           border: Border.all(
//                                             color: const Color(
//                                               0xFFC9A24D,
//                                             ).withOpacity(0.3),
//                                             width: 1.5,
//                                           ),
//                                           boxShadow: const [
//                                             BoxShadow(
//                                               color: Colors.black54,
//                                               blurRadius: 10,
//                                               spreadRadius: 1,
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       CustomPaint(
//                                         size: Size(disk, disk),
//                                         painter: _CompassTicksPainter(),
//                                       ),
//                                       _buildLabels(outer),
//                                       CustomPaint(
//                                         size: Size(disk * 0.72, disk * 0.72),
//                                         painter: _CompassNeedlePainter(),
//                                       ),
//                                     ],
//                                   );
//                                 },
//                               ),
//                             ),
//                             // 2. مؤشر القبلة يدور ناحية مكة
//                             SizedBox.expand(
//                               child: Transform.rotate(
//                                 angle: qiblaAngle,
//                                 child: Align(
//                                   alignment: Alignment.topCenter,
//                                   child: AnimatedBuilder(
//                                     animation: _pulseAnim,
//                                     builder: (_, child) => Transform.scale(
//                                       scale: _isLocked ? 1.0 : _pulseAnim.value,
//                                       child: child,
//                                     ),
//                                     child: Container(
//                                       width: 46.w,
//                                       height: 46.w,
//                                       margin: EdgeInsets.only(top: 8.h),
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: Colors.white,
//                                         border: Border.all(
//                                           color: accent,
//                                           width: 2.5,
//                                         ),
//                                         boxShadow: [
//                                           BoxShadow(
//                                             color: accent.withOpacity(
//                                               _isLocked ? 0.9 : 0.5,
//                                             ),
//                                             blurRadius: _isLocked ? 20 : 10,
//                                             spreadRadius: _isLocked ? 4 : 1,
//                                           ),
//                                           BoxShadow(
//                                             color: Colors.black.withOpacity(
//                                               0.6,
//                                             ),
//                                             blurRadius: 10,
//                                             offset: const Offset(0, 4),
//                                           ),
//                                         ],
//                                       ),
//                                       child: Container(
//                                         margin: EdgeInsets.all(3.r),
//                                         decoration: const BoxDecoration(
//                                           shape: BoxShape.circle,
//                                           color: Color(0xFF014D28),
//                                         ),
//                                         child: Icon(
//                                           Icons.mosque_rounded,
//                                           size: 22.sp,
//                                           color: accent,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 // 6. Lock banner
//                 AnimatedSwitcher(
//                   duration: const Duration(milliseconds: 500),
//                   child: _isLocked
//                       ? Container(
//                           key: const ValueKey('L'),
//                           margin: EdgeInsets.symmetric(
//                             horizontal: 24.w,
//                             vertical: 8.h,
//                           ),
//                           padding: EdgeInsets.symmetric(
//                             horizontal: 20.w,
//                             vertical: 10.h,
//                           ),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF029E50).withOpacity(0.15),
//                             borderRadius: BorderRadius.circular(14.r),
//                             border: Border.all(
//                               color: const Color(0xFF029E50).withOpacity(0.6),
//                               width: 1.5,
//                             ),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 Icons.check_circle_rounded,
//                                 color: const Color(0xFF029E50),
//                                 size: 22.sp,
//                               ),
//                               SizedBox(width: 8.w),
//                               Text(
//                                 "تم تحديد القبلة",
//                                 style: TextStyle(
//                                   color: const Color(0xFF029E50),
//                                   fontSize: 16.sp,
//                                   fontWeight: FontWeight.bold,
//                                   fontFamily: 'Tajawal',
//                                 ),
//                               ),
//                             ],
//                           ),
//                         )
//                       : SizedBox(key: const ValueKey('U'), height: 0),
//                 ),
//                 // 1. Degree + accuracy badge
//                 Padding(
//                   padding: EdgeInsets.symmetric(vertical: 12.h),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Container(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 16.w,
//                           vertical: 8.h,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.05),
//                           borderRadius: BorderRadius.circular(20.r),
//                           border: Border.all(color: Colors.white10),
//                         ),
//                         child: Text(
//                           "${normOff.toStringAsFixed(1)}°",
//                           style: TextStyle(
//                             color: const Color(0xFFC9A24D),
//                             fontSize: 22.sp,
//                             fontFamily: 'Tajawal',
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: 1.2,
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 12.w),
//                       AnimatedContainer(
//                         duration: const Duration(milliseconds: 400),
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 14.w,
//                           vertical: 8.h,
//                         ),
//                         decoration: BoxDecoration(
//                           color: accent.withOpacity(0.15),
//                           borderRadius: BorderRadius.circular(20.r),
//                           border: Border.all(color: accent.withOpacity(0.5)),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             AnimatedContainer(
//                               duration: const Duration(milliseconds: 400),
//                               width: 8.w,
//                               height: 8.w,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: accent,
//                               ),
//                             ),
//                             SizedBox(width: 6.w),
//                             Text(
//                               _label(level),
//                               style: TextStyle(
//                                 color: accent,
//                                 fontSize: 13.sp,
//                                 fontFamily: 'Tajawal',
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 8.h),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   String _label(_AccuracyLevel l) {
//     switch (l) {
//       case _AccuracyLevel.far:
//         return "بعيد";
//       case _AccuracyLevel.close:
//         return "قريب";
//       case _AccuracyLevel.accurate:
//         return "مضبوط";
//       case _AccuracyLevel.locked:
//         return "مقفّل ✓";
//     }
//   }

//   static Widget _buildLabels(double size) {
//     final s = TextStyle(
//       color: Colors.white,
//       fontWeight: FontWeight.bold,
//       fontSize: (size * 0.055).clamp(13.0, 18.0).sp,
//       letterSpacing: 1.2,
//     );
//     return SizedBox(
//       width: size,
//       height: size,
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           Align(
//             alignment: const Alignment(0, -0.68),
//             child: Text(
//               "N",
//               style: s.copyWith(
//                 color: const Color(0xFF029E50),
//                 fontSize: s.fontSize! + 2,
//               ),
//             ),
//           ),
//           Align(
//             alignment: const Alignment(0.68, 0),
//             child: Text("E", style: s),
//           ),
//           Align(
//             alignment: const Alignment(0, 0.68),
//             child: Text("S", style: s),
//           ),
//           Align(
//             alignment: const Alignment(-0.68, 0),
//             child: Text("W", style: s),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // --- fallback classes ---
// class _NoSensorView extends StatelessWidget {
//   const _NoSensorView();
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.all(30.w),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               Icons.sensors_off_rounded,
//               size: 80.sp,
//               color: const Color(0xFFC9A24D),
//             ),
//             SizedBox(height: 24.h),
//             Text(
//               "qibla.no_sensor".tr(),
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18.sp,
//                 fontWeight: FontWeight.w600,
//                 fontFamily: "Tajawal",
//                 height: 1.6,
//               ),
//             ),
//             SizedBox(height: 12.h),
//             Text(
//               "qibla.no_sensor_details".tr(),
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.white54,
//                 fontSize: 14.sp,
//                 fontFamily: "Tajawal",
//                 height: 1.5,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _LocationErrorView extends StatelessWidget {
//   final String message;
//   final VoidCallback? onEnable;
//   const _LocationErrorView({required this.message, this.onEnable});
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 30.w),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Spacer(),
//           Icon(
//             Icons.location_off_rounded,
//             size: 100.sp,
//             color: const Color(0xFFC9A24D),
//           ),
//           SizedBox(height: 30.h),
//           Text(
//             message,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 18.sp,
//               fontWeight: FontWeight.w600,
//               fontFamily: "Tajawal",
//               height: 1.6,
//             ),
//           ),
//           const Spacer(),
//           SizedBox(
//             width: double.infinity,
//             height: 52.h,
//             child: ElevatedButton(
//               onPressed: onEnable,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF014D28),
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(14.r),
//                 ),
//                 elevation: 0,
//               ),
//               child: Text(
//                 "qibla.activate".tr(),
//                 style: TextStyle(
//                   fontSize: 17.sp,
//                   fontWeight: FontWeight.bold,
//                   fontFamily: "Tajawal",
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(height: 30.h),
//         ],
//       ),
//     );
//   }
// }

// class _ProgressArcPainter extends CustomPainter {
//   final double progress;
//   final Color color;
//   _ProgressArcPainter({required this.progress, required this.color});
//   @override
//   void paint(Canvas canvas, Size size) {
//     final c = Offset(size.width / 2, size.height / 2);
//     final r = size.width / 2 - 4;
//     canvas.drawCircle(
//       c,
//       r,
//       Paint()
//         ..color = Colors.white.withOpacity(0.06)
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = 6
//         ..strokeCap = StrokeCap.round,
//     );
//     if (progress > 0) {
//       canvas.drawArc(
//         Rect.fromCircle(center: c, radius: r),
//         -math.pi / 2,
//         2 * math.pi * progress,
//         false,
//         Paint()
//           ..color = color
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = 6
//           ..strokeCap = StrokeCap.round,
//       );
//     }
//     if (progress > 0.02) {
//       final ha = -math.pi / 2 + 2 * math.pi * progress;
//       canvas.drawCircle(
//         Offset(c.dx + math.cos(ha) * r, c.dy + math.sin(ha) * r),
//         5,
//         Paint()
//           ..color = color.withOpacity(0.5)
//           ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(covariant _ProgressArcPainter o) =>
//       o.progress != progress || o.color != color;
// }

// class _LockGlowPainter extends CustomPainter {
//   final double intensity;
//   _LockGlowPainter({required this.intensity});
//   @override
//   void paint(Canvas canvas, Size size) {
//     final c = Offset(size.width / 2, size.height / 2);
//     final r = size.width / 2 * 0.88;
//     canvas.drawCircle(
//       c,
//       r,
//       Paint()
//         ..color = const Color(0xFF029E50).withOpacity(0.08 + 0.18 * intensity)
//         ..maskFilter = MaskFilter.blur(BlurStyle.normal, 18 + 14 * intensity),
//     );
//     canvas.drawCircle(
//       c,
//       r * 0.75,
//       Paint()
//         ..color = const Color(0xFF029E50).withOpacity(0.05 + 0.1 * intensity)
//         ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
//     );
//   }

//   @override
//   bool shouldRepaint(covariant _LockGlowPainter o) => o.intensity != intensity;
// }

// class _OrnamentalRingPainter extends CustomPainter {
//   final bool isDark;
//   _OrnamentalRingPainter({required this.isDark});
//   @override
//   void paint(Canvas canvas, Size size) {
//     final c = Offset(size.width / 2, size.height / 2);
//     final outerR = size.width / 2;
//     final innerR = outerR * 0.84;
//     final base = isDark ? const Color(0xFF1B7A4A) : const Color(0xFF014D28);
//     canvas.drawCircle(
//       c,
//       outerR,
//       Paint()
//         ..color = base.withOpacity(0.15)
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = 2,
//     );
//     final pp = Paint()
//       ..color = base.withOpacity(0.4)
//       ..style = PaintingStyle.fill;
//     for (int i = 0; i < 16; i++) {
//       final a = (i * 22.5) * (math.pi / 180);
//       final p1 = Offset(
//         c.dx + math.cos(a - 0.1) * innerR * 1.05,
//         c.dy + math.sin(a - 0.1) * innerR * 1.05,
//       );
//       final p2 = Offset(
//         c.dx + math.cos(a + 0.1) * innerR * 1.05,
//         c.dy + math.sin(a + 0.1) * innerR * 1.05,
//       );
//       final tip = Offset(
//         c.dx + math.cos(a) * outerR,
//         c.dy + math.sin(a) * outerR,
//       );
//       final bx = c.dx + math.cos(a) * outerR * 0.9;
//       final by = c.dy + math.sin(a) * outerR * 0.9;
//       canvas.drawPath(
//         Path()
//           ..moveTo(p1.dx, p1.dy)
//           ..quadraticBezierTo(bx, by, tip.dx, tip.dy)
//           ..quadraticBezierTo(bx, by, p2.dx, p2.dy)
//           ..close(),
//         pp,
//       );
//     }
//     final ap = Paint()
//       ..color = base.withOpacity(0.2)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.5;
//     for (int i = 0; i < 12; i++) {
//       canvas.drawArc(
//         Rect.fromCircle(center: c, radius: outerR * 0.95),
//         (i * 30 - 15) * (math.pi / 180),
//         30 * (math.pi / 180),
//         false,
//         ap,
//       );
//     }
//     final dp = Paint()
//       ..color = base.withOpacity(0.4)
//       ..style = PaintingStyle.fill;
//     for (int i = 0; i < 72; i++) {
//       final a = (i * 5) * (math.pi / 180);
//       canvas.drawCircle(
//         Offset(
//           c.dx + math.cos(a) * outerR * 0.92,
//           c.dy + math.sin(a) * outerR * 0.92,
//         ),
//         (i % 6 == 0) ? 2.5 : 1.2,
//         dp,
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter o) => false;
// }

// class _CompassTicksPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final c = Offset(size.width / 2, size.height / 2);
//     final r = size.width / 2;
//     for (int i = 0; i < 360; i += 5) {
//       final a = i * (math.pi / 180);
//       final isMaj = (i % 90 == 0);
//       final isMin = (i % 30 == 0);
//       final ir = isMaj ? r - 12 : (isMin ? r - 8 : r - 5);
//       canvas.drawLine(
//         Offset(c.dx + math.cos(a) * ir, c.dy + math.sin(a) * ir),
//         Offset(c.dx + math.cos(a) * r, c.dy + math.sin(a) * r),
//         Paint()
//           ..color = isMaj
//               ? Colors.white.withOpacity(0.8)
//               : (isMin
//                     ? Colors.white.withOpacity(0.4)
//                     : Colors.white.withOpacity(0.15))
//           ..strokeWidth = isMaj ? 2.0 : (isMin ? 1.2 : 0.5)
//           ..strokeCap = StrokeCap.round,
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter o) => false;
// }

// class _CompassNeedlePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final c = Offset(size.width / 2, size.height / 2);
//     final hw = size.width * 0.06;
//     final ln = size.height * 0.42;
//     const grn = Color(0xFF029E50);
//     const sgrn = Color(0xFF1B7A4A);
//     const dgrn = Color(0xFF0F2D1E);
//     Shader ns(Rect r) => const LinearGradient(
//       colors: [grn, sgrn],
//       begin: Alignment.topCenter,
//       end: Alignment.bottomCenter,
//     ).createShader(r);
//     Shader ss(Rect r) => const LinearGradient(
//       colors: [dgrn, sgrn],
//       begin: Alignment.bottomCenter,
//       end: Alignment.topCenter,
//     ).createShader(r);
//     canvas.drawPath(
//       Path()
//         ..moveTo(c.dx, c.dy - ln)
//         ..lineTo(c.dx - hw, c.dy)
//         ..lineTo(c.dx + hw, c.dy)
//         ..close(),
//       Paint()
//         ..shader = ns(
//           Rect.fromPoints(Offset(c.dx, c.dy - ln), Offset(c.dx, c.dy)),
//         ),
//     );
//     canvas.drawPath(
//       Path()
//         ..moveTo(c.dx, c.dy + ln)
//         ..lineTo(c.dx - hw, c.dy)
//         ..lineTo(c.dx + hw, c.dy)
//         ..close(),
//       Paint()
//         ..shader = ss(
//           Rect.fromPoints(Offset(c.dx, c.dy), Offset(c.dx, c.dy + ln)),
//         ),
//     );
//     canvas.drawPath(
//       Path()
//         ..moveTo(c.dx + ln, c.dy)
//         ..lineTo(c.dx, c.dy - hw)
//         ..lineTo(c.dx, c.dy + hw)
//         ..close(),
//       Paint()
//         ..shader = ns(
//           Rect.fromPoints(
//             Offset(c.dx, c.dy - hw),
//             Offset(c.dx + ln, c.dy + hw),
//           ),
//         ),
//     );
//     canvas.drawPath(
//       Path()
//         ..moveTo(c.dx - ln, c.dy)
//         ..lineTo(c.dx, c.dy - hw)
//         ..lineTo(c.dx, c.dy + hw)
//         ..close(),
//       Paint()
//         ..shader = ss(
//           Rect.fromPoints(
//             Offset(c.dx - ln, c.dy - hw),
//             Offset(c.dx, c.dy + hw),
//           ),
//         ),
//     );
//     final dp = Paint()
//       ..color = sgrn.withOpacity(0.6)
//       ..style = PaintingStyle.fill;
//     for (int i = 0; i < 4; i++) {
//       final a = (45 + i * 90) * (math.pi / 180);
//       final p = a + math.pi / 2;
//       final dl = ln * 0.65;
//       final dw = hw * 0.6;
//       canvas.drawPath(
//         Path()
//           ..moveTo(c.dx + math.cos(a) * dl, c.dy + math.sin(a) * dl)
//           ..lineTo(c.dx + math.cos(p) * dw, c.dy + math.sin(p) * dw)
//           ..lineTo(c.dx - math.cos(p) * dw, c.dy - math.sin(p) * dw)
//           ..close(),
//         dp,
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter o) => false;
// }
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//! الكود هنا البوصله بتتحرك صح بس الشكل مش احسن حاجه
// import 'dart:async';
// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_qiblah/flutter_qiblah.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:easy_localization/easy_localization.dart' hide TextDirection;

// class QiblaScreen extends StatefulWidget {
//   const QiblaScreen({super.key});

//   @override
//   State<QiblaScreen> createState() => _QiblaScreenState();
// }

// class _QiblaScreenState extends State<QiblaScreen> {
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     SystemChrome.setSystemUIOverlayStyle(
//       const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
//     );
//   }

//   // sensor support future (runs once)
//   final Future<bool?> _sensorSupportFuture =
//       FlutterQiblah.androidDeviceSensorSupport();

//   // location status emitted into a StreamController so we can re-check
//   final _locationStreamController =
//       StreamController<LocationStatus>.broadcast();
//   Stream<LocationStatus> get _locationStream =>
//       _locationStreamController.stream;

//   @override
//   void initState() {
//     super.initState();
//     _checkLocationStatus();
//   }

//   @override
//   void dispose() {
//     _locationStreamController.close();
//     FlutterQiblah().dispose();
//     super.dispose();
//   }

//   // ── location status ───────────────────────────────────────────
//   Future<void> _checkLocationStatus() async {
//     final locationStatus = await FlutterQiblah.checkLocationStatus();
//     if (locationStatus.enabled &&
//         locationStatus.status == LocationPermission.denied) {
//       await FlutterQiblah.requestPermissions();
//       final updated = await FlutterQiblah.checkLocationStatus();
//       _locationStreamController.sink.add(updated);
//     } else {
//       _locationStreamController.sink.add(locationStatus);
//     }
//   }

//   // Opens the OS location-settings screen, then re-checks when resumed
//   Future<void> _openLocationSettings() async {
//     await Geolocator.openLocationSettings();
//     // small delay to let the OS return properly
//     await Future.delayed(const Duration(milliseconds: 500));
//     _checkLocationStatus();
//   }

//   // ── build ─────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Theme.of(context).scaffoldBackgroundColor,
//         gradient: LinearGradient(
//           colors: [
//             const Color(0xFF0A1F17),
//             const Color(0xFF081812),
//             const Color(0xFF05100C),
//           ],
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//         ),
//       ),
//       child: Column(
//         children: [
//           // Header with Image and Info Button
//           Stack(
//             children: [
//               Image.asset(
//                 'assets/images/mosque2.jpg',
//                 width: double.infinity,
//                 height: 180.h,
//                 fit: BoxFit.cover,
//                 color: Colors.black.withOpacity(0.3),
//                 colorBlendMode: BlendMode.darken,
//               ),
//               Positioned(
//                 top: 0,
//                 left: 0,
//                 right: 0,
//                 child: SafeArea(
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 16.w,
//                       vertical: 8.h,
//                     ),
//                     child: Align(
//                       alignment: Alignment.centerRight,
//                       child: IconButton(
//                         onPressed: () => _showInstructions(context),
//                         icon: Icon(
//                           Icons.info_outline_rounded,
//                           color: Colors.white,
//                           size: 24.sp,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           // Main content
//           Expanded(child: _buildBody()),
//         ],
//       ),
//     );
//   }

//   Widget _buildBody() {
//     return _buildCompassSection();
//   }

//   // ── compass section ───────────────────────────────────────────
//   Widget _buildCompassSection() {
//     // Step 1: check sensor support (Android only; iOS always true)
//     return FutureBuilder<bool?>(
//       future: _sensorSupportFuture,
//       builder: (context, sensorSnapshot) {
//         if (sensorSnapshot.connectionState == ConnectionState.waiting) {
//           return _loadingIndicator();
//         }

//         // On iOS, androidDeviceSensorSupport() returns null → treat as supported
//         final hasSensor = sensorSnapshot.data ?? true;

//         if (!hasSensor) {
//           return _NoSensorView();
//         }

//         // Step 2: check location
//         return StreamBuilder<LocationStatus>(
//           stream: _locationStream,
//           builder: (context, locSnapshot) {
//             if (locSnapshot.connectionState == ConnectionState.waiting) {
//               return _loadingIndicator();
//             }

//             final locStatus = locSnapshot.data;

//             // Location service disabled
//             if (locStatus == null || !locStatus.enabled) {
//               return _LocationErrorView(
//                 message: "qibla.activate_location".tr(),
//                 onEnable: _openLocationSettings,
//               );
//             }

//             // Permission denied
//             if (locStatus.status == LocationPermission.denied ||
//                 locStatus.status == LocationPermission.deniedForever) {
//               return _LocationErrorView(
//                 message: locStatus.status == LocationPermission.deniedForever
//                     ? "qibla.permission_denied_forever".tr()
//                     : "qibla.activate_location".tr(),
//                 onEnable: locStatus.status == LocationPermission.deniedForever
//                     ? () async {
//                         await Geolocator.openAppSettings();
//                         await Future.delayed(const Duration(milliseconds: 500));
//                         _checkLocationStatus();
//                       }
//                     : _checkLocationStatus,
//               );
//             }

//             // All good → show compass
//             return const _QiblaCompassWidget();
//           },
//         );
//       },
//     );
//   }

//   void _showInstructions(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         padding: EdgeInsets.all(24.r),
//         decoration: BoxDecoration(
//           color: const Color(0xFF081812),
//           borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
//           border: Border(
//             top: BorderSide(color: const Color(0xFFC9A24D), width: 2),
//           ),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 40.w,
//               height: 4.h,
//               decoration: BoxDecoration(
//                 color: Colors.white24,
//                 borderRadius: BorderRadius.circular(2.r),
//               ),
//             ),
//             SizedBox(height: 24.h),
//             Icon(
//               Icons.screen_rotation_rounded,
//               color: const Color(0xFFC9A24D),
//               size: 48.sp,
//             ),
//             SizedBox(height: 16.h),
//             Text(
//               "qibla.instructions_title".tr(),
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 20.sp,
//                 fontWeight: FontWeight.bold,
//                 fontFamily: 'Tajawal',
//               ),
//             ),
//             SizedBox(height: 16.h),
//             Text(
//               "qibla.activate_location_message".tr(),
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.white70,
//                 fontSize: 16.sp,
//                 fontFamily: 'Tajawal',
//                 height: 1.5,
//               ),
//             ),
//             SizedBox(height: 32.h),
//             ElevatedButton(
//               onPressed: () => Navigator.pop(context),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF029E50),
//                 foregroundColor: Colors.white,
//                 minimumSize: Size(double.infinity, 50.h),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15.r),
//                 ),
//                 elevation: 0,
//               ),
//               child: Text(
//                 "qibla.understand".tr(),
//                 style: TextStyle(
//                   fontSize: 16.sp,
//                   fontWeight: FontWeight.bold,
//                   fontFamily: 'Tajawal',
//                 ),
//               ),
//             ),
//             SizedBox(height: 16.h),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _loadingIndicator() {
//     return const Center(
//       child: CircularProgressIndicator(
//         color: Color(0xFF029E50),
//         strokeWidth: 3,
//       ),
//     );
//   }
// }

// // ─── Compass Widget ───────────────────────────────────────────
// class _QiblaCompassWidget extends StatelessWidget {
//   const _QiblaCompassWidget();

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QiblahDirection>(
//       stream: FlutterQiblah.qiblahStream,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(
//             child: CircularProgressIndicator(
//               color: Color(0xFF029E50),
//               strokeWidth: 3,
//             ),
//           );
//         }

//         if (snapshot.hasError || !snapshot.hasData) {
//           return _NoSensorView();
//         }

//         final qiblahDirection = snapshot.data!;
//         // compassAngle: rotation for the compass face (N,E,S,W) to point North relative to phone
//         final compassAngle = qiblahDirection.direction * (math.pi / 180) * -1;
//         // qiblaAngle: rotation for the marker relative to device top
//         final qiblaAngle = (qiblahDirection.qiblah) * (math.pi / 180) * -1;
//         return LayoutBuilder(
//           builder: (context, constraints) {
//             return Column(
//               children: [
//                 SizedBox(height: 24.h),
//                 // Kaaba Icon (Professional white mosque icon)
//                 Icon(
//                   Icons.mosque_outlined,
//                   color: Colors.white.withOpacity(0.95),
//                   size: 52.sp,
//                 ),
//                 SizedBox(height: 4.h),
//                 // Premium Green Indicator Arrow
//                 TweenAnimationBuilder<double>(
//                   tween: Tween(begin: 0, end: 1),
//                   duration: const Duration(seconds: 1),
//                   builder: (context, value, child) {
//                     return Opacity(
//                       opacity: value,
//                       child: Icon(
//                         Icons.keyboard_arrow_up_rounded,
//                         color: const Color(0xFF029E50),
//                         size: 44.sp,
//                       ),
//                     );
//                   },
//                 ),
//                 SizedBox(height: 12.h),
//                 // Compass Section with fixed sizing and smooth movement
//                 Expanded(
//                   child: Center(
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 20.w),
//                       child: AspectRatio(
//                         aspectRatio: 1,
//                         child: Stack(
//                           alignment: Alignment.center,
//                           children: [
//                             // 1. Static Ornamental Mandala (Background)
//                             CustomPaint(
//                               size: Size.infinite,
//                               painter: _OrnamentalRingPainter(isDark: true),
//                             ),
//                             // 2. Rotating Compass Disk (N, S, E, W and Ticks)
//                             Transform.rotate(
//                               angle: compassAngle,
//                               child: LayoutBuilder(
//                                 builder: (context, constraints) {
//                                   final outerSize = constraints.maxWidth;
//                                   final innerDiskSize = outerSize * 0.82;
//                                   return Stack(
//                                     alignment: Alignment.center,
//                                     children: [
//                                       // Compass Face Disk (Layered Look)
//                                       Container(
//                                         width: innerDiskSize,
//                                         height: innerDiskSize,
//                                         decoration: BoxDecoration(
//                                           shape: BoxShape.circle,
//                                           gradient: const RadialGradient(
//                                             colors: [
//                                               Color(0xFF1E583A),
//                                               Color(0xFF0F2D1E),
//                                               Color(0xFF0D2519),
//                                               Color(0xFF081A12),
//                                             ],
//                                             stops: [0.0, 0.4, 0.8, 1.0],
//                                           ),
//                                           border: Border.all(
//                                             color: const Color(
//                                               0xFFC9A24D,
//                                             ).withOpacity(0.3),
//                                             width: 1.5,
//                                           ),
//                                           boxShadow: [
//                                             BoxShadow(
//                                               color: Colors.black54,
//                                               blurRadius: 10,
//                                               spreadRadius: 1,
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       // Tick marks & Labels (Rotates with Disk)
//                                       CustomPaint(
//                                         size: Size(
//                                           innerDiskSize,
//                                           innerDiskSize,
//                                         ),
//                                         painter: _CompassTicksPainter(
//                                           isDark: true,
//                                         ),
//                                       ),
//                                       // Labels positioned relative to outer size for more distance
//                                       _buildDirectionLabels(true, outerSize),
//                                       // North Pointer (Center Star)
//                                       CustomPaint(
//                                         size: Size(
//                                           innerDiskSize * 0.72,
//                                           innerDiskSize * 0.72,
//                                         ),
//                                         painter: _CompassNeedlePainter(
//                                           isDark: true,
//                                         ),
//                                       ),
//                                     ],
//                                   );
//                                 },
//                               ),
//                             ),
//                             // 3. Absolute Qibla Indicator (Mosque Marker)
//                             // This must rotate around the center of the STACK
//                             SizedBox.expand(
//                               child: Transform.rotate(
//                                 angle: qiblaAngle,
//                                 child: Align(
//                                   alignment: Alignment.topCenter,
//                                   child: Container(
//                                     width: 46.w,
//                                     height: 46.w,
//                                     // Slight offset to sit on the ornamental ring
//                                     margin: EdgeInsets.only(top: 8.h),
//                                     decoration: BoxDecoration(
//                                       shape: BoxShape.circle,
//                                       color: Colors.white,
//                                       border: Border.all(
//                                         color: const Color(0xFFC9A24D),
//                                         width: 2.5,
//                                       ),
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: Colors.black.withOpacity(0.6),
//                                           blurRadius: 10,
//                                           offset: const Offset(0, 4),
//                                         ),
//                                       ],
//                                     ),
//                                     child: Container(
//                                       margin: EdgeInsets.all(3.r),
//                                       decoration: const BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: Color(0xFF014D28),
//                                       ),
//                                       child: Icon(
//                                         Icons.mosque_rounded,
//                                         size: 22.sp,
//                                         color: const Color(0xFFC9A24D),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 // Numerical Direction
//                 Padding(
//                   padding: EdgeInsets.symmetric(vertical: 20.h),
//                   child: Container(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 16.w,
//                       vertical: 8.h,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.05),
//                       borderRadius: BorderRadius.circular(20.r),
//                       border: Border.all(color: Colors.white10),
//                     ),
//                     child: Text(
//                       "${qiblahDirection.offset.toStringAsFixed(1)}°",
//                       style: TextStyle(
//                         color: const Color(0xFFC9A24D),
//                         fontSize: 22.sp,
//                         fontFamily: 'Tajawal',
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 1.2,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   static Widget _buildDirectionLabels(bool isDark, double size) {
//     final style = TextStyle(
//       color: isDark ? Colors.white : const Color(0xFF014D28),
//       fontWeight: FontWeight.bold,
//       fontSize: (size * 0.055).clamp(13.0, 18.0).sp,
//       letterSpacing: 1.2,
//     );
//     // Labels are placed within the inner disk area but far enough from center
//     return SizedBox(
//       width: size,
//       height: size,
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           Align(
//             alignment: const Alignment(0, -0.68),
//             child: Text(
//               "N",
//               style: style.copyWith(
//                 color: const Color(0xFF029E50),
//                 fontSize: style.fontSize! + 2,
//               ),
//             ),
//           ),
//           Align(
//             alignment: const Alignment(0.68, 0),
//             child: Text("E", style: style),
//           ),
//           Align(
//             alignment: const Alignment(0, 0.68),
//             child: Text("S", style: style),
//           ),
//           Align(
//             alignment: const Alignment(-0.68, 0),
//             child: Text("W", style: style),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─── No Sensor Fallback ──────────────────────────────────────
// class _NoSensorView extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.all(30.w),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               Icons.sensors_off_rounded,
//               size: 80.sp,
//               color: const Color(0xFFC9A24D),
//             ),
//             SizedBox(height: 24.h),
//             Text(
//               "qibla.no_sensor".tr(),
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: isDark ? Colors.white : Colors.black87,
//                 fontSize: 18.sp,
//                 fontWeight: FontWeight.w600,
//                 fontFamily: 'Tajawal',
//                 height: 1.6,
//               ),
//             ),
//             SizedBox(height: 12.h),
//             Text(
//               "qibla.no_sensor_details".tr(),
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: isDark ? Colors.white54 : Colors.black54,
//                 fontSize: 14.sp,
//                 fontFamily: 'Tajawal',
//                 height: 1.5,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─── Location Error View ─────────────────────────────────────
// class _LocationErrorView extends StatelessWidget {
//   final String message;
//   final VoidCallback? onEnable;

//   const _LocationErrorView({required this.message, this.onEnable});

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 30.w),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Spacer(),
//           // Location illustration
//           SizedBox(
//             width: 200.w,
//             height: 200.w,
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 // Buildings
//                 Icon(
//                   Icons.location_city_rounded,
//                   size: 100.sp,
//                   color: const Color(0xFF1B7A4A).withValues(alpha: 0.4),
//                 ),
//                 // Pin
//                 Positioned(
//                   top: 20.h,
//                   child: Container(
//                     width: 60.w,
//                     height: 80.h,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFC9A24D),
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(30.r),
//                         topRight: Radius.circular(30.r),
//                         bottomLeft: Radius.circular(4.r),
//                         bottomRight: Radius.circular(30.r),
//                       ),
//                     ),
//                     child: Icon(
//                       Icons.location_on_rounded,
//                       size: 40.sp,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//                 // Clouds
//                 Positioned(
//                   top: 10.h,
//                   right: 20.w,
//                   child: Icon(
//                     Icons.cloud,
//                     size: 30.sp,
//                     color: isDark
//                         ? Colors.white12
//                         : Colors.grey.withValues(alpha: 0.1),
//                   ),
//                 ),
//                 Positioned(
//                   top: 30.h,
//                   left: 10.w,
//                   child: Icon(
//                     Icons.cloud,
//                     size: 24.sp,
//                     color: isDark
//                         ? Colors.white10
//                         : Colors.grey.withValues(alpha: 0.05),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 30.h),
//           Text(
//             message,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: isDark ? Colors.white : Colors.black87,
//               fontSize: 18.sp,
//               fontWeight: FontWeight.w600,
//               fontFamily: 'Tajawal',
//               height: 1.6,
//             ),
//           ),
//           const Spacer(),
//           // Enable button
//           SizedBox(
//             width: double.infinity,
//             height: 52.h,
//             child: ElevatedButton(
//               onPressed: onEnable,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF014D28),
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(14.r),
//                 ),
//                 elevation: 0,
//               ),
//               child: Text(
//                 "qibla.activate".tr(),
//                 style: TextStyle(
//                   fontSize: 17.sp,
//                   fontWeight: FontWeight.bold,
//                   fontFamily: 'Tajawal',
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(height: 30.h),
//         ],
//       ),
//     );
//   }
// }

// // ─── Custom Painters ─────────────────────────────────────────

// /// Ornamental ring (mandala-like) around the compass
// class _OrnamentalRingPainter extends CustomPainter {
//   final bool isDark;
//   _OrnamentalRingPainter({required this.isDark});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final outerRadius = size.width / 2;
//     final innerRadius = outerRadius * 0.84;

//     final baseColor = isDark
//         ? const Color(0xFF1B7A4A)
//         : const Color(0xFF014D28);

//     // Outer glow circle
//     final glowPaint = Paint()
//       ..color = baseColor.withOpacity(0.15)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2;
//     canvas.drawCircle(center, outerRadius, glowPaint);

//     // Ornamental mandala petals
//     final petalPaint = Paint()
//       ..color = baseColor.withOpacity(0.4)
//       ..style = PaintingStyle.fill;

//     const int petalCount = 16;
//     for (int i = 0; i < petalCount; i++) {
//       final angle = (i * (360 / petalCount)) * (math.pi / 180);
//       final p1 = Offset(
//         center.dx + math.cos(angle - 0.1) * (innerRadius * 1.05),
//         center.dy + math.sin(angle - 0.1) * (innerRadius * 1.05),
//       );
//       final p2 = Offset(
//         center.dx + math.cos(angle + 0.1) * (innerRadius * 1.05),
//         center.dy + math.sin(angle + 0.1) * (innerRadius * 1.05),
//       );
//       final pTip = Offset(
//         center.dx + math.cos(angle) * outerRadius,
//         center.dy + math.sin(angle) * outerRadius,
//       );

//       final path = Path()
//         ..moveTo(p1.dx, p1.dy)
//         ..quadraticBezierTo(
//           center.dx + math.cos(angle) * (outerRadius * 0.9),
//           center.dy + math.sin(angle) * (outerRadius * 0.9),
//           pTip.dx,
//           pTip.dy,
//         )
//         ..quadraticBezierTo(
//           center.dx + math.cos(angle) * (outerRadius * 0.9),
//           center.dy + math.sin(angle) * (outerRadius * 0.9),
//           p2.dx,
//           p2.dy,
//         )
//         ..close();
//       canvas.drawPath(path, petalPaint);
//     }

//     // Decorative arcs between tick marks
//     final arcPaint = Paint()
//       ..color = baseColor.withOpacity(0.2)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.5;

//     for (int i = 0; i < 12; i++) {
//       final startAngle = (i * 30 - 15) * (math.pi / 180);
//       canvas.drawArc(
//         Rect.fromCircle(center: center, radius: outerRadius * 0.95),
//         startAngle,
//         30 * (math.pi / 180),
//         false,
//         arcPaint,
//       );
//     }

//     // Outer dots pattern
//     final dotPaint = Paint()
//       ..color = baseColor.withOpacity(0.4)
//       ..style = PaintingStyle.fill;

//     for (int i = 0; i < 72; i++) {
//       final angle = (i * 5) * (math.pi / 180);
//       final pt = Offset(
//         center.dx + math.cos(angle) * (outerRadius * 0.92),
//         center.dy + math.sin(angle) * (outerRadius * 0.92),
//       );
//       final r = (i % 6 == 0) ? 2.5 : 1.2;
//       canvas.drawCircle(pt, r, dotPaint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// /// Tick marks around the compass face
// class _CompassTicksPainter extends CustomPainter {
//   final bool isDark;
//   _CompassTicksPainter({required this.isDark});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = size.width / 2;

//     final tickColor = isDark ? Colors.white : const Color(0xFF014D28);

//     for (int i = 0; i < 360; i += 5) {
//       final angle = i * (math.pi / 180);
//       final isMajor = i % 90 == 0;
//       final isMinor = i % 30 == 0;

//       final outerR = radius;
//       final innerR = isMajor
//           ? radius - 12
//           : (isMinor ? radius - 8 : radius - 5);

//       final paint = Paint()
//         ..color = isMajor
//             ? tickColor.withOpacity(0.8)
//             : (isMinor
//                   ? tickColor.withOpacity(0.4)
//                   : tickColor.withOpacity(0.15))
//         ..strokeWidth = isMajor ? 2.0 : (isMinor ? 1.2 : 0.5)
//         ..strokeCap = StrokeCap.round;

//       canvas.drawLine(
//         Offset(
//           center.dx + math.cos(angle) * innerR,
//           center.dy + math.sin(angle) * innerR,
//         ),
//         Offset(
//           center.dx + math.cos(angle) * outerR,
//           center.dy + math.sin(angle) * outerR,
//         ),
//         paint,
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// /// Star-shaped compass needle
// class _CompassNeedlePainter extends CustomPainter {
//   final bool isDark;
//   _CompassNeedlePainter({required this.isDark});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final halfW = size.width * 0.06;
//     final len = size.height * 0.42;

//     final Color primaryGreen = const Color(0xFF029E50);
//     final Color secondaryGreen = isDark
//         ? const Color(0xFF1B7A4A)
//         : const Color(0xFF014D28);
//     final Color darkGreen = isDark
//         ? const Color(0xFF0F2D1E)
//         : const Color(0xFF0A2619);

//     // North needle (green)
//     final northPath = Path()
//       ..moveTo(center.dx, center.dy - len)
//       ..lineTo(center.dx - halfW, center.dy)
//       ..lineTo(center.dx + halfW, center.dy)
//       ..close();

//     final northPaint = Paint()
//       ..shader =
//           LinearGradient(
//             colors: [primaryGreen, secondaryGreen],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ).createShader(
//             Rect.fromPoints(
//               Offset(center.dx, center.dy - len),
//               Offset(center.dx, center.dy),
//             ),
//           );
//     canvas.drawPath(northPath, northPaint);

//     // South needle (darker green)
//     final southPath = Path()
//       ..moveTo(center.dx, center.dy + len)
//       ..lineTo(center.dx - halfW, center.dy)
//       ..lineTo(center.dx + halfW, center.dy)
//       ..close();

//     final southPaint = Paint()
//       ..shader =
//           LinearGradient(
//             colors: [darkGreen, secondaryGreen],
//             begin: Alignment.bottomCenter,
//             end: Alignment.topCenter,
//           ).createShader(
//             Rect.fromPoints(
//               Offset(center.dx, center.dy),
//               Offset(center.dx, center.dy + len),
//             ),
//           );
//     canvas.drawPath(southPath, southPaint);

//     // East needle (green)
//     final eastPath = Path()
//       ..moveTo(center.dx + len, center.dy)
//       ..lineTo(center.dx, center.dy - halfW)
//       ..lineTo(center.dx, center.dy + halfW)
//       ..close();
//     canvas.drawPath(eastPath, northPaint);

//     // West needle (darker green)
//     final westPath = Path()
//       ..moveTo(center.dx - len, center.dy)
//       ..lineTo(center.dx, center.dy - halfW)
//       ..lineTo(center.dx, center.dy + halfW)
//       ..close();
//     canvas.drawPath(westPath, southPaint);

//     // Diagonal needles (thinner)
//     final diagLen = len * 0.65;
//     final diagW = halfW * 0.6;
//     final diagPaint = Paint()
//       ..color = secondaryGreen.withOpacity(0.6)
//       ..style = PaintingStyle.fill;

//     for (int i = 0; i < 4; i++) {
//       final angle = (45 + i * 90) * (math.pi / 180);
//       final tipX = center.dx + math.cos(angle) * diagLen;
//       final tipY = center.dy + math.sin(angle) * diagLen;
//       final perpAngle = angle + math.pi / 2;

//       final p = Path()
//         ..moveTo(tipX, tipY)
//         ..lineTo(
//           center.dx + math.cos(perpAngle) * diagW,
//           center.dy + math.sin(perpAngle) * diagW,
//         )
//         ..lineTo(
//           center.dx - math.cos(perpAngle) * diagW,
//           center.dy - math.sin(perpAngle) * diagW,
//         )
//         ..close();

//       canvas.drawPath(p, diagPaint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;

// ─── Accuracy System ─────────────────────────────────────────────────────────
// هذه الدالة تحسب الفرق بين اتجاه الجهاز واتجاه القبلة
double _calculateOffset(double deviceDirection, double qiblahDirection) {
  double diff = qiblahDirection - deviceDirection;
  // نطبّع القيمة لتكون بين -180 و +180
  while (diff > 180) diff -= 360;
  while (diff < -180) diff += 360;
  return diff;
}

// ─── QiblaScreen ─────────────────────────────────────────────────────────────
class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  final Future<bool?> _sensorSupportFuture =
      FlutterQiblah.androidDeviceSensorSupport();

  final _locationStreamController =
      StreamController<LocationStatus>.broadcast();
  Stream<LocationStatus> get _locationStream =>
      _locationStreamController.stream;

  final _calibNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _checkLocationStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
  }

  @override
  void dispose() {
    _locationStreamController.close();
    _calibNotifier.dispose();
    FlutterQiblah().dispose();
    super.dispose();
  }

  Future<void> _checkLocationStatus() async {
    final locationStatus = await FlutterQiblah.checkLocationStatus();
    if (locationStatus.enabled &&
        locationStatus.status == LocationPermission.denied) {
      await FlutterQiblah.requestPermissions();
      final updated = await FlutterQiblah.checkLocationStatus();
      _locationStreamController.sink.add(updated);
    } else {
      _locationStreamController.sink.add(locationStatus);
    }
  }

  Future<void> _openLocationSettings() async {
    await Geolocator.openLocationSettings();
    await Future.delayed(const Duration(milliseconds: 500));
    _checkLocationStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A1F17), Color(0xFF081812), Color(0xFF05100C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // Header with Image and Info Button
          Stack(
            children: [
              Image.asset(
                'assets/images/mosque2.jpg',
                width: double.infinity,
                height: 180.h,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.35),
                colorBlendMode: BlendMode.darken,
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () => _showInstructions(context),
                        icon: Icon(
                          Icons.info_outline_rounded,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Calibration Banner
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ValueListenableBuilder<bool>(
                  valueListenable: _calibNotifier,
                  builder: (_, isUnstable, __) => AnimatedSlide(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    offset: isUnstable ? Offset.zero : const Offset(0, 1.5),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 400),
                      opacity: isUnstable ? 1.0 : 0.0,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: const Color(0xFFFF8F00).withOpacity(0.8),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.rotate_90_degrees_ccw_outlined,
                              color: const Color(0xFFFF8F00),
                              size: 18.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              "حرّك الهاتف على شكل 8 لمعايرة البوصلة",
                              style: TextStyle(
                                color: const Color(0xFFFF8F00),
                                fontSize: 12.sp,
                                fontFamily: 'Tajawal',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Main content
          Expanded(child: _buildCompassSection()),
        ],
      ),
    );
  }

  Widget _buildCompassSection() {
    return FutureBuilder<bool?>(
      future: _sensorSupportFuture,
      builder: (context, sensorSnapshot) {
        if (sensorSnapshot.connectionState == ConnectionState.waiting) {
          return _loadingIndicator();
        }

        final hasSensor = sensorSnapshot.data ?? true;

        if (!hasSensor) {
          return const _NoSensorView();
        }

        return StreamBuilder<LocationStatus>(
          stream: _locationStream,
          builder: (context, locSnapshot) {
            if (locSnapshot.connectionState == ConnectionState.waiting) {
              return _loadingIndicator();
            }

            final locStatus = locSnapshot.data;

            if (locStatus == null || !locStatus.enabled) {
              return _LocationErrorView(
                message: "qibla.activate_location".tr(),
                onEnable: _openLocationSettings,
              );
            }

            if (locStatus.status == LocationPermission.denied ||
                locStatus.status == LocationPermission.deniedForever) {
              return _LocationErrorView(
                message: locStatus.status == LocationPermission.deniedForever
                    ? "qibla.permission_denied_forever".tr()
                    : "qibla.activate_location".tr(),
                onEnable: locStatus.status == LocationPermission.deniedForever
                    ? () async {
                        await Geolocator.openAppSettings();
                        await Future.delayed(const Duration(milliseconds: 500));
                        _checkLocationStatus();
                      }
                    : _checkLocationStatus,
              );
            }

            return _QiblaCompassWidget(calibNotifier: _calibNotifier);
          },
        );
      },
    );
  }

  void _showInstructions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: const Color(0xFF081812),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          border: const Border(
            top: BorderSide(color: Color(0xFFC9A24D), width: 2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),
            Icon(
              Icons.screen_rotation_rounded,
              color: const Color(0xFFC9A24D),
              size: 48.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              "qibla.instructions_title".tr(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              "qibla.activate_location_message".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16.sp,
                fontFamily: 'Tajawal',
                height: 1.5,
              ),
            ),
            SizedBox(height: 32.h),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF029E50),
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
                elevation: 0,
              ),
              child: Text(
                "qibla.understand".tr(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _loadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFF029E50),
        strokeWidth: 3,
      ),
    );
  }
}

// ─── Compass Widget ───────────────────────────────────────────────────────────
class _QiblaCompassWidget extends StatefulWidget {
  final ValueNotifier<bool> calibNotifier;
  const _QiblaCompassWidget({required this.calibNotifier});

  @override
  State<_QiblaCompassWidget> createState() => _QiblaCompassWidgetState();
}

class _QiblaCompassWidgetState extends State<_QiblaCompassWidget>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  bool _isLocked = false;
  final List<double> _recentDirs = [];
  Timer? _calibTimer;
  DateTime? _lastVib;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseAnim = Tween<double>(
      begin: 1.0,
      end: 1.14,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _glowAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _glowCtrl.dispose();
    _calibTimer?.cancel();
    super.dispose();
  }

  void _sideEffects(QiblahDirection qd, double calculatedOffset) {
    if (!mounted) return;
    final absOff = calculatedOffset.abs();

    // Calibration detection
    _recentDirs.add(qd.direction);
    if (_recentDirs.length > 15) _recentDirs.removeAt(0);
    if (_recentDirs.length == 15) {
      final span =
          _recentDirs.reduce((a, b) => a > b ? a : b) -
          _recentDirs.reduce((a, b) => a < b ? a : b);
      final unstable = span > 35;
      if (unstable != widget.calibNotifier.value) {
        widget.calibNotifier.value = unstable;
        if (unstable) {
          _calibTimer?.cancel();
          _calibTimer = Timer(const Duration(seconds: 5), () {
            if (mounted) widget.calibNotifier.value = false;
          });
        }
      }
    }

    // Pulse animation
    if (absOff <= 10) {
      if (!_pulseCtrl.isAnimating) _pulseCtrl.repeat(reverse: true);
    } else {
      if (_pulseCtrl.isAnimating) {
        _pulseCtrl.stop();
        _pulseCtrl.reset();
      }
    }

    // Lock state feedback
    final nowLocked = (absOff <= 3);
    if (nowLocked != _isLocked) {
      setState(() => _isLocked = nowLocked);
      if (nowLocked) {
        _glowCtrl.repeat(reverse: true);
        HapticFeedback.heavyImpact();
        Future.delayed(
          const Duration(milliseconds: 200),
          HapticFeedback.heavyImpact,
        );
      } else {
        _glowCtrl.stop();
        _glowCtrl.reset();
      }
    }

    // Haptic feedback
    if (!nowLocked) {
      final now = DateTime.now();
      final gap = _lastVib == null
          ? const Duration(seconds: 999)
          : now.difference(_lastVib!);
      if (absOff <= 15 && absOff > 5 && gap.inMilliseconds > 1200) {
        HapticFeedback.selectionClick();
        _lastVib = now;
      } else if (absOff <= 5 && gap.inMilliseconds > 700) {
        HapticFeedback.mediumImpact();
        _lastVib = now;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF029E50),
              strokeWidth: 3,
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const _NoSensorView();
        }

        final qiblahDirection = snapshot.data!;

        // ═══ الحسابات الصحيحة ═══
        // نحسب الفرق بين اتجاه الجهاز واتجاه القبلة
        final calculatedOffset = _calculateOffset(
          qiblahDirection.direction,
          qiblahDirection.qiblah,
        );

        // Schedule side effects after frame
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _sideEffects(qiblahDirection, calculatedOffset),
        );

        // compassAngle: يدور البوصلة عكس اتجاه الجهاز لإبقاء الشمال فوق
        final compassAngle = qiblahDirection.direction * (math.pi / 180) * -1;

        // qiblaAngle: زاوية القبلة المطلقة (من الشمال) - تدور المؤشر
        final qiblaAngle = qiblahDirection.qiblah * (math.pi / 180) * -1;

        final absOff = calculatedOffset.abs();
        const accent = Color(0xFFC9A24D); // Premium Gold constant color
        final progress = 1.0 - (absOff / 90).clamp(0.0, 1.0);

        return Column(
          children: [
            SizedBox(height: 20.h),
            // Kaaba Icon
            Icon(
              Icons.mosque_outlined,
              color: Colors.white.withOpacity(0.95),
              size: 52.sp,
            ),
            SizedBox(height: 4.h),
            // Premium Green Indicator Arrow
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(seconds: 1),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Icon(
                    Icons.keyboard_arrow_up_rounded,
                    color: accent,
                    size: 44.sp,
                  ),
                );
              },
            ),
            SizedBox(height: 8.h),
            // Compass Section
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Progress Arc
                        CustomPaint(
                          size: Size.infinite,
                          painter: _ProgressArcPainter(
                            progress: progress,
                            color: accent,
                          ),
                        ),
                        // Static Ornamental Mandala
                        CustomPaint(
                          size: Size.infinite,
                          painter: _OrnamentalRingPainter(),
                        ),
                        // Lock Glow
                        if (_isLocked)
                          AnimatedBuilder(
                            animation: _glowAnim,
                            builder: (_, __) => CustomPaint(
                              size: Size.infinite,
                              painter: _LockGlowPainter(
                                intensity: _glowAnim.value,
                              ),
                            ),
                          ),
                        // Rotating Compass Disk
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: compassAngle),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                          builder: (context, angle, child) {
                            return Transform.rotate(angle: angle, child: child);
                          },
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final outerSize = constraints.maxWidth;
                              final innerDiskSize = outerSize * 0.82;
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Compass Face Disk
                                  Container(
                                    width: innerDiskSize,
                                    height: innerDiskSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const RadialGradient(
                                        colors: [
                                          Color(0xFF1E583A),
                                          Color(0xFF0F2D1E),
                                          Color(0xFF0D2519),
                                          Color(0xFF081A12),
                                        ],
                                        stops: [0.0, 0.4, 0.8, 1.0],
                                      ),
                                      border: Border.all(
                                        color: const Color(
                                          0xFFC9A24D,
                                        ).withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black54,
                                          blurRadius: 10,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Tick marks
                                  CustomPaint(
                                    size: Size(innerDiskSize, innerDiskSize),
                                    painter: _CompassTicksPainter(),
                                  ),
                                  // Direction Labels
                                  _buildDirectionLabels(outerSize),
                                  // North Pointer
                                  CustomPaint(
                                    size: Size(
                                      innerDiskSize * 0.72,
                                      innerDiskSize * 0.72,
                                    ),
                                    painter: _CompassNeedlePainter(),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        // Qibla Indicator
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: qiblaAngle),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                          builder: (context, angle, child) {
                            return SizedBox.expand(
                              child: Transform.rotate(
                                angle: angle,
                                child: child,
                              ),
                            );
                          },
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: AnimatedBuilder(
                              animation: _pulseAnim,
                              builder: (_, child) => Transform.scale(
                                scale: _isLocked ? 1.0 : _pulseAnim.value,
                                child: child,
                              ),
                              child: Container(
                                width: 46.w,
                                height: 46.w,
                                margin: EdgeInsets.only(top: 8.h),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(color: accent, width: 2.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: accent.withOpacity(
                                        _isLocked ? 0.9 : 0.5,
                                      ),
                                      blurRadius: _isLocked ? 20 : 10,
                                      spreadRadius: _isLocked ? 4 : 1,
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.6),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Container(
                                  margin: EdgeInsets.all(3.r),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF014D28),
                                  ),
                                  child: Icon(
                                    Icons.mosque_rounded,
                                    size: 22.sp,
                                    color: accent,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Lock Banner
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _isLocked
                  ? Container(
                      key: const ValueKey('locked'),
                      margin: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 8.h,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF029E50).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: const Color(0xFF029E50).withOpacity(0.6),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: const Color(0xFF029E50),
                            size: 22.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            "تم تحديد القبلة",
                            style: TextStyle(
                              color: const Color(0xFF029E50),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(key: ValueKey('unlocked'), height: 0),
            ),
            // Degree Display
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: const Color(0xFFC9A24D).withOpacity(0.2),
                  ),
                ),
                child: Text(
                  "${calculatedOffset.toStringAsFixed(1)}°",
                  style: TextStyle(
                    color: const Color(0xFFC9A24D),
                    fontSize: 24.sp,
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
          ],
        );
      },
    );
  }

  static Widget _buildDirectionLabels(double size) {
    final style = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: (size * 0.055).clamp(13.0, 18.0).sp,
      letterSpacing: 1.2,
    );
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: const Alignment(0, -0.68),
            child: Text(
              "N",
              style: style.copyWith(
                color: const Color(0xFF029E50),
                fontSize: style.fontSize! + 2,
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0.68, 0),
            child: Text("E", style: style),
          ),
          Align(
            alignment: const Alignment(0, 0.68),
            child: Text("S", style: style),
          ),
          Align(
            alignment: const Alignment(-0.68, 0),
            child: Text("W", style: style),
          ),
        ],
      ),
    );
  }
}

// ─── No Sensor View ──────────────────────────────────────────────────────────
class _NoSensorView extends StatelessWidget {
  const _NoSensorView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(30.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sensors_off_rounded,
              size: 80.sp,
              color: const Color(0xFFC9A24D),
            ),
            SizedBox(height: 24.h),
            Text(
              "qibla.no_sensor".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Tajawal',
                height: 1.6,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              "qibla.no_sensor_details".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14.sp,
                fontFamily: 'Tajawal',
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Location Error View ─────────────────────────────────────────────────────
class _LocationErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onEnable;

  const _LocationErrorView({required this.message, this.onEnable});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Icon(
            Icons.location_off_rounded,
            size: 100.sp,
            color: const Color(0xFFC9A24D),
          ),
          SizedBox(height: 30.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Tajawal',
              height: 1.6,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: onEnable,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF014D28),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                elevation: 0,
              ),
              child: Text(
                "qibla.activate".tr(),
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }
}

// ─── Custom Painters ─────────────────────────────────────────────────────────

class _ProgressArcPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ProgressArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withOpacity(0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round,
      );
    }

    if (progress > 0.02) {
      final headAngle = -math.pi / 2 + 2 * math.pi * progress;
      canvas.drawCircle(
        Offset(
          center.dx + math.cos(headAngle) * radius,
          center.dy + math.sin(headAngle) * radius,
        ),
        5,
        Paint()
          ..color = color.withOpacity(0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressArcPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class _LockGlowPainter extends CustomPainter {
  final double intensity;

  _LockGlowPainter({required this.intensity});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.88;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFF029E50).withOpacity(0.08 + 0.18 * intensity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 18 + 14 * intensity),
    );

    canvas.drawCircle(
      center,
      radius * 0.75,
      Paint()
        ..color = const Color(0xFF029E50).withOpacity(0.05 + 0.1 * intensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  @override
  bool shouldRepaint(covariant _LockGlowPainter oldDelegate) =>
      oldDelegate.intensity != intensity;
}

class _OrnamentalRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.84;
    const baseColor = Color(0xFF1B7A4A);

    canvas.drawCircle(
      center,
      outerRadius,
      Paint()
        ..color = baseColor.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final petalPaint = Paint()
      ..color = baseColor.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    const int petalCount = 16;
    for (int i = 0; i < petalCount; i++) {
      final angle = (i * (360 / petalCount)) * (math.pi / 180);
      final p1 = Offset(
        center.dx + math.cos(angle - 0.1) * (innerRadius * 1.05),
        center.dy + math.sin(angle - 0.1) * (innerRadius * 1.05),
      );
      final p2 = Offset(
        center.dx + math.cos(angle + 0.1) * (innerRadius * 1.05),
        center.dy + math.sin(angle + 0.1) * (innerRadius * 1.05),
      );
      final pTip = Offset(
        center.dx + math.cos(angle) * outerRadius,
        center.dy + math.sin(angle) * outerRadius,
      );

      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..quadraticBezierTo(
          center.dx + math.cos(angle) * (outerRadius * 0.9),
          center.dy + math.sin(angle) * (outerRadius * 0.9),
          pTip.dx,
          pTip.dy,
        )
        ..quadraticBezierTo(
          center.dx + math.cos(angle) * (outerRadius * 0.9),
          center.dy + math.sin(angle) * (outerRadius * 0.9),
          p2.dx,
          p2.dy,
        )
        ..close();
      canvas.drawPath(path, petalPaint);
    }

    final arcPaint = Paint()
      ..color = baseColor.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < 12; i++) {
      final startAngle = (i * 30 - 15) * (math.pi / 180);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: outerRadius * 0.95),
        startAngle,
        30 * (math.pi / 180),
        false,
        arcPaint,
      );
    }

    final dotPaint = Paint()
      ..color = baseColor.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 72; i++) {
      final angle = (i * 5) * (math.pi / 180);
      final pt = Offset(
        center.dx + math.cos(angle) * (outerRadius * 0.92),
        center.dy + math.sin(angle) * (outerRadius * 0.92),
      );
      final r = (i % 6 == 0) ? 2.5 : 1.2;
      canvas.drawCircle(pt, r, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CompassTicksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (int i = 0; i < 360; i += 5) {
      final angle = i * (math.pi / 180);
      final isMajor = i % 90 == 0;
      final isMinor = i % 30 == 0;

      final outerR = radius;
      final innerR = isMajor
          ? radius - 12
          : (isMinor ? radius - 8 : radius - 5);

      final paint = Paint()
        ..color = isMajor
            ? Colors.white.withOpacity(0.8)
            : (isMinor
                  ? Colors.white.withOpacity(0.4)
                  : Colors.white.withOpacity(0.15))
        ..strokeWidth = isMajor ? 2.0 : (isMinor ? 1.2 : 0.5)
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(
          center.dx + math.cos(angle) * innerR,
          center.dy + math.sin(angle) * innerR,
        ),
        Offset(
          center.dx + math.cos(angle) * outerR,
          center.dy + math.sin(angle) * outerR,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CompassNeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final halfW = size.width * 0.06;
    final len = size.height * 0.42;

    const Color primaryGreen = Color(0xFF029E50);
    const Color secondaryGreen = Color(0xFF1B7A4A);
    const Color darkGreen = Color(0xFF0F2D1E);

    final northPath = Path()
      ..moveTo(center.dx, center.dy - len)
      ..lineTo(center.dx - halfW, center.dy)
      ..lineTo(center.dx + halfW, center.dy)
      ..close();

    canvas.drawPath(
      northPath,
      Paint()
        ..shader =
            const LinearGradient(
              colors: [primaryGreen, secondaryGreen],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(
              Rect.fromPoints(
                Offset(center.dx, center.dy - len),
                Offset(center.dx, center.dy),
              ),
            ),
    );

    final southPath = Path()
      ..moveTo(center.dx, center.dy + len)
      ..lineTo(center.dx - halfW, center.dy)
      ..lineTo(center.dx + halfW, center.dy)
      ..close();

    canvas.drawPath(
      southPath,
      Paint()
        ..shader =
            const LinearGradient(
              colors: [darkGreen, secondaryGreen],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ).createShader(
              Rect.fromPoints(
                Offset(center.dx, center.dy),
                Offset(center.dx, center.dy + len),
              ),
            ),
    );

    final eastPath = Path()
      ..moveTo(center.dx + len, center.dy)
      ..lineTo(center.dx, center.dy - halfW)
      ..lineTo(center.dx, center.dy + halfW)
      ..close();

    canvas.drawPath(
      eastPath,
      Paint()
        ..shader =
            const LinearGradient(
              colors: [primaryGreen, secondaryGreen],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(
              Rect.fromPoints(
                Offset(center.dx, center.dy - halfW),
                Offset(center.dx + len, center.dy + halfW),
              ),
            ),
    );

    final westPath = Path()
      ..moveTo(center.dx - len, center.dy)
      ..lineTo(center.dx, center.dy - halfW)
      ..lineTo(center.dx, center.dy + halfW)
      ..close();

    canvas.drawPath(
      westPath,
      Paint()
        ..shader =
            const LinearGradient(
              colors: [darkGreen, secondaryGreen],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ).createShader(
              Rect.fromPoints(
                Offset(center.dx - len, center.dy - halfW),
                Offset(center.dx, center.dy + halfW),
              ),
            ),
    );

    final diagLen = len * 0.65;
    final diagW = halfW * 0.6;
    final diagPaint = Paint()
      ..color = secondaryGreen.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 4; i++) {
      final angle = (45 + i * 90) * (math.pi / 180);
      final tipX = center.dx + math.cos(angle) * diagLen;
      final tipY = center.dy + math.sin(angle) * diagLen;
      final perpAngle = angle + math.pi / 2;

      final p = Path()
        ..moveTo(tipX, tipY)
        ..lineTo(
          center.dx + math.cos(perpAngle) * diagW,
          center.dy + math.sin(perpAngle) * diagW,
        )
        ..lineTo(
          center.dx - math.cos(perpAngle) * diagW,
          center.dy - math.sin(perpAngle) * diagW,
        )
        ..close();

      canvas.drawPath(p, diagPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
