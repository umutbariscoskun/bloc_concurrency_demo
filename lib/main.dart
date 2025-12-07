import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'demo_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bloc Concurrency Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bloc Concurrency Demo'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Concurrent'),
              Tab(text: 'Sequential'),
              Tab(text: 'Droppable'),
              Tab(text: 'Restartable'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            DemoPage(transformer: concurrent(), name: 'Concurrent'),
            DemoPage(transformer: sequential(), name: 'Sequential'),
            DemoPage(transformer: droppable(), name: 'Droppable'),
            DemoPage(transformer: restartable(), name: 'Restartable'),
          ],
        ),
      ),
    );
  }
}

class DemoPage extends StatelessWidget {
  final EventTransformer<TriggerEvent> transformer;
  final String name;

  const DemoPage({
    super.key,
    required this.transformer,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DemoBloc(transformer),
      child: TransformerDemoView(name: name),
    );
  }
}

class TransformerDemoView extends StatefulWidget {
  final String name;

  const TransformerDemoView({super.key, required this.name});

  @override
  State<TransformerDemoView> createState() => _TransformerDemoViewState();
}

class _TransformerDemoViewState extends State<TransformerDemoView> {
  int _eventId = 0;
  final ScrollController _scrollController = ScrollController();

  void _triggerEvent(BuildContext context) {
    _eventId++;
    context.read<DemoBloc>().add(TriggerEvent(_eventId));
  }

  void _reset(BuildContext context) {
    _eventId = 0;
    context.read<DemoBloc>().add(ResetEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Mode: ${widget.name}',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _getDescription(widget.name),
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade50,
              ),
              child: BlocBuilder<DemoBloc, DemoState>(
                builder: (context, state) {
                  // Auto-scroll to bottom
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  });

                  if (state.logs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No logs yet.\nTap "Trigger Event" to start.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: state.logs.length,
                    itemBuilder: (context, index) {
                      final log = state.logs[index];
                      final isStarted = log.contains('Started');
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isStarted ? Colors.blue.shade50 : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isStarted ? Colors.blue.shade200 : Colors.green.shade200,
                          ),
                        ),
                        child: Text(
                          log,
                          style: TextStyle(
                            color: isStarted ? Colors.blue.shade900 : Colors.green.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _triggerEvent(context),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Trigger Event (2s delay)'),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () => _reset(context),
                child: const Icon(Icons.refresh),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getDescription(String name) {
    switch (name.toLowerCase()) {
      case 'concurrent':
        return 'Process events concurrently. All events run simultaneously.';
      case 'sequential':
        return 'Process events sequentially. Events wait for the previous one to finish.';
      case 'droppable':
        return 'Ignore any events added while an event is processing.';
      case 'restartable':
        return 'Process only the latest event and cancel previous event handlers.';
      default:
        return '';
    }
  }
}
