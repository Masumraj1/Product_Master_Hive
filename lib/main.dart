import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('shoping box');
  runApp(Myapp());
}

class Myapp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController namecontrolar = TextEditingController();
  final TextEditingController quantycontrolar = TextEditingController();
  List<Map<String, dynamic>> _items = [];
  final _shopingbox = Hive.box('shoping box');

  @override
  void initState() {
    super.initState();
    _refreshitem();
  }

  void _refreshitem() {
    final data = _shopingbox.keys.map((key) {
      final item = _shopingbox.get(key);
      return {'key': key, 'name': item['name'], 'quantity': item['quantity']};
    }).toList();
    setState(() {
      _items = data.reversed.toList();
      print(_items.length);
    });
  }

  Future<void> _createitem(Map<String, dynamic> newitem) async {
    await _shopingbox.add(newitem);
    _refreshitem();
  }

  Future<void> _updateitem(int itemkey, Map<String, dynamic> item) async {
    await _shopingbox.put(itemkey, item);
    _refreshitem();
  }

  Future<void> _delateitem(int itemkey) async {
    await _shopingbox.delete(itemkey);
    _refreshitem();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("An item has been delated")));
  }

  void _showFrom(BuildContext ctx, int? itemKey) async {
    if (itemKey != null) {
      final existingitem =
          _items.firstWhere((element) => element['key'] == itemKey);
      namecontrolar.text = existingitem['name'];
      quantycontrolar.text = existingitem['quantity'];
    }
    showModalBottomSheet(
        context: ctx,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                top: 15,
                left: 15,
                right: 15,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: namecontrolar,
                    decoration: InputDecoration(hintText: "Product Name"),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: quantycontrolar,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: "Product Prize"),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (itemKey == null) {
                          _createitem({
                            "name": namecontrolar.text,
                            "quantity": quantycontrolar.text
                          });
                        }

                        if (itemKey != null) {
                          final existingitem = _items.firstWhere(
                              (element) => element['key'] == itemKey);
                          namecontrolar.text = existingitem['name'];
                          quantycontrolar.text = existingitem['quantity'];
                        }
                        namecontrolar.text = '';
                        quantycontrolar.text = '';
                        Navigator.of(context).pop();
                      },
                      child: Text(itemKey == null ? 'Create Product' : 'Upadate')),
                  SizedBox(
                    height: 15,
                  )
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text("Product Genarete",style: TextStyle(fontSize: 25,color: Colors.purple),),
      ),
      body: ListView.builder(
          itemCount: _items.length,
          itemBuilder: (_, index) {
            final curentitem = _items[index];
            return Card(
              color: Colors.white,
              margin: EdgeInsets.all(10),
              elevation: 3,
              child: ListTile(
                title: Text(curentitem['name']),
                subtitle: Text(curentitem['quantity'].toString()),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showFrom(context, curentitem['key'])),
                    IconButton(
                      icon: Icon(Icons.delete_sharp),
                      onPressed: () => _delateitem(curentitem['key']),
                    )
                  ],
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFrom(context, null),
        child: Icon(Icons.add,color: Colors.red),
      ),
    );
  }
}
