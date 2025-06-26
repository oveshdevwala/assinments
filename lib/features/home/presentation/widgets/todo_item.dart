import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/todo.dart';
import '../blocs/todo_bloc.dart';
import '../blocs/todo_event.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;

  const TodoItem({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 1,
      child: ListTile(
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (_) {
            context.read<TodoBloc>().add(ToggleTodoEvent(todo.id));
          },
        ),
        title: Text(
          todo.title,
          style: theme.textTheme.bodyLarge?.copyWith(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            color: todo.isCompleted
                ? theme.colorScheme.onSurface.withOpacity(0.5)
                : theme.colorScheme.onSurface,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () {
            context.read<TodoBloc>().add(DeleteTodoEvent(todo.id));
          },
          tooltip: 'Delete todo',
        ),
      ),
    );
  }
}
