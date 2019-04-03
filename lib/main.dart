import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:youtube_api/youtube_api.dart';

import 'package:flutter_youtube_view/flutter_youtube_view.dart';

import '_constants.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  Route _route(RouteSettings settings) {
    switch (settings.name) {
      case '/player':
        return MaterialPageRoute(builder: (BuildContext ctx) {
          return Player(id: settings.arguments);
        });
      case '/':
      default:
        return MaterialPageRoute(builder: (BuildContext ctx) {
          return VList();
        });
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return MaterialApp(
      title: Prefs.title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: _route,
    );
  }
}

class VList extends StatefulWidget {
  @override
  _VListState createState() => _VListState();
}

class _VListState extends State<VList> {
  YoutubeAPI _ytApi = YoutubeAPI(Prefs.key);
  String _word = null;
  TextEditingController _ctrl = TextEditingController();

  Future<List<YT_API>> _search(String word) async {
    return word == null
        ? await _ytApi.search('', type: 'video')
        : await _ytApi.search(word);
  }

  List<Widget> _makeItems(List<YT_API> data) {
    if (data == null) return [];
    return List<Widget>.from(data
        .map((item) => ListTile(
              leading: Image.network(item.thumbnail['default']['url']),
              title: Text(item.title),
              subtitle: Text(item.description),
              onTap: () {
                Navigator.of(context).pushNamed(
                  '/player',
                  arguments: item.id,
                );
              },
            ))
        .toList());
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Prefs.title),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext ctx) {
                  return AlertDialog(
                    title: Text(Prefs.search),
                    content: TextField(
                      controller: _ctrl,
                      autofocus: true,
                      onSubmitted: (String text) {
                        setState(() {
                          _word = text;
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text(Prefs.search),
                        onPressed: () {
                          setState(() {
                            _word = _ctrl.value.text;
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            tooltip: Prefs.search,
            icon: Icon(Icons.search),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _search(_word),
        builder: (BuildContext ctx, AsyncSnapshot<List<YT_API>> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            );
          } else {
            return ListView(children: _makeItems(snapshot.data));
          }
        },
      ),
    );
  }
}

class Player extends StatefulWidget {
  final String id;

  Player({this.id});

  _PlayerState createState() => _PlayerState(id: id);
}

class _PlayerState extends State<Player> implements YouTubePlayerListener {
  final String id;
  FlutterYoutubeViewController _ctrl;
  String _error = '';

  _PlayerState({this.id});

  void _onCreated(FlutterYoutubeViewController ctrl) {
    this._ctrl = ctrl;
  }

  @override
  void onReady() {}

  @override
  void onStateChange(String state) {}

  @override
  void onError(String error) {
    _error = error;
    setState(() {});
  }

  @override
  void onVideoDuration(double duration) {}

  @override
  void onCurrentSecond(double second) {}

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(),
      body: _error.length > 0
          ? Center(child: Text('Erorr: $_error'))
          : Stack(
              children: <Widget>[
                Container(
                  child: FlutterYoutubeView(
                    onViewCreated: _onCreated,
                    listener: this,
                    params: YoutubeParam(
                        videoId: id, showUI: true, startSeconds: 0.0),
                  ),
                ),
              ],
            ),
    );
  }
}
