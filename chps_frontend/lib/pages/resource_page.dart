import 'package:flutter/material.dart';
import '../api_client.dart';
import '../models.dart';

class ResourcePage extends StatefulWidget {
  const ResourcePage({super.key, required this.api, required this.resource});
  final ApiClient api;
  final ResourceDef resource;

  @override
  State<ResourcePage> createState() => _ResourcePageState();
}

class _ResourcePageState extends State<ResourcePage> {
  late Future<List<dynamic>> _future;
  final _formKey = GlobalKey<FormState>();
  final _formData = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    _future = widget.api.list(widget.resource.path);
  }

  Future<void> _createOrUpdate([Map<String, dynamic>? item]) async {
    _formData.clear();
    if (item != null) {
      _formData.addAll(item);
    }
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item == null ? 'Create ${widget.resource.title}' : 'Edit ${widget.resource.title}'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.resource.columns.map((field) {
              final value = _formData[field]?.toString() ?? '';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: TextFormField(
                  initialValue: value,
                  decoration: InputDecoration(labelText: field),
                  onChanged: (val) => _formData[field] = val,
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _delete(int id) async {
    await widget.api.delete(widget.resource.path, id);
    setState(() => _future = widget.api.list(widget.resource.path));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data ?? [];
        return Column(
          children: [
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('No records found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text('${widget.resource.title} #${item['id'] ?? ''}'),
                            subtitle: Text(widget.resource.columns.take(3).map((f) => '${f}: ${item[f] ?? '-'}').join(' | ')),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(onPressed: () => _createOrUpdate(item), icon: const Icon(Icons.edit)),
                                IconButton(onPressed: () => _delete((item['id'] ?? 0) as int), icon: const Icon(Icons.delete)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FloatingActionButton.extended(
                onPressed: () => _createOrUpdate(),
                label: const Text('Create'),
                icon: const Icon(Icons.add),
              ),
            ),
          ],
        );
      },
    );
  }
}
