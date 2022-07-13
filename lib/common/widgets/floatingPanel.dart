import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../global.dart';

enum PanelShape { rectangle, rounded }

enum DockType { inside, outside }

enum PanelState { open, closed }

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
  double dockOffset;
  final int dockAnimDuration;
  final Curve dockAnimCurve;
  final List<IconData> buttons;
  final void Function(int)? onPressed;
  final Color buttonFocusColor;

  final List<bool> isFocusColors = [];

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
    this.dockOffset = 20,
    this.dockAnimCurve = Curves.fastLinearToSlowEaseIn,
    this.dockAnimDuration = 300,
    this.onPressed,
    this.buttonFocusColor = Colors.red,
  })  : borderRadius = borderRadius ?? BorderRadius.circular(testBorderRadius),
        super(key: key) {
    //
    final realTestRatio = panelWidth / testPanelWidth;
    borderWidth = borderWidth * realTestRatio;
    panelWidth = panelWidth * realTestRatio;
    iconSize = iconSize * realTestRatio;
    panelOpenOffset = panelOpenOffset * realTestRatio;
    dockOffset = dockOffset * realTestRatio;
    //
    for (var i = 0; i < buttons.length; i++) {
      isFocusColors.add(false);
    }
  }

  @override
  _FloatBoxState createState() => _FloatBoxState();
}

class _FloatBoxState extends State<FloatBoxPanel> {
  // Required to set the default state to closed when the widget gets initialized;
  PanelState _panelState = PanelState.closed;
  // Default positions for the panel(0, 0]代表窗口的左上角);
  double _yOffset = 0.0;
  double _xOffset = 0.0;

  // ** PanOffset ** is used to calculate the distance from the edge of the panel
  // to the cursor, to calculate the position when being dragged;
  double _panOffsetTop = 0.0;
  double _panOffsetLeft = 0.0;

  // This is the animation duration for the panel movement, it's required to
  // dynamically change the speed depending on what the panel is being used for.
  // e.g: When panel opened or closed, the position should change in a different
  // speed than when the panel is being dragged;
  int _movementSpeed = 0;

  double? _oldYOffset; //用以复原角落ui的字段

  // Width and height of page is required for the dragging the panel;
  double get _pageWidth => MediaQuery.of(context).size.width;
  double get _pageHeight => MediaQuery.of(context).size.height;

  double _leftOffsetRatio = 1 / 2;
  double _topOffsetRatio = 1 / 3;

  late IconData _panelIcon;

  @override
  void initState() {
    _panelIcon = widget.initialPanelIcon;
    super.initState();
  }
  //#region Methods

  // Dock boundary is calculated according to the dock offset and dock type.
  double _dockBoundary() {
    debugPrint("dock boundary");
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
    if (_panelState == PanelState.open) {
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
      // debugPrint("_positionTop:$_yOffset < $_pageHeight  !!!!!!!!!");
      _oldYOffset = _yOffset;
      // 根据_panelHeight()推演
      _yOffset = 0.0 + widget.panelWidth + widget.borderWidth + _dockBoundary();
    } else {
      if (_yOffset + _panelHeight() > _pageHeight + _dockBoundary()) {
        //说明拓展后的长度超出了底边界
        final newYOffset = _pageHeight - _panelHeight() + _dockBoundary();
        if (newYOffset != _yOffset) {
          _oldYOffset = _yOffset;
          _yOffset = newYOffset;
        }
      } else {
        //说明在中端
        _oldYOffset = null;
      }
    }
  }

  // Dock Left position when open;
  double _openDockLeft() {
    if (_xOffset < (_pageWidth / 2)) {
      // If panel is docked to the left;
      debugPrint("openDockLeft");
      return widget.panelOpenOffset;
    }

    // If panel is docked to the right;
    debugPrint("openDockRight");
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
  void _forceDock() {
    debugPrint("force dock, 111 _positionTop: $_yOffset");

    if (_panelState == PanelState.closed) {
      // 调整x偏移
      double center = _xOffset + (widget.panelWidth / 2);
      _movementSpeed = widget.dockAnimDuration;
      final offsetOfLeftEdge = (center < _pageWidth / 2)
          ? -widget.panelWidth // Dock to the left edge
          : (_pageWidth - widget.panelWidth); // Dock to the right edge
      _xOffset = offsetOfLeftEdge - _dockBoundary();

      // （若原来在角落）调整y偏移
      if (_oldYOffset != null && _yOffset != _oldYOffset!) {
        _yOffset = _oldYOffset!;
      }
    } else {}

    debugPrint("force dock, 222 _positionTop: $_yOffset");
  }

  //#endregion

  @override
  Widget build(BuildContext context) {
    if (!widget.isFirstTime) {
      // update ratio for next update building
      _topOffsetRatio = _yOffset / _pageHeight;
      _leftOffsetRatio = _yOffset / _pageWidth;

      debugPrint("not first time, _positionTop: $_yOffset");
    } else {
      onPanUpdateGesture(_pageWidth - (widget.panelWidth * _leftOffsetRatio),
          _pageHeight * _topOffsetRatio);
      debugPrint("first time, _positionTop: $_yOffset");
      widget.isFirstTime = false;
    }

    return _animatedPositioned(
      child: _animatedContainer(
        child: _panel(),
      ),
    );
  }

  // #region panel body
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
        _gestureDetector(),
        _buttons(),
      ],
    );
  }

  Widget _gestureDetector() {
    // Gesture detector is required to detect the tap and drag on the panel;
    return GestureDetector(
      onPanEnd: (event) {
        debugPrint("onPanEnd");
        setState(_forceDock);
      },
      onPanStart: (event) {
        debugPrint("onPanStart");
        // Detect the offset between the top and left side of the panel and
        // x and y position of the touch(click) event;
        _panOffsetTop = event.globalPosition.dy - _yOffset;
        _panOffsetLeft = event.globalPosition.dx - _xOffset;
      },
      onPanUpdate: (event) {
        setState(
          () => onPanUpdateGesture(
              event.globalPosition.dx, event.globalPosition.dy),
        );
      },
      onTap: _onTapGesture,
      child: _FloatButton(
        focusColor: widget.panelButtonColor,
        size: widget.panelWidth,
        icon: _panelIcon,
        color: widget.panelButtonColor,
        iconSize: widget.iconSize,
      ),
    );
  }

  //#region Gesture functions

  void onPanUpdateGesture(
    double globalPositionDx,
    double globalPositionDy,
  ) {
    debugPrint("onPanUpdateGesture,$globalPositionDx,$globalPositionDy");
    // Reset Movement Speed;
    _movementSpeed = 0; //拖动时的速度需要最快，所以为0
    // Calculate the top position of the panel according to pan;
    _yOffset = globalPositionDy - _panOffsetTop;

    // Check if the top position is exceeding the dock boundaries;
    if (_yOffset < 0 + _dockBoundary()) {
      _yOffset = 0 + _dockBoundary();
    }
    if (_yOffset > (_pageHeight - _panelHeight()) - _dockBoundary()) {
      _yOffset = (_pageHeight - _panelHeight()) - _dockBoundary();
    }

    // Calculate the Left position of the panel according to pan;
    _xOffset = globalPositionDx - _panOffsetLeft;

    // Check if the left position is exceeding the dock boundaries;
    if (_xOffset < 0 + _dockBoundary()) {
      _xOffset = 0 + _dockBoundary();
    }
    if (_xOffset > (_pageWidth - widget.panelWidth) - _dockBoundary()) {
      _xOffset = (_pageWidth - widget.panelWidth) - _dockBoundary();
    }

    // 复原
    _oldYOffset = null;
  }

  void _onTapGesture() {
    setState(
      () {
        debugPrint("_onTapGesture");

        // Set the animation speed to custom duration;
        _movementSpeed = widget.panelAnimDuration;

        if (_panelState == PanelState.open) {
          _panelState = PanelState.closed;
          _forceDock();
          _panelIcon = Icons.add;
          debugPrint("Float panel closed.");
        } else {
          _panelState = PanelState.open;

          _xOffset = _openDockLeft();
          _calcPanelYOffsetWhenOpening();

          _panelIcon = CupertinoIcons.minus_circle_fill;
          debugPrint("Float Panel Open.");
        }
      },
    );
  }
  //#endregion

  Widget _buttons() {
    return Visibility(
      visible: _panelState == PanelState.open,
      child: Container(
        child: Column(
          children: List.generate(
            widget.buttons.length,
            (index) {
              return GestureDetector(
                onTap: () {
                  if (widget.onPressed != null) {
                    widget.onPressed!(index);
                  }
                },
                // child: _FloatButton(
                //   size: widget.size,
                //   icon: widget.buttons[index],
                //   color: widget.customButtonColor,
                //   iconSize: widget.iconSize,
                // ),

                child: MouseRegion(
                  onEnter: (value) {
                    setState(() {
                      widget.isFocusColors[index] = true;
                    });
                  },
                  onExit: (value) {
                    setState(() {
                      widget.isFocusColors[index] = false;
                    });
                  },
                  cursor: SystemMouseCursors.click, //Cursor type on hover
                  child: _FloatButton(
                    focusColor: widget.buttonFocusColor,
                    size: widget.panelWidth,
                    icon: widget.buttons[index],
                    color: widget.customButtonColor,
                    hightLight: widget.isFocusColors[index],
                    iconSize: widget.iconSize,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  //#endregion

}

class _FloatButton extends StatelessWidget {
  final double size;
  final Color color;
  final IconData icon;
  final double iconSize;
  final bool hightLight;
  final Color focusColor;

  _FloatButton({
    required this.icon,
    required this.focusColor,
    this.size = 70,
    this.color = Colors.white,
    this.iconSize = 24,
    this.hightLight = false,
  });

  @override
  Widget build(BuildContext context) {
    // original
    return Container(
      // color: Colors.transparent,
      width: size,
      height: size,
      child: Icon(
        icon,
        color: hightLight ? focusColor : color,
        size: iconSize,
      ),
    );

    // return InkWell(
    //   onTap: () {
    //     debugPrint("ink");
    //   },
    //   child: Ink(
    //     color: Colors.blue,
    //     width: size,
    //     height: size,
    //     child: Icon(
    //       icon,
    //       color: color,
    //       size: iconSize,
    //     ),
    //   ),
    // );

    // return Container(
    //   color: Colors.transparent,
    //   width: size,
    //   height: size,
    //   child: IconButton(
    //     icon: Icon(
    //       icon,
    //       color: color,
    //       size: iconSize,
    //     ),
    //     tooltip: 'Increase volume by 10',
    //     onPressed: () {
    //       // setState(() {
    //       //   _volume += 10;
    //       // });
    //     },
    //   ),
    // );
  }
}
