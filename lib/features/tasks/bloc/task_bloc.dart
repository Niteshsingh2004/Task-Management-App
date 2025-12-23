import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'task_event.dart';
import 'task_state.dart';
import '../model/task_model.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

 
  List<TaskModel> _allTasks = []; 
  String _searchQuery = '';       
  TaskBloc() : super(TaskLoading()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<ToggleTaskCompletion>(_onToggleTask);
    
    on<SearchTasks>(_onSearchTasks);
  }

  CollectionReference? get _tasksRef {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('tasks');
  }

  TaskState _filterTasks() {
    if (_searchQuery.isEmpty) {

      return TaskLoaded(List.from(_allTasks));
    } else {

      final filtered = _allTasks.where((task) {
        return task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               task.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
      return TaskLoaded(filtered);
    }
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      emit(TaskError("User not logged in"));
      return;
    }

    try {
      await emit.forEach(
        _tasksRef!.orderBy('dueDate').snapshots(),
        onData: (QuerySnapshot snapshot) {
          _allTasks = snapshot.docs
              .map((doc) => TaskModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList();
          
          return _filterTasks();
        },
        onError: (error, stackTrace) => TaskError("Failed to fetch tasks"),
      );
    } catch (e) {
      emit(TaskError("Unexpected Error: $e"));
    }
  }


  void _onSearchTasks(SearchTasks event, Emitter<TaskState> emit) {
    _searchQuery = event.query; 
    emit(_filterTasks());      
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    try {
      if (_tasksRef != null) await _tasksRef!.add(event.task.toMap());
    } catch (e) {
      emit(TaskError("Failed to add task"));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      if (_tasksRef != null) await _tasksRef!.doc(event.task.id).update(event.task.toMap());
    } catch (e) {
      emit(TaskError("Failed to update task"));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      if (_tasksRef != null) await _tasksRef!.doc(event.taskId).delete();
    } catch (e) {
      emit(TaskError("Failed to delete task"));
    }
  }

  Future<void> _onToggleTask(ToggleTaskCompletion event, Emitter<TaskState> emit) async {
    try {
      if (_tasksRef != null) await _tasksRef!.doc(event.taskId).update({'isCompleted': event.isCompleted});
    } catch (e) {
      emit(TaskError("Failed to update task"));
    }
  }
}