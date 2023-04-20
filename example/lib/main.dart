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
  List data = [0, 1, 2, 3, [0, 1, 2, 3, [0, 1, 2, 3, 4], 4, 5, 6]];

  @override
  void initState() {
    super.initState();
  }

  Widget createNested(List<int> currentPos, List dataInput){
    return TestUnit(
      color: Colors.indigoAccent,
      pos: currentPos,
      itemBuilder: (context, index) {
        var pos = [...currentPos, index];
        if(dataInput[index] is List){
          return Padding(
            padding: const EdgeInsets.all(16.0),
            key: Key('$pos test $index'),
            child: createNested(pos, dataInput[index]),
          );
        }
        return Card(
          key: Key('$pos test $index'),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('$pos test ${dataInput[index]}'),
          ),
        );
      },
      itemCount: dataInput.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: MultiLevelDraggableParent(
          child: createNested([], data),
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
