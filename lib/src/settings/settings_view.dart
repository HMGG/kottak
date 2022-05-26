import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kottak/main.dart';
import 'package:kottak/objectbox.g.dart';
import 'package:kottak/src/data/models.dart';
import 'package:kottak/src/settings/persistance_dialog.dart';
import 'package:path_provider/path_provider.dart';

import 'settings_controller.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatefulWidget {
  const SettingsView({Key? key, required this.controller}) : super(key: key);
  
  static const routeName = '/settings';

  final SettingsController controller;

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  String? importFileName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        // Glue the SettingsController to the theme selection DropdownButton.
        //
        // When a user selects a theme from the dropdown list, the
        // SettingsController is updated, which rebuilds the MaterialApp.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<ThemeMode>(
              decoration: const InputDecoration(labelText: 'Téma'),
              isExpanded: true,
              // Read the selected themeMode from the controller
              value: widget.controller.themeMode,
              // Call the updateThemeMode method any time the user selects a theme.
              onChanged: widget.controller.updateThemeMode,
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('Rendszer'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('Világos'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Sötét'),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextButton(
                child: const Text('Import/export'),
                onPressed: () => {
                  showDialog(
                      context: context,
                      builder: (context) => PersistanceDialog())
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

Future<void> importAsset() async {
  var data = jsonDecode(await rootBundle.loadString('assets/kottak.json'));

  List<dynamic> sheets = data['sheets'];

  var groupbox = objectbox.store.box<TagGroup>();
  groupbox.removeAll();
  groupbox.putMany([
    TagGroup(name: 'Közösség', index: 1),
    TagGroup(name: 'Téma', index: 2),
    TagGroup(name: 'Tempó', index: 3),
    TagGroup(name: 'Stílus', index: 4),
    TagGroup(name: 'Egyéb', index: 99),
  ]);

  var tagbox = objectbox.store.box<Tag>();
  tagbox.removeAll();
  for (var e in data['tags']) {
    Tag tag = Tag(name: e['name']);
    switch (e['name']) {
      case 'Bpifi':
      case 'Csermely':
      case 'Diákkör':
      case 'Gaude':
      case 'Lorx':
      case 'Mekdsz':
      case 'Mécs':
      case 'Sófár':
        {
          tag.tagGroup.target = groupbox
              .query(TagGroup_.name.equals('Közösség'))
              .build()
              .findFirst();
          break;
        }
      case 'Bizalom':
      case 'Bűnbánat':
      case 'Dicséret':
      case 'Eukarisztia':
      case 'Hála':
      case 'Karácsonyi':
      case 'Kérés/hívás':
      case 'Megváltás':
        {
          tag.tagGroup.target =
              groupbox.query(TagGroup_.name.equals('Téma')).build().findFirst();
          break;
        }
      case 'Gyors':
      case 'Lassú':
      case 'Közepes':
        {
          tag.tagGroup.target = groupbox
              .query(TagGroup_.name.equals('Tempó'))
              .build()
              .findFirst();
          break;
        }
      case 'Asszim':
      case 'Cigány':
      case 'Jazzy':
      case 'Népi':
      case 'Régi':
      case 'Zsidó':
      case 'Taizei':
        {
          tag.tagGroup.target = groupbox
              .query(TagGroup_.name.equals('Stílus'))
              .build()
              .findFirst();
          break;
        }
      case 'Kedvenc':
      case 'Ismeretlen':
        break;
      default:
        tag.tagGroup.target =
            groupbox.query(TagGroup_.name.equals('Egyéb')).build().findFirst();
    }
    tagbox.put(tag);
  }

  // print('tags done');

  var songs = sheets
      .map((e) => Song(
            id: e['id'],
            title: e['name'],
            lyrics: e['lyrics'],
            originalTitle: e['originaltitle'],
            sheets: [e['path']],
          ))
      .toList();

  for (var page in data['extrapages']) {
    songs
        .firstWhere((element) => element.id == page['sheetid'])
        .sheets
        .add(page['uri']);
  }

  var songbox = objectbox.store.box<Song>()
    ..removeAll()
    ..putMany(songs.toList());

  // print('songs done');

  for (var join in data['joins']) {
    if (join['tag'] == 'Ismeretlen') continue;
    var tag = tagbox.query(Tag_.name.equals(join['tag'])).build().findFirst();
    var song = songbox.get(join['sheetid']);
    if (song != null && join['tag'] == 'Kedvenc') {
      song.favorite = true;
      songbox.put(song);
    } else {
      tag?.songs.add(song!);
      tagbox.put(tag!);
    }
  }
  // print('done');
}
