import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
        resizeToAvoidBottomInset: false,
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
  Reaction _getReaction(int wpm, int acc) {
    if (wpm > 250) wpm = 250;
    if (wpm < 0) wpm = 0;
    if (acc > 100) acc = 100;
    if (acc < 0) acc = 0;
    while (reactions[wpm] == null) {
      wpm--;
    }
    while (reactions[wpm]?[acc] == null) {
      acc--;
    }
    return reactions[wpm]![acc]![
        Random().nextInt(reactions[wpm]?[acc]!.length ?? 0)];
  }

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
    if (kDebugMode) {
      debugIndex = debugIndex % debugText.length;
      text = debugText[debugIndex++];
    }
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
    if (kDebugMode) {
      debugIndex = debugIndex % debugText.length;
      text = debugText[debugIndex++];
    }
    totallen = text.length;
    super.initState();
  }

  String text = "";
  int totallen = 10;
  int correctlen = 0;
  int wronglen = 0;
  int totalPresses = 0;
  int debugIndex = 0;
  Stopwatch stopwatch = Stopwatch();
  bool gameOver = false;
  bool gameStarted = false;
  FocusNode focusNode = FocusNode();
  FocusNode textFocusNode = FocusNode();
  TextEditingController textController = TextEditingController(text: "`");

  @override
  Widget build(BuildContext context) {
    var correct = text.substring(0, correctlen);
    int words = correct.split(" ").length;
    double wpm = 0;
    if (stopwatch.elapsedMilliseconds > 100) {
      wpm = 60000 * words / stopwatch.elapsedMilliseconds;
    }
    double acc = 0;
    if (totalPresses > 0) {
      acc = correctlen / totalPresses * 100;
    }
    var wrong = text.substring(correctlen, correctlen + wronglen);
    var remaining = text.substring(correctlen + wronglen);
    Reaction reaction = const Reaction("");
    if (gameOver) {
      reaction = _getReaction(wpm.toInt(), acc.toInt());
    }
    return Center(
      widthFactor: RelSize(context).vw / RelSize(context).vmin,
      heightFactor: RelSize(context).vh / RelSize(context).vmin,
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
                          textAlign: TextAlign.justify,
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
                                  backgroundColor: Colors.grey.shade200,
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
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: reaction.text,
                                style: TextStyle(
                                  color: reaction.color,
                                  fontSize: reaction.fontSize *
                                      RelSize(context).pixel,
                                  fontFamily: "Hack",
                                ),
                              ),
                              TextSpan(
                                text: "\n\nPress Space to play a new game",
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
                    ),
                  )
                : Container(),
            Positioned(
              bottom: 0,
              child: KeyboardListener(
                onKeyEvent: (_) {
                  textController.selection = TextSelection.collapsed(
                      offset: textController.text.length);
                },
                focusNode: focusNode,
                child: SizedBox(
                  width: 1080 * RelSize(context).pixel,
                  height: 720 * RelSize(context).pixel,
                  child: TextField(
                    enableInteractiveSelection: false,
                    maxLines: 2,
                    autofocus: true,
                    focusNode: textFocusNode,
                    style: const TextStyle(
                      fontSize: 0,
                    ),
                    textAlign: TextAlign.justify,
                    onChanged: (_) {
                      String value = textController.value.text;
                      if (kDebugMode) {
                        print(value);
                      }
                      //start
                      if (!gameStarted &&
                          value.replaceFirst("`", "") == text[0]) {
                        setGameStart();
                      }
                      //restart
                      if (gameStarted &&
                          gameOver &&
                          value.replaceFirst("`", "") == " ") {
                        reset();
                      }
                      //update and gameover
                      if (gameStarted && !gameOver) {
                        if (wronglen == 0) {
                          if (value.replaceFirst("`", "") == text[correctlen] ||
                              text[correctlen] == "\n" &&
                                  value.replaceFirst("`", "") == " ") {
                            totalPresses++;
                            correctlen++;
                            if (correctlen == text.length) {
                              setGameOver();
                            }
                          } else if (value.isNotEmpty) {
                            totalPresses++;
                            wronglen++;
                          }
                        } else {
                          if (value.isEmpty) {
                            wronglen--;
                          } else {
                            if (correctlen + wronglen < text.length) {
                              totalPresses++;
                              wronglen++;
                            }
                          }
                        }
                        setState(() {});
                      }
                      textController.text = "`";
                    },
                    controller: textController,
                    decoration: const InputDecoration(
                      fillColor: Color.fromARGB(0, 0, 0, 0),
                      focusColor: Color.fromARGB(0, 0, 0, 0),
                      hoverColor: Color.fromARGB(0, 0, 0, 0),
                      border: InputBorder.none,
                    ),
                    cursorWidth: 0,
                  ),
                ),
              ),
            )
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
