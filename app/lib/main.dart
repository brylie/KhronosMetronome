import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// number of milliseconds in a minute
const minute = 1000 * 60;

void main() {
  runApp(const AeMetronome());
}

class AeMetronome extends StatelessWidget {
  const AeMetronome({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Æ Khronos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const MetronomePage(title: 'Æ Khronos'),
    );
  }
}

class MetronomePage extends StatefulWidget {
  const MetronomePage({super.key, required this.title});

  final String title;

  @override
  State<MetronomePage> createState() => MetronomePageState();
}

// this is made public so it is visible in the unit test
// Note: there may be a better way to test private state
class MetronomePageState extends State<MetronomePage> {
  double _tempo = 80;

  // Used to toggle metronome click
  // It is set to be a public member, so it is visible in the unit test
  bool soundEnabled = false;

  final double _minimumTempoValue = 30;
  final double _maximumTempoValue = 200;
  final double _tempoIncrement = 10;

  late double _tempoDivisions;

  late Timer _timer;

  final ButtonStyle _buttonStyle = ButtonStyle(
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );

  int _calculateTimerInterval(int tempo) {
    double timerInterval = minute / tempo;

    return timerInterval.round();
  }

  void _handleTimer(Timer timer) {
    if (soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  Timer _scheduleTimer([int milliseconds = 10000]) {
    return Timer.periodic(Duration(milliseconds: milliseconds), _handleTimer);
  }

  @override
  void initState() {
    super.initState();

    // Calculate tempo divisions for slider
    // Note: this is the only way I could find to calculate a value
    // based on other state values when the widget loads
    _tempoDivisions =
        (_maximumTempoValue - _minimumTempoValue) / _tempoIncrement;

    _timer = _scheduleTimer(_calculateTimerInterval(_tempo.round()));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _tempo.round().toString(),
              style: Theme.of(context).textTheme.headline1,
            ),
            Slider(
              value: _tempo,
              min: _minimumTempoValue,
              max: _maximumTempoValue,
              divisions: _tempoDivisions.round(),
              label: _tempo.round().toString(),
              onChanged: (double value) {
                _timer.cancel();

                setState(() {
                  _tempo = value;
                });

                _timer = _scheduleTimer(
                  _calculateTimerInterval(_tempo.round()),
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                OutlinedButton(
                  style: _buttonStyle,
                  onPressed: () {
                    setState(() {
                      soundEnabled = true;
                    });
                  },
                  child: const Icon(
                    Icons.play_arrow,
                  ),
                ),
                OutlinedButton(
                  style: _buttonStyle,
                  onPressed: () {
                    setState(() {
                      soundEnabled = false;
                    });
                  },
                  child: const Icon(
                    Icons.stop,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
