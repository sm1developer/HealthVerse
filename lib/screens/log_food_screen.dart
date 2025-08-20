import 'package:flutter/material.dart';
import '../state/food_store.dart';
import '../models/food_log.dart';

class LogFoodScreen extends StatefulWidget {
  const LogFoodScreen({super.key});

  @override
  State<LogFoodScreen> createState() => _LogFoodScreenState();
}

class _LogFoodScreenState extends State<LogFoodScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _foodCtrl = TextEditingController();
  final TextEditingController _qtyCtrl = TextEditingController(text: '1');
  String _unit = 'Grams (g)';
  final List<_FoodEntry> _entries = <_FoodEntry>[];

  @override
  void dispose() {
    _foodCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final String name = _foodCtrl.text.trim();
    final String qty = _qtyCtrl.text.trim();
    final String unit = _unit;
    final double quantity = double.tryParse(qty) ?? 0;
    if (name.isEmpty && _entries.isEmpty) return;

    // Build list of items (include current fields if valid)
    final List<_FoodEntry> items = List<_FoodEntry>.from(_entries);
    if (name.isNotEmpty && quantity > 0) {
      items.add(_FoodEntry(name: name, unit: unit, quantity: quantity));
    }
    if (items.isEmpty) return;

    final String details = items
        .map((e) => '${e.name} • ${e.quantity} ${e.unit}')
        .join('\n');
    final String logName = items.length > 1
        ? 'Food (${items.length} items)'
        : items.first.name;
    final String logUnit = items.length > 1 ? 'items' : items.first.unit;
    final double logQty = items.length > 1
        ? items.length.toDouble()
        : items.first.quantity;

    FoodStore.instance.add(
      FoodLog(
        name: logName,
        unit: logUnit,
        quantity: logQty,
        loggedAt: DateTime.now(),
        details: details,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved ${items.length} food item(s)')),
    );
    Navigator.of(context).maybePop();
  }

  void _addEntry() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final String name = _foodCtrl.text.trim();
    final double quantity = double.tryParse(_qtyCtrl.text.trim()) ?? 0;
    if (name.isEmpty || quantity <= 0) return;
    setState(() {
      _entries.add(_FoodEntry(name: name, unit: _unit, quantity: quantity));
      _foodCtrl.clear();
      _qtyCtrl.text = '1';
      _unit = 'Grams (g)';
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Log Food')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 0,
                      color: scheme.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'What did you eat?',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _foodCtrl,
                              decoration: const InputDecoration(
                                hintText: 'e.g., Grilled chicken, Salad',
                                labelText: 'Food',
                                border: OutlineInputBorder(),
                              ),
                              textInputAction: TextInputAction.next,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Please enter a food name'
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 0,
                      color: scheme.surfaceContainerHigh,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Amount',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  flex: 7,
                                  child: DropdownButtonFormField<String>(
                                    value: _unit,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'Grams (g)',
                                        child: Text('Grams (g)'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Milliliter(s) (ml)',
                                        child: Text('Milliliter(s) (ml)'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Plate(s)',
                                        child: Text('Plate(s)'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Unit(s)',
                                        child: Text('Unit(s)'),
                                      ),
                                    ],
                                    onChanged: (v) {
                                      if (v != null) setState(() => _unit = v);
                                    },
                                    decoration: const InputDecoration(
                                      labelText: 'Quantity',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 5,
                                  child: TextFormField(
                                    controller: _qtyCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Quantity',
                                      hintText:
                                          (_unit == 'Grams (g)' ||
                                              _unit == 'Milliliter(s) (ml)')
                                          ? 'e.g., 120'
                                          : 'e.g., 1',
                                      border: const OutlineInputBorder(),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Enter quantity';
                                      }
                                      final num? n = num.tryParse(v);
                                      if (n == null || n <= 0) {
                                        return 'Enter a valid number';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton.tonalIcon(
                                onPressed: _addEntry,
                                icon: const Icon(Icons.playlist_add),
                                label: const Text('Add to list'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_entries.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Card(
                        elevation: 0,
                        color: scheme.surfaceContainerHighest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Added items (${_entries.length})',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              ..._entries.asMap().entries.map((e) {
                                final int idx = e.key;
                                final _FoodEntry it = e.value;
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  leading: const Icon(Icons.restaurant),
                                  title: Text(it.name),
                                  subtitle: Text('${it.quantity} ${it.unit}'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => setState(() {
                                      _entries.removeAt(idx);
                                    }),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                shape: const StadiumBorder(),
                minimumSize: const Size.fromHeight(66),
                padding: const EdgeInsets.symmetric(vertical: 20),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor: Theme.of(
                  context,
                ).colorScheme.onPrimaryContainer,
              ),
              child: Text(
                'Save',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodEntry {
  _FoodEntry({required this.name, required this.unit, required this.quantity});
  final String name;
  final String unit;
  final double quantity;
}
