import '../model/task_model.dart';

abstract class TaskEvent {}

class LoadTasks extends TaskEvent {}

class AddTask extends TaskEvent {
  final TaskModel task;
  AddTask(this.task);
}

class UpdateTask extends TaskEvent {
  final TaskModel task;
  UpdateTask(this.task);
}

class DeleteTask extends TaskEvent {
  final String taskId;
  DeleteTask(this.taskId);
}

class SearchTasks extends TaskEvent {
  final String query;
  SearchTasks(this.query);
}

class ToggleTaskCompletion extends TaskEvent {
  final String taskId;
  final bool isCompleted;
  ToggleTaskCompletion(this.taskId, this.isCompleted);
}