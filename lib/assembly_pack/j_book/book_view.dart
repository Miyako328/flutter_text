import 'dart:io';
import 'dart:typed_data';

import 'package:epub_view/epub_view.dart';
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
  double _fontSize = GlobalStore.isMobile ? 18 : 19;
  double _lineHeight = 1.78;
  int _paperTone = 0;
  bool _showSettings = false;

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

  void _toggleSettings() {
    setState(() => _showSettings = !_showSettings);
  }

  void _changeFontSize(double value) {
    setState(() => _fontSize = value);
  }

  void _changeLineHeight(double value) {
    setState(() => _lineHeight = value);
  }

  void _changePaperTone(int value) {
    setState(() => _paperTone = value);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) {
        _closeReader();
      },
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
                    tooltip: '阅读设置',
                    onPressed: _toggleSettings,
                    icon: const Icon(Icons.tune_rounded),
                  ),
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
                  fontSize: _fontSize,
                  lineHeight: _lineHeight,
                  paperTone: _paperTone,
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
                    onOpenSettings: _toggleSettings,
                  ),
                ),
              if (_showSettings)
                Positioned(
                  top: GlobalStore.isMobile ? 12 : 92,
                  right: GlobalStore.isMobile ? 12 : 34,
                  left: GlobalStore.isMobile ? 12 : null,
                  child: _ReaderSettingsPanel(
                    fontSize: _fontSize,
                    lineHeight: _lineHeight,
                    paperTone: _paperTone,
                    onFontSizeChanged: _changeFontSize,
                    onLineHeightChanged: _changeLineHeight,
                    onPaperToneChanged: _changePaperTone,
                    onClose: _toggleSettings,
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
  final double fontSize;
  final double lineHeight;
  final int paperTone;

  const _ReaderCanvas({
    required this.controller,
    required this.fontSize,
    required this.lineHeight,
    required this.paperTone,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isMobile = GlobalStore.isMobile;
    final Color paper = _readerPaper(context, paperTone);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 0 : 36,
        isMobile ? 0 : 88,
        isMobile ? 0 : 36,
        isMobile ? 0 : 28,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: isMobile ? double.infinity : 1280),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: paper,
              borderRadius:
                  isMobile ? BorderRadius.zero : BorderRadius.circular(8),
              border: isMobile
                  ? null
                  : Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.36),
                    ),
            ),
            child: ClipRRect(
              borderRadius:
                  isMobile ? BorderRadius.zero : BorderRadius.circular(8),
              child: Stack(
                children: <Widget>[
                  Positioned.fill(child: ColoredBox(color: paper)),
                  if (isMobile)
                    EpubView(
                      controller: controller,
                      builders: _readerBuilders(
                        context: context,
                        colorScheme: colorScheme,
                        isMobile: isMobile,
                        fontSize: fontSize,
                        lineHeight: lineHeight,
                        paperTone: paperTone,
                      ),
                    )
                  else
                    EpubDesktopPagedView(
                      controller: controller,
                      pagePadding: const EdgeInsets.fromLTRB(64, 70, 64, 92),
                      pageColor: paper,
                      builders: _readerBuilders(
                        context: context,
                        colorScheme: colorScheme,
                        isMobile: isMobile,
                        fontSize: fontSize,
                        lineHeight: lineHeight,
                        paperTone: paperTone,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

EpubViewBuilders<DefaultBuilderOptions> _readerBuilders({
  required BuildContext context,
  required ColorScheme colorScheme,
  required bool isMobile,
  required double fontSize,
  required double lineHeight,
  required int paperTone,
}) {
  return EpubViewBuilders<DefaultBuilderOptions>(
    options: DefaultBuilderOptions(
      chapterPadding: EdgeInsets.fromLTRB(
        isMobile ? 38 : 128,
        isMobile ? 34 : 66,
        isMobile ? 38 : 128,
        22,
      ),
      paragraphPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 38 : 128,
        vertical: isMobile ? 3 : 4,
      ),
      textStyle: TextStyle(
        height: lineHeight,
        fontSize: fontSize,
        letterSpacing: 0,
        color: _readerTextColor(context, paperTone),
      ),
    ),
    loaderBuilder: (BuildContext context) => Center(
      child: SizedBox(
        width: 26,
        height: 26,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: colorScheme.primary,
        ),
      ),
    ),
  );
}

Color _readerBackground(BuildContext context) {
  final Brightness brightness = Theme.of(context).brightness;
  return brightness == Brightness.dark
      ? const Color(0xFF161615)
      : const Color(0xFFF3EFE7);
}

Color _readerPaper(BuildContext context, int tone) {
  final Brightness brightness = Theme.of(context).brightness;
  if (brightness == Brightness.dark) {
    return switch (tone) {
      1 => const Color(0xFF20231E),
      2 => const Color(0xFF1D2024),
      _ => const Color(0xFF20201E),
    };
  }
  return switch (tone) {
    1 => const Color(0xFFF7F0DD),
    2 => const Color(0xFFF5F7F1),
    _ => const Color(0xFFFFFCF4),
  };
}

Color _readerTextColor(BuildContext context, int tone) {
  final Brightness brightness = Theme.of(context).brightness;
  if (brightness == Brightness.dark) {
    return const Color(0xFFE5DED0);
  }
  return switch (tone) {
    1 => const Color(0xFF3F3627),
    2 => const Color(0xFF26352D),
    _ => const Color(0xFF2F2A23),
  };
}

class _ReaderTopBar extends StatelessWidget {
  final EpubController controller;
  final String title;
  final VoidCallback onBack;
  final VoidCallback onOpenToc;
  final VoidCallback onOpenSettings;

  const _ReaderTopBar({
    required this.controller,
    required this.title,
    required this.onBack,
    required this.onOpenToc,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(8),
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
                  tooltip: '阅读设置',
                  onPressed: onOpenSettings,
                  icon: const Icon(Icons.tune_rounded),
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

class _ReaderSettingsPanel extends StatelessWidget {
  final double fontSize;
  final double lineHeight;
  final int paperTone;
  final ValueChanged<double> onFontSizeChanged;
  final ValueChanged<double> onLineHeightChanged;
  final ValueChanged<int> onPaperToneChanged;
  final VoidCallback onClose;

  const _ReaderSettingsPanel({
    required this.fontSize,
    required this.lineHeight,
    required this.paperTone,
    required this.onFontSizeChanged,
    required this.onLineHeightChanged,
    required this.onPaperToneChanged,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: Align(
        alignment:
            GlobalStore.isMobile ? Alignment.topCenter : Alignment.topRight,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.46),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.auto_stories_rounded,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '阅读设置',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                      IconButton(
                        tooltip: '关闭',
                        visualDensity: VisualDensity.compact,
                        onPressed: onClose,
                        icon: const Icon(Icons.close_rounded, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _ReaderSlider(
                    label: '字号',
                    value: fontSize,
                    min: 15,
                    max: 24,
                    divisions: 9,
                    displayValue: fontSize.toStringAsFixed(0),
                    onChanged: onFontSizeChanged,
                  ),
                  _ReaderSlider(
                    label: '行距',
                    value: lineHeight,
                    min: 1.45,
                    max: 2.1,
                    divisions: 13,
                    displayValue: lineHeight.toStringAsFixed(2),
                    onChanged: onLineHeightChanged,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: 46,
                        child: Text(
                          '纸张',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Wrap(
                          spacing: 10,
                          children: <Widget>[
                            _PaperToneButton(
                              label: '米白',
                              color: const Color(0xFFFFFCF4),
                              selected: paperTone == 0,
                              onTap: () => onPaperToneChanged(0),
                            ),
                            _PaperToneButton(
                              label: '暖纸',
                              color: const Color(0xFFF7F0DD),
                              selected: paperTone == 1,
                              onTap: () => onPaperToneChanged(1),
                            ),
                            _PaperToneButton(
                              label: '青灰',
                              color: const Color(0xFFF5F7F1),
                              selected: paperTone == 2,
                              onTap: () => onPaperToneChanged(2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReaderSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String displayValue;
  final ValueChanged<double> onChanged;

  const _ReaderSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.displayValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: <Widget>[
        SizedBox(
          width: 46,
          child: Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: displayValue,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 36,
          child: Text(
            displayValue,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _PaperToneButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _PaperToneButton({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant.withValues(alpha: 0.7),
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? <BoxShadow>[
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.22),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: selected
              ? Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: colorScheme.primary,
                )
              : null,
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
      builder: (dynamic chapterValue) => Text(
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
                  dynamic chapter,
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
