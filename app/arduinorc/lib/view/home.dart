import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _controllerUp;
  late AnimationController _controllerRight;
  late AnimationController _controllerLeft;
  late AnimationController _controllerDown;

  late double _scale;

  late BluetoothConnection connection;
  bool _isConnected = false;
  bool _isListening = false;
  String _data = '';

  @override
  void initState() {
    super.initState();

    _controllerUp = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });

    _controllerRight = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });

    _controllerLeft = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });

    _controllerDown = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    if (_isConnected) connection.finish(); // Closing connection

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isListening) {
      _getData(context);
    }

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.25,
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 70.0),
                child: Image.asset('assets/icons/logo.png',
                    width: 110.0, height: 30.0),
              )),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                arrowButton('assets/icons/sort_up.png'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    arrowButton('assets/icons/sort_left.png'),
                    arrowButton('assets/icons/sort_right.png'),
                  ],
                ),
                arrowButton('assets/icons/sort_down.png'),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.25,
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.25 * 0.20),
              child: GestureDetector(
                onTap: () {} /* open the drawer */,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Select device",
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14.0,
                          color: Color(0xFF00989F)),
                    ),
                    Image.asset(
                      'assets/icons/swipe_right_gesture.png',
                      width: 20.0,
                      height: 20.0,
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: const [],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.25 * 0.5),
        child: FloatingActionButton(
          onPressed: _bluetoothConnectDevice,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 2.0),
            child: Center(
                child: Image.asset('assets/icons/shutdown.png',
                    width: 30.0, height: 30.0)),
          ),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  /// The arrow button that allows the arduino rc to move
  Widget arrowButton(iconPath) {
    switch (iconPath) {
      case 'assets/icons/sort_up.png':
        _scale = 1 - _controllerUp.value;
        break;
      case 'assets/icons/sort_left.png':
        _scale = 1 - _controllerLeft.value;
        break;
      case 'assets/icons/sort_right.png':
        _scale = 1 - _controllerRight.value;
        break;
      case 'assets/icons/sort_down.png':
        _scale = 1 - _controllerDown.value;
        break;
    }

    double _containerSize = 60.0;
    double _iconSize = 30.0;

    return GestureDetector(
      onTap: () => _onTap(iconPath),
      onTapDown: (TapDownDetails details) => _onTapDown(iconPath),
      onTapUp: (TapUpDetails details) => _onTapUp(iconPath),
      onHorizontalDragCancel: () => _onTapUp(iconPath),
      onVerticalDragCancel: () => _onTapUp(iconPath),
      child: Transform.scale(
        scale: _scale,
        child: Container(
          alignment: Alignment.center,
          width: _containerSize,
          height: _containerSize,
          decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF00989F)),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.16),
                  offset: Offset(0.0, 5.0),
                  blurRadius: 30.0,
                )
              ]),
          child: Image.asset(
            iconPath,
            width: _iconSize,
            height: _iconSize,
          ),
        ),
      ),
    );
  }

  void _onTapDown(iconPath) {
    switch (iconPath) {
      case 'assets/icons/sort_up.png':
        _controllerUp.forward();
        _sendData('w'); // Action
        break;
      case 'assets/icons/sort_left.png':
        _controllerLeft.forward();
        _sendData('a'); // Action
        break;
      case 'assets/icons/sort_right.png':
        _controllerRight.forward();
        _sendData('d'); // Action
        break;
      case 'assets/icons/sort_down.png':
        _controllerDown.forward();
        _sendData('s'); // Action
        break;
    }
  }

  void _onTap(iconPath) {
    const int _millis = 100;

    switch (iconPath) {
      case 'assets/icons/sort_up.png':
        _controllerUp.forward();

        _sendData('w'); // Action

        Future.delayed(const Duration(milliseconds: _millis), () {
          _controllerUp.reverse();
          _sendData('s'); // Action
        });

        break;
      case 'assets/icons/sort_left.png':
        _controllerLeft.forward();

        _sendData('a'); // Action

        Future.delayed(const Duration(milliseconds: _millis), () {
          _controllerLeft.reverse();
          _sendData('s'); // Action
        });
        break;
      case 'assets/icons/sort_right.png':
        _controllerRight.forward();

        _sendData('d'); // Action

        Future.delayed(const Duration(milliseconds: _millis), () {
          _controllerRight.reverse();
          _sendData('s'); // Action
        });
        break;
      case 'assets/icons/sort_down.png':
        _controllerDown.forward();

        _sendData('s'); // Action

        Future.delayed(const Duration(milliseconds: _millis),
            () => _controllerDown.reverse());
        break;
    }
  }

  void _onTapUp(iconPath) {
    switch (iconPath) {
      case 'assets/icons/sort_up.png':
        _controllerUp.reverse();
        break;
      case 'assets/icons/sort_left.png':
        _controllerLeft.reverse();
        break;
      case 'assets/icons/sort_right.png':
        _controllerRight.reverse();
        break;
      case 'assets/icons/sort_down.png':
        _controllerDown.reverse();
        break;
    }
  }

  Future<void> _bluetoothConnectDevice() async {
    if (!_isConnected) {
      try {
        //print(FlutterBluetoothSerial.instance.getBondedDevices().toString());

        await BluetoothConnection.toAddress('98:D3:31:70:91:B7')
            .then((_connection) {
          // Connected to the device
          setState(() {
            connection = _connection;
            _isConnected = true;
            _showToast(context, text: 'Succeded');
          });
        });
      } catch (exception) {
        // Ignore error
        // Cannot connect, exception occured
        setState(() => _isConnected = false);
        _showToast(context, text: 'Failed');
      }
    } else if (!connection.isConnected) {
      setState(() => _isConnected = false);
    } else {
      connection.finish(); // Closing connection
      setState(() => _isConnected = false);
    }
  }

  void _showToast(BuildContext context, {required String text}) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(_data),
        action: SnackBarAction(
            label: text,
            textColor: Colors.white,
            onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  void _getData(BuildContext context) {
    if (_isConnected) {
      try {
        setState(() => _isListening = true);
        connection.input!.listen((Uint8List data) {
          String value = ascii.decode(data).toString();
          if (value != '0' || value != ' ') {
            _data += ascii.decode(data).toString();
            if (_data.length == 4) {
              _showToast(context, text: 'ok');

              setState(() => _data = '');
            }
          }
          //connection.output.add(data); // Sending data
        }).onDone(() {
          //print('debug: Disconnected by remote request');
          setState(() => _isListening = false);
        });
      } catch (exception) {
        //print('debug: Cannot connect, exception occured');
        setState(() => _isListening = false);
      }
    }
  }

  Future<void> _sendData(String text) async {
    if (_isConnected) {
      try {
        connection.output.add(ascii.encode(text));
        await connection.output.allSent;
      } catch (e) {
        // Ignore error
        if (!connection.isConnected) {
          // Notify state
          setState(() => _isConnected = false);
        }
      }
    }
  }
}
