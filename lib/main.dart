import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bili_anime_search/anime_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

// TODO theme
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '哔哩哔哩番剧搜索',
      theme: ThemeData(
        primaryColor: Color(0xFFFA7299),
      ),
      home: HomePage(title: '哔哩哔哩番剧搜索'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List? data;
  final _viewStateStream = StreamController<ViewState>();
  ViewState _viewState = ViewState.grid;

  @override
  void initState() {
    super.initState();
    _viewStateStream.sink.add(_viewState);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: Icon(ViewStateDetail[_viewState.index][0]),
              tooltip: ViewStateDetail[_viewState.index][1],
              onPressed: () {
                setState(() {
                  _viewState = ViewState
                      .values[(_viewState.index + 1) % ViewState.values.length];
                  _viewStateStream.add(_viewState);
                  log('查看方式改变: ${_viewState.toString()}');
                });
              },
            ),
          ],
        ),
        body: FutureBuilder(
          future: _loadAnimeData(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      child: CircularProgressIndicator(),
                      width: 48,
                      height: 48,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text('载入中...'),
                    )
                  ],
                ),
              );
            } else {
              return AnimeListPage(data!, _viewStateStream.stream);
            }
          },
        ));
  }

  Future<bool> _loadAnimeData() async {
    log("Loading..");
    String j = await rootBundle.loadString('assets/anime.json');
    log("loaded");
    data = json.decode(j);
    log('${data!.length} 部动画已载入');
    return true;
  }

  @override
  void dispose() {
    _viewStateStream.close();
    super.dispose();
  }
}

enum ViewState {
  list,
  grid,
}
const List ViewStateDetail = [
  [Icons.view_list_rounded, 'List View'],
  [Icons.grid_view_rounded, 'Grid View'],
];
