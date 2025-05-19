import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:linkify/linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkifyWidget extends StatelessWidget {
  final String description;
  const LinkifyWidget({
    super.key,
    required this.description,
  });

  Future<void> _onOpen(LinkableElement link) async {
    if (!await launchUrl(Uri.parse(link.url))) {
      throw Exception('Could not launch ${link.url}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Linkify(
      onOpen: _onOpen,
      text: description,
      style: const TextStyle(fontSize: 16),
      linkStyle: const TextStyle(
        color: Colors.blue,
        decoration: TextDecoration.underline,
      ),
      linkifiers: const [
        UrlLinkifier(),
        EmailLinkifier(),
        PhoneNumberLinkifier()
      ],
    );
  }
}
