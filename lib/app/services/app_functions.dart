import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void showCustomDialog(BuildContext context,String title, String body) async {
  showDialog(context: context, builder: (context) => SimpleDialog(
    title: Text(title),
    children: [
      Text(body),
    ],
  ));
}

void launchURL(String url) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {
    debugPrint('Could not launch $url');
  }
}