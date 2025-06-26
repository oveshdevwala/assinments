import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/todo.dart';
import 'todo_event.dart';
import 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  TodoBloc() : super(const TodoState(todos: [])) {
    on<AddTodoEvent>(_onAddTodo);
    on<DeleteTodoEvent>(_onDeleteTodo);
    on<ToggleTodoEvent>(_onToggleTodo);
  }

  void _onAddTodo(AddTodoEvent event, Emitter<TodoState> emit) {
    if (event.title.trim().isEmpty) return;

    final newTodo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: event.title.trim(),
      isCompleted: false,
      createdAt: DateTime.now(),
    );

    final updatedTodos = List<Todo>.from(state.todos)..add(newTodo);
    emit(state.copyWith(todos: updatedTodos));
  }

  void _onDeleteTodo(DeleteTodoEvent event, Emitter<TodoState> emit) {
    final updatedTodos = state.todos
        .where((todo) => todo.id != event.id)
        .toList();
    emit(state.copyWith(todos: updatedTodos));
  }

  void _onToggleTodo(ToggleTodoEvent event, Emitter<TodoState> emit) {
    final updatedTodos = state.todos.map((todo) {
      if (todo.id == event.id) {
        return todo.copyWith(isCompleted: !todo.isCompleted);
      }
      return todo;
    }).toList();
    emit(state.copyWith(todos: updatedTodos));
  }
}
