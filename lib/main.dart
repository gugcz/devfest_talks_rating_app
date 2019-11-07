import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rating app',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.purple[800],
        accentColor: Colors.amber,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  Firestore _firestore = Firestore.instance;

  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DocumentReference chosenTalk;
  bool disabled = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  rateTalk(int rate) {
    setState(() {
      disabled = true;
    });
    widget._firestore.collection('ratings').document().setData({
      'talk': chosenTalk,
      'rate': rate
    });
    Future.delayed(Duration(seconds: 1)).then((result) => setState(() {
          disabled = false;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.list),
        onPressed: () {
          showDialog(
              context: context,
              builder: (b) {
                return AlertDialog(
                  content: Container(
                      width: double.maxFinite,
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Expanded(
                              child: StreamBuilder(
                                  stream: widget._firestore
                                      .collection('talks')
                                      .orderBy('name')
                                      .snapshots(),
                                  builder: (cont, snapshot) {
                                    if (snapshot.hasError)
                                      return new Text(
                                          'Error: ${snapshot.error}');
                                    switch (snapshot.connectionState) {
                                      case ConnectionState.waiting:
                                        return new Text('Loading...');
                                      default:
                                        return new ListView(
                                          children: snapshot.data.documents
                                              .map<Widget>((DocumentSnapshot document) {
                                            return new ListTile(
                                              title: new Text(document['name']),
                                              onTap: (){
                                                setState(() {
                                                  chosenTalk = document.reference;
                                                  disabled = false;
                                                });
                                                Navigator.of(context).pop();
                                              },
                                            );
                                          }).toList(),
                                        );
                                    }
                                  }),
                            )
                          ])),
                );
              });
        },
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.star),
              color: Colors.red[600],
              onPressed: (disabled
                  ? null
                  : () {
                      rateTalk(1);
                    }),
              iconSize: 160,
            ),
            IconButton(
              icon: Icon(Icons.star),
              color: Colors.orange[800],
              onPressed: (disabled
                  ? null
                  : () {
                      rateTalk(2);
                    }),
              iconSize: 160,
            ),
            IconButton(
              icon: Icon(Icons.star),
              color: Colors.amber[400],
              onPressed: (disabled
                  ? null
                  : () {
                      rateTalk(3);
                    }),
              iconSize: 160,
            ),
            IconButton(
              icon: Icon(Icons.star),
              color: Colors.green[800],
              onPressed: (disabled
                  ? null
                  : () {
                      rateTalk(4);
                    }),
              iconSize: 160,
            ),
          ],
        ),
      ),
    );
  }
}
