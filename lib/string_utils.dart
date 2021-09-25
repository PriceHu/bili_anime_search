extension StringUtil on String {
  Set<String> toKeywords() {
    return (this.toLowerCase().split(RegExp(
            '[ ·！…（）【】《》—、，。？；：‘’“”~!@#\$%^&*()\\-=_+\\[\\]{}\\\\|;:\'",.<>/?]'))
          ..removeWhere((e) => e == ''))
        .toSet();
  }
}
