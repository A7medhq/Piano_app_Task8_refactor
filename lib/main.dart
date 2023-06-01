import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_midi/flutter_midi.dart';
import 'package:piano/piano.dart';

void main() {
  runApp(PianoApp());
}

class PianoApp extends StatefulWidget {
  @override
  _PianoAppState createState() => _PianoAppState();
}

class _PianoAppState extends State<PianoApp> {
  String pianoFilename = 'Piano_Tiles_2_Soundfont.sf2';
  String guitarFilename = 'Best of Guitars-4U-v1.0.sf2';
  late String midiFilePath;
  final FlutterMidi flutterMidi = FlutterMidi();
  String selectedInstrument = 'Piano';
  bool loading = false;

  @override
  void initState() {
    super.initState();
    midiFilePath = 'assets/$pianoFilename';
    loadMidi();
  }

  void loadMidi() async {
    setState(() {
      loading = true;
    });

    ByteData sf2 = await rootBundle.load(midiFilePath);
    flutterMidi.unmute();
    flutterMidi.prepare(sf2: sf2);

    setState(() {
      loading = false;
    });
  }

  void playNote(int midiNote) {
    flutterMidi.playMidiNote(midi: midiNote);
  }

  void stopNote(int midiNote) {
    flutterMidi.stopMidiNote(midi: midiNote);
  }

  void startAud(NotePosition positionsaved) {
    final midiNote = positionsaved.note.index + (positionsaved.octave - 1) * 12;
    playNote(midiNote);
    Future.delayed(const Duration(milliseconds: 250), () => stopNote(midiNote));
  }

  void changeInstrument(String newInstrument) {
    setState(() {
      selectedInstrument = newInstrument;
    });
  }

  void switchInstrument(String instrument) {
    if (instrument == 'Piano') {
      midiFilePath = 'assets/$pianoFilename';
    } else if (instrument == 'Guitar') {
      midiFilePath = 'assets/$guitarFilename';
    }
    loadMidi();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Piano',
      home: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: DropdownButton<String>(
                value: selectedInstrument,
                onChanged: (value) {
                  changeInstrument(value!);
                  switchInstrument(value);
                },
                items: <String>['Piano', 'Guitar'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              flex: 10,
              child: loading
                  ? Center(child: CircularProgressIndicator())
                  : InteractivePiano(
                      highlightedNotes: [NotePosition(note: Note.C, octave: 3)],
                      naturalColor: Colors.white,
                      accidentalColor: Colors.black,
                      keyWidth: 60,
                      noteRange: NoteRange.forClefs([
                        Clef.Treble,
                      ]),
                      onNotePositionTapped: (position) {
                        setState(() {
                          startAud(position);
                        });
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
