import 'package:flutter/material.dart';

class MultiLevelDraggable extends StatefulWidget {
  final Widget Function(BuildContext context, int index) itemBuilder;
  final int itemCount;

  const MultiLevelDraggable(
      {required this.itemBuilder, required this.itemCount, Key? key})
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
    return ListView.builder(
      shrinkWrap: true,
      itemBuilder: (context, index) => itemBuilder(context, index),
      itemCount: widget.itemCount,
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

  void dragUpdate(Offset position) {
    setState(() {
      dragData?.dragPosition += position;
      overlayEntry?.markNeedsBuild();
    });
  }

  void dragEnd() {
    var item = items[dragData!.index]!;
    item.isDrag = false;
    dragData = null;
    overlayEntry?.remove();
    overlayEntry = null;
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
      onPanDown: (details) {
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
          multiLevelDraggableState.dragUpdate(details.delta);
        });
      },
      onPanEnd: (DragEndDetails details) {
        setState(() {
          multiLevelDraggableState.dragEnd();
          isDrag = false;
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
