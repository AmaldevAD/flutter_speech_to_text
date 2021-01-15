import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  stt.SpeechToText _speech;
  bool _isListnening = false;
  String _text = 'Press the button to speak';
  double _confidence = 1.0;
  String temp = "";

  @override
  void initState() {
    _speech = stt.SpeechToText();
    super.initState();
  }

  void sendText({@required String message}) async {
    var body = {"text": "$message"};
    var response = await http.post(
        "https://inshortsapp.herokuapp.com/api/v1/summary/sendmail",
        body: body);
    print(response.body);
    if (response.statusCode == 200) {
      Widget okButton = FlatButton(
        child: Text("Ok"),
        onPressed: () {
          Navigator.pop(context);
        },
      );
      AlertDialog alert = AlertDialog(
        title: Text("Success"),
        content: Text("Successfully sent"),
        actions: [
          okButton,
        ],
      );

      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Summary"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListnening,
        endRadius: 75.0,
        repeat: true,
        duration: const Duration(milliseconds: 2000),
        repeatPauseDuration: const Duration(milliseconds: 100),
        child: FloatingActionButton(
          onPressed: _listen,
          backgroundColor: _isListnening ? Colors.green : Colors.blue,
          child: Icon(_isListnening ? Icons.mic : Icons.mic_none),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                temp,
                style: TextStyle(fontSize: 15),
              ),
              Text(
                _text,
                style: TextStyle(fontSize: 15, color: Colors.red),
              ),
              OutlinedButton(
                onPressed: () {
                  // Respond to button press
                  setState(() {
                    temp = "";
                    _text = "";
                  });
                },
                child: Text("Clear"),
              ),
              OutlinedButton(
                onPressed: () {
                  // Respond to button press
                  sendText(message: temp);
                },
                child: Text("Send text"),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _listen() async {
    if (!_isListnening) {
      bool available = await _speech.initialize(
          onStatus: (val) => print("onstatus $val"),
          onError: (val) => print("OnError $val"));
      if (available) {
        setState(() => _isListnening = true);
        _speech.listen(onResult: (val) {
          setState(() {
            _text = val.recognizedWords;
          });
          setState(() {
            if (val.finalResult) {
              if (temp != "")
                temp = temp + ". " + val.recognizedWords;
              else
                temp = val.recognizedWords;
              // _text = "Press to speak";
            }
          });
          ;
        });
      } else {
        setState(() {
          print("---------------");
          // print(_text);
          _isListnening = false;
        });
        _speech.stop();
      }
    } else {
      setState(() {
        print("---------------");
        // print(_text);
        _isListnening = false;
      });
      _speech.stop();
    }
    //print(_text);
  }
}
