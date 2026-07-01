import 'dart:io';

import 'package:epubx/epubx.dart' as epub;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_text/assembly_pack/j_book/book_helper.dart';
import 'package:flutter_text/assembly_pack/j_book/book_view.dart';
import 'package:flutter_text/global/global.dart';
import 'package:get/get.dart';
import 'package:self_utils/utils/array_helper.dart';
import 'package:self_utils/utils/datetime_utils.dart';
import 'package:self_utils/utils/navigator.dart';
import 'package:self_utils/utils/screen.dart';
import 'package:self_utils/widget/api_call_back.dart';
import 'package:self_utils/widget/modal_utils.dart';
import 'package:flutter_text/assembly_pack/management/utils/navigator.dart';

import 'book_cache.dart';

class BookShelfWithId {
  int? id;
  epub.EpubBook? epubBook;
}

class BookShelfController extends GetxController {
  final List<BookModel> books = <BookModel>[];

  @override
  void onInit() {
    super.onInit();
    loadBooks();
  }

  Future<void> loadBooks() async {
    final List<BookModel> getCache =
        await loadingCallback(() => BookCache.getAllCache());
    getCache.sort((BookModel a, BookModel b) =>
        (b.updateTime ?? 0) - (a.updateTime ?? 0));
    books
      ..clear()
      ..addAll(getCache);
    update();
  }

  Future<void> selectBooks() async {
    final FilePickerResult? result = await loadingCallback(() =>
        FilePicker.platform.pickFiles(
            allowMultiple: true,
            type: FileType.custom,
            allowedExtensions: <String>['epub']));

    if (result != null) {
      final List<File> files = result.paths
          .whereType<String>()
          .map((String path) => File(path))
          .toList();
      final List<File> locateFile = await BookHelper.setAppLocateFile(files);
      final List<BookModel> newBooks = <BookModel>[];
      for (int i = 0; i < locateFile.length; i++) {
        final File? file = ArrayHelper.get(locateFile, i);
        if (file == null) {
          continue;
        }
        final epub.EpubBook epubBook =
            await epub.EpubReader.readBook(file.readAsBytes());
        final String image = await BookHelper.getCoverImageWithFile(
            epubBook.Content?.Images?.values.first.Content);
        final BookModel model = BookModel()
          ..id = epubBook.hashCode
          ..coverImage = image
          ..title = epubBook.Title
          ..updateTime = DateTimeHelper.getLocalTimeStamp()
          ..bookPath = file.path
          ..index = 0;
        BookCache.setCache(model);
        newBooks.add(model);
      }
      books
        ..addAll(newBooks)
        ..sort((BookModel a, BookModel b) =>
            (b.updateTime ?? 0) - (a.updateTime ?? 0));
      update();
    }
  }

  Future<void> openBook(BuildContext context, BookModel book) async {
    final int? val = await WindowsNavigator().pushWidget<int>(
      context,
      BookView(
        book: book,
      ),
      title: book.title,
    );
    if (val != null) {
      book.index = val;
      book.updateTime = DateTimeHelper.getLocalTimeStamp();
      await BookCache.updateIndex(id: book.id, index: val);
      books.sort((BookModel a, BookModel b) =>
          (b.updateTime ?? 0) - (a.updateTime ?? 0));
      update();
    }
  }

  Future<void> deleteBook(BookModel book) async {
    if (book.id == null) {
      return;
    }
    await BookCache.deleteCache(book.id!);
    books.removeWhere((BookModel element) => element.id == book.id);
    update();
  }
}

class BookShelf extends StatelessWidget {
  const BookShelf({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookShelfController>(
      init: BookShelfController(),
      builder: (BookShelfController controller) {
        return Scaffold(
          appBar: GlobalStore.isMobile
              ? AppBar(
                  title: const Text('图书馆'),
                  actions: <Widget>[
                    IconButton(
                      tooltip: '添加 EPUB',
                      onPressed: controller.selectBooks,
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                )
              : null,
          body: _BookShelfContent(controller: controller),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: controller.selectBooks,
            icon: const Icon(Icons.add_rounded),
            label: const Text('添加 EPUB'),
          ),
        );
      },
    );
  }
}

class _BookShelfContent extends StatelessWidget {
  final BookShelfController controller;

  const _BookShelfContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    final BookModel? recent =
        controller.books.isEmpty ? null : controller.books.first;
    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 16),
            child: _LibraryHeader(
              count: controller.books.length,
              recent: recent,
              onAdd: controller.selectBooks,
            ),
          ),
        ),
        if (controller.books.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _LibraryEmptyState(onAdd: controller.selectBooks),
          )
        else
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 110),
              child: _ShelfWall(
                books: controller.books,
                onOpen: (BookModel book) => controller.openBook(context, book),
                onDelete: (BookModel book) {
                  BookTip.showModel(
                    context,
                    onFunc: () => controller.deleteBook(book),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _LibraryHeader extends StatelessWidget {
  final int count;
  final BookModel? recent;
  final VoidCallback onAdd;

  const _LibraryHeader({
    required this.count,
    required this.recent,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '图书馆',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    count == 0 ? '导入 EPUB 后开始阅读' : '$count 本藏书，最近阅读优先排列',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('添加 EPUB'),
            ),
          ],
        ),
        const SizedBox(height: 22),
        _RecentBookPanel(recent: recent),
      ],
    );
  }
}

class _RecentBookPanel extends StatelessWidget {
  final BookModel? recent;

  const _RecentBookPanel({required this.recent});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.44),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.menu_book_rounded,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    recent?.title ?? '还没有最近阅读',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recent == null
                        ? '添加一本书后，这里会显示你最近打开的内容'
                        : '阅读位置 ${recent?.index ?? 0} · ${_formatUpdateTime(recent?.updateTime)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryEmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _LibraryEmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.local_library_outlined,
              size: 58,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              '书架还是空的',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '导入 EPUB 文件后，可以在这里继续阅读和管理。',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('添加 EPUB'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShelfWall extends StatelessWidget {
  final List<BookModel> books;
  final ValueChanged<BookModel> onOpen;
  final ValueChanged<BookModel> onDelete;

  const _ShelfWall({
    required this.books,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int perShelf = (constraints.maxWidth / 142).floor().clamp(2, 6);
        final List<List<BookModel>> shelves = <List<BookModel>>[];
        for (int i = 0; i < books.length; i += perShelf) {
          shelves.add(
            books.sublist(
              i,
              (i + perShelf).clamp(0, books.length),
            ),
          );
        }
        return Column(
          children: shelves
              .map(
                (List<BookModel> shelfBooks) => Padding(
                  padding: const EdgeInsets.only(bottom: 22),
                  child: _ShelfRow(
                    books: shelfBooks,
                    onOpen: onOpen,
                    onDelete: onDelete,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _ShelfRow extends StatelessWidget {
  final List<BookModel> books;
  final ValueChanged<BookModel> onOpen;
  final ValueChanged<BookModel> onDelete;

  const _ShelfRow({
    required this.books,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.36),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _ShelfBoard(),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.start,
                children: books
                    .map(
                      (BookModel book) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _ShelfBook(
                          book: book,
                          onTap: () => onOpen(book),
                          onDelete: () => onDelete(book),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShelfBoard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        Container(
          height: 14,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(8),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShelfBook extends StatefulWidget {
  final BookModel book;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ShelfBook({
    required this.book,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<_ShelfBook> createState() => _ShelfBookState();
}

class _ShelfBookState extends State<_ShelfBook> {
  bool _isHovering = false;

  void _setHovering(bool value) {
    if (_isHovering == value) {
      return;
    }
    setState(() {
      _isHovering = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 122,
      height: 192,
      child: MouseRegion(
        onEnter: (_) => _setHovering(true),
        onExit: (_) => _setHovering(false),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: widget.onTap,
            onLongPress: widget.onDelete,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    width: 92,
                    height: 124,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.bottomCenter,
                      children: <Widget>[
                        AnimatedSlide(
                          duration: const Duration(milliseconds: 210),
                          curve: Curves.easeOutCubic,
                          offset:
                              _isHovering ? Offset.zero : const Offset(0, 0.03),
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 210),
                            curve: Curves.easeOutCubic,
                            scale: _isHovering ? 1.03 : 1,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 210),
                              curve: Curves.easeOutCubic,
                              width: 76,
                              height: 112,
                              decoration: BoxDecoration(
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: _isHovering ? 0.16 : 0.10,
                                    ),
                                    blurRadius: _isHovering ? 14 : 8,
                                    offset: Offset(0, _isHovering ? 7 : 4),
                                  ),
                                ],
                              ),
                              child: _BookCover(
                                path: widget.book.coverImage,
                                width: 76,
                                height: 112,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 0,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 140),
                            opacity: _isHovering ? 1 : 0,
                            child: IgnorePointer(
                              ignoring: !_isHovering,
                              child: Tooltip(
                                message: '删除',
                                child: InkResponse(
                                  radius: 16,
                                  onTap: widget.onDelete,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: colorScheme.surface
                                          .withValues(alpha: 0.92),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: colorScheme.outlineVariant
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
                                    child: const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Icon(
                                        Icons.close_rounded,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 31,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 160),
                        opacity: _isHovering ? 1 : 0.74,
                        child: Text(
                          widget.book.title ?? '未命名书籍',
                          maxLines: _isHovering ? 2 : 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: _isHovering ? 13 : 12,
                            fontWeight: FontWeight.w700,
                            height: 1.18,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 17,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 160),
                      opacity: _isHovering ? 1 : 0,
                      child: _BookMetaChip(
                        icon: Icons.bookmark_border_rounded,
                        text: '位置 ${widget.book.index ?? 0}',
                      ),
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

class _BookCover extends StatelessWidget {
  final String? path;
  final double width;
  final double height;

  const _BookCover({
    required this.path,
    this.width = 58,
    this.height = 82,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool hasCover = path != null;
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: width,
        height: height,
        child: hasCover
            ? Image.file(
                File(path!),
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object error,
                    StackTrace? stackTrace) {
                  return ColoredBox(
                    color: colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.menu_book_outlined),
                  );
                },
              )
            : ColoredBox(
                color: _fallbackBookColor(colorScheme, path),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 9,
                        color: colorScheme.scrim.withValues(alpha: 0.10),
                      ),
                    ),
                    Center(
                      child: Icon(
                        Icons.menu_book_rounded,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

Color _fallbackBookColor(ColorScheme colorScheme, String? seed) {
  final int index = (seed ?? '').hashCode.abs() % 4;
  final List<Color> colors = <Color>[
    colorScheme.primaryContainer,
    colorScheme.secondaryContainer,
    colorScheme.tertiaryContainer,
    colorScheme.surfaceContainerHighest,
  ];
  return colors[index].withValues(alpha: 0.92);
}

class _BookMetaChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BookMetaChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          icon,
          size: 14,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

String _formatUpdateTime(int? timestamp) {
  if (timestamp == null || timestamp == 0) {
    return '未阅读';
  }
  final DateTime time = DateTime.fromMillisecondsSinceEpoch(timestamp);
  final DateTime now = DateTime.now();
  if (time.year == now.year && time.month == now.month && time.day == now.day) {
    return '今天 ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
  return '${time.year}.${time.month.toString().padLeft(2, '0')}.${time.day.toString().padLeft(2, '0')}';
}

class BookTip {
  static Future<void> showModel(BuildContext context, {void onFunc()?}) async {
    await ModalUtils.showModal(
      context,
      modalBackgroundColor: const Color(0x00999999),
      dynamicBottom: Container(
        alignment: Alignment.center,
        child: Container(
          width: screenUtil.adaptive(820),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: const Color(0xffffffff),
              borderRadius: BorderRadius.circular(screenUtil.adaptive(30))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                  top: screenUtil.adaptive(60),
                ),
                alignment: Alignment.center,
                child: Text(
                  '提示',
                  style: TextStyle(
                      color: const Color(0xff404040),
                      fontSize: screenUtil.getAutoSp(45)),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(
                  top: screenUtil.adaptive(80),
                  bottom: screenUtil.adaptive(90),
                  left: screenUtil.adaptive(73),
                ),
                child: Text(
                  '是否删除这本书？',
                  style: TextStyle(
                    fontSize: screenUtil.getAutoSp(43),
                    color: const Color(0xff426ba5),
                  ),
                ),
              ),
              Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(
                    bottom: screenUtil.adaptive(30),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        child: InkWell(
                          onTap: () {
                            NavigatorUtils.pop(context);
                          },
                          borderRadius:
                              BorderRadius.circular(screenUtil.adaptive(20)),
                          child: Container(
                            width: screenUtil.adaptive(360),
                            height: screenUtil.adaptive(110),
                            decoration: BoxDecoration(
                              color: const Color(0xb3eeeeee),
                              borderRadius: BorderRadius.circular(
                                  screenUtil.adaptive(20)),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '取消',
                              style: TextStyle(
                                color: const Color(0xff878787),
                                fontSize: screenUtil.getAutoSp(43),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        child: InkWell(
                          onTap: () {
                            NavigatorUtils.pop(context);
                            onFunc?.call();
                          },
                          borderRadius:
                              BorderRadius.circular(screenUtil.adaptive(20)),
                          child: Container(
                            width: screenUtil.adaptive(360),
                            height: screenUtil.adaptive(110),
                            decoration: BoxDecoration(
                              color: const Color(0xff577fba),
                              borderRadius: BorderRadius.circular(
                                  screenUtil.adaptive(20)),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '确定',
                              style: TextStyle(
                                color: const Color(0xffffffff),
                                fontSize: screenUtil.getAutoSp(43),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
