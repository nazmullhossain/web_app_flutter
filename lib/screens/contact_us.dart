import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:web_ksa/responsiveness.dart';
import 'package:web_ksa/screens/widgets/footer_widget.dart';

import '../app/services/add_uni_codes.dart';
import '../constants.dart';
import 'home.dart';

class ContactUSScreen extends StatelessWidget {
  const ContactUSScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
          icon: Icon(MdiIcons.arrowLeft),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.0.r),
        child: ListView(
          shrinkWrap: true,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(top: 20.sp,),
              // color: const Color(0xFFE57373),
              alignment: Alignment.center,
              // height: 1000.h,
              child: Column(
                children: [
                  const Text(Constants.myAddress, textDirection: TextDirection.rtl,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(Constants.myName,),
                      SizedBox(width: 10.w,),
                      const Text(Constants.nameLabel, textDirection: TextDirection.rtl,),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(Constants.myPhone,),
                      SizedBox(width: 10.w,),
                      const Text(Constants.phoneLabel, textDirection: TextDirection.rtl,),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(Constants.myEmail, textDirection: TextDirection.rtl,),
                      SizedBox(width: 10.w,),
                      const Text(Constants.emailLabel, textDirection: TextDirection.rtl,),

                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h,),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(top: 20.sp,),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/contact.jpg')
                )
              ),
              // color: const Color(0xFFE57373),
              alignment: Alignment.center,
              height: 700.h,
            ),
            SizedBox(height: 20.h,),
            AdSenseAdUnit(viewID: 'kadamaDisplayAdd1', addUnit: kadamaDisplayApp, width: MediaQuery.of(context).size.width, height: 200.h,),
            SizedBox(height: 16.h),
            if (Responsive.screenWidth < Responsive.maxMobileWidth)
              const FooterWidget(),
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
            ),
          ],
        ),
      ),
    );
  }
}
