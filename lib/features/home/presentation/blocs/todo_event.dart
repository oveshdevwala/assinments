import '../../domain/entities/todo.dart';

abstract class TodoEvent {
  const TodoEvent();
}

class AddTodoEvent extends TodoEvent {
  final String title;

  const AddTodoEvent(this.title);
}

class DeleteTodoEvent extends TodoEvent {
  final String id;

  const DeleteTodoEvent(this.id);
}

class ToggleTodoEvent extends TodoEvent {
  final String id;

  const ToggleTodoEvent(this.id);
}
