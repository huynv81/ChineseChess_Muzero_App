import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../global.dart';

enum PanelShape { rectangle, rounded }

enum DockType { inside, outside }

enum PanelState { expanded, closed }

class FloatBoxPanel extends StatefulWidget {
  bool isFirstTime = true;

  // final double positionTop;
  // final double positionLeft;
  final Color borderColor;
  double borderWidth;

  /// Widget size if the width of the panel;
  double panelWidth;
  double iconSize;
  IconData initialPanelIcon;
  final BorderRadius borderRadius;
  final Color backgroundColor;
  final Color panelButtonColor;
  final Color customButtonColor;
  final PanelShape panelShape;

  double panelOpenOffset;
  final int panelAnimDuration;
  final Curve panelAnimCurve;
  final DockType dockType;

  /// Dock offset creates the boundary for the page depending on the DockType;
  late double dockOffset;
  bool dockActivate;
  final int dockAnimDuration;
  final Curve dockAnimCurve;
  final List<IconData> buttons;
  final void Function(int)? onPressed;
  final Color innerButtonFocusColor;
  final Color customButtonFocusColor;

  final List<bool> isFocusColors = []; //（包括内置按钮）

  FloatBoxPanel({
    Key? key,
    this.buttons = const [],
    this.borderColor = const Color(0xFF333333),
    this.borderWidth = 0,
    this.panelWidth = testPanelWidth,
    this.iconSize = 24,
    this.initialPanelIcon = Icons.add,
    BorderRadius? borderRadius,
    this.panelOpenOffset = 5.0,
    this.panelAnimDuration = 600,
    this.panelAnimCurve = Curves.fastLinearToSlowEaseIn,
    this.backgroundColor = const Color(0xFF333333),
    this.panelButtonColor = Colors.white,
    this.customButtonColor = Colors.white,
    this.panelShape = PanelShape.rounded,
    this.dockType = DockType.outside,
    this.dockAnimCurve = Curves.fastLinearToSlowEaseIn,
    this.dockAnimDuration = 300,
    this.onPressed,
    this.innerButtonFocusColor = Colors.blue,
    this.customButtonFocusColor = Colors.red,
    this.dockActivate = false,
  })  : borderRadius = borderRadius ?? BorderRadius.circular(testBorderRadius),
        super(key: key) {
    //
    final realTestRatio = panelWidth / testPanelWidth;
    borderWidth = borderWidth * realTestRatio;
    panelWidth = panelWidth * realTestRatio;
    iconSize = iconSize * realTestRatio;
    panelOpenOffset = panelOpenOffset * realTestRatio;
    dockOffset = panelWidth / 2;

    // +1 是因为还有个内置按钮（第一个）
    for (var i = 0; i < (buttons.length + 1); i++) {
      isFocusColors.add(false);
    }
  }

  @override
  _FloatBoxState createState() => _FloatBoxState();
}

class _FloatBoxState extends State<FloatBoxPanel> {
  // Required to set the default state to closed when the widget gets initialized;
  PanelState _panelState = PanelState.closed;
  //panel相对于窗口左上角的相对偏移，为[0, 0]则代表其处于窗口的左上角;
  double _xOffset = 0.0;
  double _yOffset = 0.0;

  // 拖动panel时为了让鼠标居中于panel中心而设置的临时变量
  double _mouseOffsetX = 0.0;
  double _mouseOffsetY = 0.0;

  // This is the animation duration for the panel movement, it's required to
  // dynamically change the speed depending on what the panel is being used for.
  // e.g: When panel opened or closed, the position should change in a different
  // speed than when the panel is being dragged;
  int _movementSpeed = 0;

  double? _oldYOffset; //用以复原角落ui的y轴偏移字段
  double? _oldYOffsetRatio; //用以复原角落ui比率字段

  // Width and height of page is required for the dragging the panel;
  double get _pageWidth => MediaQuery.of(context).size.width;
  double get _pageHeight => MediaQuery.of(context).size.height;

  double? _xOffsetRatio;
  double _yOffsetRatio = 1 / 3;

  late IconData _panelIcon;

  @override
  void initState() {
    super.initState();
    _panelIcon = widget.initialPanelIcon;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isFirstTime) {
      // 拖动后会触发这里（无论panel是否展开）
      // update ratio for next update building
      _xOffsetRatio = _xOffset / _pageWidth;
      _yOffsetRatio = _yOffset / _pageHeight;
      //  debugPrint("not first time, _xOffset: $_xOffset, _yOffset: $_yOffset，yRatio:$_yOffsetRatio");
    } else {
      // 首次更新或者窗口缩放大小时会触发这里，
      //  debugPrint("first time before, _xOffset: $_xOffset, _yOffset: $_yOffset");
      if (_xOffsetRatio == null) {
        _xOffset = _pageWidth; //为让首次dock到右边，所以取≥_pageWidth的偏移
        _getPoperDockXOffset();
        _xOffsetRatio = _xOffset / _pageWidth;
      }

      onPanUpdateGesture(
          _pageWidth * _xOffsetRatio!, _pageHeight * _yOffsetRatio,
          isReScale: true);
      //  debugPrint("first time after, _xOffset: $_xOffset, _yOffset: $_yOffset，yRatio:$_yOffsetRatio");

      _calcOffsetWhenForceDock(); //这步一定要有，否则初始化时的按钮无法贴边一半
      widget.isFirstTime = false;
    }

    return _animatedPositioned(
      child: _animatedContainer(
        child: _panel(),
      ),
    );
  }

  // Dock boundary is calculated according to the dock offset and dock type.
  double _dockBoundary() {
    //  debugPrint("dock boundary");
    if (widget.dockType == DockType.inside) {
      // If it's an 'inside' type dock, dock offset will remain the same;
      return widget.dockOffset;
    }

    // If it's an 'outside' type dock, dock offset will be inverted, hence
    // negative value;
    return -(widget.dockOffset);
  }

  // If panel shape is set to rectangle, the border radius will be set to custom
  // border radius property of the WIDGET, else it will be set to the size of
  // widget to make all corners rounded.
  BorderRadius _borderRadius() {
    if (widget.panelShape == PanelShape.rectangle) {
      // If panel shape is 'rectangle', border radius can be set to custom or 0;
      return widget.borderRadius;
    }

    // If panel shape is 'rounded', border radius will be the size of widget
    // to make it rounded;
    return BorderRadius.circular(widget.panelWidth);
  }

  // Height of the panel according to the panel state;
  double _panelHeight() {
    if (_panelState == PanelState.expanded) {
      return widget.panelWidth * (widget.buttons.length + 1) +
          widget.borderWidth;
    }
    return widget.panelWidth + (widget.borderWidth) * 2;
  }

  // Panel top needs to be recalculated while opening the panel, to make sure
  // the height doesn't exceed the bottom of the page;
  void _calcPanelYOffsetWhenOpening() {
    if (_yOffset < 0) {
      //说明在顶端
      ////  debugPrint("_yOffset:$_yOffset < $_pageHeight  !!!!!!!!!");
      _updateOldYOffset();

      // 根据_panelHeight()推演
      _yOffset = 0.0 + widget.panelWidth + widget.borderWidth + _dockBoundary();
    } else {
      if (_yOffset + _panelHeight() > _pageHeight + _dockBoundary()) {
        //说明拓展后的长度超出了底边界
        final newYOffset = _pageHeight - _panelHeight() + _dockBoundary();
        if (newYOffset != _yOffset) {
          _updateOldYOffset();
          _yOffset = newYOffset;
        }
      } else {
        //说明在中端
        _oldYOffset = null;
        _updateOldYOffset();
      }
    }
  }

  void _updateOldYOffset({setNull = false}) {
    if (setNull) {
      _oldYOffset = null;
      _oldYOffsetRatio = null;
    } else {
      _oldYOffset = _yOffset;
      _oldYOffsetRatio = _oldYOffset! / _pageHeight;
    }
  }

  // Dock Left position when open;
  double _openDockLeft() {
    if (_xOffset < (_pageWidth / 2)) {
      // If panel is docked to the left;
      //  debugPrint("openDockLeft");
      return widget.panelOpenOffset;
    }

    // If panel is docked to the right;
    //  debugPrint("openDockRight");
    return ((_pageWidth - widget.panelWidth)) - (widget.panelOpenOffset);
  }

  // Panel border is only enabled if the border width is greater than 0;
  Border? _panelBorder() {
    if (widget.borderWidth <= 0) {
      return null;
    }

    return Border.all(
      color: widget.borderColor,
      width: widget.borderWidth,
    );
  }

  // Force dock will dock the panel to it's nearest edge of the screen;
  void _calcOffsetWhenForceDock() {
    //  debugPrint("force dock, _yOffset: $_yOffset");

    if (_panelState == PanelState.closed) {
      _movementSpeed = widget.dockAnimDuration;
      // 调整x偏移
      _getPoperDockXOffset();
      //（若原来在角落）调整y偏移
      if (_oldYOffset != null && _yOffset != _oldYOffset!) {
        _yOffset = _oldYOffset!;
      }
    }
  }

  void _getPoperDockXOffset() {
    double center = _xOffset + (widget.panelWidth / 2);
    final dockEdgeOffset = (center < _pageWidth / 2)
        ? -widget.panelWidth // Dock to the left edge
        : (_pageWidth - widget.panelWidth); // Dock to the right edge
    _xOffset = dockEdgeOffset - _dockBoundary();
  }

  Widget _animatedPositioned({required Widget child}) {
    // Animated positioned widget can be moved to any part of the screen with
    // animation;
    return AnimatedPositioned(
      duration: Duration(milliseconds: _movementSpeed),
      top: _yOffset,
      left: _xOffset,
      curve: widget.dockAnimCurve,
      child: child,
    );
  }

  Widget _animatedContainer({required Widget child}) {
    return AnimatedContainer(
      duration: Duration(milliseconds: widget.panelAnimDuration),
      width: widget.panelWidth,
      height: _panelHeight(),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: _borderRadius(),
        border: _panelBorder(),
      ),
      curve: widget.panelAnimCurve,
      child: child,
    );
  }

  Widget _panel() {
    return Wrap(
      direction: Axis.horizontal,
      children: [
        _innerButton(),
        _customButtons(),
      ],
    );
  }

  Widget _innerButton() {
    return GestureDetector(
      onPanEnd: (event) {
        //  debugPrint("onPanEnd");
        setState(_calcOffsetWhenForceDock);
      },
      onPanStart: (event) {
        //  debugPrint("onPanStart");
        // Detect the offset between the top and left side of the panel and
        // x and y position of the touch(click) event;
        ////  debugPrint(
        // "global x: ${event.globalPosition.dx}  y: ${event.globalPosition.dy}");
        _mouseOffsetX = event.globalPosition.dx - _xOffset;
        _mouseOffsetY = event.globalPosition.dy - _yOffset;
      },
      onPanUpdate: (event) {
        setState(
          () => onPanUpdateGesture(
              event.globalPosition.dx, event.globalPosition.dy),
        );
      },
      onTap: _onInnerButtonTapGesture,
      // 顶部内置按钮部分
      child: MouseRegion(
        onEnter: (value) {
          setState(() {
            widget.isFocusColors[0] = true;
          });
        },
        onExit: (value) {
          setState(() {
            widget.isFocusColors[0] = false;
          });
        },
        cursor: SystemMouseCursors.click, //Cursor type on hover
        child: _FloatButton(
          focusColor: widget.innerButtonFocusColor,
          size: widget.panelWidth,
          icon: _panelIcon,
          color: widget.panelButtonColor,
          hightLight: widget.isFocusColors[0],
          iconSize: widget.iconSize,
        ),
      ),
    );
  }

  Widget _customButtons() {
    return Visibility(
      visible: _panelState == PanelState.expanded,
      child: Column(
        children: List.generate(
          widget.buttons.length,
          (index) {
            return GestureDetector(
              onPanStart: (event) {
                //  debugPrint("onPanStart customButton");
                // Detect the offset between the top and left side of the panel and
                // x and y position of the touch(click) event;
                ////  debugPrint(
                // "global x: ${event.globalPosition.dx}  y: ${event.globalPosition.dy}");
                _mouseOffsetX = event.globalPosition.dx - _xOffset;
                _mouseOffsetY = event.globalPosition.dy - _yOffset;
              },
              onPanUpdate: (event) {
                setState(
                  () => onPanUpdateGesture(
                      event.globalPosition.dx, event.globalPosition.dy),
                );
              },
              onTap: () {
                if (widget.onPressed != null) {
                  widget.onPressed!(index);
                }
              },
              // 自定义按钮部分
              child: MouseRegion(
                onEnter: (value) {
                  setState(() {
                    widget.isFocusColors[index + 1] = true;
                    // Offset offset = _getActivatedOffset();
                  });
                },
                onExit: (value) {
                  setState(() {
                    widget.isFocusColors[index + 1] = false;
                  });
                },
                cursor: SystemMouseCursors.click, //Cursor type on hover
                child: _FloatButton(
                  focusColor: widget.customButtonFocusColor,
                  size: widget.panelWidth,
                  icon: widget.buttons[index],
                  color: widget.customButtonColor,
                  hightLight: widget.isFocusColors[index + 1],
                  iconSize: widget.iconSize,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // 鼠标拖动或窗口缩放时会被调用
  void onPanUpdateGesture(double globalPositionDx, double globalPositionDy,
      {bool isReScale = false}) {
    //  debugPrint("onPanUpdateGesture,$globalPositionDx,$globalPositionDy");
    _movementSpeed = 0; //拖动或初始化（窗口大小变化）时的速度需要最快，所以为0

    // Calculate the top position of the panel according to pan;
    _yOffset = isReScale ? globalPositionDy : globalPositionDy - _mouseOffsetY;
    if (_yOffset < 0 + _dockBoundary()) {
      _yOffset = 0 + _dockBoundary();
    }
    if (_yOffset > (_pageHeight - _panelHeight()) - _dockBoundary()) {
      _yOffset = (_pageHeight - _panelHeight()) - _dockBoundary();
    }

    // Calculate the Left position of the panel according to pan;
    _xOffset = isReScale ? globalPositionDx : globalPositionDx - _mouseOffsetX;
    if (_xOffset < 0 + _dockBoundary()) {
      _xOffset = 0 + _dockBoundary();
    }
    if (_xOffset > (_pageWidth - widget.panelWidth) - _dockBoundary()) {
      _xOffset = (_pageWidth - widget.panelWidth) - _dockBoundary();
    }

    // 复原 , TODO: isScale模式下最好重新计算_oldYOffset
    if (!isReScale) {
      _oldYOffset = null;
    } else if (_oldYOffset != null) {
      _oldYOffset = _oldYOffsetRatio! * _pageHeight;
    }
  }

  void _onInnerButtonTapGesture() {
    setState(
      () {
        //  debugPrint("_onTapGesture");

        // Set the animation speed to custom duration;
        _movementSpeed = widget.panelAnimDuration;

        if (_panelState == PanelState.expanded) {
          _panelState = PanelState.closed;
          _calcOffsetWhenForceDock();
          _panelIcon = Icons.add;
          //  debugPrint("Float panel closed.");
        } else {
          _panelState = PanelState.expanded;
          _calcOffsetWhenExpand();
          _panelIcon = CupertinoIcons.minus_circle_fill;
          //  debugPrint("Float Panel Expanded.");
        }
      },
    );
  }

  void _calcOffsetWhenExpand() {
    _xOffset = _openDockLeft();
    _calcPanelYOffsetWhenOpening();
  }
}

class _FloatButton extends StatelessWidget {
  final double size;
  final Color color;
  final IconData icon;
  final double iconSize;
  final bool hightLight;
  final Color focusColor;

  const _FloatButton({
    required this.icon,
    required this.color,
    required this.focusColor,
    this.size = 70,
    this.iconSize = 24,
    this.hightLight = false,
  });

  @override
  Widget build(BuildContext context) {
    // original
    return Ink(
      // color: Colors.transparent,
      width: size,
      height: size,
      child: Icon(
        icon,
        color: hightLight ? focusColor : color,
        size: iconSize,
      ),
    );
  }
}
