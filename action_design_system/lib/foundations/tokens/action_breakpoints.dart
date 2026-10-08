abstract final class ActionBreakpoints {
  static const double narrow = 720;

  static const double compact = 1024;

  static const double barHeight = 56;

  static const double navWidth = 240;

  static bool isNarrow(double width) => width < narrow;
  static bool isCompact(double width) => width < compact;
}
