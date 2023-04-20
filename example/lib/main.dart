import 'package:flutter/material.dart';
import 'package:multi_level_draggable/widget/multi_level_draggable.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: const TestUnit(
          level: 1,
          color: Colors.indigo,
          child: TestUnit(
            color: Colors.indigoAccent,
            level: 2,
          ),
        ),
      ),
    );
  }
}

class TestUnit extends StatelessWidget {
  final Widget? child;
  final Color color;
  final int level;

  const TestUnit({this.child, required this.level, Key? key, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: ListView(
        shrinkWrap: true,
        children: [
          Text('level $level'),
          MultiLevelDraggable(
              itemBuilder: (context, index) => Card(
                    key: Key('$level test $index'),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('test $index'),
                    ),
                  ),
              itemCount: 10),
          if (child != null) Padding(
            padding: const EdgeInsets.all(16.0),
            child: child!,
          ),
        ],
      ),
    );
  }
}
