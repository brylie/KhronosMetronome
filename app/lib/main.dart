import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:reliable_interval_timer/reliable_interval_timer.dart';

// number of milliseconds in a minute
const minute = 1000 * 60;
const double _minimumTempoValue = 30;
const double _maximumTempoValue = 200;
const double _tempoIncrement = 10;
const double tempoRange = _maximumTempoValue - _minimumTempoValue;
const double _tempoDivisions = tempoRange / _tempoIncrement;

const metronomeAudioPath =
    'audio/243748__unfa__metronome-2khz-strong-pulse.wav';

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

  late ReliableIntervalTimer _timer;
  // late AudioPlayer player;
  static AudioPlayer player = AudioPlayer();

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

  void onTimerTick(int elapsedMilliseconds) async {
    if (soundEnabled) {
      player.play(AssetSource(metronomeAudioPath));
    }
  }

  ReliableIntervalTimer _scheduleTimer([int milliseconds = 10000]) {
    return ReliableIntervalTimer(
      interval: Duration(milliseconds: milliseconds),
      callback: onTimerTick,
    );
  }

  @override
  void initState() {
    super.initState();

    _timer = _scheduleTimer(_calculateTimerInterval(_tempo.round()));

    _timer.start();
  }

  @override
  void dispose() {
    _timer.stop();

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
                _timer.stop();

                setState(() {
                  _tempo = value;
                });

                _timer = _scheduleTimer(
                  _calculateTimerInterval(_tempo.round()),
                );

                _timer.start();
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
