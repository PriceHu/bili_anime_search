import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class AnimeListPage extends StatefulWidget {
  AnimeListPage(this.data);

  final List data;

  @override
  State<StatefulWidget> createState() => _AnimeListPageState();
}

class _AnimeListPageState extends State<AnimeListPage> {
  String keyword = '';
  late List content;

  @override
  void initState() {
    content = widget.data;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 60.0,
          padding: EdgeInsets.only(right: 16.0, left: 16.0, top: 8.0),
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
                  Icons.search,
                  color: Theme.of(context).accentColor,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(12.0),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 180,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 9.0 / 17.0,
            ),
            itemBuilder: _itemBuilder,
            // itemCount: 3,
            itemCount: content.length,
          ),
        )
      ],
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
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
            httpHeaders: {
              'Accept':
                  'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
              'Referer': 'https://www.bilibili.com/',
              'Origin': 'https://www.bilibili.com',
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.164 Safari/537.36',
            },
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
                child: Stack(
                  children: stack,
                )),
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

  void _search() {
    log('searching: $keyword');
    if (keyword == '') {
      setState(() {
        content = widget.data;
      });
    } else {
      content = [];
      for (var anime in widget.data) {
        if (anime['title'].toString().contains(keyword)) {
          content.add(anime);
        }
      }
      setState(() {});
    }
  }

  void _launch(String url) async {
    try {
      await launch(url);
    } catch (e) {
      log('$e');
    }
  }
}
