import 'package:chewie/chewie.dart';
import 'package:chewie/src/chewie_player.dart';
import 'package:chewie_example/menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'custom_controls.dart';
import 'package:flutter/services.dart';

Future main() async {
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    ChewieDemo(),
  );
}

class ChewieDemo extends StatefulWidget {
  ChewieDemo({this.title = 'Chewie Demo'});

  final String title;

  @override
  State<StatefulWidget> createState() {
    return _ChewieDemoState();
  }
}

class _ChewieDemoState extends State<ChewieDemo> {
  TargetPlatform _platform;
  VideoPlayerController _videoPlayerController1;
  VideoPlayerController _videoPlayerController2;
  ChewieController _chewieController;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _videoPlayerController1 =
        VideoPlayerController.network('http://res.uquabc.com/HLS_Apple/all.m3u8');
    _videoPlayerController2 = VideoPlayerController.network(
        'https://www.sample-videos.com/video123/mp4/480/asdasdas.mp4');
    _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController1,
        aspectRatio: 3 / 2,
        autoPlay: false,
        autoInitialize: true,
        looping: true,
        customControls: CustomControls(
            videoTitle: '我是测试视频啊',
            onPressMoreAction: (context) {
              Navigator.of(context)
                  .push(MenuPopRoute<Widget>(pageBuilder: (context, animation, secondaryAnimation) {
                return MoreActionWidget(_chewieController);
              }));
            }));
  }

  @override
  void dispose() {
    _videoPlayerController1.dispose();
    _videoPlayerController2.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: widget.title,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        platform: _platform ?? Theme.of(context).platform,
      ),
      home: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          children: <Widget>[
            Chewie(
              controller: _chewieController,
            ),
            FlatButton(
              onPressed: () {
                _chewieController.enterFullScreen();
              },
              child: Text('Fullscreen'),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: FlatButton(
                    onPressed: () {
                      setState(() {
                        _chewieController.dispose();
                        _videoPlayerController2.pause();
                        _videoPlayerController2.seekTo(Duration(seconds: 0));
                        _chewieController = ChewieController(
                          videoPlayerController: _videoPlayerController1,
                          aspectRatio: 3 / 2,
                          autoPlay: true,
                          looping: true,
                        );
                      });
                    },
                    child: Padding(
                      child: Text("Video 1"),
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                    ),
                  ),
                ),
                Expanded(
                  child: FlatButton(
                    onPressed: () {
                      setState(() {
                        _chewieController.dispose();
                        _videoPlayerController1.pause();
                        _videoPlayerController1.seekTo(Duration(seconds: 0));
                        _chewieController = ChewieController(
                          videoPlayerController: _videoPlayerController2,
                          aspectRatio: 3 / 2,
                          autoPlay: true,
                          looping: true,
                        );
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text("Error Video"),
                    ),
                  ),
                )
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: FlatButton(
                    onPressed: () {
                      setState(() {
                        _platform = TargetPlatform.android;
                      });
                    },
                    child: Padding(
                      child: Text("Android controls"),
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                    ),
                  ),
                ),
                Expanded(
                  child: FlatButton(
                    onPressed: () {
                      setState(() {
                        _platform = TargetPlatform.iOS;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text("iOS controls"),
                    ),
                  ),
                )
              ],
            ),
            Row(
              children: <Widget>[
                FlatButton(
                  child: Text(
                    '我是考试大纲啊   定位到1分钟',
                    style: TextStyle(color: Colors.blue),
                  ),
                  onPressed: () {
                    _chewieController.seekTo(Duration(minutes: 1));
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class MoreActionWidget extends StatefulWidget {
  final ChewieController _chewieController;

  const MoreActionWidget(this._chewieController);

  @override
  _MoreActionWidgetState createState() => _MoreActionWidgetState();
}

class _MoreActionWidgetState extends State<MoreActionWidget> {
  var resolutionsWidget = <Widget>[];

  @override
  void initState() {
    super.initState();
    if (resolutionsWidget.isEmpty) {
      widget._chewieController.videoPlayerController.getResolutions().then((value) {
        value.entries.forEach((entry) {
          resolutionsWidget.add(FlatButton(
            child: Text(
              entry.value,
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              widget._chewieController.videoPlayerController.switchResolutions(entry.key);
            },
          ));
        });
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Container(),
        ),
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.black54,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    FlatButton.icon(
                        onPressed: null,
                        icon: Icon(
                          Icons.cached,
                          color: Colors.white,
                        ),
                        label: Text(
                          '缓存',
                          style: TextStyle(color: Colors.white),
                        )),
                  ],
                ),
                Text('分辨率：'),
                Column(
                  children: resolutionsWidget,
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
