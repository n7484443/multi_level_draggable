import 'package:flutter/material.dart';
import 'package:multi_level_draggable/widget/multi_level_draggable.dart';
import 'package:multi_level_draggable/util/pos.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List data = [
    0,
    1,
    2,
    3,
    <dynamic>[
      0,
      1,
      2,
      3,
      <dynamic>[0, 1, 2, 3, 4],
      4,
      5,
      6
    ]
  ];

  @override
  void initState() {
    super.initState();
  }

  Widget createNested(Pos currentPos, List dataInput) {
    return TestUnit(
      color: Colors.indigoAccent,
      pos: currentPos,
      itemBuilder: (context, index) {
        var pos = currentPos.addLast(index);
        if (dataInput[index] is List) {
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
      removeFunction: (context, index) {
        List currentArray = data;
        for (var i in currentPos.data) {
          currentArray = currentArray[i];
        }
        var removed = currentArray[index];
        setState(() {
          currentArray.removeAt(index);
        });
        return removed;
      },
      insertFunction: (context,
          {required Pos from, required Pos to, required dynamic removed}) {
        setState(() {
          var currentArray = data;
          for (var i in to.removeLast().data) {
            currentArray = currentArray[i];
          }
          currentArray.insert(
              to.last,
              removed
          );
        });
      },
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
          child: createNested(const Pos(), data),
        ),
      ),
    );
  }
}

class TestUnit extends StatelessWidget {
  final Color color;
  final Pos pos;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final dynamic Function(BuildContext context, int index) removeFunction;
  final void Function(BuildContext context,
      {required Pos from,
      required Pos to,
      required dynamic removed}) insertFunction;
  final int itemCount;

  const TestUnit(
      {required this.color,
      required this.pos,
      required this.itemBuilder,
      required this.itemCount,
      required this.removeFunction,
      required this.insertFunction,
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
            removeFunction: removeFunction,
            insertFunction: insertFunction,
            pos: pos,
          ),
        ],
      ),
    );
  }
}
