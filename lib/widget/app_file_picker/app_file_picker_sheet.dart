import 'package:flutter/material.dart';

import 'app_file_picker_models.dart';

Future<AppPickerSource?> showAppFilePickerSourceSheet(
  BuildContext context, {
  bool allowCamera = true,
  bool allowGallery = true,
  bool allowFileSystem = true,
}) {
  return showModalBottomSheet<AppPickerSource>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (allowCamera)
                _SourceTile(
                  icon: Icons.photo_camera_outlined,
                  title: '拍照',
                  onTap: () =>
                      Navigator.of(context).pop(AppPickerSource.camera),
                ),
              if (allowGallery)
                _SourceTile(
                  icon: Icons.photo_library_outlined,
                  title: '从相册选择',
                  onTap: () =>
                      Navigator.of(context).pop(AppPickerSource.gallery),
                ),
              if (allowFileSystem)
                _SourceTile(
                  icon: Icons.folder_open_rounded,
                  title: '从文件中选择',
                  onTap: () =>
                      Navigator.of(context).pop(AppPickerSource.fileSystem),
                ),
            ],
          ),
        ),
      );
    },
  );
}

class _SourceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SourceTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}
