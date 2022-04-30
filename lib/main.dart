import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:cats_facts/api.dart';
import 'package:cats_facts/theme_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class NoThumbScrollBehavior extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
      };
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeModel(),
      child: Consumer<ThemeModel>(
          builder: (context, ThemeModel themeNotifier, child) {
        return MaterialApp(
          title: 'Cats Facts',
          scrollBehavior: NoThumbScrollBehavior().copyWith(scrollbars: false),
          theme: ThemeData(
              fontFamily: "HeyComic",
              brightness:
                  themeNotifier.isDark ? Brightness.dark : Brightness.light,
              tooltipTheme: TooltipThemeData(
                  waitDuration: const Duration(milliseconds: 500),
                  textStyle: TextStyle(
                      fontFeatures: const [FontFeature.proportionalFigures()],
                      fontSize: 15,
                      color: themeNotifier.isDark
                          ? Colors.black87
                          : Colors.white))),
          themeMode: themeNotifier.isDark ? ThemeMode.dark : ThemeMode.light,
          debugShowCheckedModeBanner: false,
          home: const MyHomePage(title: 'Cats Facts'),
        );
      }),
    );
  }
}

class MyHomePage extends StatefulHookWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<Fact> futureFact;

  Future<Fact> _fetchData() async {
    final response = await http
        .get(Uri.parse('https://cat-fact.herokuapp.com/facts/random'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Fact.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load fact');
    }
  }

  @override
  Widget build(BuildContext context) {
    final _counter = useState(0);

    useEffect(() {
      futureFact = _fetchData();
      return null;
    }, [_counter.value]);

    return Consumer<ThemeModel>(
        builder: (context, ThemeModel themeNotifier, child) {
      return DefaultTabController(
          length: 0,
          child: Scaffold(
              body: NestedScrollView(
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      SliverAppBar(
                        backgroundColor: themeNotifier.isDark
                            ? Colors.black54
                            : Colors.amber,
                        title: InkWell(
                          onTap: () {
                            launchUrl(
                                Uri.parse('https://cat-fact.herokuapp.com/#/'));
                          },
                          child: Row(
                            children: [
                              const Image(
                                image: AssetImage('assets/images/64.png'),
                                width: 45,
                                height: 45,
                              ),
                              const SizedBox(width: 10),
                              Text('Cats Facts',
                                  style: TextStyle(
                                      color: themeNotifier.isDark
                                          ? Colors.amber
                                          : Colors.black87,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 26,
                                      fontFeatures: const [
                                        FontFeature.proportionalFigures()
                                      ]))
                            ],
                          ),
                        ),
                        // centerTitle: true,
                        pinned: true,
                        floating: true,
                        actions: [
                          IconButton(
                              tooltip: themeNotifier.isDark
                                  ? 'Light theme'
                                  : 'Dark theme',
                              splashRadius: 20,
                              onPressed: () {
                                themeNotifier.isDark
                                    ? themeNotifier.isDark = false
                                    : themeNotifier.isDark = true;
                              },
                              color: themeNotifier.isDark
                                  ? Colors.amber
                                  : Colors.black87,
                              icon: Icon(themeNotifier.isDark
                                  ? Icons.nightlight_round
                                  : Icons.wb_sunny)),
                          IconButton(
                              tooltip: 'New fact',
                              splashRadius: 20,
                              color: themeNotifier.isDark
                                  ? Colors.amber
                                  : Colors.black87,
                              icon: const Icon(Icons.refresh),
                              onPressed: () => _counter.value++)
                        ],
                      ),
                    ];
                  },
                  body: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Center(
                      child: FutureBuilder<Fact>(
                        future: futureFact,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              snapshot.data!.text,
                              style: const TextStyle(fontSize: 22),
                            );
                          } else if (snapshot.hasError) {
                            return Text(
                              '${snapshot.error}',
                              style: const TextStyle(fontSize: 22),
                            );
                          }

                          // By default, show a loading spinner.
                          return const CircularProgressIndicator(
                            color: Colors.amber,
                          );
                        },
                      ),
                    ),
                  ))));
    });
  }
}
