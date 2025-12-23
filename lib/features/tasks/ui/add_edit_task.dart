import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../model/task_model.dart';

class AddEditTaskScreen extends StatefulWidget {
  final TaskModel? task;

  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _priority = 'medium';

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descController.text = widget.task!.description;
      _selectedDate = widget.task!.dueDate;
      _priority = widget.task!.priority;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.task == null ? "New Task" : "Edit Task")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Title")),
            const SizedBox(height: 16),
            TextField(controller: _descController, decoration: const InputDecoration(labelText: "Description")),
            const SizedBox(height: 16),

            Row(
              children: [
                const Text("Due Date: "),
                TextButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000), 
                      lastDate: DateTime(2030),
                    );
                    if (date != null) setState(() => _selectedDate = date);
                  },
                  child: Text("${_selectedDate.toLocal()}".split(' ')[0]),
                ),
              ],
            ),
            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: _priority,
              items: ['low', 'medium', 'high']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase())))
                  .toList(),
              onChanged: (val) => setState(() => _priority = val!),
              decoration: const InputDecoration(labelText: "Priority"),
            ),
            
            const Spacer(),
            
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty) {
                  final task = TaskModel(
                    id: widget.task?.id ?? '', 
                    title: _titleController.text,
                    description: _descController.text,
                    dueDate: _selectedDate,
                    priority: _priority,
                    isCompleted: widget.task?.isCompleted ?? false, 
                  );

                  if (widget.task == null) {
                    context.read<TaskBloc>().add(AddTask(task));
                  } else {
                    context.read<TaskBloc>().add(UpdateTask(task));
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(widget.task == null ? "Save Task" : "Update Task"),
            ),
          ],
        ),
      ),
    );
  }
}