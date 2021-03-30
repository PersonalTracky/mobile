import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;
import 'package:graphql_flutter/graphql_flutter.dart';
import 'dart:developer';

Future main() async {
  await DotEnv.load(fileName: ".env");
  await initHiveForFlutter();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final HttpLink httpLink = HttpLink(
      DotEnv.env['GRAPHQL_URL'],
    );
    log('GraphQL origin: ' +  DotEnv.env['GRAPHQL_URL']);
    ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        link: httpLink,
        // The default store is the InMemoryStore, which does NOT persist to disk
        cache: GraphQLCache(store: HiveStore()),
      ),
    );
    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String meQuery = '''
      query Me {
      me {
        id
        username
        profilePictureUrl
      }
    }
  ''';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Test'),
        ),
        body: Query(
          options: QueryOptions(
            document: gql(meQuery),
          ),
          builder: (QueryResult result,
              {Refetch refetch, FetchMore fetchMore}) {
            if (result.hasException) {
              return Text(result.exception.toString());
            }
            if (result.data == null) {
              return Center(
                child: Text("Loading..."),
              );
            } else {
              return Text(result.data["me"]);
            }
          },
        ),
      ),
    );
  }
}
