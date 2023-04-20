import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../util/pos.dart';

class MultiLevelDraggableParent extends StatefulWidget {
  final Widget child;

  const MultiLevelDraggableParent({required this.child, Key? key})
      : super(key: key);

  @override
  State<MultiLevelDraggableParent> createState() =>
      MultiLevelDraggableParentState();
}

class MultiLevelDraggableParentState extends State<MultiLevelDraggableParent> {
  MultiLevelDraggableState? currentDragOn;

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  static MultiLevelDraggableParentState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<MultiLevelDraggableParentState>();
  }
}

class MultiLevelDraggable extends StatefulWidget {
  final Widget Function(BuildContext context, int index) itemBuilder;
  final dynamic Function(BuildContext context, int index) removeFunction;
  final void Function(BuildContext context,
      {required Pos from,
      required Pos to,
      required dynamic removed}) insertFunction;
  final int itemCount;
  final Pos pos;

  const MultiLevelDraggable(
      {required this.itemBuilder,
      required this.itemCount,
      required this.removeFunction,
      required this.insertFunction,
      required this.pos,
      Key? key})
      : super(key: key);

  @override
  State<MultiLevelDraggable> createState() => MultiLevelDraggableState();

  static MultiLevelDraggableState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<MultiLevelDraggableState>();
  }
}

class MultiLevelDraggableState extends State<MultiLevelDraggable> {
  OverlayEntry? overlayEntry;
  DragData? dragData;
  Map<int, MultiLevelDraggableChildState> items = {};

  @override
  Widget build(BuildContext context) {
    return MetaData(
      metaData: this,
      behavior: HitTestBehavior.translucent,
      child: ListView.builder(
        shrinkWrap: true,
        itemBuilder: (context, index) => itemBuilder(context, index),
        itemCount: widget.itemCount,
      ),
    );
  }

  Widget itemBuilder(BuildContext context, int index) {
    final Widget child = widget.itemBuilder(context, index);
    assert(child.key != null, 'All list items must have a key');
    final OverlayState overlay = Overlay.of(context, debugRequiredFor: widget);
    return MultiLevelDraggableChild(
      key: child.key,
      index: index,
      capturedThemes:
          InheritedTheme.capture(from: context, to: overlay.context),
      child: child,
    );
  }

  void dragStart(Offset position) {
    var item = items[dragData!.index]!;
    item.isDrag = true;
    var overlay = Overlay.of(context);
    overlayEntry = OverlayEntry(builder: dragData!.buildProxy);
    overlay.insert(overlayEntry!);
  }

  Iterable<MultiLevelDraggableState> getTargets(Iterable<HitTestEntry> path) {
    final List<MultiLevelDraggableState> targets = <MultiLevelDraggableState>[];
    for (final HitTestEntry entry in path) {
      final HitTestTarget target = entry.target;

      if (target is RenderMetaData) {
        targets.add(target.metaData);
      }
    }
    return targets;
  }

  void dragUpdate(DragUpdateDetails details) {
    final HitTestResult result = HitTestResult();
    WidgetsBinding.instance.hitTest(result, details.globalPosition);
    final List<MultiLevelDraggableState> targets =
        getTargets(result.path).toList();
    var parent = MultiLevelDraggableParentState.maybeOf(context);
    assert(parent != null);
    if (targets.isNotEmpty) {
      parent?.setState(() {
        parent.currentDragOn = targets.first;
      });
    }
    setState(() {
      dragData?.dragPosition += details.delta;
      overlayEntry?.markNeedsBuild();
    });
  }

  void dragEnd() {
    insert(dragData!);
    var item = items[dragData!.index]!;
    item.isDrag = false;
    dragData = null;
    overlayEntry?.remove();
    overlayEntry = null;
  }

  void insert(DragData data) {
    var parent = MultiLevelDraggableParentState.maybeOf(context);
    var removed = widget.removeFunction(context, data.index);
    var toParent = parent?.currentDragOn?.widget;

    var from = widget.pos.addLast(data.index);
    var to = toParent!.pos.addLast(0);
    var isSameParent = widget.pos.contain(to);
    if (isSameParent) {
      if (data.index < to.data[from.length - 1]) {
        var copy = [...to.data];
        copy[from.length - 1] -= 1;
        to = Pos(data: copy);
      }
    }
    toParent.insertFunction(
      context,
      from: from,
      to: to,
      removed: removed,
    );
  }

  void register(
      MultiLevelDraggableChildState multiLevelDraggableChildState, int index) {
    items[index] = multiLevelDraggableChildState;
  }

  MultiLevelDraggableChildState? unRegister(int index) {
    return items.remove(index);
  }
}

class MultiLevelDraggableChild extends StatefulWidget {
  final Widget child;
  final int index;
  final CapturedThemes capturedThemes;

  const MultiLevelDraggableChild(
      {Key? key,
      required this.child,
      required this.index,
      required this.capturedThemes})
      : super(key: key);

  @override
  State<MultiLevelDraggableChild> createState() =>
      MultiLevelDraggableChildState();
}

class MultiLevelDraggableChildState extends State<MultiLevelDraggableChild> {
  Offset offset = const Offset(0, 0);
  bool isDrag = false;
  bool isSelected = false;
  late MultiLevelDraggableState multiLevelDraggableState;

  @override
  void initState() {
    multiLevelDraggableState = MultiLevelDraggable.maybeOf(context)!;
    multiLevelDraggableState.register(this, widget.index);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          multiLevelDraggableState.dragData = DragData(
              capturedThemes: widget.capturedThemes,
              index: widget.index,
              size: context.size!,
              child: widget.child,
              item: this);
          multiLevelDraggableState.dragStart(details.localPosition);
          isDrag = true;
        });
      },
      onPanUpdate: (details) {
        setState(() {
          multiLevelDraggableState.dragUpdate(details);
        });
      },
      onPanEnd: (DragEndDetails details) {
        setState(() {
          multiLevelDraggableState.dragEnd();
          isDrag = false;
          isSelected = false;
        });
      },
      child: isDrag
          ? const SizedBox()
          : Transform.translate(
              offset: offset,
              child: widget.child,
            ),
    );
  }
}

class DragData {
  final int index;
  late Offset dragOffset;
  late Offset dragPosition;
  final Size size;
  final CapturedThemes capturedThemes;
  final Widget child;

  DragData({
    required MultiLevelDraggableChildState item,
    required this.capturedThemes,
    required this.index,
    required this.size,
    required this.child,
    Offset initialPosition = Offset.zero,
  }) {
    final RenderBox itemRenderBox =
        item.context.findRenderObject()! as RenderBox;
    dragPosition = initialPosition;
    dragOffset = itemRenderBox.globalToLocal(initialPosition);
  }

  Widget buildProxy(BuildContext context) {
    var pos = dragPosition - dragOffset - _overlayOrigin(context);
    return capturedThemes.wrap(
      Positioned(
        left: pos.dx,
        top: pos.dy,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: IgnorePointer(
            child: child,
          ),
        ),
      ),
    );
  }
}

Offset _overlayOrigin(BuildContext context) {
  final OverlayState overlay =
      Overlay.of(context, debugRequiredFor: context.widget);
  final RenderBox overlayBox = overlay.context.findRenderObject()! as RenderBox;
  return overlayBox.localToGlobal(Offset.zero);
}
