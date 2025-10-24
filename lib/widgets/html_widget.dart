import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

/// A lightweight HTML renderer tailored to the needs of this app.
///
/// The widget supports a curated subset of HTML tags that are commonly
/// returned by the nutrition summaries, including paragraphs, emphasis and
/// basic lists. Rendering is kept deliberately small to avoid bringing in the
/// heavy dependency that no longer compiles on the latest Flutter versions.
class HtmlWidget extends StatelessWidget {
  const HtmlWidget(
    this.html, {
    super.key,
    this.textStyle,
  });

  /// Raw HTML content to render.
  final String html;

  /// Optional style applied to the entire block.
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    if (html.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final fragment = html_parser.parseFragment(html);
    final baseStyle = textStyle ?? DefaultTextStyle.of(context).style;
    final blocks = _buildBlockWidgets(fragment.nodes, baseStyle);

    if (blocks.isEmpty) {
      return const SizedBox.shrink();
    }

    if (blocks.length == 1) {
      return blocks.first;
    }

    final children = <Widget>[];
    for (var i = 0; i < blocks.length; i++) {
      children.add(blocks[i]);
      if (i != blocks.length - 1) {
        children.add(const SizedBox(height: 8));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

List<Widget> _buildBlockWidgets(List<dom.Node> nodes, TextStyle baseStyle) {
  final widgets = <Widget>[];

  for (final node in nodes) {
    final widget = _buildBlockWidget(node, baseStyle);
    if (widget != null) {
      widgets.add(widget);
    }
  }

  return widgets;
}

Widget? _buildBlockWidget(dom.Node node, TextStyle baseStyle) {
  if (node is dom.Text) {
    final text = node.text.trim();
    if (text.isEmpty) {
      return null;
    }

    return Text(
      _normalizeBlockText(text),
      style: baseStyle,
    );
  }

  if (node is dom.Element) {
    switch (node.localName) {
      case 'p':
      case 'div':
        final span = _buildInlineSpan(node.nodes, baseStyle);
        if (_spanIsEmpty(span)) {
          return null;
        }
        return Text.rich(
          span,
          textAlign: TextAlign.start,
        );
      case 'br':
        return const SizedBox(height: 8);
      case 'ul':
        return _buildList(node.children, baseStyle, ordered: false);
      case 'ol':
        return _buildList(node.children, baseStyle, ordered: true);
      default:
        final span = _buildInlineSpan(node.nodes, baseStyle);
        if (_spanIsEmpty(span)) {
          return null;
        }
        return Text.rich(span);
    }
  }

  return null;
}

Widget _buildList(List<dom.Element> items, TextStyle baseStyle, {required bool ordered}) {
  final rows = <Widget>[];
  var index = 1;

  for (final element in items) {
    if (element.localName != 'li') {
      continue;
    }

    final span = _buildInlineSpan(element.nodes, baseStyle);
    if (_spanIsEmpty(span)) {
      continue;
    }

    final marker = ordered ? '$index.' : '•';
    index++;

    rows.add(
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            marker,
            style: baseStyle,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              span,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: rows,
  );
}

TextSpan _buildInlineSpan(List<dom.Node> nodes, TextStyle baseStyle) {
  final children = <InlineSpan>[];

  for (final node in nodes) {
    final span = _buildSpan(node, baseStyle);
    if (span != null) {
      children.add(span);
    }
  }

  return TextSpan(style: baseStyle, children: children);
}

InlineSpan? _buildSpan(dom.Node node, TextStyle baseStyle) {
  if (node is dom.Text) {
    final text = _collapseWhitespace(node.text);
    if (text.trim().isEmpty) {
      return null;
    }
    return TextSpan(text: text);
  }

  if (node is dom.Element) {
    switch (node.localName) {
      case 'br':
        return const TextSpan(text: '\n');
      case 'strong':
      case 'b':
        return _buildStyledSpan(node, baseStyle, const TextStyle(fontWeight: FontWeight.bold));
      case 'em':
      case 'i':
        return _buildStyledSpan(node, baseStyle, const TextStyle(fontStyle: FontStyle.italic));
      case 'u':
        return _buildStyledSpan(node, baseStyle, const TextStyle(decoration: TextDecoration.underline));
      case 'a':
        return _buildStyledSpan(
          node,
          baseStyle,
          const TextStyle(
            decoration: TextDecoration.underline,
            color: Colors.blue,
          ),
        );
      default:
        final childSpan = _buildInlineSpan(node.nodes, baseStyle);
        if (_spanIsEmpty(childSpan)) {
          return null;
        }
        return childSpan;
    }
  }

  return null;
}

InlineSpan? _buildStyledSpan(dom.Element element, TextStyle baseStyle, TextStyle modifier) {
  final mergedStyle = baseStyle.merge(modifier);
  final span = _buildInlineSpan(element.nodes, mergedStyle);
  if (_spanIsEmpty(span)) {
    return null;
  }
  return TextSpan(style: mergedStyle, children: span.children);
}

bool _spanIsEmpty(TextSpan span) {
  final queue = <InlineSpan>[span];

  while (queue.isNotEmpty) {
    final current = queue.removeLast();
    if (current is TextSpan) {
      if ((current.text ?? '').trim().isNotEmpty) {
        return false;
      }
      if (current.children != null) {
        queue.addAll(current.children!);
      }
    }
  }

  return true;
}

String _collapseWhitespace(String input) {
  return input.replaceAll(RegExp(r'\s+'), ' ');
}

String _normalizeBlockText(String input) {
  return _collapseWhitespace(input).trim();
}
