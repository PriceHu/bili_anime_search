const BiliHeaders = {
  'Accept':
      'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
  'Referer': 'https://www.bilibili.com/',
  'Origin': 'https://www.bilibili.com',
  'User-Agent':
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.164 Safari/537.36',
};

extension StringUtil on String {
  // TODO
  Set<String> toKeywords() {
    return (this.toLowerCase().split(RegExp(
            '[ ·！…（）【】《》—、，。？；：‘’“”~!@#\$%^&*()\\-=_+\\[\\]{}\\\\|;:\'",.<>/?]'))
          ..removeWhere((e) => e == ''))
        .toSet();
  }
}

extension Paging on List {
  List getPage(int page, int pageLength) {
    if (page * pageLength > length) {
      return [];
    } else {
      return this.sublist(page * pageLength,
          (page + 1) * pageLength > length ? length : (page + 1) * pageLength);
    }
  }
}
