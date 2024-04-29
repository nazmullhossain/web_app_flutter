import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Import Firebase Messaging
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:web_ksa/app/services/toaster.dart';
import 'package:web_ksa/responsiveness.dart';

import '../app/services/analytic_engin.dart';
import '../constants.dart';
import 'home.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _verificationCodeController = TextEditingController();

  String _verificationId = '';

  // Function to get the current user ID
  String? getCurrentUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  // Function to store FCM token in the user's document
  Future<void> storeFCMTokenInUserDocument() async {
    // Get the current user ID
    try {
      String? userId = getCurrentUserId();

      if (userId != null) {
        // Obtain the FCM token
        String? fcmToken = await FirebaseMessaging.instance.getToken(vapidKey: Constants.vapIdKey);



        // Update the user's document in the 'users' collection with the FCM token
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'fcmToken': fcmToken,
        });
      }
    } on Exception catch (e) {
      debugPrint("Store Token ::: ${e.toString()}");
    }
  }

  Future<void> _signInWithPhoneNumber() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    // print("+92${_phoneNumberController.text}");
    try {
      String phoneNumber = '+966${_phoneNumberController.text.replaceAll(RegExp(r'[^0-9]'), '')}';
      // String phoneNumber = '+923135455405';

      AnalyticEngin.eventLogin("signInWithPhoneNumber");
      debugPrint(phoneNumber);
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          AnalyticEngin.eventLog("Logged in success");
          // The user is signed in, add user data to the 'users' collection
          await _addUserDataToFirestore();
          // Store the FCM token in the user's document
          await storeFCMTokenInUserDocument();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('Verification failed: $e');
          AnalyticEngin.eventLog("Logged in failed");
          ShowSnack(context).error("(${e.code}) ${e.message}");
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint("Verification::: $verificationId");
          setState(() {
            _verificationId = verificationId;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-retrieval of the code timed out
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      debugPrint('Error signing in with phone number: $e');
      // Handle the sign-in error here
      ShowSnack(context).error(e.toString());
    }
  }

  Future<void> _submitVerificationCode() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_formKey2.currentState!.validate()) return;
    _formKey.currentState!.save();
    _formKey2.currentState!.save();
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _verificationCodeController.text,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      // The user is signed in, add user data to the 'users' collection
      await _addUserDataToFirestore();
      // Store the FCM token in the user's document
      await storeFCMTokenInUserDocument();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Error submitting verification code: $e');
      // Handle the verification code submission error here
      ShowSnack(context).error("(${e.code}) ${e.message}");
    } catch (e) {
      debugPrint('Error submitting verification code: $e');
      // Handle the verification code submission error here
      ShowSnack(context).error(e.toString());
    }
  }

  Future<void> _addUserDataToFirestore() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Add user data to the 'users' collection
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'userId': user.uid,
          'phoneNumber': user.phoneNumber,
          // Add any additional user data you want to store
        });
      }
    } catch (e) {
      debugPrint('Error adding user data to Firestore: $e');
      // Handle the error adding user data to Firestore
      ShowSnack(context).error(e.toString());
    }
  }

  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل الدخول'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(MdiIcons.arrowLeft),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Phone Number TextFormField
              Form(
                key: _formKey,
                child: SizedBox(
                  width: 530.w,
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: _phoneNumberController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      prefixText: '+966',
                      labelText: 'رقم الهاتف',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(height: 20.sp),
              // Sign In with Phone Number Button
              ElevatedButton(
                onPressed: _signInWithPhoneNumber,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                ),
                child: const Text('ارسل كود التحقق', style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 20.sp),
              // Verification Code TextFormField
              Form(
                key: _formKey2,
                child: SizedBox(
                  width: 530.w,
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: _verificationCodeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'كود التحقق',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(height: 20.sp),
              // Submit Verification Code Button
              ElevatedButton(
                onPressed: _submitVerificationCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                ),
                child: const Text('تأكيد الكود', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
