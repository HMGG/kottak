import 'package:flutter/material.dart';
import 'package:kottak/src/data/models.dart';
import 'package:kottak/src/shared/confirm_dialog.dart';

class TagGroupForm extends StatefulWidget {
  TagGroupForm(this.tagGroup, {Key? key, this.newForm = false})
      : super(key: key) {
    nameControl = TextEditingController.fromValue(
      TextEditingValue(text: tagGroup.name),
    );
  }

  final bool newForm;

  final TagGroup tagGroup;

  late final TextEditingController nameControl;

  @override
  State<TagGroupForm> createState() => _TagGroupFormState();
}

class _TagGroupFormState extends State<TagGroupForm> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.newForm
          ? const Text('Új csoport')
          : Text(widget.tagGroup.name),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              controller: widget.nameControl,
              decoration: const InputDecoration(labelText: 'Név'),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!widget.newForm)
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => ConfirmDialog(
                        'Törlés',
                        '${widget.tagGroup.name} törlésének megerősítése',
                      ),
                    ).then((value) {
                      if (value == true) {
                        Navigator.pop(context, 'delete');
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
                        Navigator.pop(
                          context,
                          widget.tagGroup..name = widget.nameControl.text,
                        );
                      },
                      child: const Text('Mentés'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
