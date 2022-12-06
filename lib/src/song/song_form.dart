import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:kottak/src/data/models.dart';
import 'package:kottak/src/shared/confirm_dialog.dart';
import 'package:kottak/src/shared/tag_groups.dart';
import 'package:reorderables/reorderables.dart';

class SongForm extends StatefulWidget {
  SongForm({
    Key? key,
    required this.song,
    required this.onSave,
    this.onDelete,
  }) : super(key: key) {
    titleControl = TextEditingController.fromValue(
      TextEditingValue(text: song.title),
    );
    lyricsControl = TextEditingController.fromValue(
      TextEditingValue(text: song.lyrics),
    );
    authorControl = TextEditingController.fromValue(
      TextEditingValue(text: song.author),
    );
    originalTitleControl = TextEditingController.fromValue(
      TextEditingValue(text: song.originalTitle),
    );
    translatorControl = TextEditingController.fromValue(
      TextEditingValue(text: song.translator),
    );
  }

  final void Function(Song) onSave;

  final void Function(int)? onDelete;

  final Song song;

  late final TextEditingController titleControl;
  late final TextEditingController lyricsControl;
  late final TextEditingController authorControl;
  late final TextEditingController originalTitleControl;
  late final TextEditingController translatorControl;

  @override
  State<SongForm> createState() => _SongFormState();
}

class _SongFormState extends State<SongForm> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: widget.titleControl,
                        decoration: const InputDecoration(labelText: 'Cím'),
                      ),
                      TextFormField(
                        controller: widget.lyricsControl,
                        decoration: const InputDecoration(labelText: 'Szöveg'),
                        maxLines: null,
                      ),
                      TextFormField(
                        controller: widget.authorControl,
                        decoration: const InputDecoration(labelText: 'Szerző'),
                      ),
                      TextFormField(
                        controller: widget.originalTitleControl,
                        decoration:
                            const InputDecoration(labelText: 'Eredeti cím'),
                      ),
                      TextFormField(
                        controller: widget.translatorControl,
                        decoration: const InputDecoration(labelText: 'Fordító'),
                      ),
                    ],
                  ),
                ),
                CheckboxListTile(
                  title: const Text('Kedvenc'),
                  value: widget.song.favorite,
                  onChanged: (value) {
                    setState(() {
                      widget.song.favorite = value!;
                    });
                  },
                ),
                TagGroups(widget.song.tags),
                ReorderableWrap(
                  onReorder: (oldIndex, newIndex) => setState(() => widget
                      .song.sheets
                      .insert(newIndex, widget.song.sheets.removeAt(oldIndex))),
                  alignment: WrapAlignment.spaceEvenly,
                  children: widget.song.sheets
                      .map(
                        (sheet) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: SizedBox.square(
                                      dimension: 180,
                                      child: Image.file(File(sheet)),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 180,
                                    child: Text(
                                      sheet.split('/').last,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return ConfirmDialog(
                                        'Törlés',
                                        '${sheet.split('/').last} kotta törlésének megerősítése',
                                      );
                                    },
                                    barrierDismissible: true,
                                  ).then((value) {
                                    if (value) {
                                      setState(() {
                                        widget.song.sheets.remove(sheet);
                                      });
                                    }
                                  });
                                },
                                icon: CircleAvatar(
                                  backgroundColor:
                                      Colors.black.withOpacity(0.25),
                                  child: Icon(
                                    Icons.delete,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  footer: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: SizedBox.square(
                            dimension: 180,
                            child: OutlinedButton(
                              child: const Icon(Icons.add),
                              onPressed: () {
                                FilePicker.platform
                                    .pickFiles(
                                  type: FileType.image,
                                  allowMultiple: true,
                                )
                                    .then((FilePickerResult? result) {
                                  if (result != null) {
                                    setState(() {
                                      widget.song.sheets.addAll(
                                          result.files.map((e) => e.path!));
                                    });
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 180,
                          child: Text(
                            "Új oldal",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (widget.onDelete != null)
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => ConfirmDialog(
                      'Törlés',
                      '${widget.song.title} törlésének megerősítése',
                    ),
                  ).then((value) {
                    if (value == true) {
                      widget.onDelete!(widget.song.id);
                      Navigator.pop(context);
                    }
                  });
                },
                child: const Text('Törlés'),
              ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      widget.song.title = widget.titleControl.value.text.trim();
                      widget.song.lyrics = widget.lyricsControl.value.text.trim();
                      widget.song.author = widget.authorControl.value.text.trim();
                      widget.song.originalTitle =
                          widget.originalTitleControl.value.text.trim();
                      widget.song.translator =
                          widget.translatorControl.value.text.trim();
                      widget.onSave(widget.song);
                      Navigator.pop(context);
                    },
                    child: const Text('Mentés'),
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }
}
