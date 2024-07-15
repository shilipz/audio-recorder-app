import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AudioPlayer audioPlayer = AudioPlayer();
  final AudioRecorder audioRecorder = AudioRecorder();
  bool isRecording = false, isPlaying = false;
  String? recordingPath;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _recordingButton(),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (recordingPath != null)
            MaterialButton(
              onPressed: () async {
                if (audioPlayer.playing) {
                  audioPlayer.stop();
                  setState(() {
                    isPlaying = false;
                  });
                } else {
                  await audioPlayer.setFilePath(recordingPath!);
                  audioPlayer.play();
                  setState(() {
                    isPlaying = true;
                  });
                }
              },
              color: Theme.of(context).colorScheme.primary,
              child: Text(isPlaying
                  ? "Stop Playing Recording"
                  : "Start Playing Recordng"),
            ),
          if (recordingPath == null) const Text("No Recording found. :(")
        ],
      ),
    );
  }

  Widget _recordingButton() {
    return FloatingActionButton(
        onPressed: () async {
          if (isRecording) {
            String? filePath = await audioRecorder.stop();
            if (filePath != null) {
              setState(() {
                isRecording = false;
                recordingPath = filePath;
              });
            }
          } else {
            if (await audioRecorder.hasPermission()) {
              final Directory appDocumentsDir =
                  await getApplicationDocumentsDirectory();
              final String filePath =
                  p.join(appDocumentsDir.path, "recording.wav");
              await audioRecorder.start(const RecordConfig(), path: filePath);
              setState(() {
                isRecording = true;
                recordingPath = null;
              });
            }
          }
        },
        child: Icon(isRecording ? Icons.stop : Icons.mic));
  }
}
