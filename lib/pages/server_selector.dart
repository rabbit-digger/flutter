import 'package:flutter/material.dart';
import 'package:rdp_flutter/pages/model.dart';

class ServerSelector extends StatefulWidget {
  const ServerSelector({Key? key, required this.child}) : super(key: key);
  final Widget? child;

  @override
  State<StatefulWidget> createState() => ServerSelectorState();
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

  @override
  Widget build(BuildContext context) {
    final items = _servers?.items ?? [];
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select a Server"),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _buildItem(items[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pushAddScreen,
        tooltip: 'New Server',
        child: const Icon(Icons.add),
      ),
    );
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
    );
  }

  void _pushEditScreen(ServerItem i) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return ServerForm(
          title: const Text('Edit Server'),
          formdata: i,
          onSubmit: (_) => _edit());
    }));
  }

  void _pushAddScreen() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return ServerForm(title: const Text('Add Server'), onSubmit: _add);
    }));
  }

  void _add(ServerItem i) {
    setState(() {
      _servers?.add(i);
    });
  }

  void _edit() {
    setState(() {
      _servers?.save();
    });
  }

  void _removeItem(ServerItem i) {
    setState(() {
      _servers?.remove(i);
    });
  }

  _remove(ServerItem i) {
    AlertDialog alert = AlertDialog(
      title: const Text("You are going to remove this server"),
      content: Text(
          "Are you sure to remove ${i.inlineDescription()}? This action cannot be undone."),
      actions: [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text("Remove"),
          onPressed: () {
            _removeItem(i);
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
  const ServerForm(
      {Key? key, this.formdata, required this.onSubmit, required this.title})
      : super(key: key);
  final void Function(ServerItem) onSubmit;
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
      widget.onSubmit(formdata);
      Navigator.pop(context);
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
              tooltip: 'Add',
              onPressed: _submit,
            )
          ],
        ),
        body: Form(
            key: _formKey,
            child: Column(children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Server URL',
                    hintText: 'http://127.0.0.1:8030',
                    contentPadding: EdgeInsets.all(16.0),
                    prefixIcon: Icon(Icons.language)),
                autofocus: true,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter URL';
                  }
                  return null;
                },
                initialValue: formdata.url,
                onSaved: (v) => formdata.url = v ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Server1',
                    contentPadding: EdgeInsets.all(16.0),
                    prefixIcon: Icon(Icons.description)),
                initialValue: formdata.description,
                onSaved: (v) => formdata.description = v ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Token',
                    hintText: 'A very secret token',
                    contentPadding: EdgeInsets.all(16.0),
                    prefixIcon: Icon(Icons.lock)),
                obscureText: true,
                textInputAction: TextInputAction.done,
                initialValue: formdata.token,
                onSaved: (v) => formdata.token = v ?? '',
                onFieldSubmitted: (_) => _submit(),
              )
            ])));
  }
}
