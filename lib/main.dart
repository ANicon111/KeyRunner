import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyrunner/definitions.dart';
import 'package:keyrunner/texts.dart';

void main() {
  runApp(const Home());
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        textTheme: Typography.whiteMountainView.apply(
          fontFamily: 'Hack',
        ),
      ),
      home: const Scaffold(
        body: NotTyperacer(),
      ),
    );
  }
}

class NotTyperacer extends StatefulWidget {
  const NotTyperacer({super.key});

  @override
  State<NotTyperacer> createState() => _NotTyperacerState();
}

class _NotTyperacerState extends State<NotTyperacer> {
  void setGameOver() {
    gameStarted = true;
    gameOver = true;
    stopwatch.stop();
    setState(() {});
  }

  void reset() {
    gameOver = false;
    gameStarted = false;
    correctlen = 0;
    wronglen = 0;
    totalPresses = 0;
    stopwatch.reset();
    text = entries[Random().nextInt(entries.length)];
    totallen = text.length;
    setState(() {});
  }

  void setGameStart() {
    gameOver = false;
    gameStarted = true;
    stopwatch.start();
    setState(() {});
  }

  @override
  void initState() {
    text = entries[Random().nextInt(entries.length)];
    totallen = text.length;
    super.initState();
  }

  String text = "";
  int totallen = 10;
  int correctlen = 0;
  int wronglen = 0;
  int totalPresses = 0;
  Stopwatch stopwatch = Stopwatch();
  bool gameOver = false;
  bool gameStarted = false;
  FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    var correct = text.substring(0, correctlen);
    int words = correct.split(" ").length;
    double wpm = 0;
    if (stopwatch.elapsedMilliseconds > 100) {
      wpm = words / stopwatch.elapsedMilliseconds * 60000;
    }
    double acc = 0;
    if (totalPresses > 0) {
      acc = correctlen / totalPresses * 100;
    }
    var wrong = text.substring(correctlen, correctlen + wronglen);
    var remaining = text.substring(correctlen + wronglen);
    return Center(
      child: SizedBox(
        width: 1080 * RelSize(context).pixel,
        height: 960 * RelSize(context).pixel,
        child: Stack(
          children: [
            Cron(stopwatch: stopwatch),
            Positioned(
              top: 90 * RelSize(context).pixel,
              left: 350 * RelSize(context).pixel,
              child: Text(
                "WPM:${wpm.toStringAsFixed(0)}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32 * RelSize(context).pixel,
                  fontFamily: "Hack",
                ),
              ),
            ),
            Positioned(
              top: 90 * RelSize(context).pixel,
              right: 350 * RelSize(context).pixel,
              child: Text(
                "ACC:${acc.toStringAsFixed(2)}%",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32 * RelSize(context).pixel,
                  fontFamily: "Hack",
                ),
              ),
            ),
            Positioned(
              top: 160 * RelSize(context).pixel,
              child: Row(
                children: [
                  Container(
                    height: 80 * RelSize(context).pixel,
                    width:
                        1080 * RelSize(context).pixel * correctlen / totallen,
                    color: Colors.green,
                  ),
                  Container(
                    height: 80 * RelSize(context).pixel,
                    width: 1080 *
                        RelSize(context).pixel *
                        (1 - correctlen / totallen),
                    color: Colors.red,
                  )
                ],
              ),
            ),
            Positioned(
              top: 160 * RelSize(context).pixel,
              left: 1000 * RelSize(context).pixel * correctlen / totallen,
              child: Icon(
                Icons.abc,
                size: RelSize(context).pixel * 80,
              ),
            ),
            Positioned(
              bottom: 0,
              child: KeyboardListener(
                onKeyEvent: (value) {
                  if (gameStarted &&
                      gameOver &&
                      value.logicalKey == LogicalKeyboardKey.space) {
                    reset();
                    return;
                  }
                  if (!gameStarted && value.character == text[0]) {
                    setGameStart();
                  }
                  if (gameStarted &&
                      !gameOver &&
                      value.logicalKey != LogicalKeyboardKey.shiftLeft &&
                      value.runtimeType == KeyDownEvent) {
                    if (wronglen == 0) {
                      totalPresses++;
                      if (value.character == text[correctlen]) {
                        correctlen++;
                        if (correctlen == text.length) {
                          setGameOver();
                          return;
                        }
                      } else if (value.logicalKey !=
                          LogicalKeyboardKey.backspace) {
                        totalPresses++;
                        wronglen++;
                      }
                    } else {
                      if (value.logicalKey == LogicalKeyboardKey.backspace) {
                        wronglen--;
                      } else {
                        if (correctlen + wronglen < text.length) {
                          wronglen++;
                        }
                      }
                    }
                    setState(() {});
                  }
                },
                focusNode: focusNode,
                autofocus: true,
                child: Container(
                  color: Colors.white,
                  width: 1080 * RelSize(context).pixel,
                  height: 720 * RelSize(context).pixel,
                  child: Padding(
                    padding: EdgeInsets.all(10 * RelSize(context).pixel),
                    child: Flex(
                      direction: Axis.horizontal,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: correct,
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontSize: 32 * RelSize(context).pixel,
                                    backgroundColor: Colors.green.shade200,
                                    fontFamily: "Hack",
                                  ),
                                ),
                                TextSpan(
                                  text: wrong,
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 32 * RelSize(context).pixel,
                                    backgroundColor: Colors.red.shade200,
                                    fontFamily: "Hack",
                                  ),
                                ),
                                TextSpan(
                                  text: remaining,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 32 * RelSize(context).pixel,
                                    fontFamily: "Hack",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            !gameStarted
                ? Positioned(
                    bottom: 0,
                    child: Container(
                      color: Colors.white,
                      width: 1080 * RelSize(context).pixel,
                      height: 720 * RelSize(context).pixel,
                      child: Center(
                        child: Text(
                          "Press ${text[0]} to start",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 32 * RelSize(context).pixel,
                            fontFamily: "Hack",
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(),
            gameOver
                ? Positioned(
                    bottom: 0,
                    child: Container(
                      color: Colors.white,
                      width: 1080 * RelSize(context).pixel,
                      height: 720 * RelSize(context).pixel,
                      child: Center(
                        child: Text(
                          "Press Space to play a new game",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 32 * RelSize(context).pixel,
                            fontFamily: "Hack",
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}

class Cron extends StatefulWidget {
  final Stopwatch stopwatch;
  const Cron({super.key, required this.stopwatch});

  @override
  State<Cron> createState() => _CronState();
}

class _CronState extends State<Cron> {
  Timer? timer;
  @override
  void initState() {
    timer ??= Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 30 * RelSize(context).pixel),
      child: Center(
        heightFactor: 0,
        child: Text(
          "${(widget.stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)}s",
          style: TextStyle(
            color: Colors.white,
            fontSize: 32 * RelSize(context).pixel,
            fontFamily: "Hack",
          ),
        ),
      ),
    );
  }
}
