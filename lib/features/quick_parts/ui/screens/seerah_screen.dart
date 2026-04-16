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
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _pdfController = PdfViewerController();
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SeerahCubit(),
      child: _SeerahView(
        pdfController: _pdfController,
        pdfViewerKey: _pdfViewerKey,
      ),
    );
  }
}

class _SeerahView extends StatelessWidget {
  final PdfViewerController pdfController;
  final GlobalKey<SfPdfViewerState> pdfViewerKey;

  const _SeerahView({required this.pdfController, required this.pdfViewerKey});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SeerahCubit>();
    final primary = AppColors.getPrimary(context);

    return BlocBuilder<SeerahCubit, SeerahState>(
      buildWhen: (prev, curr) => prev.isSearching != curr.isSearching,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.colorScheme.surface,
          appBar: state.isSearching
              ? _buildSearchAppBar(context, cubit, primary)
              : _buildAppBar(context, cubit, primary),
          body: _SeerahBody(
            cubit: cubit,
            pdfController: pdfController,
            pdfViewerKey: pdfViewerKey,
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    SeerahCubit cubit,
    Color primary,
  ) {
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

  PreferredSizeWidget _buildSearchAppBar(
    BuildContext context,
    SeerahCubit cubit,
    Color primary,
  ) {
    return AppBar(
      backgroundColor: context.colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        onPressed: cubit.toggleSearch,
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
      ),
      actions: [
        BlocBuilder<SeerahCubit, SeerahState>(
          buildWhen: (p, c) => p.hasSearchResult != c.hasSearchResult,
          builder: (context, state) {
            if (!state.hasSearchResult) return const SizedBox.shrink();
            return Row(
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

class _SeerahBody extends StatefulWidget {
  final SeerahCubit cubit;
  final PdfViewerController pdfController;
  final GlobalKey<SfPdfViewerState> pdfViewerKey;

  const _SeerahBody({
    required this.cubit,
    required this.pdfController,
    required this.pdfViewerKey,
  });

  @override
  State<_SeerahBody> createState() => _SeerahBodyState();
}

class _SeerahBodyState extends State<_SeerahBody> {
  @override
  void dispose() {
    widget.cubit.saveCurrentPage(widget.pdfController.pageNumber);
    super.dispose();
  }

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
    final primary = AppColors.getPrimary(context);

    return Stack(
      children: [
        SfPdfViewer.asset(
          'assets/pdfs/alrraheqAlmakhtom.pdf',
          key: widget.pdfViewerKey,
          controller: widget.pdfController,
          onDocumentLoaded: _onDocumentLoaded,
          canShowScrollHead: true,
          canShowScrollStatus: true,
          canShowPaginationDialog: true,
          enableTextSelection: true,
          enableDocumentLinkAnnotation: true,
          pageSpacing: 4,
          maxZoomLevel: 5,
          onPageChanged: (details) =>
              widget.cubit.saveCurrentPage(details.newPageNumber),
        ),
        BlocBuilder<SeerahCubit, SeerahState>(
          buildWhen: (p, c) => p.isLoaded != c.isLoaded,
          builder: (context, state) {
            if (state.isLoaded) return const SizedBox.shrink();
            return Container(
              color: context.colorScheme.surface,
              child: Center(
                child: CircularProgressIndicator(
                  color: primary,
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

class _SearchField extends StatelessWidget {
  final SeerahCubit cubit;
  final Color primary;
  final PdfViewerController pdfController;
  final TextEditingController _controller = TextEditingController();

  _SearchField({
    required this.cubit,
    required this.primary,
    required this.pdfController,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      autofocus: true,
      textInputAction: TextInputAction.search,
      onSubmitted: (q) => cubit.performSearch(q, pdfController),
      style: TextStyle(fontSize: 16.sp, color: context.colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: 'ابحث في الكتاب...',
        hintStyle: TextStyle(fontSize: 15.sp, color: AppColors.grey),
        border: InputBorder.none,
        suffixIcon: IconButton(
          onPressed: () => cubit.performSearch(_controller.text, pdfController),
          icon: Icon(Icons.search_rounded, size: 22.sp, color: primary),
        ),
      ),
    );
  }
}
