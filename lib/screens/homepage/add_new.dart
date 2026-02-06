import 'package:flutter/material.dart';
import '../../servers/models/server.dart';

import '../../helpers/decoration.dart';
import '../../helpers/db.dart';
import '../../servers/servers.dart';

class AddNewScreen extends StatefulWidget {
  const AddNewScreen({super.key});

  @override
  State<AddNewScreen> createState() => _AddNewScreenState();
}

class _AddNewScreenState extends State<AddNewScreen> {
  final _addNewServerKey = GlobalKey<FormState>();

  String? _url;
  String? _label;
  String? _username;
  String? _password;
  String? _serverType;

  bool isInvalid = false;
  bool detecting = false;
  bool testing = false;

  bool readyToDetect = false;
  bool readyToTest = false;
  bool readyToAdd = false;

  Widget testButtonChild = const Text('Test');

  Future<void> detectServerType() async {
    setState(() => detecting = true);
    final server = Server(
      url: _url ?? '',
      username: _username ?? '',
      password: _password ?? '',
    );

    final type = await Servers.getServerType(server);

    if (type == null) {
      return setState(() {
        detecting = false;
        isInvalid = true;
      });
    }

    setState(() {
      isInvalid = false;
      detecting = false;
      switch (type) {
        case ServerType.qbittorrent:
          _serverType = 'qBittorrent';
          checkReadyToTest();
          checkReadyToAdd();
          break;
        default:
          _serverType = null;
          break;
      }
    });
  }

  Future<void> addServer() async {
    if (_url == null ||
        _username == null ||
        _password == null ||
        _serverType == null) {
      setState(() {
        isInvalid = true;
      });
      return;
    }

    final server = Server(
      id: null,
      url: _url!,
      label: _label,
      username: _username!,
      password: _password!,
      type: _serverType,
    );

    final dbInstance = Db();

    await dbInstance.insertServer(server);
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> checkReadyToDetect() async {
    setState(() {
      readyToDetect = _url != null;
    });
  }

  Future<void> checkReadyToTest() async {
    setState(() {
      readyToTest =
          _url != null &&
          _username != null &&
          _password != null &&
          _serverType != null;
    });
  }

  Future<void> checkReadyToAdd() async {
    setState(() {
      readyToAdd =
          _label != null &&
          _url != null &&
          _username != null &&
          _password != null &&
          _serverType != null;
    });
  }

  Future<void> testServer() async {
    final server = Servers.getServerInstance(
      Server(
        url: _url!,
        username: _username!,
        password: _password!,
        type: _serverType,
      ),
    );

    if (server == null) {
      return setState(() {
        isInvalid = true;
      });
    }

    setState(() {
      testing = true;
      testButtonChild = const CircularProgressIndicator();
    });

    final response = await server.isValidCredentials();

    setState(() {
      testing = false;
      if (response == null) {
        testButtonChild = const Icon(Icons.check_circle, color: Colors.green);
      } else {
        testButtonChild = const Icon(Icons.error, color: Colors.red);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Login Error'),
            content: Text(response),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Column(
      children: [
        const Text('Add New Screen'),
        Form(
          key: _addNewServerKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text('Label'),
              TextFormField(
                decoration: textFieldDecoration.copyWith(
                  hintText: 'My Server',
                  labelText: 'Server Label',
                ),
                onChanged: (value) {
                  setState(() {
                    _label = value;
                    checkReadyToAdd();
                  });
                },
              ),
              const Text('URL'),
              TextFormField(
                decoration: textFieldDecoration.copyWith(
                  hintText: 'https://example.com',
                  labelText: 'Server URL',
                ),
                onChanged: (value) {
                  setState(() {
                    _url = value;
                    checkReadyToDetect();
                    checkReadyToTest();
                    checkReadyToAdd();
                  });
                },
              ),
              const Text('Username'),
              TextFormField(
                decoration: textFieldDecoration.copyWith(
                  hintText: 'Enter username',
                  labelText: 'Username',
                ),
                onChanged: (value) {
                  setState(() {
                    _username = value;
                    checkReadyToTest();
                    checkReadyToAdd();
                  });
                },
              ),
              const Text('Password'),
              TextFormField(
                obscureText: true,
                decoration: textFieldDecoration.copyWith(
                  hintText: 'Enter password',
                  labelText: 'Password',
                ),
                onChanged: (value) {
                  setState(() {
                    _password = value;
                    checkReadyToTest();
                    checkReadyToAdd();
                  });
                },
              ),
              const Text('Type'),
              Row(
                children: [
                  DropdownButton<String>(
                    value: _serverType,
                    items: <String>['BitTorrent', 'uTorrent', 'qBittorrent']
                        .map(
                          (value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _serverType = newValue;
                        checkReadyToTest();
                        checkReadyToAdd();
                      });
                    },
                    hint: const Text('Select Server Type'),
                  ),
                  ElevatedButton(
                    key: const Key('autoDetectButton'),
                    onPressed: !detecting && readyToDetect
                        ? detectServerType
                        : null,
                    child: detecting
                        ? const CircularProgressIndicator()
                        : const Text('Auto Detect'),
                  ),
                ],
              ),
              if (isInvalid && !detecting)
                const Text(
                  'Invalid server details',
                  style: TextStyle(color: Colors.red),
                ),

              Row(
                children: [
                  ElevatedButton(
                    onPressed: readyToTest ? testServer : null,
                    child: testButtonChild,
                  ),
                  ElevatedButton(
                    onPressed: readyToAdd ? addServer : null,
                    child: const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
