import 'package:flutter/material.dart';
import '../servers/models/server.dart';

import '../helpers/decoration.dart';
import '../helpers/db.dart';
import '../servers/servers.dart';

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
        case ServerType.bittorrent:
          _serverType = 'BitTorrent';
          break;
        default:
          _serverType = null;
          break;
      }
    });
  }

  Future<void> addServer() async {
    if (_url == null || _username == null || _password == null || _serverType == null) {
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
                    });
                  },
                ),
                const Text('Password'),
                TextFormField(
                  decoration: textFieldDecoration.copyWith(
                    hintText: 'Enter password',
                    labelText: 'Password',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _password = value;
                    });
                  },
                ),
                const Text('Type'),
                Row(
                  children: [
                    DropdownButton<String>(
                      value: _serverType,
                      items: <String>['BitTorrent', 'uTorrent', 'qBittorrent']
                          .map((value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ))
                          .toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _serverType = newValue;
                        });
                      },
                      hint: const Text('Select Server Type'),
                    ),
                    ElevatedButton(
                      key: const Key('autoDetectButton'),
                      onPressed: detecting ? null : detectServerType,
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

                ElevatedButton(
                  onPressed: addServer,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
}
