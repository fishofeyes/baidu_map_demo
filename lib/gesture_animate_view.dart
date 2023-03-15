import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

enum ScrollEnum {
  top,
  middle,
}

const kVelocityMin = 320.0;

/*

Stack(
  fit: StackFit.expand,
  children: [
    Container(color: Colors.black),
    GestureAnimateView(
      child: DefaultTabController(
        length: 1,
        child: TabBarView(
          children: [
            Container(color: Colors.red),
            Container(color: Colors.blue),
            Container(color: Colors.pink),
          ],
        ),
      ),
      headView: Container(
        height: 40,
        width: double.infinity,
        alignment: Alignment.center,
        color: Colors.yellow,
        child: Text("----拖拽头-----"),
      ),
    ),
  ],
),


 */
class GestureAnimateView extends StatefulWidget {
  final Widget child;
  final Widget? headView;

  // 值越大缩在底部的部分就越小
  final double bottomHeight;
  final Function(ScrollEnum e)? onScrollCall;

  const GestureAnimateView({
    Key? key,
    required this.child,
    this.bottomHeight = 600.0,
    this.headView,
    this.onScrollCall,
  }) : super(key: key);

  @override
  State<GestureAnimateView> createState() => _GestureAnimateViewState();
}

class _GestureAnimateViewState extends State<GestureAnimateView> with TickerProviderStateMixin {
  final double minHeight = 0;
  double bottomHeight = 300;
  double maxHeight = 600;

  double _offsetY = 300;
  bool isScroll = true;
  ScrollEnum _scrollEnum = ScrollEnum.middle;
  final _velocityTracker = VelocityTracker.withKind(PointerDeviceKind.unknown);
  late Animation<double> _animation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _animation = Tween(begin: 1.0, end: 2.0).animate(_animationController);
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _offsetY = _getPinHeight();
        isScroll = true;
        _animationController.reset();
      }
    });
    bottomHeight = widget.bottomHeight;
    maxHeight = widget.bottomHeight;
    _offsetY = widget.bottomHeight;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // print(_scrollController.offset);
  }

  void _scrollEnd() {
    isScroll = false;
    if (_animationController.isAnimating) return;
    final vlc = _velocityTracker.getVelocity();
    if (vlc.pixelsPerSecond.dy.abs() > kVelocityMin) {
      if (vlc.pixelsPerSecond.dy > 0) {
        if (_scrollEnum == ScrollEnum.top) {
          _scrollEnum = ScrollEnum.middle;
          if (widget.onScrollCall != null) widget.onScrollCall!(_scrollEnum);
        } else if (_scrollEnum == ScrollEnum.middle) {
          // _scrollEnum = ScrollEnum.bottom;
        }
        _startAnimation(_offsetY, _getPinHeight());
      } else {
        if (_scrollEnum == ScrollEnum.middle) {
          _scrollEnum = ScrollEnum.top;
          if (widget.onScrollCall != null) widget.onScrollCall!(_scrollEnum);
        }
        _startAnimation(_offsetY, _getPinHeight());
      }
    } else {
      final double offset = _offsetY;
      final double _top = (offset - minHeight).abs();
      final double _middle = (offset - bottomHeight).abs();
      final double _bottom = (offset - maxHeight).abs();
      if (_top < _middle && _top < _bottom) {
        _scrollEnum = ScrollEnum.top;
        if (widget.onScrollCall != null) widget.onScrollCall!(_scrollEnum);
      } else if (_middle < _top && _middle < _bottom) {
        _scrollEnum = ScrollEnum.middle;
        if (widget.onScrollCall != null) widget.onScrollCall!(_scrollEnum);
      }
      _startAnimation(_offsetY, _getPinHeight());
    }
  }

  double _getPinHeight() {
    switch (_scrollEnum) {
      case ScrollEnum.top:
        return minHeight;
      case ScrollEnum.middle:
        return bottomHeight;
      // case ScrollEnum.bottom:
      //   return maxHeight;
      default:
        return bottomHeight;
    }
  }

  void _startAnimation(double from, double to) {
    _animation = Tween<double>(
      begin: from,
      end: to,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.fastLinearToSlowEaseIn),
    );
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned.fill(
          top: isScroll ? _offsetY : _animation.value,
          child: Listener(
            onPointerDown: (e) {
              _velocityTracker.addPosition(e.timeStamp, e.position);
              isScroll = true;
              _offsetY = _getPinHeight();
            },
            onPointerMove: (e) {
              if (e.delta.dx.abs() > e.delta.dy.abs()) return;
              isScroll = true;
              _velocityTracker.addPosition(e.timeStamp, e.position);
              double temp = _offsetY;
              if (_scrollEnum == ScrollEnum.middle && e.delta.dy > 0) return;
              temp += e.delta.dy;
              if (temp < minHeight) temp = minHeight;
              if (temp > maxHeight) temp = maxHeight;
              setState(() {
                _offsetY = temp;
              });
            },
            onPointerCancel: (e) => _scrollEnd(),
            onPointerUp: (e) => _scrollEnd(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                widget.headView ??
                    Container(
                      height: 27,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xff242424),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, -1),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xff4a4a4a),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                Expanded(child: widget.child),
              ],
            ),
          ),
        );
      },
    );
  }
}
