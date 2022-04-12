import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rdp_flutter/model.dart';

import 'server_selector.i18n.dart';

class ServerSelector extends StatefulWidget {
  const ServerSelector({Key? key, required this.builder}) : super(key: key);
  final Widget Function(ServerItem server) builder;

  @override
  State<StatefulWidget> createState() => ServerSelectorState();
}

class SelectServer extends ChangeNotifier {
  SelectServer(this._setSelected);
  final Function(ServerItem?) _setSelected;

  void set(ServerItem? server) {
    _setSelected(server);
    notifyListeners();
  }

  void clear() {
    _setSelected(null);
    notifyListeners();
  }
}

class ServerSelectorState extends State<ServerSelector> {
  ServerList? _servers;

  void _load() async {
    final items = await ServerList.load();
    setState(() {
      _servers = items;
    });
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  void setSelected(ServerItem? i) {
    setState(() {
      _servers?.setSelected(i);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_servers == null) {
      return Scaffold(
          appBar: AppBar(
            title: Text("Select a Server".i18n),
          ),
          body: const Center(child: CircularProgressIndicator()));
    }
    final items = _servers?.items ?? [];
    final selected = _servers?.getSelected();

    final child = selected != null
        ? ChangeNotifierProvider(
            create: (context) => SelectServer(setSelected),
            child: widget.builder(selected))
        : Scaffold(
            appBar: AppBar(
              title: Text("Select a Server".i18n),
            ),
            body: items.isEmpty
                ? Center(
                    child: Text("No server. Add one?".i18n),
                  )
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return _buildItem(items[index]);
                    },
                  ),
            floatingActionButton: FloatingActionButton(
              onPressed: _pushAddScreen,
              tooltip: 'Add Server'.i18n,
              child: const Icon(Icons.add),
            ),
          );

    return child;
  }

  Widget _buildItem(ServerItem item) {
    return ListTile(
      title: Text(item.title()),
      subtitle: Text(item.subtitle()),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _pushEditScreen(item),
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _remove(item),
        ),
      ]),
      onTap: () => setSelected(item),
    );
  }

  void _pushEditScreen(ServerItem i) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return ServerForm(
        title: Text('Edit Server'.i18n),
        formdata: i,
      );
    }));
    setState(() {
      _servers?.save();
    });
  }

  void _pushAddScreen() async {
    ServerItem? i =
        await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return ServerForm(title: Text('Add Server'.i18n));
    }));
    if (i != null) {
      setState(() {
        _servers?.add(i);
      });
    }
  }

  void _remove(ServerItem i) {
    AlertDialog alert = AlertDialog(
      title: Text("Remove Server".i18n),
      content: Text("Are you sure to remove %s? This action cannot be undone."
          .i18n
          .fill([i.inlineDescription()])),
      actions: [
        TextButton(
          child: Text("Cancel".i18n),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("Remove".i18n),
          onPressed: () {
            setState(() {
              _servers?.remove(i);
            });
            Navigator.of(context).pop();
          },
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class ServerForm extends StatefulWidget {
  const ServerForm({Key? key, this.formdata, required this.title})
      : super(key: key);
  final ServerItem? formdata;
  final Widget title;

  @override
  State<StatefulWidget> createState() => ServerFormState();
}

class ServerFormState extends State<ServerForm> {
  ServerFormState();
  late ServerItem formdata;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    formdata = widget.formdata ?? ServerItem(url: '');
  }

  _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.pop(context, formdata);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: widget.title,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.check),
              tooltip: 'Add'.i18n,
              onPressed: _submit,
            )
          ],
        ),
        body: Form(
            key: _formKey,
            child: Column(children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Server URL'.i18n,
                    hintText: 'http://127.0.0.1:8030',
                    contentPadding: const EdgeInsets.all(16.0),
                    prefixIcon: const Icon(Icons.language)),
                autofocus: true,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter URL'.i18n;
                  }
                  return null;
                },
                initialValue: formdata.url,
                onSaved: (v) => formdata.url = v ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Description'.i18n,
                    hintText: 'Server1'.i18n,
                    contentPadding: const EdgeInsets.all(16.0),
                    prefixIcon: const Icon(Icons.description)),
                initialValue: formdata.description,
                onSaved: (v) => formdata.description = v ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Token'.i18n,
                    hintText: 'A very secret token'.i18n,
                    contentPadding: const EdgeInsets.all(16.0),
                    prefixIcon: const Icon(Icons.lock)),
                obscureText: true,
                textInputAction: TextInputAction.done,
                initialValue: formdata.token,
                onSaved: (v) => formdata.token = v ?? '',
                onFieldSubmitted: (_) => _submit(),
              )
            ])));
  }
}
