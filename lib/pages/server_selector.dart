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
        onPressed: _pushAddTodoScreen,
        tooltip: 'New Server',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildItem(ServerItem item) {
    return ListTile(
      title: Text(item.title()),
      subtitle: Text(item.subtitle()),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () => _remove(item),
      ),
    );
  }

  void _pushAddTodoScreen() {
    Navigator.of(context).push(
        // MaterialPageRoute will automatically animate the screen entry, as well
        // as adding a back button to close it
        MaterialPageRoute(builder: (context) {
      return ServerForm(onSubmit: _add);
    }));
  }

  void _add(ServerItem i) {
    setState(() {
      _servers?.add(i);
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
  const ServerForm({Key? key, this.formdata, required this.onSubmit})
      : super(key: key);
  final void Function(ServerItem) onSubmit;
  final ServerItem? formdata;

  @override
  State<StatefulWidget> createState() => ServerFormState();
}

class ServerFormState extends State<ServerForm> {
  ServerFormState();
  late ServerItem formdata = widget.formdata ?? ServerItem(url: '');
  final _formKey = GlobalKey<FormState>();

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
          title: const Text('Add a new Server'),
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
                onSaved: (v) => formdata.url = v ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Server1',
                    contentPadding: EdgeInsets.all(16.0),
                    prefixIcon: Icon(Icons.description)),
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
                onSaved: (v) => formdata.token = v ?? '',
                onFieldSubmitted: (_) => _submit(),
              )
            ])));
  }
}
