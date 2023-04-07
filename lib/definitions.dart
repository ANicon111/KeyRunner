import 'dart:math';

import 'package:flutter/material.dart';

class RelSize {
  final BuildContext context;
  RelSize(this.context);

  double get vw =>
      (MediaQuery.of(context).size.width -
          MediaQuery.of(context).viewInsets.left -
          MediaQuery.of(context).viewInsets.right) /
      100;

  double get vh =>
      (MediaQuery.of(context).size.height -
          MediaQuery.of(context).viewInsets.top -
          MediaQuery.of(context).viewInsets.bottom) /
      100;

  double get vmin => min(vw, vh);

  double get vmax => max(vw, vh);

  double get pixel => max(min(vw, vh) / 10.8, 0.2);
}
