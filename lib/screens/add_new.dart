import 'package:flutter/material.dart';
import 'package:mtorrent/servers/models/server.dart';

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

    ServerType? type = await Servers.getServerType(server);

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

    var server = Server(
      id: null,
      url: _url!,
      label: _label,
      username: _username!,
      password: _password!,
      type: _serverType,
    );

    Db dbInstance = Db();

    await dbInstance.insertServer(server);
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Text('Add New Screen'),
          Form(
            key: _addNewServerKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Label'),
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
                Text('URL'),
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
                Text('Username'),
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
                Text('Password'),
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
                Text('Type'),
                Row(
                  children: [
                    DropdownButton<String>(
                      value: _serverType,
                      items: <String>['BitTorrent', 'uTorrent', 'qBittorrent']
                          .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          })
                          .toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _serverType = newValue;
                        });
                      },
                      hint: Text('Select Server Type'),
                    ),
                    ElevatedButton(
                      key: Key('autoDetectButton'),
                      onPressed: detecting ? null : detectServerType,
                      child: detecting
                          ? CircularProgressIndicator()
                          : Text('Auto Detect'),
                    ),
                  ],
                ),
                if (isInvalid && !detecting)
                  Text(
                    'Invalid server details',
                    style: TextStyle(color: Colors.red),
                  ),

                ElevatedButton(
                  onPressed: addServer,
                  child: Text('Add'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
