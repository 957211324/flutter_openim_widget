import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// message content: @uid1 @uid2 xxxxxxx
///
class ChatAtText extends StatelessWidget {
  final String text;
  final String? prefixText;
  final TextStyle? atTextStyle;
  final TextStyle? urlTextStyle;
  final TextStyle? textStyle;
  final TextStyle? prefixTextStyle;
  final ValueChanged<String>? onClickAt;
  final ValueChanged<String>? onClickUrl;

  /// isReceived ? TextAlign.left : TextAlign.right
  final TextAlign textAlign;
  final TextOverflow overflow;
  final int? maxLines;

  /// all user info
  /// key:userid
  /// value:username
  final Map<String, String> allAtMap;

  // final TextAlign textAlign;
  const ChatAtText({
    Key? key,
    required this.text,
    required this.allAtMap,
    this.textAlign = TextAlign.left,
    this.overflow = TextOverflow.clip,
    this.prefixText,
    this.onClickAt,
    this.onClickUrl,
    // this.textAlign = TextAlign.start,
    this.textStyle,
    this.atTextStyle,
    this.urlTextStyle,
    this.prefixTextStyle,
    this.maxLines,
  }) : super(key: key);

  static var _textStyle = TextStyle(
    fontSize: 14.sp,
    color: Color(0xFF333333),
  );

  static var _atTextStyle = TextStyle(
    color: Color(0xFF1B72EC),
    fontSize: 14.sp,
  );

  static var _urlTextStyle = TextStyle(
    color: Color(0xFF1B72EC),
    fontSize: 14.sp,
    decoration: TextDecoration.underline,
  );

  //
  // static var _httpExp = RegExp(
  //     r"^((((H|h)(T|t)|(F|f))(T|t)(P|p)((S|s)?))\://)?(www.|[a-zA-Z0-9].)[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,6}(\:[0-9]{1,5})*(/($|[a-zA-Z0-9\.\,\;\?\'\\\+&amp;%\$#\=~_\-]+))*$");

  static var _httpExp = RegExp(
      r"((https?|ftp|smtp):\/\/)?(www.)?[a-z0-9]+(\.[a-z]+)+(\/[a-zA-Z0-9#]+\/?)*");

  static var _atExp = RegExp(r"(@\S+\s)");

  @override
  Widget build(BuildContext context) {
    final List<InlineSpan> children = <InlineSpan>[];
    if (prefixText != null && "" != prefixText) {
      children.add(TextSpan(text: prefixText, style: prefixTextStyle));
    }
    var style = textStyle ?? _textStyle;
    var atStyle = atTextStyle ?? _atTextStyle;
    var urlStyle = urlTextStyle ?? _urlTextStyle;

    // match at text
    text.splitMapJoin(
      _atExp,
      onMatch: (Match m) {
        late InlineSpan inlineSpan;
        String uid = m.group(0)!.replaceAll("@", "").trim();
        if (allAtMap.containsKey(uid)) {
          var name = allAtMap[uid]!;
          inlineSpan = WidgetSpan(
            child: GestureDetector(
              onTap: null != onClickAt
                  ? () {
                      print('click:$uid');
                      onClickAt!(uid);
                    }
                  : null,
              behavior: HitTestBehavior.translucent,
              child: Text('@$name ', style: atStyle),
            ),
          );
        } else {
          inlineSpan = TextSpan(text: '${m.group(0)}', style: style);
        }
        children.add(inlineSpan);
        return m.group(0)!;
      },
      onNonMatch: (text) {
        // match url text
        text.splitMapJoin(
          _httpExp,
          onMatch: (Match m) {
            String url = m.group(0)!;
            var inlineSpan = WidgetSpan(
              child: GestureDetector(
                onTap: onClickUrl != null
                    ? () {
                        print('click:$url');
                        onClickUrl?.call(url);
                      }
                    : null,
                behavior: HitTestBehavior.translucent,
                child: Text('$url', style: urlStyle),
              ),
            );
            children.add(inlineSpan);
            return m.group(0)!;
          },
          onNonMatch: (text) {
            children.add(TextSpan(text: text, style: style));
            return text;
          },
        );
        return text;
      },
    );

    return Container(
      constraints: BoxConstraints(maxWidth: 0.5.sw),
      child: RichText(
        textAlign: textAlign,
        overflow: overflow,
        maxLines: maxLines,
        text: TextSpan(children: children),
      ),
    );
  }
}
