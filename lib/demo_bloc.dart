import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class DemoEvent extends Equatable {
  const DemoEvent();
}

class TriggerEvent extends DemoEvent {
  final int id;
  const TriggerEvent(this.id);

  @override
  List<Object> get props => [id];
}

class ResetEvent extends DemoEvent {
  @override
  List<Object> get props => [];
}

// State
class DemoState extends Equatable {
  final List<String> logs;

  const DemoState({this.logs = const []});

  DemoState copyWith({List<String>? logs}) {
    return DemoState(logs: logs ?? this.logs);
  }

  @override
  List<Object> get props => [logs];
}

// Bloc
class DemoBloc extends Bloc<DemoEvent, DemoState> {
  final EventTransformer<TriggerEvent> _transformer;

  DemoBloc(this._transformer) : super(const DemoState()) {
    on<TriggerEvent>(_onTriggerEvent, transformer: _transformer);
    on<ResetEvent>(_onResetEvent);
  }

  Future<void> _onTriggerEvent(TriggerEvent event, Emitter<DemoState> emit) async {
    final startLog = 'Event ${event.id}: Started';
    emit(state.copyWith(logs: [...state.logs, startLog]));

    // Simulate network request or heavy computation
    try {
      await Future.delayed(const Duration(seconds: 2));
      
      final completeLog = 'Event ${event.id}: Completed';
      emit(state.copyWith(logs: [...state.logs, completeLog]));
    } on Exception catch (_) {
       // Handle cancellation if needed, though bloc handles it automatically
    }
  }

  void _onResetEvent(ResetEvent event, Emitter<DemoState> emit) {
    emit(const DemoState(logs: []));
  }
}
