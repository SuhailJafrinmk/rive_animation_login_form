import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

class RiveLoginForm extends StatefulWidget {
  @override
  State<RiveLoginForm> createState() => _RiveLoginFormState();
}

class _RiveLoginFormState extends State<RiveLoginForm> {
  Artboard? _artboard;
  StateMachineController? _controller;
  SMITrigger? _success;
  SMITrigger? _fail;
  SMIBool? _handsUp;
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRiveFile();
  }

  // Load Rive file and set up the state machine
  void _loadRiveFile() async {
    final data = await rootBundle.load('assets/login_screen_character.riv');
    final file = RiveFile.import(data);
    final artboard = file.mainArtboard;

    var controller = StateMachineController.fromArtboard(artboard, 'State Machine 1');
    if (controller != null) {
      artboard.addController(controller);
      setState(() {
        _controller = controller;
        _success = controller.findInput<bool>('success') as SMITrigger?;
        _fail = controller.findInput<bool>('fail') as SMITrigger?;
        _handsUp = controller.findInput<bool>('hands_up') as SMIBool?;
      });
    }

    setState(() {
      _artboard = artboard;
    });
  }

  // Mock login validation
  void _login() {
    if (_formKey.currentState!.validate()) {
      // Mock login logic: if username == "user" and password == "123", it's successful
      if (_usernameController.text == 'user' && _passwordController.text == '123') {
        _success?.fire();
      } else {
        _fail?.fire();
      }
    }
  }

  // This will trigger hands-up when focusing on password
  void _handlePasswordFocusChange(bool hasFocus) {
    if (_handsUp != null) {
      _handsUp!.value = hasFocus;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: _artboard == null
                ? const Center(child: CircularProgressIndicator())
                : Rive(artboard: _artboard!),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Focus(
                      onFocusChange: _handlePasswordFocusChange,
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _login,
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
