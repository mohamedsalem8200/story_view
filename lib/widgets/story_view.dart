import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';

import '../controller/story_controller.dart';
import '../utils.dart';
import 'story_image.dart';
import 'story_video.dart';

/// Indicates where the progress indicators should be placed.
enum ProgressPosition { top, bottom, none }

/// This is used to specify the height of the progress indicator. Inline stories
/// should use [small]
enum IndicatorHeight { small, medium, large }

/// This is a representation of a story item (or page).
class StoryItem {
  /// Specifies how long the page should be displayed. It should be a reasonable
  /// amount of time greater than 0 milliseconds.
  final Duration duration;

  /// Has this page been shown already? This is used to indicate that the page
  /// has been displayed. If some pages are supposed to be skipped in a story,
  /// mark them as shown `shown = true`.
  ///
  /// However, during initialization of the story view, all pages after the
  /// last unshown page will have their `shown` attribute altered to false. This
  /// is because the next item to be displayed is taken by the last unshown
  /// story item.
  bool shown;

  /// The page content
  final Widget view;

  StoryItem(this.view, {
    required this.duration,
    this.shown = false,
  });

  /// Short hand to create text-only page.
  static StoryItem text({
    required String title,
    required Color backgroundColor,
    Key? key,
    TextStyle? textStyle,
    bool shown = false,
    bool roundedTop = false,
    bool roundedBottom = false,
    EdgeInsetsGeometry? textOuterPadding,
    Duration? duration,
  }) {
    double contrast = ContrastHelper.contrast([
      backgroundColor.r,
      backgroundColor.g,
      backgroundColor.b,
    ], [
      255.0,
      255.0,
      255.0
    ] /** white text */);

    return StoryItem(
      Container(
        key: key,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(roundedTop ? 8 : 0),
            bottom: Radius.circular(roundedBottom ? 8 : 0),
          ),
        ),
        padding: textOuterPadding ??
            const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
        child: Center(
          child: Text(
            title,
            style: textStyle?.copyWith(
              color: contrast > 1.8 ? Colors.white : Colors.black,
            ) ??
                TextStyle(
                  color: contrast > 1.8 ? Colors.white : Colors.black,
                  fontSize: 18,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      shown: shown,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  /// Factory constructor for page images.
  factory StoryItem.pageImage({
    required String url,
    required StoryController controller,
    Key? key,
    BoxFit imageFit = BoxFit.fitWidth,
    Widget? caption,
    bool shown = false,
    Map<String, dynamic>? requestHeaders,
    Widget? loadingWidget,
    Widget? errorWidget,
    EdgeInsetsGeometry? captionOuterPadding,
    Duration? duration,
  }) {
    return StoryItem(
      Container(
        key: key,
        color: Colors.black,
        child: Stack(
          children: <Widget>[
            StoryImage.url(
              url,
              controller: controller,
              fit: imageFit,
              requestHeaders: requestHeaders,
              loadingWidget: loadingWidget,
              errorWidget: errorWidget,
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  color: caption != null ? Colors.black54 : Colors.transparent,
                  child: caption ?? const SizedBox.shrink(),
                ),
              ),
            )
          ],
        ),
      ),
      shown: shown,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  /// Shorthand for creating inline image.
  factory StoryItem.inlineImage({
    required String url,
    Text? caption,
    required StoryController controller,
    Key? key,
    BoxFit imageFit = BoxFit.cover,
    Map<String, dynamic>? requestHeaders,
    bool shown = false,
    bool roundedTop = true,
    bool roundedBottom = false,
    Widget? loadingWidget,
    Widget? errorWidget,
    EdgeInsetsGeometry? captionOuterPadding,
    Duration? duration,
  }) {
    return StoryItem(
      ClipRRect(
        key: key,
        child: Container(
          color: Colors.grey[100],
          child: Container(
            color: Colors.black,
            child: Stack(
              children: <Widget>[
                StoryImage.url(
                  url,
                  controller: controller,
                  fit: imageFit,
                  requestHeaders: requestHeaders,
                  loadingWidget: loadingWidget,
                  errorWidget: errorWidget,
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: captionOuterPadding ??
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Align(
                    alignment: AlignmentDirectional.bottomStart,
                    child: Container(
                      child: caption ?? const SizedBox.shrink(),
                      width: double.infinity,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(roundedTop ? 8 : 0),
          bottom: Radius.circular(roundedBottom ? 8 : 0),
        ),
      ),
      shown: shown,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  /// Shorthand for creating page video.
  factory StoryItem.pageVideo(String url, {
    required StoryController controller,
    Key? key,
    Duration? duration,
    BoxFit imageFit = BoxFit.fitWidth,
    Widget? caption,
    bool shown = false,
    Map<String, dynamic>? requestHeaders,
    Widget? loadingWidget,
    Widget? errorWidget,
  }) {
    return StoryItem(
      Container(
        key: key,
        color: Colors.black,
        child: Stack(
          children: <Widget>[
            StoryVideo.url(
              url,
              controller: controller,
              requestHeaders: requestHeaders,
              loadingWidget: loadingWidget,
              errorWidget: errorWidget,
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  color: caption != null ? Colors.black54 : Colors.transparent,
                  child: caption ?? const SizedBox.shrink(),
                ),
              ),
            )
          ],
        ),
      ),
      shown: shown,
      duration: duration ?? const Duration(seconds: 10),
    );
  }

  /// Shorthand for creating a story item from an image provider.
  factory StoryItem.pageProviderImage(ImageProvider image, {
    Key? key,
    BoxFit imageFit = BoxFit.fitWidth,
    String? caption,
    bool shown = false,
    Duration? duration,
  }) {
    return StoryItem(
      Container(
        key: key,
        color: Colors.black,
        child: Stack(
          children: <Widget>[
            Center(
              child: Image(
                image: image,
                height: double.infinity,
                width: double.infinity,
                fit: imageFit,
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(
                    bottom: 24,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  color:
                      caption != null ? Colors.black54 : Colors.transparent,
                  child: caption != null
                      ? Text(
                          caption,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            )
          ],
        ),
      ),
      shown: shown,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  /// Shorthand for creating an inline story item from an image provider.
  factory StoryItem.inlineProviderImage(ImageProvider image, {
    Key? key,
    Text? caption,
    bool shown = false,
    bool roundedTop = true,
    bool roundedBottom = false,
    Duration? duration,
  }) {
    return StoryItem(
      Container(
        key: key,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(roundedTop ? 8 : 0),
            bottom: Radius.circular(roundedBottom ? 8 : 0),
          ),
          image: DecorationImage(
            image: image,
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Align(
            alignment: AlignmentDirectional.bottomStart,
            child: Container(
              child: caption == null ? const SizedBox() : caption,
              width: double.infinity,
            ),
          ),
        ),
      ),
      shown: shown,
      duration: duration ?? const Duration(seconds: 3),
    );
  }
}

/// Widget to display stories like Whatsapp/Instagram.
class StoryView extends StatefulWidget {
  /// The pages to displayed.
  final List<StoryItem?> storyItems;

  /// Callback for when a full cycle of story is shown.
  final VoidCallback? onComplete;

  /// Callback for when a vertical swipe gesture is detected.
  final Function(Direction?)? onVerticalSwipeComplete;

  /// Callback for when a story and it index is currently being shown.
  final void Function(StoryItem storyItem, int index)? onStoryShow;

  /// Where the progress indicator should be placed.
  final ProgressPosition progressPosition;

  /// Should the story be repeated forever?
  final bool repeat;

  /// Inline mode?
  final bool inline;

  /// Controls the playback of the stories
  final StoryController controller;

  /// Indicator Color
  final Color? indicatorColor;

  /// Indicator Foreground Color
  final Color? indicatorForegroundColor;

  /// Determine the height of the indicator
  final IndicatorHeight indicatorHeight;

  /// Use this if you want to give outer padding to the indicator
  final EdgeInsetsGeometry indicatorOuterPadding;

  /// Force text direction if needed, otherwise it follows app direction.
  final TextDirection? textDirection;

  StoryView({
    required this.storyItems,
    required this.controller,
    this.onComplete,
    this.onStoryShow,
    this.progressPosition = ProgressPosition.top,
    this.repeat = false,
    this.inline = false,
    this.onVerticalSwipeComplete,
    this.indicatorColor,
    this.indicatorForegroundColor,
    this.indicatorHeight = IndicatorHeight.large,
    this.indicatorOuterPadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.textDirection,
  });

  @override
  State<StatefulWidget> createState() {
    return StoryViewState();
  }
}

class StoryViewState extends State<StoryView> with TickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _currentAnimation;
  Timer? _nextDebouncer;

  StreamSubscription<PlaybackState>? _playbackSubscription;

  VerticalDragInfo? verticalDragInfo;

  StoryItem? get _currentStory {
    return widget.storyItems.firstWhereOrNull((it) => !it!.shown);
  }

  Widget get _currentView {
    var item = widget.storyItems.firstWhereOrNull((it) => !it!.shown);
    item ??= widget.storyItems.last;
    return item?.view ?? Container();
  }

  @override
  void initState() {
    super.initState();

    // All pages after the first unshown page should have their shown value as false
    final firstPage = widget.storyItems.firstWhereOrNull((it) => !it!.shown);
    if (firstPage == null) {
      for (var it2 in widget.storyItems) {
        it2!.shown = false;
      }
    } else {
      final lastShownPos = widget.storyItems.indexOf(firstPage);
      for (var it in widget.storyItems.sublist(lastShownPos)) {
        it!.shown = false;
      }
    }

    _playbackSubscription =
        widget.controller.playbackNotifier.listen((playbackStatus) {
          switch (playbackStatus) {
            case PlaybackState.play:
              _removeNextHold();
              _animationController?.forward();
              break;

            case PlaybackState.pause:
              _holdNext();
              _animationController?.stop(canceled: false);
              break;

            case PlaybackState.next:
              _removeNextHold();
              _goForward();
              break;

            case PlaybackState.previous:
              _removeNextHold();
              _goBack();
              break;
          }
        });

    _play();
  }

  @override
  void dispose() {
    _clearDebouncer();
    _animationController?.dispose();
    _playbackSubscription?.cancel();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _play() {
    _animationController?.dispose();
    final storyItem = widget.storyItems.firstWhere((it) => !it!.shown)!;
    final storyItemIndex = widget.storyItems.indexOf(storyItem);

    if (widget.onStoryShow != null) {
      widget.onStoryShow!(storyItem, storyItemIndex);
    }

    _animationController =
        AnimationController(duration: storyItem.duration, vsync: this);

    _animationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        storyItem.shown = true;
        if (widget.storyItems.last != storyItem) {
          _beginPlay();
        } else {
          _onComplete();
        }
      }
    });

    _currentAnimation = Tween(begin: 0.0, end: 1.0).animate(_animationController!);

    widget.controller.play();
  }

  void _beginPlay() {
    setState(() {});
    _play();
  }

  void _onComplete() {
    if (widget.onComplete != null) {
      widget.controller.pause();
      widget.onComplete!();
    }

    if (widget.repeat) {
      for (var it in widget.storyItems) {
        it!.shown = false;
      }
      _beginPlay();
    }
  }

  void _goBack() {
    _animationController!.stop();

    if (_currentStory == null) {
      widget.storyItems.last!.shown = false;
    }

    if (_currentStory == widget.storyItems.first) {
      _beginPlay();
    } else {
      _currentStory!.shown = false;
      int lastPos = widget.storyItems.indexOf(_currentStory);
      final previous = widget.storyItems[lastPos - 1]!;
      previous.shown = false;
      _beginPlay();
    }
  }

  void _goForward() {
    if (_currentStory != widget.storyItems.last) {
      _animationController!.stop();
      final _last = _currentStory;
      if (_last != null) {
        _last.shown = true;
        if (_last != widget.storyItems.last) {
          _beginPlay();
        }
      }
    } else {
      _animationController!.animateTo(1.0, duration: const Duration(milliseconds: 10));
    }
  }

  void _clearDebouncer() {
    _nextDebouncer?.cancel();
    _nextDebouncer = null;
  }

  void _removeNextHold() {
    _nextDebouncer?.cancel();
    _nextDebouncer = null;
  }

  void _holdNext() {
    _nextDebouncer?.cancel();
    _nextDebouncer = Timer(const Duration(milliseconds: 500), () {});
  }

  @override
  Widget build(BuildContext context) {
    final effectiveDirection = widget.textDirection ?? Directionality.of(context);

    return Directionality(
      textDirection: effectiveDirection,
      child: Container(
        color: Colors.white,
        child: Stack(
          children: <Widget>[
            _currentView,
            Visibility(
              visible: widget.progressPosition != ProgressPosition.none,
              child: Align(
                alignment: widget.progressPosition == ProgressPosition.top
                    ? Alignment.topCenter
                    : Alignment.bottomCenter,
                child: SafeArea(
                  bottom: widget.inline ? false : true,
                  child: Container(
                    padding: widget.indicatorOuterPadding,
                    child: PageBar(
                      widget.storyItems
                          .map((it) => PageData(it!.duration, it.shown))
                          .toList(),
                      _currentAnimation,
                      key: UniqueKey(),
                      indicatorHeight: widget.indicatorHeight,
                      indicatorColor: widget.indicatorColor,
                      indicatorForegroundColor: widget.indicatorForegroundColor,
                      textDirection: effectiveDirection,
                    ),
                  ),
                ),
              ),
            ),

            /// "Next" area at end side (right in LTR, left in RTL)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              heightFactor: 1,
              child: GestureDetector(
                onTapDown: (details) {
                  widget.controller.pause();
                },
                onTapCancel: () {
                  widget.controller.play();
                },
                onTapUp: (details) {
                  if (_nextDebouncer?.isActive == false) {
                    widget.controller.play();
                  } else {
                    widget.controller.next();
                  }
                },
                onVerticalDragStart: widget.onVerticalSwipeComplete == null
                    ? null
                    : (details) {
                        widget.controller.pause();
                      },
                onVerticalDragCancel: widget.onVerticalSwipeComplete == null
                    ? null
                    : () {
                        widget.controller.play();
                      },
                onVerticalDragUpdate: widget.onVerticalSwipeComplete == null
                    ? null
                    : (details) {
                        verticalDragInfo ??= VerticalDragInfo();
                        verticalDragInfo!.update(details.primaryDelta!);
                      },
                onVerticalDragEnd: widget.onVerticalSwipeComplete == null
                    ? null
                    : (details) {
                        widget.controller.play();
                        if (!verticalDragInfo!.cancel &&
                            widget.onVerticalSwipeComplete != null) {
                          widget.onVerticalSwipeComplete!(
                              verticalDragInfo!.direction);
                        }
                        verticalDragInfo = null;
                      },
              ),
            ),

            /// "Previous" area at start side (left in LTR, right in RTL)
            Align(
              alignment: AlignmentDirectional.centerStart,
              heightFactor: 1,
              child: SizedBox(
                width: 70,
                child: GestureDetector(
                  onTap: () {
                    widget.controller.previous();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Capsule holding the duration and shown property of each story.
class PageData {
  Duration duration;
  bool shown;

  PageData(this.duration, this.shown);
}

/// Horizontal bar displaying a row of [StoryProgressIndicator]
class PageBar extends StatefulWidget {
  final List<PageData> pages;
  final Animation<double>? animation;
  final IndicatorHeight indicatorHeight;
  final Color? indicatorColor;
  final Color? indicatorForegroundColor;
  final TextDirection textDirection;

  PageBar(this.pages,
      this.animation, {
      this.indicatorHeight = IndicatorHeight.large,
      this.indicatorColor,
      this.indicatorForegroundColor,
      required this.textDirection,
      Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PageBarState();
  }
}

class PageBarState extends State<PageBar> {
  double spacing = 4;

  @override
  void initState() {
    super.initState();

    int count = widget.pages.length;
    spacing = (count > 15) ? 2 : ((count > 10) ? 3 : 4);

    widget.animation!.addListener(() {
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  bool isPlaying(PageData page) {
    return widget.pages.firstWhereOrNull((it) => !it.shown) == page;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: widget.textDirection,
      child: Row(
        children: widget.pages.map((it) {
          return Expanded(
            child: Container(
              padding: EdgeInsetsDirectional.only(
                end: widget.pages.last == it ? 0 : spacing,
              ),
              child: StoryProgressIndicator(
                isPlaying(it) ? widget.animation!.value : (it.shown ? 1 : 0),
                indicatorHeight: widget.indicatorHeight == IndicatorHeight.large
                    ? 5
                    : widget.indicatorHeight == IndicatorHeight.medium
                        ? 3
                        : 2,
                indicatorColor: widget.indicatorColor,
                indicatorForegroundColor: widget.indicatorForegroundColor,
                textDirection: widget.textDirection,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Custom progress bar with rounded sides.
class StoryProgressIndicator extends StatelessWidget {
  /// From `0.0` to `1.0`, determines the progress of the indicator
  final double value;
  final double indicatorHeight;
  final Color? indicatorColor;
  final Color? indicatorForegroundColor;
  final TextDirection textDirection;

  StoryProgressIndicator(this.value, {
    this.indicatorHeight = 5,
    this.indicatorColor,
    this.indicatorForegroundColor,
    this.textDirection = TextDirection.ltr,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.fromHeight(indicatorHeight),
      foregroundPainter: IndicatorOval(
        indicatorForegroundColor ?? Colors.white.withValues(alpha: 0.8),
        value,
        textDirection,
      ),
      painter: IndicatorOval(
        indicatorColor ?? Colors.white.withValues(alpha: 0.4),
        1.0,
        textDirection,
      ),
    );
  }
}

class IndicatorOval extends CustomPainter {
  final Color color;
  final double widthFactor;
  final TextDirection textDirection;

  IndicatorOval(this.color, this.widthFactor, this.textDirection);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    // Fill from start side: left in LTR, right in RTL
    final w = size.width * widthFactor;
    final rect = (textDirection == TextDirection.rtl)
        ? Rect.fromLTWH(size.width - w, 0, w, size.height)
        : Rect.fromLTWH(0, 0, w, size.height);

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

/// Concept source: https://stackoverflow.com/a/9733420
class ContrastHelper {
  static double luminance(double? r, double? g, double? b) {
    final a = [r, g, b].map((it) {
      double value = it!.toDouble() / 255.0;
      return value <= 0.03928
          ? value / 12.92
          : pow((value + 0.055) / 1.055, 2.4);
    }).toList();

    return a[0] * 0.2126 + a[1] * 0.7152 + a[2] * 0.0722;
  }

  static double contrast(rgb1, rgb2) {
    return luminance(rgb2[0], rgb2[1], rgb2[2]) /
        luminance(rgb1[0], rgb1[1], rgb1[2]);
  }
}
