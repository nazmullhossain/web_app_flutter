import 'package:flutter/material.dart';
import 'package:web_ksa/responsiveness.dart';

import '../../app/services/app_functions.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () => launchURL('https://t.me/kaademaa'),
          icon: Image.asset("assets/telegram.png"),
        ),
        SizedBox(width: 10.w,),
        IconButton(
          onPressed: () => launchURL(
              'https://whatsapp.com/channel/0029VaS3E8FEawdlcgOjux3u'),
          icon: Image.asset("assets/whatsapp.png"),
        ),
      ],
    );
  }
}
