import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:youtube_api/youtube_api.dart';

import 'package:flutter_youtube_view/flutter_youtube_view.dart';

import '_constants.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  Route _getRoute(RouteSettings settings) {
    String videoId;
    switch (settings.name) {
      case '/player':
        return new MaterialPageRoute(builder: (BuildContext context) {
          return new VideoPlayer(videoId: videoId);
        });
      case '/':
      default:
        return new MaterialPageRoute(builder: (BuildContext context) {
          return new VideoList();
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
  _VideoListState createState() => new _VideoListState();
}

class _VideoListState extends State<VideoList> {
  static YoutubeAPI api = new YoutubeAPI(Constants.key);
  static String word = null;

  Future<List<YT_API>> _search(String word) {
    if (word == null)
      return api.search(null, type: 'channel');
    else
      return api.search(word);
  }

  List<Widget> _getListItems(List<YT_API> data) {
    if (data == null) return [];
    return new List<Widget>.from(data
        .map((item) => ListTile(
              leading: Image.network(item.thumbnail['default']),
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
      appBar: new AppBar(
        title: Text(Constants.title),
        actions: <Widget>[
          new IconButton(
            onPressed: null, //TODO dialog
            tooltip: Constants.search,
            icon: new Icon(Icons.search),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _search(word),
        builder: (BuildContext context, AsyncSnapshot<List<YT_API>> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
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
