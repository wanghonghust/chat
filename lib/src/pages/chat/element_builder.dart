import 'package:chat/src/pages/chat/highlight_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markdown/markdown.dart' as md;

class CodeElementBuilder extends MarkdownElementBuilder {
  CodeElementBuilder({required this.context});
  final BuildContext context;

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    String _class = element.attributes["class"] ?? '';
    List<String> parts = _class.split('-');
    if (parts.last.isEmpty) {
      return HighlightView(
        element.textContent,
        language: parts.last,
        theme: Theme.of(context).brightness == Brightness.light
            ? blockLightTheme
            : blockDarkTheme,
        padding: const EdgeInsets.all(2),
        textStyle: GoogleFonts.robotoMono(),
      );
    }
    return Row(children: [
      Expanded(
          child: HighlightView(
        element.textContent,
        language: parts.last,
        theme: Theme.of(context).brightness == Brightness.light
            ? atomOneLightTheme
            : atomOneDarkTheme,
        padding: const EdgeInsets.all(2),
        textStyle: GoogleFonts.robotoMono(),
      ))
    ]);
  }
}

class PreElementBuilder extends MarkdownElementBuilder {
  PreElementBuilder({required this.context});
  final BuildContext context;

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    String _class = element.attributes["class"] ?? '';
    List<String> parts = _class.split('-');

    return Row(children: [
      Expanded(
          child: HighlightView(
        // The original code to be highlighted
        element.textContent,

        // Specify language
        // It is recommended to give it a value for performance
        language: parts.last,

        // Specify highlight theme
        // All available themes are listed in `themes` folder
        theme: Theme.of(context).brightness == Brightness.light
            ? atomOneLightTheme
            : atomOneDarkTheme,

        // Specify padding
        padding: const EdgeInsets.all(8),

        // Specify text style
        textStyle: const TextStyle(fontFamily: 'monospace'),
      ))
    ]);
  }
}

const blockLightTheme = {
  'comment': TextStyle(color: Color(0xff776977)),
  'quote': TextStyle(color: Color(0xff776977)),
  'variable': TextStyle(color: Color(0xffca402b)),
  'template-variable': TextStyle(color: Color(0xffca402b)),
  'attribute': TextStyle(color: Color(0xffca402b)),
  'tag': TextStyle(color: Color(0xffca402b)),
  'name': TextStyle(color: Color(0xffca402b)),
  'regexp': TextStyle(color: Color(0xffca402b)),
  'link': TextStyle(color: Color(0xffca402b)),
  'selector-id': TextStyle(color: Color(0xffca402b)),
  'selector-class': TextStyle(color: Color(0xffca402b)),
  'number': TextStyle(color: Color(0xffa65926)),
  'meta': TextStyle(color: Color(0xffa65926)),
  'built_in': TextStyle(color: Color(0xffa65926)),
  'builtin-name': TextStyle(color: Color(0xffa65926)),
  'literal': TextStyle(color: Color(0xffa65926)),
  'type': TextStyle(color: Color(0xffa65926)),
  'params': TextStyle(color: Color(0xffa65926)),
  'string': TextStyle(color: Color(0xff918b3b)),
  'symbol': TextStyle(color: Color(0xff918b3b)),
  'bullet': TextStyle(color: Color(0xff918b3b)),
  'title': TextStyle(color: Color(0xff516aec)),
  'section': TextStyle(color: Color(0xff516aec)),
  'keyword': TextStyle(color: Color(0xff7b59c0)),
  'selector-tag': TextStyle(color: Color(0xff7b59c0)),
  'root': TextStyle(
      backgroundColor: Color.fromARGB(36, 255, 255, 255), color: Colors.black),
  'emphasis': TextStyle(fontStyle: FontStyle.italic),
  'strong': TextStyle(fontWeight: FontWeight.bold),
};

const blockDarkTheme = {
  'root': TextStyle(
      color: Colors.white,
      backgroundColor: Color.fromARGB(36, 0, 0, 0),
      fontWeight: FontWeight.bold),
  'keyword': TextStyle(color: Color(0xffF92672)),
  'operator': TextStyle(color: Color(0xffF92672)),
  'pattern-match': TextStyle(color: Color(0xffF92672)),
  'function': TextStyle(color: Color(0xff61aeee)),
  'comment': TextStyle(color: Color(0xffb18eb1), fontStyle: FontStyle.italic),
  'quote': TextStyle(color: Color(0xffb18eb1), fontStyle: FontStyle.italic),
  'doctag': TextStyle(color: Color(0xffc678dd)),
  'formula': TextStyle(color: Color(0xffc678dd)),
  'section': TextStyle(color: Color(0xffe06c75)),
  'name': TextStyle(color: Color(0xffe06c75)),
  'selector-tag': TextStyle(color: Color(0xffe06c75)),
  'deletion': TextStyle(color: Color(0xffe06c75)),
  'subst': TextStyle(color: Color(0xffe06c75)),
  'literal': TextStyle(color: Color(0xff56b6c2)),
  'string': TextStyle(color: Color(0xff98c379)),
  'regexp': TextStyle(color: Color(0xff98c379)),
  'addition': TextStyle(color: Color(0xff98c379)),
  'attribute': TextStyle(color: Color(0xff98c379)),
  'meta-string': TextStyle(color: Color(0xff98c379)),
  'built_in': TextStyle(color: Color(0xffe6c07b)),
  'attr': TextStyle(color: Color(0xffd19a66)),
  'variable': TextStyle(color: Color(0xffd19a66)),
  'template-variable': TextStyle(color: Color(0xffd19a66)),
  'type': TextStyle(color: Color(0xffd19a66)),
  'selector-class': TextStyle(color: Color(0xffd19a66)),
  'selector-attr': TextStyle(color: Color(0xffd19a66)),
  'selector-pseudo': TextStyle(color: Color(0xffd19a66)),
  'number': TextStyle(color: Color(0xffd19a66)),
  'symbol': TextStyle(color: Color(0xff61aeee)),
  'bullet': TextStyle(color: Color(0xff61aeee)),
  'link': TextStyle(color: Color(0xff61aeee)),
  'meta': TextStyle(color: Color(0xff61aeee)),
  'selector-id': TextStyle(color: Color(0xff61aeee)),
  'title': TextStyle(color: Color(0xff61aeee)),
  'emphasis': TextStyle(fontStyle: FontStyle.italic),
  'strong': TextStyle(fontWeight: FontWeight.bold),
};


const atomOneLightTheme = {
  'root':
      TextStyle(color: Color(0xff383a42), backgroundColor: Color.fromARGB(76, 250, 250, 250)),
  'comment': TextStyle(color: Color(0xffa0a1a7), fontStyle: FontStyle.italic),
  'quote': TextStyle(color: Color(0xffa0a1a7), fontStyle: FontStyle.italic),
  'doctag': TextStyle(color: Color(0xffa626a4)),
  'keyword': TextStyle(color: Color(0xffa626a4)),
  'formula': TextStyle(color: Color(0xffa626a4)),
  'section': TextStyle(color: Color(0xffe45649)),
  'name': TextStyle(color: Color(0xffe45649)),
  'selector-tag': TextStyle(color: Color(0xffe45649)),
  'deletion': TextStyle(color: Color(0xffe45649)),
  'subst': TextStyle(color: Color(0xffe45649)),
  'literal': TextStyle(color: Color(0xff0184bb)),
  'string': TextStyle(color: Color(0xff50a14f)),
  'regexp': TextStyle(color: Color(0xff50a14f)),
  'addition': TextStyle(color: Color(0xff50a14f)),
  'attribute': TextStyle(color: Color(0xff50a14f)),
  'meta-string': TextStyle(color: Color(0xff50a14f)),
  'built_in': TextStyle(color: Color(0xffc18401)),
  'attr': TextStyle(color: Color(0xff986801)),
  'variable': TextStyle(color: Color(0xff986801)),
  'template-variable': TextStyle(color: Color(0xff986801)),
  'type': TextStyle(color: Color(0xff986801)),
  'selector-class': TextStyle(color: Color(0xff986801)),
  'selector-attr': TextStyle(color: Color(0xff986801)),
  'selector-pseudo': TextStyle(color: Color(0xff986801)),
  'number': TextStyle(color: Color(0xff986801)),
  'symbol': TextStyle(color: Color(0xff4078f2)),
  'bullet': TextStyle(color: Color(0xff4078f2)),
  'link': TextStyle(color: Color(0xff4078f2)),
  'meta': TextStyle(color: Color(0xff4078f2)),
  'selector-id': TextStyle(color: Color(0xff4078f2)),
  'title': TextStyle(color: Color(0xff4078f2)),
  'emphasis': TextStyle(fontStyle: FontStyle.italic),
  'strong': TextStyle(fontWeight: FontWeight.bold),
};


const atomOneDarkTheme = {
  'root':
      TextStyle(color: Color(0xffabb2bf), backgroundColor: Color.fromARGB(133, 40, 44, 52)),
  'comment': TextStyle(color: Color(0xff5c6370), fontStyle: FontStyle.italic),
  'quote': TextStyle(color: Color(0xff5c6370), fontStyle: FontStyle.italic),
  'doctag': TextStyle(color: Color(0xffc678dd)),
  'keyword': TextStyle(color: Color(0xffc678dd)),
  'formula': TextStyle(color: Color(0xffc678dd)),
  'section': TextStyle(color: Color(0xffe06c75)),
  'name': TextStyle(color: Color(0xffe06c75)),
  'selector-tag': TextStyle(color: Color(0xffe06c75)),
  'deletion': TextStyle(color: Color(0xffe06c75)),
  'subst': TextStyle(color: Color(0xffe06c75)),
  'literal': TextStyle(color: Color(0xff56b6c2)),
  'string': TextStyle(color: Color(0xff98c379)),
  'regexp': TextStyle(color: Color(0xff98c379)),
  'addition': TextStyle(color: Color(0xff98c379)),
  'attribute': TextStyle(color: Color(0xff98c379)),
  'meta-string': TextStyle(color: Color(0xff98c379)),
  'built_in': TextStyle(color: Color(0xffe6c07b)),
  'attr': TextStyle(color: Color(0xffd19a66)),
  'variable': TextStyle(color: Color(0xffd19a66)),
  'template-variable': TextStyle(color: Color(0xffd19a66)),
  'type': TextStyle(color: Color(0xffd19a66)),
  'selector-class': TextStyle(color: Color(0xffd19a66)),
  'selector-attr': TextStyle(color: Color(0xffd19a66)),
  'selector-pseudo': TextStyle(color: Color(0xffd19a66)),
  'number': TextStyle(color: Color(0xffd19a66)),
  'symbol': TextStyle(color: Color(0xff61aeee)),
  'bullet': TextStyle(color: Color(0xff61aeee)),
  'link': TextStyle(color: Color(0xff61aeee)),
  'meta': TextStyle(color: Color(0xff61aeee)),
  'selector-id': TextStyle(color: Color(0xff61aeee)),
  'title': TextStyle(color: Color(0xff61aeee)),
  'emphasis': TextStyle(fontStyle: FontStyle.italic),
  'strong': TextStyle(fontWeight: FontWeight.bold),
};