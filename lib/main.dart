import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:keyrunner/definitions.dart';
import 'package:keyrunner/data.dart';

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
    int wpm = 250;
    if (stopwatch.elapsedMilliseconds > 50) {
      wpm = 12000 * correctlen ~/ stopwatch.elapsedMilliseconds;
    }
    int acc = correctlen * 100 ~/ totalPresses;
    gameStarted = true;
    gameOver = true;
    combo = 0;
    updateComboFontSize;
    reaction = _getReaction(wpm, acc);
    stopwatch.stop();
    timer?.cancel();
    timer = null;
    setState(() {});
  }

  void reset(double wpm) {
    gameOver = false;
    gameStarted = false;
    correctlen = 0;
    wronglen = 0;
    totalPresses = 0;
    combo = 0;
    updateComboFontSize;
    stopwatch.reset();
    text = wpm < 60
        ? entries[Random().nextInt(entries.length)]
        : difficultEntries[Random().nextInt(entries.length)];
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
    timer ??= Timer.periodic(const Duration(milliseconds: 500), (timer) {
      updateComboFontSize;
      setState(() {});
    });
    setState(() {});
  }

  void get updateComboFontSize {
    if (stopwatch.elapsedMilliseconds > 50) {
      double wpm = 12000 * correctlen / stopwatch.elapsedMilliseconds;
      comboFontSize = (combo >= comboStart && comboFX
          ? 24 + 4 * sqrt(min(combo, 100)) + 3 * sqrt(min(wpm, 250))
          : 0);
    }
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

  @override
  void dispose() {
    timer?.cancel();
    timer = null;
    stopwatch.stop();
    super.dispose();
  }

  //game data
  Stopwatch stopwatch = Stopwatch();
  Timer? timer;
  String text = "";
  Reaction reaction = const Reaction("");
  int totallen = 10;
  int correctlen = 0;
  int wronglen = 0;
  int totalPresses = 0;
  int combo = 0;
  double comboFontSize = 0;
  bool gameOver = false;
  bool gameStarted = false;
  //text getter(s)
  TextEditingController textController = TextEditingController(text: "`");
  FocusNode textFocusNode = FocusNode();
  FocusNode focusNode = FocusNode();
  //settings
  bool comboFX = true;
  bool startingLetter = true;
  bool finalMessages = true;
  //debug
  int debugIndex = 0;

  @override
  Widget build(BuildContext context) {
    var correct = text.substring(0, correctlen);
    double wpm = 0;
    if (stopwatch.elapsedMilliseconds > 50) {
      wpm = 12000 * correct.length / stopwatch.elapsedMilliseconds;
    } else if (gameOver) {
      wpm = 69420;
    }
    double acc = 0;
    if (totalPresses > 0) {
      acc = correctlen / totalPresses * 100;
    }
    var wrong = text.substring(correctlen, correctlen + wronglen);
    var remaining = text.substring(correctlen + wronglen);
    RelSize relSize = RelSize(context);
    return Center(
      widthFactor: relSize.vw / relSize.vmin,
      heightFactor: relSize.vh / relSize.vmin,
      child: SizedBox(
        width: 1080 * relSize.pixel,
        height: 1080 * relSize.pixel,
        child: Stack(
          children: [
            Cron(
              stopwatch: stopwatch,
              relSize: relSize,
            ),
            Positioned(
              top: 90 * relSize.pixel,
              left: 350 * relSize.pixel,
              child: Text(
                "WPM:${wpm.toStringAsFixed(0)}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32 * relSize.pixel,
                  fontFamily: "NotoSans",
                ),
              ),
            ),
            Positioned(
              top: 90 * relSize.pixel,
              right: 350 * relSize.pixel,
              child: Text(
                "ACC:${acc.toStringAsFixed(2)}%",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32 * relSize.pixel,
                  fontFamily: "NotoSans",
                ),
              ),
            ),
            Positioned(
              top: 160 * relSize.pixel,
              child: Row(
                children: [
                  Container(
                    height: 80 * relSize.pixel,
                    width: 1080 * relSize.pixel * correctlen / totallen,
                    color: Colors.green,
                  ),
                  Container(
                    height: 80 * relSize.pixel,
                    width: 1080 * relSize.pixel * (1 - correctlen / totallen),
                    color: Colors.red,
                  )
                ],
              ),
            ),
            Positioned(
              top: 160 * relSize.pixel,
              left: 1000 * relSize.pixel * correctlen / totallen -
                  20 * relSize.pixel,
              child: Container(
                width: relSize.pixel * 120,
                height: relSize.pixel * 81,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(relSize.pixel * 20),
                ),
                child: Icon(
                  Icons.abc,
                  size: relSize.pixel * 80,
                  color: combo >= comboStart && comboFX
                      ? comboColors[(combo - comboStart) % comboColors.length]
                      : Colors.black,
                ),
              ),
            ),
            Positioned(
              bottom: 120 * relSize.pixel,
              child: Container(
                color: Colors.white,
                width: 1080 * relSize.pixel,
                height: 720 * relSize.pixel,
                child: Padding(
                  padding: EdgeInsets.all(10 * relSize.pixel),
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
                                  color: combo >= comboStart && comboFX
                                      ? comboColors[(combo - comboStart) %
                                          comboColors.length]
                                      : const Color.fromARGB(255, 56, 142, 60),
                                  fontSize: 40 * relSize.pixel,
                                  backgroundColor: combo >= comboStart &&
                                          comboFX
                                      ? comboColors[(combo - comboStart) %
                                              comboColors.length]
                                          .withAlpha(80)
                                      : const Color.fromARGB(80, 56, 142, 60),
                                  fontFamily: "NotoSans",
                                ),
                              ),
                              TextSpan(
                                text: wrong,
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 211, 47, 47),
                                  fontSize: 40 * relSize.pixel,
                                  backgroundColor:
                                      const Color.fromARGB(80, 211, 47, 47),
                                  fontFamily: "NotoSans",
                                ),
                              ),
                              TextSpan(
                                text: remaining,
                                style: TextStyle(
                                  color: Colors.black,
                                  backgroundColor:
                                      const Color.fromARGB(20, 0, 0, 0),
                                  fontSize: 40 * relSize.pixel,
                                  fontFamily: "NotoSans",
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
                    bottom: 120 * relSize.pixel,
                    child: Container(
                      color: Colors.white,
                      width: 1080 * relSize.pixel,
                      height: 720 * relSize.pixel,
                      child: Center(
                        child: Text(
                          "Press ${text[0]} to start",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 48 * relSize.pixel,
                            fontFamily: "NotoSans",
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(),
            gameStarted && !gameOver
                ? Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: AnimatedDefaultTextStyle(
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: comboFontSize * relSize.pixel,
                      ),
                      duration: relSize.isResizing
                          ? const Duration(
                              milliseconds: 0,
                            )
                          : Duration(
                              milliseconds: 8000 ~/ (16 + sqrt(max(wpm, 250))),
                            ),
                      curve: const Cubic(.5, 0, .6, 2),
                      child: Text(
                        combo < 1000 ? "Combo: $combo" : "Combo: 999+",
                        style: TextStyle(
                          color: comboColors[
                              (combo >= comboStart ? combo - comboStart : 0) %
                                  comboColors.length],
                          fontFamily: "NotoSans",
                        ),
                      ),
                    ),
                  )
                : Container(),
            !gameStarted
                ? Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Setting(
                          relSize: relSize,
                          text: "Enable ComboFX",
                          val: comboFX,
                          setVal: (val) => setState(() {
                            comboFX = val ?? true;
                          }),
                        ),
                        Setting(
                          relSize: relSize,
                          text: "Type the starting letter",
                          val: startingLetter,
                          setVal: (val) => setState(() {
                            startingLetter = val ?? true;
                          }),
                        ),
                        Setting(
                          relSize: relSize,
                          text: "Show final messages",
                          val: finalMessages,
                          setVal: (val) => setState(() {
                            finalMessages = val ?? true;
                          }),
                        ),
                      ],
                    ),
                  )
                : Container(),
            gameOver
                ? Positioned(
                    bottom: 120 * relSize.pixel,
                    child: Container(
                      color: Colors.white,
                      width: 1080 * relSize.pixel,
                      height: 720 * relSize.pixel,
                      child: Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: finalMessages
                                ? [
                                    TextSpan(
                                      text: reaction.text,
                                      style: TextStyle(
                                        color: reaction.color,
                                        fontSize:
                                            reaction.fontSize * relSize.pixel,
                                        fontFamily: "Emoji",
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          "\n\nPress Space to play a new game",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 48 * relSize.pixel,
                                        fontFamily: "NotoSans",
                                      ),
                                    ),
                                  ]
                                : [
                                    TextSpan(
                                      text: "Press Space to play a new game",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 48 * relSize.pixel,
                                        fontFamily: "NotoSans",
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
              bottom: 120 * relSize.pixel,
              child: KeyboardListener(
                onKeyEvent: (_) {
                  textController.selection = TextSelection.collapsed(
                      offset: textController.text.length);
                },
                focusNode: focusNode,
                child: SizedBox(
                  width: 1080 * relSize.pixel,
                  height: 720 * relSize.pixel,
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
                          value.replaceFirst("`", "")[0] == text[0]) {
                        setGameStart();
                        if (!startingLetter) {
                          textController.text = "`";
                          setState(() {});
                          return;
                        }
                      }
                      //restart
                      if (gameStarted &&
                          gameOver &&
                          value.replaceFirst("`", "")[0] == " ") {
                        reset(wpm);
                      }
                      //update and gameover
                      if (gameStarted && !gameOver) {
                        if (wronglen == 0) {
                          if (value.isNotEmpty) {
                            if (value.replaceFirst("`", "")[0] ==
                                    text[correctlen] ||
                                text[correctlen] == "\n" &&
                                    value.replaceFirst("`", "")[0] == " ") {
                              totalPresses++;
                              correctlen++;
                              combo++;
                              if (combo == comboStart) {
                                updateComboFontSize;
                              }
                              if (correctlen == text.length) {
                                setGameOver();
                              }
                            } else if (value.isNotEmpty) {
                              totalPresses++;
                              wronglen++;
                              combo = 0;
                              updateComboFontSize;
                            }
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
                      }
                      textController.text = "`";
                      setState(() {});
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
  final RelSize relSize;
  const Cron({super.key, required this.stopwatch, required this.relSize});

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
      padding: EdgeInsets.only(top: 30 * widget.relSize.pixel),
      child: Center(
        heightFactor: 0,
        child: Text(
          "${(widget.stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)}s",
          style: TextStyle(
            color: Colors.white,
            fontSize: 32 * widget.relSize.pixel,
            fontFamily: "NotoSans",
          ),
        ),
      ),
    );
  }
}

class Setting extends StatelessWidget {
  final RelSize relSize;
  final String text;
  final bool val;
  final void Function(bool?) setVal;
  const Setting(
      {super.key,
      required this.relSize,
      required this.text,
      required this.val,
      required this.setVal});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24 * relSize.pixel,
            fontFamily: "NotoSans",
          ),
        ),
        SizedBox(
          width: 64 * relSize.pixel,
          height: 64 * relSize.pixel,
          child: Transform.scale(
            scale: 2 * relSize.pixel,
            child: Checkbox(
              checkColor: Colors.black,
              fillColor: MaterialStateColor.resolveWith(
                (states) => Colors.white,
              ),
              value: val,
              onChanged: setVal,
            ),
          ),
        ),
      ],
    );
  }
}
