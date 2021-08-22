import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_midi/flutter_midi.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Piano',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Piano(),
    );
  }
}

class Piano extends StatefulWidget {
  const Piano({Key? key}) : super(key: key);

  @override
  _PianoState createState() => _PianoState();
}

class _PianoState extends State<Piano> {
  int octave = 3; //Trocar isso troca as nota tud

  get octaveStartingNote => (octave * 12) % 128;

  final FlutterMidi flutterMidi = FlutterMidi();

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    setupMIDIPlugin();
    super.initState();
  }

  Future<void> setupMIDIPlugin() async {
    flutterMidi.unmute();
    ByteData _byte = await rootBundle.load("assets/file.sf2");
    flutterMidi.prepare(sf2: _byte, name: 'file.sf2');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final whiteKeySize = size.width / 7;
    final blackKeySize = whiteKeySize / 2;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  octave -= 1;
                });
              },
              icon: Icon(Icons.arrow_back_ios_new_rounded),
            ),
            Text('OCTAVE : $octave'),
            IconButton(
              onPressed: () {
                setState(() {
                  octave += 1;
                });
              },
              icon: Icon(Icons.arrow_forward_ios_rounded),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          _buildWhiteKeys(whiteKeySize),
          _buildBlackKeys(size.height, blackKeySize, whiteKeySize),
        ],
      ),
    );
    //   },
    // );
  }

  _buildWhiteKeys(double whiteKeySize) {
    return Row(
      children: [
        PianoKey.white(
            flutterMidi: flutterMidi,
            width: whiteKeySize,
            midiNote: octaveStartingNote),
        PianoKey.white(
            flutterMidi: flutterMidi,
            width: whiteKeySize,
            midiNote: octaveStartingNote + 2),
        PianoKey.white(
            flutterMidi: flutterMidi,
            width: whiteKeySize,
            midiNote: octaveStartingNote + 4),
        PianoKey.white(
            flutterMidi: flutterMidi,
            width: whiteKeySize,
            midiNote: octaveStartingNote + 5),
        PianoKey.white(
            flutterMidi: flutterMidi,
            width: whiteKeySize,
            midiNote: octaveStartingNote + 7),
        PianoKey.white(
            flutterMidi: flutterMidi,
            width: whiteKeySize,
            midiNote: octaveStartingNote + 9),
        PianoKey.white(
            flutterMidi: flutterMidi,
            width: whiteKeySize,
            midiNote: octaveStartingNote + 11),
      ],
    );
  }

  _buildBlackKeys(
      double pianoHeight, double blackKeySize, double whiteKeySize) {
    return Container(
      height: pianoHeight * 0.40,
      child: Row(
        children: [
          SizedBox(
            width: whiteKeySize - blackKeySize / 2,
          ),
          PianoKey.black(
              flutterMidi: flutterMidi,
              width: blackKeySize,
              midiNote: octaveStartingNote + 1),
          SizedBox(
            width: whiteKeySize - blackKeySize,
          ),
          PianoKey.black(
              flutterMidi: flutterMidi,
              width: blackKeySize,
              midiNote: octaveStartingNote + 3),
          SizedBox(
            width: whiteKeySize,
          ),
          SizedBox(
            width: whiteKeySize - blackKeySize,
          ),
          PianoKey.black(
              flutterMidi: flutterMidi,
              width: blackKeySize,
              midiNote: octaveStartingNote + 6),
          SizedBox(
            width: whiteKeySize - blackKeySize,
          ),
          PianoKey.black(
              flutterMidi: flutterMidi,
              width: blackKeySize,
              midiNote: octaveStartingNote + 8),
          SizedBox(
            width: whiteKeySize - blackKeySize,
          ),
          PianoKey.black(
              flutterMidi: flutterMidi,
              width: blackKeySize,
              midiNote: octaveStartingNote + 10),
        ],
      ),
    );
  }
}

enum KeyColor { WHITE, BLACK }

class PianoKey extends StatefulWidget {
  final KeyColor color;
  final double width;
  final int midiNote;
  final FlutterMidi flutterMidi;

  const PianoKey.white({
    Key? key,
    required this.width,
    required this.midiNote,
    required this.flutterMidi,
  })  : this.color = KeyColor.WHITE,
        super(key: key);

  const PianoKey.black(
      {Key? key,
      required this.width,
      required this.midiNote,
      required this.flutterMidi,})
      : this.color = KeyColor.BLACK,
        super(key: key);

  @override
  _PianoKeyState createState() => _PianoKeyState();
}

class _PianoKeyState extends State<PianoKey> {
  bool isPlaying = false;

  playNote() {
    setState(() {
      isPlaying = true;
    });
    widget.flutterMidi.playMidiNote(midi: widget.midiNote);
  }

  stopNote() {
    setState(() {
      isPlaying = false;
    });
    widget.flutterMidi.stopMidiNote(midi: widget.midiNote);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => playNote(),
      onTapUp: (_) => stopNote(),
      child: Container(
        width: widget.width,
        decoration: BoxDecoration(
            color: widget.color == KeyColor.WHITE
                ? (isPlaying ? Colors.grey : Colors.white)
                : Colors.black,
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(10))),
      ),
    );
  }
}
