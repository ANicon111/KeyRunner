import 'dart:math';

import 'package:flutter/material.dart';

Size oldSize = const Size(0, 0);

class RelSize {
  final BuildContext context;
  late bool isResizing;
  late double vw;
  late double vh;
  RelSize(this.context) {
    Size size = MediaQuery.of(context).size;
    isResizing = (oldSize != size);
    oldSize = MediaQuery.of(context).size;
    vw = (MediaQuery.of(context).size.width -
            MediaQuery.of(context).viewInsets.left -
            MediaQuery.of(context).viewInsets.right) /
        100;
    vh = (MediaQuery.of(context).size.height -
            MediaQuery.of(context).viewInsets.top -
            MediaQuery.of(context).viewInsets.bottom) /
        100;
  }

  double get vmin => min(vw, vh);

  double get vmax => max(vw, vh);

  double get pixel => max(min(vw, vh) / 10.8, 0.2);
}
