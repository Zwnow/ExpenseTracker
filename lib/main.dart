import 'package:flutter/material.dart';
import 'package:namer_app/src/accounts/account.dart';
import 'package:namer_app/src/database/database.dart';
import 'package:provider/provider.dart';

import 'src/categories/category.dart';
import 'src/expenses/expense.dart';

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
        page = ExpensePage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            Expanded(
              child: Container(
                  color: const Color.fromARGB(255, 255, 255, 255), child: page),
            )
          ],
        ),
        bottomNavigationBar: BottomAppBar(
            color: const Color.fromARGB(255, 29, 29, 29),
            child: IconTheme(
                data: IconThemeData(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      onPressed: () {
                        setState(() {
                          selectedIndex = 0;
                        });
                      },
                      icon: const Icon(Icons.account_box),
                      tooltip: 'Menu',
                    ),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            selectedIndex = 1;
                          });
                        },
                        icon: const Icon(Icons.menu)),
                  ],
                ))),
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
  Future<void>? _futureData;

  String displayMoney(double amount) {
    final text = amount.toString();
    final euro = text.split('.')[0];
    final cents = text.split('.')[1];

    if (int.parse(cents) <= 9) {
      return "$euro.0$cents€";
    } else {
      return "$euro.$cents€";
    }
  }

  Future<void> fetchData() async {
    final DatabaseHelper dbhelper = DatabaseHelper();
    var accounts = await dbhelper.accounts();

    setState(() {
      _data = accounts;
    });
  }

  void _setData() {
    setState(() {
      _futureData = fetchData();
    });
  }

  @override
  void initState() {
    super.initState();
    _setData();
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
        Center(child: Text('Startseite', style: TextStyle(fontSize: 24))),
        SizedBox(height: 30),
        FutureBuilder(
            future: _futureData,
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListBody(
                  children: [Center(child: CircularProgressIndicator())],
                );
              } else if (snapshot.connectionState == ConnectionState.done &&
                  _data.isEmpty) {
                return ListBody(
                  children: [
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
                        child: Column(children: [
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
                              if (value.length >= 15) {
                                return "Es können maximal 15 Zeichen genutzt werden.";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                String name = _nameEditingController.text;
                                Account account =
                                    Account(id: 0, name: name, total: 0.00);

                                DatabaseHelper dh = DatabaseHelper();
                                await dh.insertAccount(account);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Der Account wurde erstellt.')),
                                );

                                // Reload the data and update the UI
                                _setData();
                              }
                            },
                            child: Text("Bestätigen"),
                          ),
                        ])),
                  ],
                );
              } else if (snapshot.connectionState == ConnectionState.done &&
                  _data.isNotEmpty) {
                return ListBody(
                  children: [
                    Center(
                      child: Text(_data.first.name,
                          style: TextStyle(fontSize: 32)),
                    ),
                    SizedBox(height: 30),
                    Center(
                      child: Text("Ausgaben", style: TextStyle(fontSize: 24)),
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: Text(
                        displayMoney(_data.first.total),
                        style: TextStyle(fontSize: 32),
                      ),
                    ),
                  ],
                );
              } else {
                return Center(
                    child: Text('Es gab einen Fehler beim laden der Daten.'));
              }
            }),
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

class ExpensePage extends StatefulWidget {
  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  final _formKey = GlobalKey<FormState>();

  List<Expense> _expenses = [];
  List<Category> _categories = [];
  Future<void>? _futureData;

  Future<void> fetchData() async {
    final DatabaseHelper dbhelper = DatabaseHelper();
    var expenses = await dbhelper.expenses();
    var categories = await dbhelper.categories();
    print(categories);

    setState(() {
      _expenses = expenses;
      _categories = categories;
    });
  }

  void _setData() {
    setState(() {
      _futureData = fetchData();
    });
  }

  @override
  void initState() {
    super.initState();
    _setData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
        children: [
        Expanded(
            child: ListView(children: [
          SizedBox(height: 10),
          Center(child: Text('Ausgaben', style: TextStyle(fontSize: 24))),
          SizedBox(height: 30),
          FutureBuilder(
              future: _futureData,
              builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                // Loading/Waiting
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListBody(
                    children: [
                      Center(
                        child: CircularProgressIndicator(),
                      )
                    ],
                  );
                } else if (snapshot.connectionState == ConnectionState.done &&
                    _expenses.isEmpty) {
                  return ListBody(
                    children: [
                      Text(
                        "Es wurden noch keine Ausgaben erfasst. Zum erfassen einer Ausgabe, drücken Sie einfach auf das Plus Symbol.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      )
                    ],
                  );
                } else {
                  return ListBody(
                    children: [
                      for (var expense in _expenses)
                        ListTile(
                          title: Text(expense.title),
                          subtitle: Text("$expense.createdOn"),
                          trailing: Text("$expense.amount"),
                        ),
                    ],
                  );
                }
              })
        ])),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            onPressed: () {
              _showAddExepenseForm(context, _categories);
            },
            icon: Icon(Icons.add),
            label: Text(""),
            style: ElevatedButton.styleFrom(
              iconColor: Colors.white,
              backgroundColor: Colors.black,
              shape: StadiumBorder(), // Makes the button pill-shaped
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        )
      ],
    ));
  }
}

void _showAddExepenseForm(BuildContext context, List<Category> categories) {
  print(categories);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Add an expense"),
        content: SingleChildScrollView(
          child: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: "Titel"),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Summe"),
                ),
                DropdownButton(
                  hint: Text("Kategorie"),
                  items: categories.map(
                    (category) {
                      return DropdownMenuItem(value: category.id, child: Text(category.name));
                    }
                  ).toList(), 
                  onChanged: (value) {
                    print(value);
                  })
              ],
            )
          )
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Abbrechen")
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();

            }, child: Text("Ok"))
        ],
      );
    }
  );
}