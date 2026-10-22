import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/domain/tokenizer_entities.dart';
import '../domain/model_repository.dart';
import 'model_mutation_cubit.dart';
import 'models_cubit.dart';

class ModelActions extends StatelessWidget {
  const ModelActions({super.key, required this.model, this.onDeleted});
  final SavedModel model;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) => PopupMenuButton<bool>(
    tooltip: 'Model actions',
    icon: const Icon(Icons.more_vert),
    itemBuilder: (_) => const [
      PopupMenuItem(
        value: false,
        child: ListTile(
          leading: Icon(Icons.edit_outlined),
          title: Text('Rename model'),
        ),
      ),
      PopupMenuItem(
        value: true,
        child: ListTile(
          leading: Icon(Icons.delete_outline),
          title: Text('Delete model'),
        ),
      ),
    ],
    onSelected: (delete) async {
      final repository = context.read<ModelRepository>();
      final completed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => BlocProvider(
          create: (_) => ModelMutationCubit(repository),
          child: _ModelDialog(model: model, delete: delete),
        ),
      );
      if (!context.mounted) return;
      final removed = !context.read<ModelsCubit>().state.models.any(
        (m) => m.id == model.id,
      );
      if (completed == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(delete ? 'Model deleted' : 'Model renamed')),
        );
      }
      if (delete && (completed == true || removed)) onDeleted?.call();
    },
  );
}

class _ModelDialog extends StatefulWidget {
  const _ModelDialog({required this.model, required this.delete});
  final SavedModel model;
  final bool delete;
  @override
  State<_ModelDialog> createState() => _ModelDialogState();
}

class _ModelDialogState extends State<_ModelDialog> {
  late final _name = TextEditingController(text: widget.model.name);
  final _form = GlobalKey<FormState>();
  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    final cubit = context.read<ModelMutationCubit>();
    if (widget.delete) {
      cubit.delete(widget.model);
    } else if (_form.currentState!.validate()) {
      cubit.rename(widget.model, _name.text);
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<ModelMutationCubit, ModelMutationState>(
    listener: (context, state) {
      if (state.completed) Navigator.of(context).pop(true);
    },
    builder: (context, state) => PopScope(
      canPop: !state.busy,
      child: AlertDialog(
        title: Text(widget.delete ? 'Delete model?' : 'Rename model'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.delete)
                  Text(
                    'Delete “${widget.model.name}” and its saved tokenizer file and training metadata? This cannot be undone. Your original training text files will be kept.',
                  )
                else
                  Form(
                    key: _form,
                    child: TextFormField(
                      controller: _name,
                      autofocus: true,
                      enabled: !state.busy,
                      maxLength: 80,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Model name',
                      ),
                      validator: (value) {
                        try {
                          validateModelName(value ?? '');
                          return null;
                        } on AppFailure catch (error) {
                          return error.message;
                        }
                      },
                      onFieldSubmitted: (_) {
                        if (!state.busy) _submit();
                      },
                    ),
                  ),
                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      state.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                if (state.busy)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: LinearProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: state.busy
                ? null
                : () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: widget.delete
                ? FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  )
                : null,
            onPressed: state.busy ? null : _submit,
            child: Text(
              state.busy
                  ? 'Saving…'
                  : widget.delete
                  ? 'Delete'
                  : 'Save',
            ),
          ),
        ],
      ),
    ),
  );
}
