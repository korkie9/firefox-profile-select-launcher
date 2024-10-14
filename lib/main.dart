import 'dart:convert';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:ff_profile_launcher/components/input_modal.dart';
import 'package:ff_profile_launcher/components/long_button.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());

  doWhenWindowReady(() {
    const initialSize = Size(600, 600);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
    appWindow.maxSize = initialSize;
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false, // Add this line
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FocusNode _focusNode = FocusNode();
  String _browserPath = "";
  List<String> users = [];
  int activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadBrowserPath();
    _loadUsers();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleKeyPress(KeyEvent event) async {
    if (event is KeyDownEvent) {
      // Check which keys are pressed
      if (event.logicalKey == LogicalKeyboardKey.keyJ ||
          event.logicalKey == LogicalKeyboardKey.arrowDown) {
        if (!(activeIndex + 1 > users.length - 1)) {
          setState(() {
            activeIndex += 1;
          });
        }
      }
      if (event.logicalKey == LogicalKeyboardKey.keyK ||
          event.logicalKey == LogicalKeyboardKey.arrowUp) {
        if (!(activeIndex - 1 < 0)) {
          setState(() {
            activeIndex -= 1;
          });
        }
      }

      if (event.logicalKey == LogicalKeyboardKey.enter) {
        await launchAndExit(users[activeIndex]);
      }

      if (event.logicalKey == LogicalKeyboardKey.keyD) {
        final prefs = await SharedPreferences.getInstance();
        String? jsonString = prefs.getString('users');

        List<String> userList = [];

        if (jsonString != null) {
          userList = List<String>.from(jsonDecode(jsonString));
        }

        userList.removeAt(activeIndex);

        String updatedJsonString = jsonEncode(userList);

        await prefs.setString('users', updatedJsonString);
        setState(() {
          users = userList;
        });
      }
    }
  }

  Future<void> _loadBrowserPath() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _browserPath = prefs.getString('browserPath') ?? '';
    });
  }

  Future<void> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('users');
    if (jsonString != null) {
      setState(() {
        users = List<String>.from(jsonDecode(jsonString));
      });
    }
  }

  Future<void> launchAndExit(String user) async {
    if (_browserPath.length > 1) {
      await Process.run(_browserPath, ['-P', user]);
      SystemNavigator.pop();
    }
  }

  void setPath() async {
    final List<XFile> files = await openFiles();
    if (files.isNotEmpty) {
      final String path = files[0].path;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('browserPath', path);
      setState(() {
        _browserPath = path;
      });
    }
  }

  Future<void> addUser(String user) async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('users');

    List<String> userList = [];

    if (jsonString != null) {
      userList = List<String>.from(jsonDecode(jsonString));
    }

    userList.add(user);

    String updatedJsonString = jsonEncode(userList);

    await prefs.setString('users', updatedJsonString);
    setState(() {
      users = userList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyPress,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                // Wrap LongButtonList in Expanded
                child: LongButtonList(
                  onLongButtonPressed: launchAndExit,
                  activeButtonIndex: activeIndex,
                  users: users,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                child: FloatingActionButton(
                  onPressed: () async {
                    String? result = await showInputModal(context);
                    if (result != null) {
                      addUser(result);
                    }
                  },
                  tooltip: 'Set browser path',
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: setPath,
        tooltip: 'Set browser path',
        child: const Icon(Icons.browser_updated),
      ),
    );
  }
}
