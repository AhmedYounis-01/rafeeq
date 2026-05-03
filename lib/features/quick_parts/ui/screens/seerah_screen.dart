import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rafeeq/features/quick_parts/logic/seerah_cubit.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:rafeeq/core/extensions/theme_extension.dart';
import 'package:rafeeq/core/themes/app_colors.dart';

class SeerahScreen extends StatefulWidget {
  const SeerahScreen({super.key});

  @override
  State<SeerahScreen> createState() => _SeerahScreenState();
}

class _SeerahScreenState extends State<SeerahScreen> {
  late final PdfViewerController _pdfController;
  late final SeerahCubit _cubit;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  // ✅ Controller هنا عشان يتـdispose صح
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pdfController = PdfViewerController();
    _cubit = SeerahCubit();
  }

  @override
  void dispose() {
    _pdfController.dispose();
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: _SeerahView(
        pdfController: _pdfController,
        pdfViewerKey: _pdfViewerKey,
        searchController: _searchController,
        cubit: _cubit,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
class _SeerahView extends StatelessWidget {
  final PdfViewerController pdfController;
  final GlobalKey<SfPdfViewerState> pdfViewerKey;
  final TextEditingController searchController;
  final SeerahCubit cubit;

  const _SeerahView({
    required this.pdfController,
    required this.pdfViewerKey,
    required this.searchController,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.getPrimary(context);

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      // ✅ BlocSelector بدل BlocBuilder - بيـrebuild AppBar بس
      appBar: _SeerahAppBar(
        pdfController: pdfController,
        pdfViewerKey: pdfViewerKey,
        searchController: searchController,
        cubit: cubit,
        primary: primary,
      ),
      body: _SeerahBody(
        cubit: cubit,
        pdfController: pdfController,
        pdfViewerKey: pdfViewerKey,
        primary: primary,
      ),
    );
  }
}

// ─── AppBar كـ PreferredSizeWidget مستقل ─────────────────────────────────
class _SeerahAppBar extends StatelessWidget implements PreferredSizeWidget {
  final PdfViewerController pdfController;
  final GlobalKey<SfPdfViewerState> pdfViewerKey;
  final TextEditingController searchController;
  final SeerahCubit cubit;
  final Color primary;

  const _SeerahAppBar({
    required this.pdfController,
    required this.pdfViewerKey,
    required this.searchController,
    required this.cubit,
    required this.primary,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    // ✅ بيبني AppBar بس لما isSearching تتغير
    return BlocSelector<SeerahCubit, SeerahState, bool>(
      selector: (state) => state.isSearching,
      builder: (context, isSearching) {
        return isSearching
            ? _buildSearchBar(context)
            : _buildNormalBar(context);
      },
    );
  }

  AppBar _buildNormalBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      backgroundColor: context.colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20.sp,
          color: context.colorScheme.onSurface,
        ),
      ),
      title: Text(
        'quick_parts_screens.seerah_title'.tr(),
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: context.colorScheme.onSurface,
        ),
      ),
      actions: [
        IconButton(
          onPressed: cubit.toggleSearch,
          tooltip: 'بحث',
          icon: Icon(
            Icons.search_rounded,
            size: 22.sp,
            color: context.colorScheme.onSurface,
          ),
        ),
        IconButton(
          onPressed: () => pdfViewerKey.currentState?.openBookmarkView(),
          tooltip: 'الفهرس',
          icon: Icon(
            Icons.bookmark_outline_rounded,
            size: 22.sp,
            color: context.colorScheme.onSurface,
          ),
        ),
        SizedBox(width: 4.w),
      ],
    );
  }

  AppBar _buildSearchBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        onPressed: () {
          searchController.clear();
          cubit.toggleSearch();
        },
        icon: Icon(
          Icons.close_rounded,
          size: 22.sp,
          color: context.colorScheme.onSurface,
        ),
      ),
      title: _SearchField(
        cubit: cubit,
        primary: primary,
        pdfController: pdfController,
        controller: searchController,
      ),
      actions: [
        // ✅ BlocSelector للأزرار بس - مش بيأثر على AppBar كله
        BlocSelector<SeerahCubit, SeerahState, bool>(
          selector: (state) => state.hasSearchResult,
          builder: (_, hasResult) {
            if (!hasResult) return const SizedBox.shrink();
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: cubit.previousSearchInstance,
                  icon: Icon(Icons.keyboard_arrow_up_rounded, size: 24.sp),
                ),
                IconButton(
                  onPressed: cubit.nextSearchInstance,
                  icon: Icon(Icons.keyboard_arrow_down_rounded, size: 24.sp),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
class _SeerahBody extends StatefulWidget {
  final SeerahCubit cubit;
  final PdfViewerController pdfController;
  final GlobalKey<SfPdfViewerState> pdfViewerKey;
  final Color primary;

  const _SeerahBody({
    required this.cubit,
    required this.pdfController,
    required this.pdfViewerKey,
    required this.primary,
  });

  @override
  State<_SeerahBody> createState() => _SeerahBodyState();
}

class _SeerahBodyState extends State<_SeerahBody> {
  void _onDocumentLoaded(PdfDocumentLoadedDetails details) {
    if (!mounted) return;
    final savedPage = widget.cubit.savedPage;
    if (savedPage > 1 && savedPage <= widget.pdfController.pageCount) {
      widget.pdfController.jumpToPage(savedPage);
    }
    widget.cubit.onDocumentLoaded();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ✅ RepaintBoundary يمنع الـ PDF من الـ repaint لما الـ loading تختفي
        RepaintBoundary(
          child: _PdfBody(
            pdfViewerKey: widget.pdfViewerKey,
            pdfController: widget.pdfController,
            onDocumentLoaded: _onDocumentLoaded,
            onPageChanged: (details) =>
                widget.cubit.saveCurrentPage(details.newPageNumber),
          ),
        ),

        // ✅ Loading overlay - بيختفي مرة واحدة بس
        BlocSelector<SeerahCubit, SeerahState, bool>(
          selector: (state) => state.isLoaded,
          builder: (context, isLoaded) {
            if (isLoaded) return const SizedBox.shrink();
            return ColoredBox(
              color: context.colorScheme.surface,
              child: Center(
                child: CircularProgressIndicator(
                  color: widget.primary,
                  strokeWidth: 3,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// ✅ StatelessWidget - Controller بييجي من الأب مش بيتعمل جوا
class _SearchField extends StatelessWidget {
  final SeerahCubit cubit;
  final Color primary;
  final PdfViewerController pdfController;
  final TextEditingController controller;

  const _SearchField({
    required this.cubit,
    required this.primary,
    required this.pdfController,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: true,
      textInputAction: TextInputAction.search,
      onSubmitted: (q) => cubit.performSearch(q, pdfController),
      style: TextStyle(fontSize: 16.sp, color: context.colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: 'ابحث في الكتاب...',
        hintStyle: TextStyle(fontSize: 15.sp, color: AppColors.grey),
        border: InputBorder.none,
        suffixIcon: IconButton(
          onPressed: () => cubit.performSearch(controller.text, pdfController),
          icon: Icon(Icons.search_rounded, size: 22.sp, color: primary),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// ✅ StatelessWidget منفصل - الـ PDF مش بيتبنى إلا مرة واحدة
class _PdfBody extends StatelessWidget {
  final GlobalKey<SfPdfViewerState> pdfViewerKey;
  final PdfViewerController pdfController;
  final void Function(PdfDocumentLoadedDetails) onDocumentLoaded;
  final void Function(PdfPageChangedDetails) onPageChanged;

  const _PdfBody({
    required this.pdfViewerKey,
    required this.pdfController,
    required this.onDocumentLoaded,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SfPdfViewer.asset(
      'assets/pdfs/alrraheqAlmakhtom.pdf',
      key: pdfViewerKey,
      controller: pdfController,
      onDocumentLoaded: onDocumentLoaded,
      canShowScrollHead: true,
      canShowScrollStatus: true,
      canShowPaginationDialog: true,
      enableTextSelection: true,
      enableDocumentLinkAnnotation: true,
      pageSpacing: 4,
      maxZoomLevel: 5,
      onPageChanged: onPageChanged,
    );
  }
}
