import 'dart:async';
import 'dart:ui' show PointerDeviceKind;

import 'package:collection/collection.dart' show IterableExtension;
import 'package:epub_view/src/data/epub_cfi_reader.dart';
import 'package:epub_view/src/data/epub_parser.dart';
import 'package:epub_view/src/data/models/chapter.dart';
import 'package:epub_view/src/data/models/chapter_view_value.dart';
import 'package:epub_view/src/data/models/paragraph.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

export 'package:epubx/epubx.dart' hide Image;

part '../epub_controller.dart';
part '../helpers/epub_view_builders.dart';

const _minTrailingEdge = 0.55;
const _minLeadingEdge = -0.05;

typedef ExternalLinkPressed = void Function(String href);

class EpubView extends StatefulWidget {
  const EpubView({
    required this.controller,
    this.onExternalLinkPressed,
    this.onChapterChanged,
    this.onDocumentLoaded,
    this.onDocumentError,
    this.builders = const EpubViewBuilders<DefaultBuilderOptions>(
      options: DefaultBuilderOptions(),
    ),
    this.shrinkWrap = false,
    Key? key,
  }) : super(key: key);

  final EpubController controller;
  final ExternalLinkPressed? onExternalLinkPressed;
  final bool shrinkWrap;
  final void Function(EpubChapterViewValue? value)? onChapterChanged;

  /// Called when a document is loaded
  final void Function(EpubBook document)? onDocumentLoaded;

  /// Called when a document loading error
  final void Function(Exception? error)? onDocumentError;

  /// Builders
  final EpubViewBuilders builders;

  @override
  State<EpubView> createState() => _EpubViewState();
}

abstract class _EpubViewHost {
  EpubChapterViewValue? get currentValue;
  Exception? get loadingError;
  set loadingError(Exception? error);
  List<int> get chapterIndexes;

  Future<bool> initDocument();

  void jumpTo({
    required int index,
    double alignment = 0,
  });

  Future<void>? scrollTo({
    required int index,
    Duration duration = const Duration(milliseconds: 250),
    double alignment = 0,
    Curve curve = Curves.linear,
  });

  void gotoEpubCfi(
    String? epubCfi, {
    double alignment = 0,
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.linear,
  });

  String? generateEpubCfi();
}

class _EpubViewState extends State<EpubView> implements _EpubViewHost {
  Exception? _loadingError;
  ItemScrollController? _itemScrollController;
  ItemPositionsListener? _itemPositionListener;
  List<EpubChapter> _chapters = [];
  List<Paragraph> _paragraphs = [];
  EpubCfiReader? _epubCfiReader;
  EpubChapterViewValue? _currentValue;
  final _chapterIndexes = <int>[];

  EpubController get _controller => widget.controller;

  @override
  EpubChapterViewValue? get currentValue => _currentValue;

  @override
  Exception? get loadingError => _loadingError;

  @override
  set loadingError(Exception? error) => _loadingError = error;

  @override
  List<int> get chapterIndexes => _chapterIndexes;

  @override
  void initState() {
    super.initState();
    _itemScrollController = ItemScrollController();
    _itemPositionListener = ItemPositionsListener.create();
    _controller._attach(this);
    _controller.loadingState.addListener(() {
      switch (_controller.loadingState.value) {
        case EpubViewLoadingState.loading:
          break;
        case EpubViewLoadingState.success:
          widget.onDocumentLoaded?.call(_controller._document!);
          break;
        case EpubViewLoadingState.error:
          widget.onDocumentError?.call(_loadingError);
          break;
      }

      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _itemPositionListener!.itemPositions.removeListener(_changeListener);
    _controller._detach();
    super.dispose();
  }

  @override
  Future<bool> initDocument() async {
    if (_controller.isBookLoaded.value) {
      return true;
    }
    _chapters = parseChapters(_controller._document!);
    final parseParagraphsResult =
        parseParagraphs(_chapters, _controller._document!.Content);
    _paragraphs = parseParagraphsResult.flatParagraphs;
    _chapterIndexes.addAll(parseParagraphsResult.chapterIndexes);

    _epubCfiReader = EpubCfiReader.parser(
      cfiInput: _controller.epubCfi,
      chapters: _chapters,
      paragraphs: _paragraphs,
    );
    _itemPositionListener!.itemPositions.addListener(_changeListener);
    _controller.isBookLoaded.value = true;

    return true;
  }

  @override
  void jumpTo({
    required int index,
    double alignment = 0,
  }) =>
      _itemScrollController?.jumpTo(
        index: index,
        alignment: alignment,
      );

  @override
  Future<void>? scrollTo({
    required int index,
    Duration duration = const Duration(milliseconds: 250),
    double alignment = 0,
    Curve curve = Curves.linear,
  }) =>
      _itemScrollController?.scrollTo(
        index: index,
        duration: duration,
        alignment: alignment,
        curve: curve,
      );

  void _changeListener() {
    if (_paragraphs.isEmpty ||
        _itemPositionListener!.itemPositions.value.isEmpty) {
      return;
    }
    final position = _itemPositionListener!.itemPositions.value.first;
    final chapterIndex = _getChapterIndexBy(
      positionIndex: position.index,
      trailingEdge: position.itemTrailingEdge,
      leadingEdge: position.itemLeadingEdge,
    );
    final paragraphIndex = _getParagraphIndexBy(
      positionIndex: position.index,
      trailingEdge: position.itemTrailingEdge,
      leadingEdge: position.itemLeadingEdge,
    );
    _currentValue = EpubChapterViewValue(
      chapter: chapterIndex >= 0 ? _chapters[chapterIndex] : null,
      chapterNumber: chapterIndex + 1,
      paragraphNumber: paragraphIndex + 1,
      position: position,
    );
    _controller.currentValueListenable.value = _currentValue;
    widget.onChapterChanged?.call(_currentValue);
  }

  @override
  void gotoEpubCfi(
    String? epubCfi, {
    double alignment = 0,
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.linear,
  }) {
    _epubCfiReader?.epubCfi = epubCfi;
    final index = _epubCfiReader?.paragraphIndexByCfiFragment;

    if (index == null) {
      return;
    }

    _itemScrollController?.scrollTo(
      index: index,
      duration: duration,
      alignment: alignment,
      curve: curve,
    );
  }

  @override
  String? generateEpubCfi() => _epubCfiReader?.generateCfi(
        book: _controller._document,
        chapter: _currentValue?.chapter,
        paragraphIndex: _getAbsParagraphIndexBy(
          positionIndex: _currentValue?.position.index ?? 0,
          trailingEdge: _currentValue?.position.itemTrailingEdge,
          leadingEdge: _currentValue?.position.itemLeadingEdge,
        ),
      );

  void _onLinkPressed(String href) {
    if (href.contains('://')) {
      widget.onExternalLinkPressed?.call(href);
      return;
    }

    // Chapter01.xhtml#ph1_1 -> [ph1_1, Chapter01.xhtml] || [ph1_1]
    String? hrefIdRef;
    String? hrefFileName;

    if (href.contains('#')) {
      final dividedHref = href.split('#');
      if (dividedHref.length == 1) {
        hrefIdRef = href;
      } else {
        hrefFileName = dividedHref[0];
        hrefIdRef = dividedHref[1];
      }
    } else {
      hrefFileName = href;
    }

    if (hrefIdRef == null) {
      final chapter = _chapterByFileName(hrefFileName);
      if (chapter != null) {
        final cfi = _epubCfiReader?.generateCfiChapter(
          book: _controller._document,
          chapter: chapter,
          additional: ['/4/2'],
        );

        gotoEpubCfi(cfi);
      }
      return;
    } else {
      final paragraph = _paragraphByIdRef(hrefIdRef);
      final chapter =
          paragraph != null ? _chapters[paragraph.chapterIndex] : null;

      if (chapter != null && paragraph != null) {
        final paragraphIndex =
            _epubCfiReader?.getParagraphIndexByElement(paragraph.element);
        final cfi = _epubCfiReader?.generateCfi(
          book: _controller._document,
          chapter: chapter,
          paragraphIndex: paragraphIndex,
        );

        gotoEpubCfi(cfi);
      }

      return;
    }
  }

  Paragraph? _paragraphByIdRef(String idRef) =>
      _paragraphs.firstWhereOrNull((paragraph) {
        if (paragraph.element.id == idRef) {
          return true;
        }

        return paragraph.element.children.isNotEmpty &&
            paragraph.element.children[0].id == idRef;
      });

  EpubChapter? _chapterByFileName(String? fileName) =>
      _chapters.firstWhereOrNull((chapter) {
        if (fileName != null) {
          if (chapter.ContentFileName!.contains(fileName)) {
            return true;
          } else {
            return false;
          }
        }
        return false;
      });

  int _getChapterIndexBy({
    required int positionIndex,
    double? trailingEdge,
    double? leadingEdge,
  }) {
    final posIndex = _getAbsParagraphIndexBy(
      positionIndex: positionIndex,
      trailingEdge: trailingEdge,
      leadingEdge: leadingEdge,
    );
    final index = posIndex >= _chapterIndexes.last
        ? _chapterIndexes.length
        : _chapterIndexes.indexWhere((chapterIndex) {
            if (posIndex < chapterIndex) {
              return true;
            }
            return false;
          });

    return index - 1;
  }

  int _getParagraphIndexBy({
    required int positionIndex,
    double? trailingEdge,
    double? leadingEdge,
  }) {
    final posIndex = _getAbsParagraphIndexBy(
      positionIndex: positionIndex,
      trailingEdge: trailingEdge,
      leadingEdge: leadingEdge,
    );

    final index = _getChapterIndexBy(positionIndex: posIndex);

    if (index == -1) {
      return posIndex;
    }

    return posIndex - _chapterIndexes[index];
  }

  int _getAbsParagraphIndexBy({
    required int positionIndex,
    double? trailingEdge,
    double? leadingEdge,
  }) {
    int posIndex = positionIndex;
    if (trailingEdge != null &&
        leadingEdge != null &&
        trailingEdge < _minTrailingEdge &&
        leadingEdge < _minLeadingEdge) {
      posIndex += 1;
    }

    return posIndex;
  }

  static Widget _chapterDividerBuilder(EpubChapter chapter) => Container(
        height: 56,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0x24000000),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          chapter.Title ?? '',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  static Widget _chapterBuilder(
    BuildContext context,
    EpubViewBuilders builders,
    EpubBook document,
    List<EpubChapter> chapters,
    List<Paragraph> paragraphs,
    int index,
    int chapterIndex,
    int paragraphIndex,
    ExternalLinkPressed onExternalLinkPressed,
  ) {
    if (paragraphs.isEmpty) {
      return Container();
    }

    final defaultBuilder = builders as EpubViewBuilders<DefaultBuilderOptions>;
    final options = defaultBuilder.options;

    return Column(
      children: <Widget>[
        if (chapterIndex >= 0 && paragraphIndex == 0)
          builders.chapterDividerBuilder(chapters[chapterIndex]),
        Html(
          data: paragraphs[index].element.outerHtml,
          onLinkTap: (href, _, __) => onExternalLinkPressed(href!),
          style: {
            'html': Style().merge(Style.fromTextStyle(options.textStyle)),
          },
          // customRenders: {
          //   tagMatcher('img'):
          //       CustomRender.widget(widget: (context, buildChildren) {
          //     final url = context.tree.element!.attributes['src']!
          //         .replaceAll('../', '');
          //     return Image(
          //       image: MemoryImage(
          //         Uint8List.fromList(
          //           document.Content!.Images![url]!.Content!,
          //         ),
          //       ),
          //     );
          //   }),
          // },
        ),
      ],
    );
  }

  Widget _buildLoaded(BuildContext context) {
    return ScrollablePositionedList.builder(
      shrinkWrap: widget.shrinkWrap,
      initialScrollIndex: _epubCfiReader!.paragraphIndexByCfiFragment ?? 0,
      itemCount: _paragraphs.length,
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionListener,
      itemBuilder: (BuildContext context, int index) {
        return widget.builders.chapterBuilder(
          context,
          widget.builders,
          widget.controller._document!,
          _chapters,
          _paragraphs,
          index,
          _getChapterIndexBy(positionIndex: index),
          _getParagraphIndexBy(positionIndex: index),
          _onLinkPressed,
        );
      },
    );
  }

  static Widget _builder(
    BuildContext context,
    EpubViewBuilders builders,
    EpubViewLoadingState state,
    WidgetBuilder loadedBuilder,
    Exception? loadingError,
  ) {
    final Widget content = () {
      switch (state) {
        case EpubViewLoadingState.loading:
          return KeyedSubtree(
            key: const Key('epubx.root.loading'),
            child: builders.loaderBuilder?.call(context) ?? const SizedBox(),
          );
        case EpubViewLoadingState.error:
          return KeyedSubtree(
            key: const Key('epubx.root.error'),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: builders.errorBuilder?.call(context, loadingError!) ??
                  Center(child: Text(loadingError.toString())),
            ),
          );
        case EpubViewLoadingState.success:
          return KeyedSubtree(
            key: const Key('epubx.root.success'),
            child: loadedBuilder(context),
          );
      }
    }();

    final defaultBuilder = builders as EpubViewBuilders<DefaultBuilderOptions>;
    final options = defaultBuilder.options;

    return AnimatedSwitcher(
      duration: options.loaderSwitchDuration,
      transitionBuilder: options.transitionBuilder,
      child: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.builders.builder(
      context,
      widget.builders,
      _controller.loadingState.value,
      _buildLoaded,
      _loadingError,
    );
  }
}

class EpubDesktopPagedView extends StatefulWidget {
  const EpubDesktopPagedView({
    required this.controller,
    this.onExternalLinkPressed,
    this.onChapterChanged,
    this.onDocumentLoaded,
    this.onDocumentError,
    this.builders = const EpubViewBuilders<DefaultBuilderOptions>(
      options: DefaultBuilderOptions(),
    ),
    this.pagePadding = const EdgeInsets.fromLTRB(96, 62, 96, 54),
    this.pageColor,
    Key? key,
  }) : super(key: key);

  final EpubController controller;
  final ExternalLinkPressed? onExternalLinkPressed;
  final void Function(EpubChapterViewValue? value)? onChapterChanged;
  final void Function(EpubBook document)? onDocumentLoaded;
  final void Function(Exception? error)? onDocumentError;
  final EpubViewBuilders builders;
  final EdgeInsets pagePadding;
  final Color? pageColor;

  @override
  State<EpubDesktopPagedView> createState() => _EpubDesktopPagedViewState();
}

class _EpubDesktopPagedViewState extends State<EpubDesktopPagedView>
    implements _EpubViewHost {
  Exception? _loadingError;
  late PageController _pageController;
  List<EpubChapter> _chapters = [];
  List<Paragraph> _paragraphs = [];
  EpubCfiReader? _epubCfiReader;
  EpubChapterViewValue? _currentValue;
  final List<int> _chapterIndexes = <int>[];
  List<List<int>> _pages = <List<int>>[];
  int _currentPage = 0;
  int _targetParagraphIndex = 0;

  int get _spreadCount => (_pages.length / 2).ceil();

  EpubController get _controller => widget.controller;

  @override
  EpubChapterViewValue? get currentValue => _currentValue;

  @override
  Exception? get loadingError => _loadingError;

  @override
  set loadingError(Exception? error) => _loadingError = error;

  @override
  List<int> get chapterIndexes => _chapterIndexes;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _controller._attach(this);
    _controller.loadingState.addListener(_loadingStateListener);
  }

  @override
  void dispose() {
    _controller.loadingState.removeListener(_loadingStateListener);
    _controller._detach();
    _pageController.dispose();
    super.dispose();
  }

  void _loadingStateListener() {
    switch (_controller.loadingState.value) {
      case EpubViewLoadingState.loading:
        break;
      case EpubViewLoadingState.success:
        widget.onDocumentLoaded?.call(_controller._document!);
        break;
      case EpubViewLoadingState.error:
        widget.onDocumentError?.call(_loadingError);
        break;
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Future<bool> initDocument() async {
    if (_controller.isBookLoaded.value) {
      return true;
    }
    _chapters = parseChapters(_controller._document!);
    final ParseParagraphsResult parseParagraphsResult =
        parseParagraphs(_chapters, _controller._document!.Content);
    _paragraphs = parseParagraphsResult.flatParagraphs;
    _chapterIndexes.addAll(parseParagraphsResult.chapterIndexes);
    _epubCfiReader = EpubCfiReader.parser(
      cfiInput: _controller.epubCfi,
      chapters: _chapters,
      paragraphs: _paragraphs,
    );
    _targetParagraphIndex = _epubCfiReader?.paragraphIndexByCfiFragment ?? 0;
    _controller.isBookLoaded.value = true;
    return true;
  }

  @override
  void jumpTo({
    required int index,
    double alignment = 0,
  }) {
    _jumpToParagraph(index, animated: false);
  }

  @override
  Future<void>? scrollTo({
    required int index,
    Duration duration = const Duration(milliseconds: 250),
    double alignment = 0,
    Curve curve = Curves.linear,
  }) {
    _jumpToParagraph(index, duration: duration, curve: curve);
    return null;
  }

  @override
  void gotoEpubCfi(
    String? epubCfi, {
    double alignment = 0,
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.linear,
  }) {
    _epubCfiReader?.epubCfi = epubCfi;
    final int? index = _epubCfiReader?.paragraphIndexByCfiFragment;
    if (index != null) {
      _jumpToParagraph(index, duration: duration, curve: curve);
    }
  }

  @override
  String? generateEpubCfi() => _epubCfiReader?.generateCfi(
        book: _controller._document,
        chapter: _currentValue?.chapter,
        paragraphIndex: _currentValue?.position.index,
      );

  void _jumpToParagraph(
    int index, {
    bool animated = true,
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.linear,
  }) {
    _targetParagraphIndex = index.clamp(0, _paragraphs.length - 1);
    final int page = _pageForParagraph(_targetParagraphIndex);
    _goToPage(page, animated: animated, duration: duration, curve: curve);
  }

  void _goToPage(
    int page, {
    bool animated = true,
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.linear,
  }) {
    if (_pages.isEmpty) {
      return;
    }
    final int nextPage = page.clamp(0, _pages.length - 1);
    final int nextSpread = nextPage ~/ 2;
    if (!_pageController.hasClients) {
      _currentPage = nextSpread * 2;
      return;
    }
    if (!animated) {
      _pageController.jumpToPage(nextSpread);
    } else {
      _pageController.animateToPage(
        nextSpread,
        duration: duration,
        curve: curve,
      );
    }
    _updateCurrentSpread(nextSpread);
  }

  void _updateCurrentSpread(int spread) {
    if (_pages.isEmpty) {
      return;
    }
    _currentPage =
        (spread.clamp(0, _spreadCount - 1) * 2).clamp(0, _pages.length - 1);
    final int paragraphIndex = _pages[_currentPage].first;
    final int chapterIndex = _getChapterIndexBy(positionIndex: paragraphIndex);
    final int inChapterParagraphIndex =
        _getParagraphIndexBy(positionIndex: paragraphIndex);
    _currentValue = EpubChapterViewValue(
      chapter: chapterIndex >= 0 ? _chapters[chapterIndex] : null,
      chapterNumber: chapterIndex + 1,
      paragraphNumber: inChapterParagraphIndex + 1,
      position: ItemPosition(
        index: paragraphIndex,
        itemLeadingEdge: 0,
        itemTrailingEdge: 1,
      ),
    );
    _controller.currentValueListenable.value = _currentValue;
    widget.onChapterChanged?.call(_currentValue);
    if (mounted) {
      setState(() {});
    }
  }

  int _getChapterIndexBy({required int positionIndex}) {
    if (_chapterIndexes.isEmpty) {
      return -1;
    }
    final int index = positionIndex >= _chapterIndexes.last
        ? _chapterIndexes.length
        : _chapterIndexes.indexWhere((int chapterIndex) {
            return positionIndex < chapterIndex;
          });
    return index - 1;
  }

  int _getParagraphIndexBy({required int positionIndex}) {
    final int chapterIndex = _getChapterIndexBy(positionIndex: positionIndex);
    if (chapterIndex == -1) {
      return positionIndex;
    }
    return positionIndex - _chapterIndexes[chapterIndex];
  }

  int _pageForParagraph(int paragraphIndex) {
    if (_pages.isEmpty) {
      return 0;
    }
    final int page = _pages.indexWhere((List<int> indexes) {
      return indexes.first <= paragraphIndex && paragraphIndex <= indexes.last;
    });
    return page == -1 ? 0 : page;
  }

  List<List<int>> _paginate({
    required Size size,
    required TextStyle textStyle,
  }) {
    if (_paragraphs.isEmpty) {
      return <List<int>>[];
    }
    final double singlePageWidth =
        ((size.width - 28) / 2).clamp(280, double.infinity).toDouble();
    final double usableWidth = (singlePageWidth - widget.pagePadding.horizontal)
        .clamp(280, double.infinity)
        .toDouble();
    final double usableHeight = (size.height - widget.pagePadding.vertical - 24)
        .clamp(280, double.infinity)
        .toDouble();
    final List<List<int>> pages = <List<int>>[];
    List<int> current = <int>[];
    double currentHeight = 0;

    for (int i = 0; i < _paragraphs.length; i += 1) {
      final Paragraph paragraph = _paragraphs[i];
      final int chapterIndex = _getChapterIndexBy(positionIndex: i);
      final int paragraphIndexInChapter =
          _getParagraphIndexBy(positionIndex: i);
      final double paragraphHeight = _measureParagraphHeight(
        paragraph: paragraph,
        chapter: chapterIndex >= 0 ? _chapters[chapterIndex] : null,
        isChapterStart: chapterIndex >= 0 && paragraphIndexInChapter == 0,
        textStyle: textStyle,
        maxWidth: usableWidth,
      );
      if (current.isNotEmpty &&
          currentHeight + paragraphHeight > usableHeight) {
        pages.add(current);
        current = <int>[];
        currentHeight = 0;
      }
      current.add(i);
      currentHeight += paragraphHeight;
    }

    if (current.isNotEmpty) {
      pages.add(current);
    }
    return pages;
  }

  double _measureParagraphHeight({
    required Paragraph paragraph,
    required EpubChapter? chapter,
    required bool isChapterStart,
    required TextStyle textStyle,
    required double maxWidth,
  }) {
    final String tag = paragraph.element.localName ?? '';
    final String text = paragraph.element.text.trim();
    final bool isHeading = tag.startsWith('h');
    final bool isListItem = tag == 'li';
    final TextStyle measuredStyle = textStyle.copyWith(
      fontSize:
          isHeading ? (textStyle.fontSize ?? 18) * 1.28 : textStyle.fontSize,
      fontWeight: isHeading ? FontWeight.w700 : textStyle.fontWeight,
    );
    double height = 0;
    if (isChapterStart && chapter?.Title?.trim().isNotEmpty == true) {
      final TextPainter chapterPainter = TextPainter(
        text: TextSpan(
          text: chapter!.Title!.trim(),
          style: textStyle.copyWith(
            fontSize: (textStyle.fontSize ?? 18) * 1.36,
            fontWeight: FontWeight.w700,
            height: 1.35,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: maxWidth);
      height += chapterPainter.height + 26;
    }
    if (text.isNotEmpty) {
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: measuredStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: maxWidth);
      height += textPainter.height;
      height += isHeading
          ? 26
          : isListItem
              ? 16
              : 22;
    } else {
      height += 14;
    }
    final double imageHeight =
        paragraph.element.getElementsByTagName('img').length * 320;
    return height + imageHeight;
  }

  void _onLinkPressed(String href) {
    if (href.contains('://')) {
      widget.onExternalLinkPressed?.call(href);
    }
  }

  Widget _buildLoaded(BuildContext context) {
    final EpubViewBuilders<DefaultBuilderOptions> builders =
        widget.builders as EpubViewBuilders<DefaultBuilderOptions>;
    final DefaultBuilderOptions options = builders.options;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Size size = constraints.biggest;
        final List<List<int>> nextPages = _paginate(
          size: size,
          textStyle: options.textStyle,
        );
        final bool pagePlanChanged = _pages.length != nextPages.length ||
            (_pages.isNotEmpty &&
                nextPages.isNotEmpty &&
                _pages.first.length != nextPages.first.length);
        if (pagePlanChanged) {
          _pages = nextPages;
          final int targetPage = _pageForParagraph(_targetParagraphIndex);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _pageController.hasClients) {
              final int targetSpread = targetPage ~/ 2;
              _pageController.jumpToPage(targetSpread);
              _updateCurrentSpread(targetSpread);
            }
          });
        }
        if (_pages.isEmpty) {
          return const SizedBox();
        }
        return Stack(
          children: <Widget>[
            ScrollConfiguration(
              behavior: const _DesktopPageScrollBehavior(),
              child: PageView.builder(
                controller: _pageController,
                itemCount: _spreadCount,
                onPageChanged: _updateCurrentSpread,
                itemBuilder: (BuildContext context, int spreadIndex) {
                  final int leftPage = spreadIndex * 2;
                  final int rightPage = leftPage + 1;
                  return _DesktopReaderSpread(
                    document: widget.controller._document!,
                    chapters: _chapters,
                    paragraphs: _paragraphs,
                    leftParagraphIndexes: _pages[leftPage],
                    rightParagraphIndexes:
                        rightPage < _pages.length ? _pages[rightPage] : null,
                    chapterIndexes: _chapterIndexes,
                    builders: widget.builders,
                    pagePadding: widget.pagePadding,
                    pageColor: widget.pageColor,
                    onExternalLinkPressed: _onLinkPressed,
                  );
                },
              ),
            ),
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: _PageTurnButton(
                icon: Icons.chevron_left_rounded,
                tooltip: '上一页',
                enabled: _currentPage > 0,
                onPressed: () => _goToPage(_currentPage - 2),
              ),
            ),
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: _PageTurnButton(
                icon: Icons.chevron_right_rounded,
                tooltip: '下一页',
                enabled: _currentPage + 2 < _pages.length,
                onPressed: () => _goToPage(_currentPage + 2),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.builders.builder(
      context,
      widget.builders,
      _controller.loadingState.value,
      _buildLoaded,
      _loadingError,
    );
  }
}

class _DesktopReaderSpread extends StatelessWidget {
  const _DesktopReaderSpread({
    required this.document,
    required this.chapters,
    required this.paragraphs,
    required this.leftParagraphIndexes,
    required this.rightParagraphIndexes,
    required this.chapterIndexes,
    required this.builders,
    required this.pagePadding,
    required this.pageColor,
    required this.onExternalLinkPressed,
  });

  final EpubBook document;
  final List<EpubChapter> chapters;
  final List<Paragraph> paragraphs;
  final List<int> leftParagraphIndexes;
  final List<int>? rightParagraphIndexes;
  final List<int> chapterIndexes;
  final EpubViewBuilders builders;
  final EdgeInsets pagePadding;
  final Color? pageColor;
  final ExternalLinkPressed onExternalLinkPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: <Widget>[
        Expanded(
          child: _DesktopReaderPage(
            document: document,
            chapters: chapters,
            paragraphs: paragraphs,
            paragraphIndexes: leftParagraphIndexes,
            chapterIndexes: chapterIndexes,
            builders: builders,
            pagePadding: pagePadding,
            pageColor: pageColor,
            onExternalLinkPressed: onExternalLinkPressed,
          ),
        ),
        SizedBox(
          width: 28,
          child: Center(
            child: Container(
              width: 1,
              height: double.infinity,
              color: colorScheme.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
        ),
        Expanded(
          child: rightParagraphIndexes == null
              ? const SizedBox.expand()
              : _DesktopReaderPage(
                  document: document,
                  chapters: chapters,
                  paragraphs: paragraphs,
                  paragraphIndexes: rightParagraphIndexes!,
                  chapterIndexes: chapterIndexes,
                  builders: builders,
                  pagePadding: pagePadding,
                  pageColor: pageColor,
                  onExternalLinkPressed: onExternalLinkPressed,
                ),
        ),
      ],
    );
  }
}

class _DesktopReaderPage extends StatelessWidget {
  const _DesktopReaderPage({
    required this.document,
    required this.chapters,
    required this.paragraphs,
    required this.paragraphIndexes,
    required this.chapterIndexes,
    required this.builders,
    required this.pagePadding,
    required this.pageColor,
    required this.onExternalLinkPressed,
  });

  final EpubBook document;
  final List<EpubChapter> chapters;
  final List<Paragraph> paragraphs;
  final List<int> paragraphIndexes;
  final List<int> chapterIndexes;
  final EpubViewBuilders builders;
  final EdgeInsets pagePadding;
  final Color? pageColor;
  final ExternalLinkPressed onExternalLinkPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: pagePadding,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return ClipRect(
            child: Stack(
              children: <Widget>[
                OverflowBox(
                  alignment: Alignment.topCenter,
                  minHeight: 0,
                  maxHeight: double.infinity,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: paragraphIndexes.map((int paragraphIndex) {
                        final int chapterIndex =
                            _chapterIndexForParagraph(paragraphIndex);
                        final int paragraphIndexInChapter =
                            _paragraphIndexInChapter(
                                paragraphIndex, chapterIndex);
                        return _DesktopParagraphText(
                          paragraph: paragraphs[paragraphIndex],
                          chapter:
                              chapterIndex >= 0 ? chapters[chapterIndex] : null,
                          isChapterStart:
                              chapterIndex >= 0 && paragraphIndexInChapter == 0,
                          textStyle: (builders
                                  as EpubViewBuilders<DefaultBuilderOptions>)
                              .options
                              .textStyle,
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  int _chapterIndexForParagraph(int paragraphIndex) {
    if (chapterIndexes.isEmpty) {
      return -1;
    }
    final int index = paragraphIndex >= chapterIndexes.last
        ? chapterIndexes.length
        : chapterIndexes.indexWhere((int chapterIndex) {
            return paragraphIndex < chapterIndex;
          });
    return index - 1;
  }

  int _paragraphIndexInChapter(int paragraphIndex, int chapterIndex) {
    if (chapterIndex == -1) {
      return paragraphIndex;
    }
    return paragraphIndex - chapterIndexes[chapterIndex];
  }
}

class _DesktopParagraphText extends StatelessWidget {
  const _DesktopParagraphText({
    required this.paragraph,
    required this.chapter,
    required this.isChapterStart,
    required this.textStyle,
  });

  final Paragraph paragraph;
  final EpubChapter? chapter;
  final bool isChapterStart;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    final String tag = paragraph.element.localName ?? '';
    final bool isHeading = tag.startsWith('h');
    final bool isListItem = tag == 'li';
    final String text = paragraph.element.text.trim();
    final List<Widget> children = <Widget>[];
    if (isChapterStart && chapter?.Title?.trim().isNotEmpty == true) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 26),
          child: Text(
            chapter!.Title!.trim(),
            style: textStyle.copyWith(
              fontSize: (textStyle.fontSize ?? 18) * 1.36,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ),
      );
    }
    if (text.isNotEmpty) {
      children.add(
        Padding(
          padding: EdgeInsets.only(
            bottom: isHeading
                ? 26
                : isListItem
                    ? 16
                    : 22,
          ),
          child: Text(
            text,
            softWrap: true,
            style: textStyle.copyWith(
              fontSize: isHeading
                  ? (textStyle.fontSize ?? 18) * 1.22
                  : textStyle.fontSize,
              fontWeight: isHeading ? FontWeight.w700 : textStyle.fontWeight,
              height: textStyle.height,
            ),
          ),
        ),
      );
    }
    if (children.isEmpty) {
      return const SizedBox(height: 14);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

class _DesktopPageScrollBehavior extends MaterialScrollBehavior {
  const _DesktopPageScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => <PointerDeviceKind>{
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) =>
      child;
}

class _PageTurnButton extends StatelessWidget {
  const _PageTurnButton({
    required this.icon,
    required this.tooltip,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: enabled ? 1 : 0.28,
        child: IconButton.filledTonal(
          tooltip: tooltip,
          onPressed: enabled ? onPressed : null,
          icon: Icon(icon, size: 28),
        ),
      ),
    );
  }
}
