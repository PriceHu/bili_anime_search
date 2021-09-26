import 'dart:collection';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

import 'main.dart';
import 'utils.dart';

class AnimeListPage extends StatefulWidget {
  AnimeListPage(this.data, this.viewStateStream);

  final List data;
  final Stream<ViewState> viewStateStream;

  @override
  State<StatefulWidget> createState() => _AnimeListPageState();
}

class _AnimeListPageState extends State<AnimeListPage> {
  String keyword = '';
  List searchResult = [];
  late List content;
  ViewState viewState = ViewState.grid;
  final ScrollController scrollController = ScrollController();

  static const int pageLength = 15;
  int page = 0;

  @override
  void initState() {
    content = widget.data.sublist(0, pageLength);
    widget.viewStateStream.listen((event) {
      setState(() {
        viewState = event;
      });
    });
    scrollController.addListener(_pagination);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget resultList;
    switch (viewState) {
      case ViewState.list:
        resultList = ListView.builder(
          itemBuilder: _listItemBuilder,
          itemCount: content.length,
          controller: scrollController,
        );
        break;
      case ViewState.grid:
      default:
        resultList = GridView.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 180,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 9.0 / 17.0,
          ),
          itemBuilder: _gridItemBuilder,
          // itemCount: 3,
          itemCount: content.length,
          controller: scrollController,
        );
        break;
    }
    return Column(
      children: [
        Container(
          height: 60.0,
          padding: EdgeInsets.only(right: 16.0, left: 16.0, top: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(right: 8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '搜索',
                      hintText: '请输入番剧名称',
                    ),
                    textAlignVertical: TextAlignVertical.bottom,
                    textInputAction: TextInputAction.search,
                    onChanged: (str) {
                      keyword = str;
                    },
                    onSubmitted: (str) {
                      keyword = str;
                      _search();
                    },
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  _search();
                },
                icon: Icon(
                  Icons.search_rounded,
                  color: Theme.of(context).accentColor,
                ),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: resultList,
          ),
        )
      ],
    );
  }

  Widget _listItemBuilder(BuildContext context, int index) {
    return Container(
      height: 96.0,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          splashColor:
              Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
          highlightColor: Colors.transparent,
          onTap: () {
            _launch(content[index]['link']);
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AspectRatio(
                aspectRatio: 3.0 / 4.0,
                child: _buildCover(context, index),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    content[index]['title'],
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gridItemBuilder(BuildContext context, int index) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        splashColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
        highlightColor: Colors.transparent,
        onTap: () {
          _launch(content[index]['link']);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 12,
              child: _buildCover(context, index),
            ),
            Expanded(
              flex: 5,
              child: Container(
                padding: EdgeInsets.all(4.0),
                alignment: Alignment.center,
                child: Text(
                  content[index]['title'],
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCover(BuildContext context, int index) {
    List<Widget> stack = [
      Positioned.fill(
        child: Container(
          // padding: EdgeInsets.all(16.0),
          child: CachedNetworkImage(
            fit: BoxFit.cover,
            imageUrl: content[index]['cover'],
            placeholder: (context, url) {
              return Image.asset('assets/loading.png');
            },
            errorWidget: (context, url, _) {
              return Image.asset('assets/error.png');
            },
            httpHeaders: BiliHeaders,
          ),
        ),
      )
    ];
    if (content[index]['badge'] != '') {
      stack.add(Positioned(
        top: 0,
        left: 0,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Color(int.parse(
                  'FF' + content[index]['badge_info']['bg_color'].substring(1),
                  radix: 16)),
              borderRadius:
                  BorderRadius.only(bottomRight: Radius.circular(8.0))),
          child: Text(
            content[index]['badge'],
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
      ));
    }
    return Stack(children: stack);
  }

  void _search() {
    // TODO 繁化:process using script
    // TODO implement complex search
    // TODO 搜索语法
    log('searching: $keyword');
    _reset();
    if (keyword == '') {
      setState(() {
        content = widget.data.getPage(0, pageLength);
      });
    } else {
      content.clear();
      var keywords = keyword.toKeywords();
      SplayTreeMap<int, List> hitMap = SplayTreeMap((a, b) => b - a);
      for (var anime in widget.data) {
        int hit = 0;
        String title = anime['title'].toString().toLowerCase();
        keywords.forEach((e) {
          if (anime['simplified'].toString().toLowerCase().contains(e) ||
              anime['traditional'].toString().toLowerCase().contains(e)) hit++;
        });
        if (hit > 0) {
          hitMap.containsKey(hit)
              ? hitMap[hit]?.add(anime)
              : hitMap[hit] = [anime];
        }
      }
      hitMap.forEach((key, value) {
        searchResult.addAll(value);
      });
      log('search for "$keyword" returned ${searchResult.length} items.');
      setState(() {
        content = searchResult.getPage(0, pageLength);
      });
    }
  }

  void _reset() {
    searchResult.clear();
    page = 0;
    scrollController.jumpTo(0.0);
  }

  void _launch(String url) async {
    try {
      await launch(url);
    } catch (e) {
      log('$e');
    }
  }

  void _pagination() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 10.0 &&
        content.length <
            (searchResult.isEmpty ? widget.data.length : searchResult.length)) {
      setState(() {
        page += 1;
        content.addAll((searchResult.isEmpty ? widget.data : searchResult)
            .getPage(page, pageLength));
        log('loaded page ${page + 1}');
      });
    }
  }
}
