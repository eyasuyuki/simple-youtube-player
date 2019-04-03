import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:youtube_api/youtube_api.dart';

import 'package:flutter_youtube_view/flutter_youtube_view.dart';

import '_constants.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  Route _getRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/player':
        return MaterialPageRoute(builder: (BuildContext context) {
          return VideoPlayer(videoId: settings.arguments);
        });
      case '/':
      default:
        return MaterialPageRoute(builder: (BuildContext context) {
          return VideoList();
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: _getRoute,
    );
  }
}

class VideoList extends StatefulWidget {
  @override
  _VideoListState createState() => _VideoListState();
}

class _VideoListState extends State<VideoList> {
  YoutubeAPI _api = YoutubeAPI(Constants.key);
  String _word = null;
  TextEditingController _controller = TextEditingController();

  Future<List<YT_API>> _search(String word) async {
    List<YT_API> result = <YT_API>[];
    if (word == null)
      result = await _api.search('', type: 'video');
    else
      result = await _api.search(word);
    return result;
  }

  List<Widget> _getListItems(List<YT_API> data) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Constants.title),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(Constants.search),
                    content: TextField(
                      controller: _controller,
                      autofocus: true,
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text(Constants.search),
                        onPressed: () {
                          setState(() {
                            _word = _controller.value.text;
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }, //TODO dialog
            tooltip: Constants.search,
            icon: Icon(Icons.search),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _search(_word),
        builder: (BuildContext context, AsyncSnapshot<List<YT_API>> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            );
          } else {
            return ListView(children: _getListItems(snapshot.data));
          }
        },
      ),
    );
  }
}

class VideoPlayer extends StatelessWidget implements YouTubePlayerListener {
  final String videoId;
  FlutterYoutubeViewController _controller;

  void _onYoutubeCreated(FlutterYoutubeViewController controller) {
    this._controller = controller;
  }

  VideoPlayer({this.videoId});

  @override
  void onReady() {}

  @override
  void onStateChange(String state) {}

  @override
  void onError(String error) {}

  @override
  void onVideoDuration(double duration) {}

  @override
  void onCurrentSecond(double second) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Constants.title),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            child: FlutterYoutubeView(
              onViewCreated: _onYoutubeCreated,
              listener: this,
              params: YoutubeParam(
                  videoId: videoId, showUI: true, startSeconds: 0.0),
            ),
          ),
        ],
      ),
    );
  }
}
