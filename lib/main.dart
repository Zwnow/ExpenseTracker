import 'package:flutter/material.dart';
import 'package:namer_app/src/accounts/account.dart';
import 'package:namer_app/src/database/database.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Expense Tracker',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 18, 58, 139)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class Dog {
  final int id;
  final String name;
  final int age;

  const Dog({
    required this.id,
    required this.name,
    required this.age,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
    };
  }

  @override
  String toString() {
    return 'Dog{id: $id, name: $name, age: $age}';
  }

}

class MyAppState extends ChangeNotifier {
    final DatabaseHelper dbhelper = DatabaseHelper();
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = LandingPage();
      case 1:
        page = OtherPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            Expanded(
              child: Container(
                color: Colors.red,
                child: page
              ),
            )
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.blue,
          child: IconTheme(
            data: IconThemeData(
              color: Theme.of(context).colorScheme.onPrimary,
          ), child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(onPressed: () {
                setState(() {
                  selectedIndex = 0;
                });
              }, icon:const Icon(Icons.menu), tooltip: 'Menu',),
              IconButton(onPressed: () {
                setState(() {
                  selectedIndex = 1;
                });
              }, icon:const Icon(Icons.ac_unit)),
            ],
          ))
        ),
        
      );
    });
  }
}

class LandingPage extends StatefulWidget {
  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  List<Account> _data = [];

  Future<void> fetchData() async {
    final DatabaseHelper dbhelper = DatabaseHelper();
    var accounts = await dbhelper.accounts();

    setState(() {
      _data = accounts;
    });
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameEditingController = TextEditingController();

  @override
  void dispose() {
    _nameEditingController.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return ListView(
    padding: EdgeInsets.symmetric(horizontal: 20),
    children: [
      SizedBox(height: 40),
      Center(child: Text('Landing Page', style: TextStyle(fontSize: 24))),
      if (_data.isEmpty) ...[
        SizedBox(height: 30),
        Text(
          "Willkommen, so wie es aussieht hast du noch keinen Account.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 30),
        Text(
          "Bitte gib dem Account hier einen Namen:",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 16),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameEditingController,
                decoration: InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Bitte geben Sie einen gültigen Namen ein.";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    String name = _nameEditingController.text;
                    Account account = Account(id: 0, name: name, total: 0.00);

                    DatabaseHelper dh = DatabaseHelper();
                    await dh.insertAccount(account);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Der Account wurde erstellt.')),
                    );

                    // Reload the data and update the UI
                    setState(() {
                      fetchData();
                    });
                  }
                },
                child: Text("Bestätigen"),
              ),
            ],
          ),
        ),
      ] else ...[
        ListBody(
          children: [
            Text("Kontoliste:", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            for (var account in _data) // Assuming _data contains the list of accounts
              ListTile(
                title: Text(account.name), // Display account name
              ),
          ],
        ),
      ],
    ],
  );
}

}
class OtherPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Other Page'),
      ],
    );
  }
}