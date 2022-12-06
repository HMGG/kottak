import 'package:flutter/material.dart';
import 'package:kottak/src/data/models.dart';
import 'package:kottak/src/shared/confirm_dialog.dart';

class TagForm extends StatefulWidget {
  TagForm(this.tag, {Key? key, this.newForm = false}) : super(key: key) {
    nameControl = TextEditingController.fromValue(
      TextEditingValue(text: tag.name),
    );
  }

  final bool newForm;

  final Tag tag;

  late final TextEditingController nameControl;

  @override
  State<TagForm> createState() => _TagFormState();
}

class _TagFormState extends State<TagForm> {
  late int? groupId;

  @override
  void initState() {
    groupId = widget.tag.tagGroup.target?.id;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.tag.name),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              controller: widget.nameControl,
              decoration: const InputDecoration(labelText: 'Név'),
            ),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Csoport'),
              isExpanded: true,
              value: groupId,
              items: TagGroup.getAll()
                  .map(
                    (tagGroup) => DropdownMenuItem(
                      value: tagGroup.id,
                      child: Text(tagGroup.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => groupId = value!);
              },
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
                        '${widget.tag.name} törlésének megerősítése',
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
                      onPressed: () => Navigator.pop(
                        context,
                        widget.tag
                          ..name = widget.nameControl.text
                          ..tagGroup.targetId = groupId,
                      ),
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
