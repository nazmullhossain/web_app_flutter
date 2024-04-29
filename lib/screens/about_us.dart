import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:web_ksa/constants.dart';
import 'package:web_ksa/responsiveness.dart';
import 'package:web_ksa/screens/video_view.dart';
import 'package:web_ksa/screens/widgets/footer_widget.dart';

import '../app/services/add_uni_codes.dart';
import 'home.dart';

class AboutUSScreen extends StatefulWidget {
  const AboutUSScreen({super.key});

  @override
  State<AboutUSScreen> createState() => _AboutUSScreenState();
}

class _AboutUSScreenState extends State<AboutUSScreen> {
  final _carouselController = CarouselController();
  int _initialPage = 0;
  void onPageChange(int value) {
    setState(() {
      _initialPage = value;
    });
  }
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
              padding: EdgeInsets.only(top: 20.sp, bottom: 20.sp, left: 6.sp, right: 6.sp),
              color: const Color(0xFFE57373),
              alignment: Alignment.center,
              // height: 1000.h,
              child: Text(
                Constants.aboutUS,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.normal,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
            SizedBox(height: 20.h,),
            const VideoView(),
            SizedBox(height: 20.h,),
            CarouselSlider(
              carouselController: _carouselController,
              // disableGesture: true,
              options: CarouselOptions(initialPage: _initialPage, height: Responsive.screenWidth >= Responsive.maxMobileWidth ? 1024.h : 512.h, aspectRatio: 16/9,
                onPageChanged: (i, r) {
                  setState(() {
                    _initialPage = i;
                  });
                },
                viewportFraction: 0.9,),
              items: ["assets/1.jpg","assets/2.jpg","assets/3.jpg","assets/4.jpg", "assets/5.jpg", "assets/6.jpg"].map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0.r),
                      decoration: BoxDecoration(
                        // color: Colors.amber
                        image: DecorationImage(image: AssetImage(i), fit: BoxFit.fill),
                      ),
                      // child: Text('text $i', style: TextStyle(fontSize: 30.0.sp),)
                    );
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 30.h,),
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
