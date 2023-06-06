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
  String? midiFilePath_choice;
  final FlutterMidi flutterMidi = FlutterMidi();
  late double key_width;
  double _scale = 1.0;
  double _previousScale = 1.0;
  List<int> activeNotes = []; // Track active MIDI notes

  @override
  void initState() {
    key_width = 60;
    loadMidi('assets/Piano_Tiles_2_Soundfont.sf2');
    super.initState();
  }

  void loadMidi(String asset) async {
    for (int midiNote in activeNotes) {
      flutterMidi.stopMidiNote(midi: midiNote);
    }
    activeNotes.clear(); // Clear the list of active notes

    ByteData sf2 = await rootBundle.load(asset);
    flutterMidi.prepare(
        sf2: sf2,
        name: 'assets/$midiFilePath_choice'.replaceAll('assets/', ''));
  }

  void stopNote(int midiNote) {
    flutterMidi.stopMidiNote(midi: midiNote);
    activeNotes.remove(midiNote); // Remove the stopped note from active notes
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: midiFilePath_choice ?? 'Piano',
      home: Scaffold(
        appBar: AppBar(
          leadingWidth: 120,
          leading: Padding(
            padding: const EdgeInsets.all(20.0),
            child: DropdownButton<String>(
                value: midiFilePath_choice ?? 'Piano_Tiles_2_Soundfont.sf2',
                items: const [
                  DropdownMenuItem(
                    child: Text('Piano'),
                    value: 'Piano_Tiles_2_Soundfont.sf2',
                  ),
                  DropdownMenuItem(
                    child: Text('Draums'),
                    value: 'PNS Drum Kit.SF2',
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    midiFilePath_choice = value;
                  });
                  loadMidi('assets/$midiFilePath_choice');
                }),
          ),
          title: Center(child: Text('Piano')),
        ),
        body: GestureDetector(
          onScaleStart: (ScaleStartDetails details) {
            _previousScale = _scale;
          },
          onScaleUpdate: (ScaleUpdateDetails details) {
            setState(() {
              _scale = (_previousScale * details.scale).clamp(0.1, 1.0);
              key_width = 60 + (_scale * 40);
            });
          },
          child: InteractivePiano(
            highlightedNotes: [NotePosition(note: Note.C, octave: 3)],
            naturalColor: Colors.white,
            accidentalColor: Colors.black,
            keyWidth: key_width,
            noteRange: NoteRange.forClefs([
              Clef.Treble,
            ]),
            onNotePositionTapped: (position) {

                flutterMidi.playMidiNote(midi: position.pitch);
                // activeNotes.add(position.pitch); //

            },
          ),
        ),
      ),
    );
  }
}


















////////////////////////
////*
////*
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_midi/flutter_midi.dart';
// import 'package:piano/piano.dart';

// void main() {
//   runApp(PianoApp());
// }

// class PianoApp extends StatefulWidget {
//   @override
//   _PianoAppState createState() => _PianoAppState();
// }

// class _PianoAppState extends State<PianoApp> {
//   String pianoFilename = 'Piano_Tiles_2_Soundfont.sf2';
//   String guitarFilename = 'Best of Guitars-4U-v1.0.sf2';
//   late String midiFilePath;
//   final FlutterMidi flutterMidi = FlutterMidi();
//   String selectedInstrument = 'Piano';
//   bool loading = false;
//   Map<String, ByteData> loadedMidiFiles = {};

//   @override
//   void initState() {
//     super.initState();
//     midiFilePath = 'assets/$pianoFilename';
//     loadMidi();
//   }

//   Future<ByteData> loadOrGetMidi(String midiFilePath) async {
//     if (loadedMidiFiles.containsKey(midiFilePath)) {
//       // Use the already loaded MIDI file
//       return loadedMidiFiles[midiFilePath]!;
//     } else {
//       // Load the MIDI file
//       ByteData sf2 = await rootBundle.load(midiFilePath);
//       loadedMidiFiles[midiFilePath] = sf2; // Store the loaded MIDI file
//       return sf2;
//     }
//   }

//   void loadMidi() async {
//     setState(() {
//       loading = true;
//     });

//     ByteData sf2 = await loadOrGetMidi(midiFilePath);
//     flutterMidi.unmute();
//     flutterMidi.prepare(sf2: sf2);

//     setState(() {
//       loading = false;
//     });
//   }

//   void playNote(int midiNote) {
//     flutterMidi.playMidiNote(midi: midiNote);
//   }

//   void stopNote() {
//     // Stop playing all MIDI notes
//     for (int midiNote = 0; midiNote < 128; midiNote++) {
//       flutterMidi.stopMidiNote(midi: midiNote);
//     }
//   }

//   void startAud(NotePosition positionsaved) {
//     final midiNote = positionsaved.note.index + (positionsaved.octave - 1) * 12;
//     playNote(midiNote);
//     Future.delayed(const Duration(milliseconds: 250), () => stopNote());
//   }

//   void changeInstrument(String newInstrument) {
//     setState(() {
//       selectedInstrument = newInstrument;
//     });
//   }

//   void switchInstrument(String instrument) async {
//     if (instrument == 'Piano') {
//       midiFilePath = 'assets/$pianoFilename';
//     } else if (instrument == 'Guitar') {
//       midiFilePath = 'assets/$guitarFilename';
//     }

//     setState(() {
//       loading = true;
//     });

//     if (loadedMidiFiles.containsKey(midiFilePath)) {
//       // Use the already loaded MIDI file
//       ByteData sf2 = loadedMidiFiles[midiFilePath]!;
//       flutterMidi.prepare(sf2: sf2);
//       setState(() {
//         loading = false;
//       });
//     } else {
//       // Load the MIDI file
//       ByteData sf2 = await loadOrGetMidi(midiFilePath);
//       loadedMidiFiles[midiFilePath] = sf2; // Store the loaded MIDI file
//       flutterMidi.unmute();
//       flutterMidi.prepare(sf2: sf2);

//       setState(() {
//         loading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Piano',
//       home: Scaffold(
//         body: Column(
//           children: [
//             Expanded(
//               child: DropdownButton<String>(
//                 value: selectedInstrument,
//                 onChanged: (value) {
//                   if (value != selectedInstrument) {
//                     switchInstrument(value!);
//                     changeInstrument(value);
//                   }
//                 },
//                 items: <String>['Piano', 'Guitar'].map((String value) {
//                   return DropdownMenuItem<String>(
//                     value: value,
//                     child: Text(value),
//                   );
//                 }).toList(),
//               ),
//             ),
//             Expanded(
//               flex: 10,
//               child: loading
//                   ? Center(child: CircularProgressIndicator())
//                   : InteractivePiano(
//                       highlightedNotes: [NotePosition(note: Note.C, octave: 3)],
//                       naturalColor: Colors.white,
//                       accidentalColor: Colors.black,
//                       keyWidth: 60,
//                       noteRange: NoteRange.forClefs([
//                         Clef.Treble,
//                       ]),
//                       onNotePositionTapped: (position) {
//                         setState(() {
//                           startAud(position);
//                         });
//                       },
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
