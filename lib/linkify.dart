abstract class LinkifyElement {}

/// Represents an element containing a link
class LinkElement extends LinkifyElement {
  final String url;
  final String text;

  LinkElement(this.url, [String text]) : this.text = text ?? url;

  @override
  String toString() {
    return "LinkElement: $url ($text)";
  }
}

/// Represents an element containing text
class TextElement extends LinkifyElement {
  final String text;

  TextElement(this.text);

  @override
  String toString() {
    return "TextElement: $text";
  }
}

final _linkifyRegex = RegExp(
  r"(\n*?.*?\s*?)((?:https?):\/\/[^\s/$.?#].[^\s]*)",
  caseSensitive: false,
);

/// Turns [text] into a list of [LinkifyElement]
///
/// Use [humanize] to remove http/https from the start of the URL shown.
List<LinkifyElement> linkify(String text,
    {bool humanize = false, List<String> aliases, int aliasIndex = 0}) {
  final list = List<LinkifyElement>();
  if (aliases == null) {
    aliases = [];
  }

  if (text == null || text.isEmpty) {
    return list;
  }

  final match = _linkifyRegex.firstMatch(text);
  if (match == null) {
    list.add(TextElement(text));
  } else {
    text = text.replaceFirst(_linkifyRegex, "");

    if (match.group(1).isNotEmpty) {
      list.add(TextElement(match.group(1)));
    }

    if (match.group(2).isNotEmpty) {
      if (humanize ?? false) {
        print("humanizing ${match.group(2)}");
        list.add(LinkElement(
          match.group(2),
          aliases.length >= aliasIndex
              ? aliases[aliasIndex]
              : match.group(2).replaceFirst(RegExp(r"https?://"), ""),
        ));
      } else {
        print("not humanizing ${match.group(2)}");
        list.add(LinkElement(match.group(2)));
      }
    }

    list.addAll(linkify(text,
        humanize: humanize, aliases: aliases, aliasIndex: ++aliasIndex));
  }

  return list;
}
