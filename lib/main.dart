import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'VehicleMaintenancePage.dart';
import 'expense_tracker_page.dart';
import 'customer_list_page.dart';
import 'database.dart';
import 'event_planner_page.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  runApp(MyApp(database:database));
}
/*Future<void> main() async {
  var delegate = await LocalizationDelegate.create(
      fallbackLocale: 'en',
      supportedLocales: ['en', 'ko']
  );
  final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  runApp(LocalizedApp(delegate, MyApp(database: database,)));
}*/

class MyApp extends StatelessWidget {
  final AppDatabase database;
  const MyApp({super.key , required this.database });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    /*var localizationDelegate = LocalizedApp.of(context).delegate;

    return LocalizationProvider(
      state: LocalizationProvider.of(context).state,
      child: MaterialApp(
        title: 'Flutter Demo',
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          localizationDelegate
        ],
        supportedLocales: localizationDelegate.supportedLocales,
        locale: localizationDelegate.currentLocale,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),*/
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),

        home: const MyHomePage(title: 'Final Project Assignment Home Page'),
        routes: {
          '/EventPlanner': (context) {
            return EventplannerPage();
          },
          '/CustomerList': (context) {
            return CustomerListPage();
          },
          '/ExpenseTracker': (context) {
            return ExpenseTrackerPage();
          },
          //'/ExpenseTracker: (context) => ExpenseTrackerPage(),

          '/VehicleMaintenance': (context) {
            return VehicleMaintenancePage(database:database);
          }
        });

  }
}

/// MyHomePage
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = screenWidth / 3;
    final buttonHeight = buttonWidth / 2;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, "/EventPlanner").then((_) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyHomePage(
                                  title:
                                  "Final Project Assignment - Event Planner")),
                        );
                      });
                    },
                    child: const Text('Event Planner'),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, "/CustomerList").then((_) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyHomePage(
                                  title:
                                  "Final Project Assignment -Customer List")),
                        );
                      });
                    },
                    child: const Text('Customer List'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, "/ExpenseTracker").then((_) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyHomePage(
                                  title:
                                  "Final Project Assignment - Expense Tracker")),
                        );
                      });
                    },
                    child: const Text('Expense Tracker'),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, "/VehicleMaintenance")
                          .then((_) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyHomePage(
                                  title:
                                  "Final Project Assignment - Vehicle Maintenance")),
                        );
                      });
                    },
                    child: const Text('Vehicle Maintenance'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
