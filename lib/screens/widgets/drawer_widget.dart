import 'package:flutter/material.dart';
import 'package:web_ksa/responsiveness.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.5,
      child: Column(
        children: [
          SizedBox(height: 50.h,),
          ListTile(
            contentPadding: EdgeInsets.only(top: 10.h, right: 10.w),
            title: const Text(
              'اضف منشور',
              textDirection: TextDirection.rtl,
              style: TextStyle(color: Colors.teal),
            ),
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.only(top: 10.h, right: 10.w),
            title: const Text(
              'معلومات عنا',
              textDirection: TextDirection.rtl,
              style: TextStyle(color: Colors.teal),
            ),
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.only(top: 10.h, right: 10.w),
            title: const Text(
              'الشروط و الاحكام',
              textDirection: TextDirection.rtl,
              style: TextStyle(color: Colors.teal),
            ),
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.only(top: 10.h, right: 10.w),
            title: const Text(
              'تسجيل',
              textDirection: TextDirection.rtl,
              style: TextStyle(color: Colors.teal),
            ),
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.only(top: 10.h, right: 10.w),
            title: const Text(
              'تسجيل خروج',
              textDirection: TextDirection.rtl,
              style: TextStyle(color: Colors.teal),
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
