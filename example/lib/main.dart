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
        body: MultiLevelDraggableParent(
          child: TestUnit(
            pos: const [0],
            color: Colors.indigo,
            itemBuilder: (context, index) {
              if (index == 4) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  key: Key('${[0, 0]} test $index'),
                  child: TestUnit(
                    color: Colors.indigoAccent,
                    pos: const [0, 0],
                    itemBuilder: (context, index) {
                      if (index == 4) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          key: Key('${[0, 0, 0]} test $index'),
                          child: TestUnit(
                            color: Colors.indigoAccent,
                            pos: const [0, 0, 0],
                            itemBuilder: (context, index) {
                              return Card(
                                key: Key('${[0, 0, 0]} test $index'),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('test $index'),
                                ),
                              );
                            },
                            itemCount: 5,
                          ),
                        );
                      }
                      return Card(
                        key: Key('${[0, 0]} test $index'),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('test $index'),
                        ),
                      );
                    },
                    itemCount: 5,
                  ),
                );
              }
              return Card(
                key: Key('${[0]} test $index'),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('test $index'),
                ),
              );
            },
            itemCount: 5,
          ),
        ),
      ),
    );
  }
}

class TestUnit extends StatelessWidget {
  final Color color;
  final List<int> pos;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final int itemCount;

  const TestUnit(
      {required this.color,
      required this.pos,
      required this.itemBuilder,
      required this.itemCount,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: ListView(
        shrinkWrap: true,
        children: [
          Text('level $pos'),
          MultiLevelDraggable(
            itemBuilder: itemBuilder,
            itemCount: itemCount,
            removeFunction: (BuildContext context, int index) {
              print("removed $pos $index");
            },
            insertFunction: (BuildContext context, List<int> start, int index) {
              print("insert $pos $index");
            },
            pos: pos,
          ),
        ],
      ),
    );
  }
}
