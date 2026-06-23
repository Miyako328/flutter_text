import 'dart:io';
import 'dart:typed_data';

import 'package:epub_view/epub_view.dart';
import 'package:epub_view/src/data/models/chapter.dart';
import 'package:epub_view/src/data/models/chapter_view_value.dart';
import 'package:flutter/material.dart';
import 'package:flutter_text/assembly_pack/j_book/book_cache.dart';
import 'package:flutter_text/global/global.dart';
import 'package:self_utils/utils/navigator.dart';
import 'package:self_utils/utils/screen.dart';
import 'package:self_utils/widget/api_call_back.dart';

class BookView extends StatefulWidget {
  final BookModel book;

  const BookView({required this.book});

  @override
  _BookViewState createState() => _BookViewState();
}

class _BookViewState extends State<BookView> {
  late EpubController _epubController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    final Uint8List bytes = File(widget.book.bookPath!).readAsBytesSync();
    _epubController = EpubController(
      document: EpubReader.readBook(bytes),
    );
    Future<void>.delayed(const Duration(milliseconds: 200)).then(
      (_) => setIndex(),
    );
  }

  @override
  void dispose() {
    _epubController.dispose();
    super.dispose();
  }

  void setIndex() async {
    if ((widget.book.index ?? 0) > 0) {
      await loadingCallback(
        () => Future<void>.delayed(const Duration(milliseconds: 16)).then(
          (_) => _epubController.scrollTo(
            index: widget.book.index ?? 0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutQuart,
          ),
        ),
      );
    }
  }

  Future<bool> _closeReader() async {
    final int? currentIndex = _epubController.currentValue?.position.index;
    await BookCache.updateIndex(
      id: widget.book.id,
      index: currentIndex,
    );
    if (mounted) {
      NavigatorUtils.pop(context, results: currentIndex);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _closeReader,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: _readerBackground(context),
        appBar: GlobalStore.isMobile
            ? AppBar(
                leading: IconButton(
                  tooltip: '返回',
                  onPressed: _closeReader,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
                title: _ChapterTitle(controller: _epubController),
                actions: <Widget>[
                  IconButton(
                    tooltip: '目录',
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    icon: const Icon(Icons.format_list_bulleted_rounded),
                  ),
                ],
              )
            : null,
        drawer: Drawer(
          child: _ReaderTableOfContents(controller: _epubController),
        ),
        body: RepaintBoundary(
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: _ReaderCanvas(
                  controller: _epubController,
                ),
              ),
              if (!GlobalStore.isMobile)
                Positioned(
                  top: 18,
                  left: 22,
                  right: 22,
                  child: _ReaderTopBar(
                    controller: _epubController,
                    title: widget.book.title ?? '未命名书籍',
                    onBack: _closeReader,
                    onOpenToc: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                ),
              Positioned(
                bottom: screenUtil.adaptive(20),
                right: screenUtil.adaptive(20),
                child: RepaintBoundary(
                  child: IndexPage(epubController: _epubController),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReaderCanvas extends StatelessWidget {
  final EpubController controller;

  const _ReaderCanvas({required this.controller});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        GlobalStore.isMobile ? 0 : 28,
        GlobalStore.isMobile ? 0 : 76,
        GlobalStore.isMobile ? 0 : 28,
        0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _readerPaper(context),
              borderRadius: GlobalStore.isMobile
                  ? BorderRadius.zero
                  : BorderRadius.circular(8),
              border: GlobalStore.isMobile
                  ? null
                  : Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.36),
                    ),
              boxShadow: GlobalStore.isMobile
                  ? null
                  : <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
            ),
            child: ClipRRect(
              borderRadius: GlobalStore.isMobile
                  ? BorderRadius.zero
                  : BorderRadius.circular(8),
              child: EpubView(
                controller: controller,
                builders: EpubViewBuilders<DefaultBuilderOptions>(
                  options: DefaultBuilderOptions(
                    chapterPadding: EdgeInsets.fromLTRB(
                      GlobalStore.isMobile ? 20 : 52,
                      GlobalStore.isMobile ? 24 : 44,
                      GlobalStore.isMobile ? 20 : 52,
                      18,
                    ),
                    paragraphPadding: EdgeInsets.symmetric(
                      horizontal: GlobalStore.isMobile ? 20 : 52,
                      vertical: 2,
                    ),
                    textStyle: TextStyle(
                      height: 1.72,
                      fontSize: GlobalStore.isMobile ? 17 : 18,
                      color: colorScheme.onSurface.withValues(alpha: 0.88),
                    ),
                  ),
                  loaderBuilder: (BuildContext context) => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Color _readerBackground(BuildContext context) {
  final Brightness brightness = Theme.of(context).brightness;
  return brightness == Brightness.dark
      ? const Color(0xFF161615)
      : const Color(0xFFF3EFE7);
}

Color _readerPaper(BuildContext context) {
  final Brightness brightness = Theme.of(context).brightness;
  return brightness == Brightness.dark
      ? const Color(0xFF20201E)
      : const Color(0xFFFFFCF4);
}

class _ReaderTopBar extends StatelessWidget {
  final EpubController controller;
  final String title;
  final VoidCallback onBack;
  final VoidCallback onOpenToc;

  const _ReaderTopBar({
    required this.controller,
    required this.title,
    required this.onBack,
    required this.onOpenToc,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.36),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: <Widget>[
                IconButton(
                  tooltip: '返回书架',
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      _ChapterTitle(
                        controller: controller,
                        textStyle: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: '目录',
                  onPressed: onOpenToc,
                  icon: const Icon(Icons.format_list_bulleted_rounded),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChapterTitle extends StatelessWidget {
  final EpubController controller;
  final TextStyle? textStyle;

  const _ChapterTitle({
    required this.controller,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return EpubViewActualChapter(
      controller: controller,
      builder: (EpubChapterViewValue? chapterValue) => Text(
        chapterValue?.chapter?.Title?.trim().isNotEmpty == true
            ? chapterValue!.chapter!.Title!.trim()
            : '正在阅读',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.start,
        style: textStyle,
      ),
    );
  }
}

class _ReaderTableOfContents extends StatelessWidget {
  final EpubController controller;

  const _ReaderTableOfContents({required this.controller});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colorScheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 12),
              child: Text(
                '目录',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            Divider(
              height: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            Expanded(
              child: EpubViewTableOfContents(
                controller: controller,
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemBuilder: (
                  BuildContext context,
                  int index,
                  EpubViewChapter chapter,
                  int itemCount,
                ) {
                  return ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 2,
                    ),
                    title: Text(
                      chapter.title?.trim() ?? '未命名章节',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    leading: Text(
                      '${index + 1}'.padLeft(2, '0'),
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    onTap: () {
                      controller.scrollTo(index: chapter.startIndex);
                      Navigator.of(context).maybePop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IndexPage extends StatefulWidget {
  final EpubController epubController;

  const IndexPage({required this.epubController});

  @override
  _IndexState createState() => _IndexState();
}

class _IndexState extends State<IndexPage> {
  int index = 0;
  late VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    listenerPage();
  }

  @override
  void dispose() {
    widget.epubController.currentValueListenable.removeListener(_listener);
    super.dispose();
  }

  void listenerPage() {
    _listener = () {
      index = widget.epubController.currentValue?.position.index ?? 0;
      if (mounted) {
        setState(() {});
      }
    };
    widget.epubController.currentValueListenable.addListener(_listener);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.36),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.bookmark_border_rounded,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                '进度 $index',
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.82),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
