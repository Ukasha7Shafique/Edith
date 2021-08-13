import 'package:flutter/material.dart';
import 'package:practice_app/api/utils.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceButton extends StatefulWidget {
  const VoiceButton({Key? key}) : super(key: key);
  static const routeName = '/voicePage';

  @override
  _VoiceButtonState createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton> {
  SpeechToText? _speech;
  bool _isListening = false;
  String _text = "Press the button and start speeking";

  @override
  void initState() {
    super.initState();
    _speech = SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Input Voice Page',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple[200],
        onPressed: _listen,
        child: Icon(_isListening ? Icons.mic : Icons.mic_none),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: _isListening
            ? Text(
                _text,
                style: TextStyle(
                  fontSize: 32.0,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
              )
            : Text('Kindly tap the mic button to input voice command:)'),
      ),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech!.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() {
          _isListening = true;
        });
        _speech!.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            print(_text);
          }),
        );
      }
    } else {
      Future.delayed(Duration(seconds: 1), () {
        Utils.scanText(_text);
      });
      setState(() {
        _isListening = false;
      });
      _speech!.stop();
    }
  }
}
