import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:flutter/foundation.dart' show kIsWeb;

class ShareTile extends StatelessWidget {
  final String msg;
  ShareTile({this.msg});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            icon: Image.asset(
              'assets/facebook_small.png',
              height: 32,
              width: 32,
            ),
            onPressed: () async {
              if (await url_launcher.canLaunch(
                  'https://www.facebook.com/sharer/sharer.php?u=https://ihike-pk.web.app&quote=$msg')) {
                url_launcher.launch(
                    'https://www.facebook.com/sharer/sharer.php?u=https://ihike-pk.web.app&quote=$msg');
                return;
              }
            },
          ),
          IconButton(
            icon: Image.asset(
              'assets/twitter_small.png',
              height: 32,
              width: 32,
            ),
            onPressed: () async {
              if (kIsWeb) {
                if (await url_launcher.canLaunch(
                    'http://twitter.com/share?text=$msg&url=https://ihike-pk.web.app&hashtags=IhikePakistan')) {
                  url_launcher.launch(
                      'http://twitter.com/share?text=$msg&url=https://ihike-pk.web.app&hashtags=IhikePakistan');
                  return;
                }
              } else {
                FlutterShareMe().shareToTwitter(msg: msg);
              }
            },
          ),
          IconButton(
            icon: Image.asset(
              'assets/whatsapp_small.png',
              height: 32,
              width: 32,
            ),
            onPressed: () async {
              if (kIsWeb) {
                if (await url_launcher
                    .canLaunch('https://api.whatsapp.com/send?text=$msg')) {
                  url_launcher
                      .launch('https://api.whatsapp.com/send?text=$msg');
                  return;
                }
              } else {
                FlutterShareMe().shareToWhatsApp(msg: msg);
              }
            },
          ),
          IconButton(
            icon: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(7)),
              child: Container(
                height: 32,
                width: 32,
                color: Colors.grey.shade400,
                child: Icon(
                  Icons.share,
                  color: Colors.white,
                ),
              ),
            ),
            onPressed: () async {
              if (kIsWeb) {
                FlutterClipboard.copy(msg);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Copied to clipboard!'),
                ));
              } else {
                FlutterShareMe().shareToSystem(msg: msg);
              }
            },
          ),
        ],
      ),
    );
  }
}
