import 'dart:html' as html;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:web_ksa/constants.dart';
import 'package:web_ksa/responsiveness.dart';
import 'package:web_ksa/screens/home.dart';
import 'package:web_ksa/screens/login.dart';
import 'package:http/http.dart' as http;
import 'package:web_ksa/text_input_formatter.dart';

import '../app/services/analytic_engin.dart';

class AddPostScreen extends StatefulWidget {
  final String? postId;
  final String? userId;

  const AddPostScreen({super.key, this.postId, this.userId});

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  // List<QueryDocumentSnapshot>? _filteredPosts;

  String? _pickedImage;
  String? _selectedTitle;
  String? _description;
  String?  _userId;
  // Store the previous post data
  String? _previousTitle;
  String? _previousDescription;
  String? _previousImage;

  @override
  void initState() {
    super.initState();
    debugPrint('UserId in initState: ${widget.userId}');

    debugPrint('InitState is called!');
    // If userId is not null, fetch existing post data
    if (widget.userId != null) {
      debugPrint('UserId: ${widget.userId}');
      _fetchPostData(widget.userId!);
    } else {
      // Handle the case where userId is null (if needed)
    }
  }



  void _fetchPostData(String userId) async {
    try {
      debugPrint('Fetching post data for userId: $userId');

      // Fetch the user's post using the user ID
      QuerySnapshot postSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('user_id', isEqualTo: userId)
          .get();

      if (postSnapshot.docs.isNotEmpty) {
        // For simplicity, assuming the user has only one post.
        // If not, you might need to handle multiple posts.
        DocumentSnapshot postDocument = postSnapshot.docs.first;

        // Set the values from the existing post
        setState(() {
          _selectedTitle = postDocument['title'];
          _description = postDocument['description'];
          _pickedImage = postDocument['image'];
          _userId = postDocument['user_id'];
          // Store the previous post data
          _previousTitle = _selectedTitle;
          _previousDescription = _description;
          _previousImage = _pickedImage;

          // Set the values for text controllers
          _titleController.text = _selectedTitle ?? '';
          _descriptionController.text = _previousDescription ?? '';
        });

        debugPrint('Post data fetched successfully.');
        debugPrint('Selected Title: $_selectedTitle');
        debugPrint('Description: $_description');
        debugPrint('Picked Image: $_pickedImage');
        debugPrint('Previous Title: $_previousTitle');
        debugPrint('Previous Description: $_previousDescription');
        debugPrint('Previous Image: $_previousImage');
      } else {
        debugPrint('No posts found for userId: $userId');
      }
    } catch (error, stackTrace) {
      debugPrint('Error fetching post data: $error');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  void _pickImage() {
    final html.InputElement input =
    html.FileUploadInputElement() as html.InputElement;
    input.click();

    input.onChange.listen((html.Event e) {
      final html.File file = input.files!.first;
      final reader = html.FileReader();

      reader.onLoadEnd.listen((e) {
        final List<int> bytes = reader.result as List<int>;
        final String base64Image = base64Encode(Uint8List.fromList(bytes));
        setState(() {
          _pickedImage = base64Image;
        });
      });

      reader.readAsArrayBuffer(file);
    });
  }
  Future<void> sendNotificationToAll(String title, String body) async {
    // Fetch all FCM tokens from Firestore
    QuerySnapshot<Map<String, dynamic>> usersSnapshot =
    await FirebaseFirestore.instance.collection('users').get();

    List<String> fcmTokens = [];

    for (QueryDocumentSnapshot<Map<String, dynamic>> userSnapshot
    in usersSnapshot.docs) {
      String? fcmToken = userSnapshot.get('fcmToken');
      if (fcmToken != null && fcmToken.isNotEmpty) {
        fcmTokens.add(fcmToken);
        debugPrint("Tokens $fcmToken");
      }
    }

    // Use your server key from the Firebase Console
    const String serverKey =
        "AAAAllA6K2c:APA91bGJDMV4RXk0R0UY_UY_CIwBY19v2G4cRsXM-OYfU32ayurJGxLyHSotXqbBfMGK1vfh1myXxvrS23HOyoaO4hJMCOTP3ns5iELv9nqe0YzluYVRc9nI2ZV8w6vAOtKV1T5sIcQ0";

    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': body,
            'title': title,
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
          },
          'registration_ids': fcmTokens,
        },
      ),
    );
  }

  Future<void> sendNotification(String userId, String title, String body) async {
    // Retrieve FCM token from Firestore based on userId
    final token = await FirebaseMessaging.instance.getToken(vapidKey: Constants.vapIdKey);
    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
    await FirebaseFirestore.instance.collection('users').doc(userId).get();

    String? fcmToken = userSnapshot.get('fcmToken');

    // Use your server key from the Firebase Console
    // const String serverKey = "AAAAllA6K2c:APA91bGJDMV4RXk0R0UY_UY_CIwBY19v2G4cRsXM-OYfU32ayurJGxLyHSotXqbBfMGK1vfh1myXxvrS23HOyoaO4hJMCOTP3ns5iELv9nqe0YzluYVRc9nI2ZV8w6vAOtKV1T5sIcQ0";

    await http.post(
      Uri.parse('https://fcm.googleapis.com/v1/projects/kodar-58d3a/messages:send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(
        {
          "message" : <String, dynamic>{
            'notification': <String, dynamic>{
              'body': body,
              'title': title,
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done',
            },
            'to': fcmToken,
          }
        },
      ),
    );
  }

  bool isSubmitting = false;

  void _submitPost() async {
    try {

      debugPrint('Submitting post...');
      if (!_formKey.currentState!.validate()) return;
      _formKey.currentState!.save();

      setState(() => isSubmitting = true);

      AnalyticEngin.eventLog("Submitting post");
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignInScreen()),
        );

        user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          debugPrint('User is still null after sign-in');
          setState(() => isSubmitting = false);
          return;
        }
      }

      DocumentSnapshot userPost = await FirebaseFirestore.instance
          .collection('posts')
          .doc(user.uid)
          .get();

      if (userPost.exists) {
        // Get comments for the post
        QuerySnapshot commentsSnapshot = await FirebaseFirestore.instance
            .collection('posts')
            .doc(user.uid)
            .collection('comments')
            .get();

        // Delete comments
        for (var commentDoc in commentsSnapshot.docs) {
          await commentDoc.reference.delete();
        }

        // Ask for confirmation to edit the existing post
        bool confirmEdit = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Center(child: Text('هل انت موافق')),
            content: const Center(
              child: Text('هذا البوست سيحل محل البوست القديم'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('الغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('موافق'),
              ),
            ],
          ),
        );

        if (confirmEdit == true) {
          // Update the existing post
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(user.uid)
              .update({
            'title': _selectedTitle,
            'description': _description,
            // 'image': _pickedImage ?? "",
          });
        } else {
          // Create a new post
          await FirebaseFirestore.instance.collection('posts').doc(user.uid).set({
            'title': _selectedTitle,
            'description': _description,
            // 'image': _pickedImage ?? "",
            'user_id': user.uid,
          });
        }
      } else {
        // Create a new post
        await FirebaseFirestore.instance.collection('posts').doc(user.uid).set({
          'title': _selectedTitle,
          'description': _description,
          // 'image': _pickedImage,
          'user_id': user.uid,
        });
      }

      // After submitting the post, notify all users
      // QuerySnapshot usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      // for (var userDoc in usersSnapshot.docs) {
      //   String? userFcmToken = userDoc.get('fcmToken');
      //   if (userFcmToken != null && userFcmToken.isNotEmpty) {
      //     await sendNotificationToAll(
      //       'New Post',
      //       'A new post has been added!',
      //     );
      //     // await sendNotification(
      //     //   userFcmToken,
      //     //   'New Post',
      //     //   'A new post has been added!',
      //     // );
      //   }
      // }

      // usersSnapshot.docs.forEach((userDoc) async {
      //   String? userFcmToken = userDoc.get('fcmToken');
      //   if (userFcmToken != null && userFcmToken.isNotEmpty) {
          // await sendNotificationToAll(
          //   'New Post',
          //   'A new post has been added!',
          // );
      //     // await sendNotification(
      //     //   userFcmToken,
      //     //   'New Post',
      //     //   'A new post has been added!',
      //     // );
      //   }
      // });
      // Navigate to the home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
      await sendNotificationToAll(
        'منشور جديد',
        'يوجد عاملة منزليه للتنازل',
      );
    } catch (error, stackTrace) {
      debugPrint('Error submitting post: $error');
      debugPrint('Stack trace: $stackTrace');
    }
    setState(() => isSubmitting = false);
  }

  void _deletePost() async {
    try {
      bool confirmDelete = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Center(child: Text('مسح البوست')),
          content: const Center(child: Text('هل متاكد انك تريد مسح هذا البوست')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('الغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('مسح'),
            ),
          ],
        ),
      );

      if (confirmDelete == true) {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          String postId = user.uid;

          // Get comments for the post
          QuerySnapshot commentsSnapshot = await FirebaseFirestore.instance
              .collection('posts')
              .doc(postId)
              .collection('comments')
              .get();

          // Delete comments
          commentsSnapshot.docs.forEach((commentDoc) async {
            await commentDoc.reference.delete();
          });

          // Delete the post
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(postId)
              .delete();

          // After deleting the post and comments, navigate to the home screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      }
    } catch (error, stackTrace) {
      debugPrint('Error deleting post: $error');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  Future<DocumentSnapshot> _getPostData(String postId) async {
    return await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .get();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مشاركة'),
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
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(10.r),
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'مشاركة',
                        style: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 40.h),
                      SizedBox(
                        width: 530.w,
                        // padding: EdgeInsets.symmetric(horizontal: 8.sp),
                        child: DropdownButtonFormField<String>(
                          items: Constants.dropdownItems.map((e) => DropdownMenuItem(value: _previousTitle == null ? e : e,child: Text(e),)).toList(),
                          padding: EdgeInsets.symmetric(horizontal: 8.sp),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onChanged: (String? selectedValue) {
                            setState(() {
                              _selectedTitle = selectedValue;
                              _titleController.text = selectedValue ?? '';
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return "";
                            }
                            return null;
                          },
                          value: _selectedTitle,
                          hint: const Text('اضغط للاختيار'),
                          icon: Icon(MdiIcons.chevronDown),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.redAccent.shade700,
                              )
                            )

                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      SizedBox(
                        width: 530.0.r,
                        child: TextFormField(
                          maxLines: 13,
                          maxLength: 500,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _descriptionController,
                          onChanged: (value) {
                            setState(() {
                              _description = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "";
                            }
                            return null;
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
                            FilteringTextInputFormatter.deny(RegExp(r'https?://')),
                            FilteringTextInputFormatter.deny(RegExp(
                                r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])'
                            ),),
                            // LengthLimitingTextInputFormatter(500),
                            MaxWordTextInputFormatter(maxWords: 500),
                          ],
                          decoration: const InputDecoration(
                            hintText: 'Enter Description',
                            labelText: 'الوصف',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      // ElevatedButton(
                      //   onPressed: _pickImage,
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Colors.teal,
                      //     foregroundColor: Colors.white,
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(5.0.r),
                      //     ),
                      //   ),
                      //   child: const Text(
                      //     'اضف صورة',
                      //     textDirection: TextDirection.rtl,
                      //   ),
                      // ),
                      // SizedBox(height: 20.h),
                      // Display picked image
                      // _pickedImage != null
                      //     ? Image.memory(
                      //   Uint8List.fromList(base64Decode(_pickedImage!)),
                      //   height: 200.h,
                      // )
                      //     : _previousImage != null
                      //     ? Image.memory(
                      //   Uint8List.fromList(base64Decode(_previousImage!)),
                      //   height: 200.h,
                      // )
                      //     : Container(
                      //   height: 200.h,
                      //   width: 200.w,
                      //   color: Colors.grey, // Placeholder color
                      //   child: const Center(
                      //     child: Text(
                      //       'No Image',
                      //       style: TextStyle(color: Colors.white),
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(height: 20.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _deletePost,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.all(6.0.r),
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0.r),
                              ),
                            ),
                            child: const Text(
                              ' حذف البوست',
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                          SizedBox(width: 20.w),
                          ElevatedButton(
                            onPressed: isSubmitting ? null : _submitPost,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.all(6.0.r),
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0.r),
                              ),
                            ),
                            child: const Text(
                              'ادراج البوست',
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (isSubmitting)
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: SizedBox(
                width: 60.w,
                height: 60.h,
                child: const CircularProgressIndicator(),
              ),
            ),
          )
        ],
      ),
    );
  }
}
