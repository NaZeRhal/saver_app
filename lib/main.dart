import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saver_app/models/transaction.dart';
import 'package:saver_app/widgets/chart.dart';
import 'package:saver_app/widgets/new_transaction.dart';
import 'package:saver_app/widgets/ttx_list.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setPreferredOrientations(
  //   [
  //     DeviceOrientation.portraitUp,
  //     DeviceOrientation.portraitDown,
  //   ],
  // );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saver App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        accentColor: Colors.amber,
        fontFamily: 'BalsamiqSans',
        textTheme: ThemeData.light().textTheme.copyWith(
              title: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              button: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
        appBarTheme: AppBarTheme(
          textTheme: ThemeData.light().textTheme.copyWith(
                title: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  bool _showChart = false;

  @override
  void initState() {
    //add lifecycle listener
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    //remove lifecycle listner
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  final List<Transaction> _userTransactions = [];
  //   Transaction(
  //       id: 't1', title: 'New Shoes', amount: 69.99, date: DateTime.now()),
  //   Transaction(
  //       id: 't2',
  //       title: 'Cinema',
  //       amount: 29.99,
  //       date: DateTime.now().subtract(Duration(days: 3))),
  //   Transaction(
  //       id: 't2',
  //       title: 'Cafe',
  //       amount: 41.79,
  //       date: DateTime.now().subtract(Duration(days: 3))),
  //   Transaction(
  //       id: 't3',
  //       title: 'Biking to London',
  //       amount: 99.99,
  //       date: DateTime.now().subtract(Duration(days: 2))),
  //   Transaction(
  //       id: 't4',
  //       title: 'New Book',
  //       amount: 19.99,
  //       date: DateTime.now().subtract(Duration(days: 1))),
  //   Transaction(
  //       id: 't4',
  //       title: 'Sport',
  //       amount: 39.59,
  //       date: DateTime.now().subtract(Duration(days: 1))),
  // ];

  List<Transaction> get _recentTransactions {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(DateTime.now().subtract(Duration(days: 7)));
    }).toList();
  }

  void _addNewTransaction(Transaction transaction) {
    setState(() {
      _userTransactions.add(transaction);
    });
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((element) => element.id == id);
    });
  }

  void _startAddingNewTransaction(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return GestureDetector(
            onTap: () {},
            child: NewTransaction(addTransaction: _addNewTransaction),
            behavior: HitTestBehavior.opaque,
          );
        });
  }

  List<Widget> _buildLandscapeContent(MediaQueryData mediaQuery, AppBar appBar,
      Widget transactionListContainer) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Show Chart',
            style: Theme.of(context).textTheme.title,
          ),
          Switch.adaptive(
            activeColor: Theme.of(context).accentColor,
            value: _showChart,
            onChanged: (val) {
              setState(() {
                _showChart = val;
              });
            },
          ),
        ],
      ),
      _showChart
          ? Container(
              height: (mediaQuery.size.height -
                      appBar.preferredSize.height -
                      mediaQuery.padding.top) *
                  0.65,
              child: Chart(recentTransactions: _recentTransactions),
            )
          : transactionListContainer
    ];
  }

  List<Widget> _buildPortraitContent(MediaQueryData mediaQuery, AppBar appBar,
      Widget transactionListContainer) {
    return [
      Container(
        height: (mediaQuery.size.height -
                appBar.preferredSize.height -
                mediaQuery.padding.top) *
            0.3,
        child: Chart(recentTransactions: _recentTransactions),
      ),
      transactionListContainer
    ];
  }

  Widget _buildCupertinoNavBar() {
    return CupertinoNavigationBar(
      middle: Text(
        'Saver App',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            child: Icon(CupertinoIcons.add),
            onTap: () => _startAddingNewTransaction(context),
          )
        ],
      ),
    );
  }

  Widget _buildMaterialAppBar() {
    return AppBar(
      title: Text(
        'Saver App',
        style: TextStyle(fontFamily: 'OpenSans'),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () => _startAddingNewTransaction(context),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final PreferredSizeWidget appBar =
        Platform.isIOS ? _buildCupertinoNavBar() : _buildMaterialAppBar();

    final transactionListContainer = Container(
      height: (mediaQuery.size.height -
              appBar.preferredSize.height -
              mediaQuery.padding.top) *
          0.7,
      child: TransactionList(
        transactions: _userTransactions,
        deleteTransaction: _deleteTransaction,
      ),
    );

    final mainPageBody = SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            if (isLandscape)
              ..._buildLandscapeContent(
                mediaQuery,
                appBar,
                transactionListContainer,
              ),
            if (!isLandscape)
              ..._buildPortraitContent(
                mediaQuery,
                appBar,
                transactionListContainer,
              ),
          ],
        ),
      ),
    );

    return Platform.isIOS
        ? CupertinoPageScaffold(
            child: mainPageBody,
            navigationBar: appBar,
          )
        : Scaffold(
            appBar: appBar,
            body: mainPageBody,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Platform.isIOS
                ? Container()
                : FloatingActionButton(
                    onPressed: () => _startAddingNewTransaction(context),
                    child: Icon(
                      Icons.add,
                      color: Theme.of(context).textTheme.button.color,
                    ),
                  ),
          );
  }
}
