import 'dart:convert';
import 'dart:html' as html;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_ksa/app/services/add_uni_codes.dart';
import 'package:web_ksa/app/services/analytic_engin.dart';
import 'package:web_ksa/app/services/toaster.dart';
import 'package:web_ksa/constants.dart';
import 'package:web_ksa/responsiveness.dart';
import 'package:web_ksa/screens/about_us.dart';
import 'package:web_ksa/screens/contact_us.dart';
import 'package:web_ksa/screens/terms.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app/services/app_functions.dart';
import 'add _post.dart';
import 'login.dart';
import 'package:http/http.dart' as http;

import 'widgets/footer_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class AdSenseAdUnit extends StatelessWidget {
  const AdSenseAdUnit({super.key, this.width, this.height, required this.addUnit, required this.viewID,});
  final double? width, height;

  final String viewID, addUnit;
  @override
  Widget build(BuildContext context) {


    return SizedBox(
      height: height ?? (Responsive.screenWidth >= Responsive.maxMobileWidth
    ? 900.h
        : 1200.h), // Set the desired height
      width: width ?? 530.w, // Set the desired width
      child: Card(
        child: HtmlElementView(
          viewType: viewID,
          key: UniqueKey(), // Ensure the key is unique to force recreation
          // Create the IFrameElement directly in the Widget build method
          // (Note: This is a basic example and might need further adjustments)
          onPlatformViewCreated: (int id) {
            html.IFrameElement()
              ..srcdoc = '''
            <!DOCTYPE html>
            <html>
              <head>
              </head>
              <body>
                $addUnit
                </body>
              </html>
            '''
              ..style.border = 'none'
              ..width = '100%'
              ..height = '100%'
              ..id = 'iframe_$id'
              ..onLoad.listen((event) {
                // Do something when the iframe is loaded, if needed
              })
              ..onError.listen((event) {
                // Handle iframe load errors, if needed
              })
              ..onResize.listen((event) {
                // Handle iframe resize events, if needed
              })
              ..requestFullscreen(); // Request full screen for the iframe
          },
        ),
      ),
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedFilter;
  late PageController _pageController;
  List<QueryDocumentSnapshot>? _filteredPosts;
  List<QueryDocumentSnapshot<Object?>> posts = [];
  List<TextEditingController> commentsControllers = [];
  List<String> commentsList = [];
  // List<GlobalKey<FormState>> formsKeys = [];

  // TextEditingController commentController = TextEditingController();

  Future<void> getPostsData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('posts').get();

      posts = querySnapshot.docs;
      setState(() {});
    } catch (e) {
      // Handle errors
      print('Error fetching posts: $e');
      // return [];
    }
  }

  String dataFetchingError = '';

  late final Future<QuerySnapshot<Map<String,dynamic>>> myFuture;

  Future<QuerySnapshot<Map<String,dynamic>>> fetchMyFuture() async {
    return _selectedFilter == null
        ? FirebaseFirestore.instance.collection('posts').get()
        : FirebaseFirestore.instance
        .collection('posts')
        .where('title', isEqualTo: _selectedFilter)
        .get();
  }

  @override
  void initState() {
    super.initState();
    // commentController = TextEditingController();
    myFuture = fetchMyFuture();
    getPostsData();

    _pageController = PageController();
    // fetchCommentsForPost();
    fetchCommentTextField();
  }

  getToken() async {
    String? devicetoken =
        await FirebaseMessaging.instance.getToken(vapidKey: Constants.vapIdKey);
    debugPrint('tokennnnn ${devicetoken!}');
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut().then(
            (value) => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SignInScreen()),
            ),
          );
      // Navigate to the sign-in or authentication screen
    } catch (e) {
      debugPrint('Error signing out: $e');
      // Handle the sign-out error here
    }
  }

  Future<void> _showSignOutConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تسجيل خروج'),
          content: const Text('هل تريد تسجيل الخروح؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('لا'),
            ),
            TextButton(
              onPressed: () async {
                await _signOut(context);
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('نعم'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showSignInDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text('يرجى تسجيل الدخول')),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
              child: const Text('الغاء', style: TextStyle(color: Colors.white)),
            ),
            SizedBox(
              width: 8.w,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                _navigateToSignUp(); // Navigate to the sign-in screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
              child: const Text('تسجيل دخول',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }

  void _navigateToTermsAndConditions() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TermsAndConditionsScreen()),
    );
  }

  void _navigateToAddPost() {
    // Check if the user is signed in before navigating to add post screen
    if (FirebaseAuth.instance.currentUser != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddPostScreen(
            postId: POSTID,
            userId: user!.uid,
          ),
        ),
      );
    } else {
      // User is not signed in
      debugPrint('User not authenticated. Please log in.');
      _showSignInDialog(); // Show the sign-in dialog
    }
  }

  void _navigateToAboutUs() {
    // Check if the user is signed in before navigating to add post screen
    // if (FirebaseAuth.instance.currentUser != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AboutUSScreen(
            // postId: POSTID,
            // userId: user!.uid,
          ),
        ),
      );
    // } else {
    //   // User is not signed in
    //   debugPrint('User not authenticated. Please log in.');
    //   _showSignInDialog(); // Show the sign-in dialog
    // }
  }

  void _navigateToContactUs() {
    // Check if the user is signed in before navigating to add post screen
    // if (FirebaseAuth.instance.currentUser != null) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ContactUSScreen(),
      ),
    );
    // } else {
    //   // User is not signed in
    //   debugPrint('User not authenticated. Please log in.');
    //   _showSignInDialog(); // Show the sign-in dialog
    // }
  }

  // void _applyFilter() {
  //   setState(() {
  //     // Refresh the UI to apply the filter
  //   });
  // }

  void _navigateToPreviousPage() {
    if (_pageController.page != null && _pageController.page! > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateToNextPage() {
    if (_pageController.page != null &&
        _pageController.page! < _pageController.position.maxScrollExtent) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _launchDialer(String phoneNumber) async {
    if (await canLaunchUrl(Uri.parse('tel:+966557346096'))) {
      await launchUrl(Uri.parse('tel:+966557346096'));
    } else {
      debugPrint('Could not dial $phoneNumber');
    }
  }

  Future<String> getPostLink(String postId) async {
    // Replace 'your_collection' with your actual Firestore collection
    // and modify the link structure based on your app's routing
    String postLink = 'https://our-w.com/';
    return postLink;
  }

  Future<void> _sharePostLink(String postLink) async {
    debugPrint('Sharing link: $postLink');
    await Share.share(postLink, subject: 'Check out this post!');
  }

  // void _sharePost(String title, String? url) async {
  //   if (url != null) {
  //     await FlutterShare.share(
  //       title: 'Check out this post: $title',
  //       text: 'Visit the website: $url',
  //       linkUrl: url,
  //     );
  //   } else {
  //     print('Post URL is null or not available');
  //   }
  // }

  String? text;

  getComments() async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc('')
        .collection('comments')
        .doc('')
        .get()
        .then((value) {});
  }

  Future<List<DocumentSnapshot<Object?>>> getCommentsForPost(
      String postId, String userId) async {
    try {
      // Reference to the specific post document
      DocumentReference postReference =
          FirebaseFirestore.instance.collection('posts').doc(postId);

      // Reference to the "comments" subcollection within the post
      CollectionReference commentsCollection =
          postReference.collection('comments');

      // Get all comments for the specified post
      QuerySnapshot querySnapshot = await commentsCollection.get();

      // Return the list of comment documents
      return querySnapshot.docs;
    } catch (e) {
      print('Error getting comments: $e');
      return [];
    }
  }

  String commentTextField = '';

  Future<void> fetchCommentTextField() async {
    print('USERRRRRRRRR${user!.uid}');
    try {
      // Reference to the "posts" collection
      CollectionReference postsCollection =
          FirebaseFirestore.instance.collection('posts');

      // Query to filter posts based on the user_id field
      QuerySnapshot postQuerySnapshot =
          await postsCollection.where('user_id', isEqualTo: user!.uid).get();

      // Check if a matching post is found
      if (postQuerySnapshot.docs.isNotEmpty) {
        // Reference to the specific post document
        DocumentReference postReference =
            postQuerySnapshot.docs.first.reference;

        // Reference to the "comments" subcollection within the post
        CollectionReference commentsCollection =
            postReference.collection('comments');

        // Query to filter comments based on the user_id field

        QuerySnapshot commentQuerySnapshot = await commentsCollection
            .where('user_id', isEqualTo: user!.uid)
            .get();

        // Check if a matching comment is found
        if (commentQuerySnapshot.docs.isNotEmpty) {
          // Reference to the specific comment document
          DocumentReference commentReference =
              commentQuerySnapshot.docs.first.reference;

          // Get the comment document
          DocumentSnapshot commentSnapshot = await commentReference.get();

          // Check if the comment exists and belongs to the specified user
          if (commentSnapshot.exists) {
            // Set the text field of the comment
            setState(() {
              commentTextField = commentSnapshot['text'];
              print('Comment Text: ${commentTextField}');
            });
          } else {
            // Comment not found
            print('Comment not found.');
          }
        } else {
          // No matching comments found
          print('No matching comments found.');
        }
      } else {
        // No matching posts found
        print('No matching posts found.');
      }
    } catch (e) {
      print('Error fetching comment text field: $e');
    }
  }

  List<DocumentSnapshot>? comments;

  Future<void> fetchCommentsForPost(String postId) async {
    String userId = user!.uid;

    comments = await getCommentsForPost(postId, userId);

    // Process the comments for the post
    for (DocumentSnapshot comment in comments!) {
      // print('Comment ID: ${comment!.id}, Data: ${comment!.data()}');
      // Add your processing logic here
    }
  }

  User? user = FirebaseAuth.instance.currentUser;

  Future<void> sendNotification(
      String userId, String title, String body) async {
    final token =
        await FirebaseMessaging.instance.getToken(vapidKey: Constants.vapIdKey);
    // Retrieve FCM token from Firestore based on userId
    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    debugPrint(userId.toString());
    print(userSnapshot.data());
    debugPrint("Hello  3");
    String? fcmToken = await userSnapshot.get('fcmToken');
    debugPrint("Hello  1");
    debugPrint('FCM Token for user $userId: $fcmToken');
    debugPrint("Hello  2");
    // Use your server key from the Firebase Console
    // const String serverKey =
    //     "AAAAllA6K2c:APA91bGJDMV4RXk0R0UY_UY_CIwBY19v2G4cRsXM-OYfU32ayurJGxLyHSotXqbBfMGK1vfh1myXxvrS23HOyoaO4hJMCOTP3ns5iELv9nqe0YzluYVRc9nI2ZV8w6vAOtKV1T5sIcQ0";

    // Print the notification payload
    debugPrint('Sending notification:');
    debugPrint('  Title: $title');
    debugPrint('  Body: $body');
    debugPrint('  FCM Token: $fcmToken');

    var data = await http.post(
      Uri.parse(
          'https://fcm.googleapis.com/v1/projects/kodar-58d3a/messages:send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(
        {
          "message": <String, dynamic>{
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
            'token': fcmToken,
          }
        },
      ),
    );
    debugPrint("data is ${data.body}");
    debugPrint('Notification sent successfully.');
  }

  Future<void> _addComment(String postId, String commentText) async {
    if (user == null) {
      debugPrint('User not authenticated. Please log in.');
      ShowSnack(context).toaster("User not authenticated. Please log in.");
      return;
    }

    try {
      // String commentText = commentController.text;
      AnalyticEngin.eventLog("Commenting..");

      // Add the comment to Firestore
      DocumentReference commentRef = await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .add({
        'user_id': user!.uid,
        'text': commentText,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Log the added comment's ID
      debugPrint('Comment added with ID: ${commentRef.id}');

      // Listen for changes in the comments collection
      FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentRef.id)
          .snapshots()
          .listen((commentSnapshot) async {
        // Get the post owner's FCM token
        DocumentSnapshot postSnapshot = await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .get();

        String postOwnerId = postSnapshot.get('user_id');
        String? postOwnerFcmToken = await _getUserFcmToken(postOwnerId);

        // Notify the post owner about the new comment
        if (postOwnerFcmToken != null) {
          await sendNotification(
            postOwnerId,
            'تعليق جديد',
            'احدهم علق على منشورك',
          );
        }

        // Refresh the UI to show the updated comments
        setState(() {
          // Your existing code to refresh the UI
        });
      });
    } catch (error) {
      debugPrint('Error adding comment: $error');
    }
  }

  Future<String?> _getUserFcmToken(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      // Check if the 'fcmToken' field exists in the document
      if (userSnapshot.exists &&
          userSnapshot.data() is Map<String, dynamic> &&
          (userSnapshot.data() as Map<String, dynamic>)
              .containsKey('fcmToken')) {
        return (userSnapshot.data() as Map<String, dynamic>)['fcmToken'];
      } else {
        debugPrint('User document or fcmToken field not found.');
        return null;
      }
    } catch (error) {
      debugPrint('Error getting user FCM token: $error');
      return null;
    }
  }

  Widget _buildCommentList(List<DocumentSnapshot<Object?>>? comments) {
    if (comments == null || comments.isEmpty) {
      return const Center(child: Text('لا يوجد تعليقات'));
    }

    return SingleChildScrollView(
      child: Column(
        children: comments.map((e) => _buildCommentCard(e)).toList(),
      ),
    );
  }

  Widget _buildCommentCard(DocumentSnapshot<Object?> comment) {
    final commentData = comment.data() as Map<String, dynamic>?;

    if (commentData != null) {
      final commentText = commentData['text'] as String?;
      debugPrint('Comment Text: $commentText');
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        child: ListTile(
          title: Text(commentText ?? 'No text available'),
        ),
      );
    } else {
      debugPrint('Comment data is null');
      return const Card(
        margin: EdgeInsets.symmetric(vertical: 4.0),
        child: ListTile(
          title: Text('No text available'),
        ),
      );
    }
  }

  Widget _buildPostCard(
      Map<String, dynamic> post,
      String postId,
      List<DocumentSnapshot<Object?>>? comments,
      TextEditingController controller,
      int index,
      ) {
    // Handle null comments by providing an empty list
    List<DocumentSnapshot<Object?>>? postComments = comments ?? [];

    return SizedBox(
      width: double.infinity,
      height:
          Responsive.screenWidth >= Responsive.maxMobileWidth ? 900.h : 1200.h,
      child: Card(
        margin: EdgeInsets.all(8.0.r),
        child: Padding(
          padding: EdgeInsets.all(8.0.r),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Use the screen width to determine the layout
              if (Responsive.screenWidth >= Responsive.maxMobileWidth) {
                // Desktop layout
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children:
                      _buildRowChildren(post, postId, postComments, controller),
                );
              } else {
                // Mobile layout
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: _buildColumnChildren(
                      post, postId, postComments, controller, index),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRowChildren(
    Map<String, dynamic> post,
    String postId,
    List<DocumentSnapshot<Object?>>? postComments,
    TextEditingController commentController,
  ) {
    final formKey = GlobalKey<FormState>();
    return [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              post['title'] ?? '',
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
              ),
              textDirection: TextDirection.rtl,
            ),
            SizedBox(height: 8.h),
            Container(
              width: 800.w,
              padding: EdgeInsets.symmetric(horizontal: 8.0.r),
              child: Text(
                post['description'] ?? '',
                // maxLines: 2,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w500,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(MdiIcons.share),
                  onPressed: () async => _sharePostLink(Constants.webLink),
                ),
                IconButton(
                  icon: Icon(MdiIcons.comment),
                  onPressed: () {
                    // Add your comment logic here
                    debugPrint('Commenting on post ${post['title']}');
                  },
                ),
              ],
            ),
            Expanded(
              child: Container(
                width: 840.w,
                // height: 240.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: _buildCommentList(postComments),
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              width: 840.w,
              child: TextFormField(
                maxLength: 200,
                // onTap: () {
                //   // Check if the user is signed in before adding a comment
                //   if (FirebaseAuth.instance.currentUser != null) {
                //     if (postId.isNotEmpty) {
                //       // _addComment(postId);
                //       // commentController.clear();
                //     } else {
                //       debugPrint('Post ID is null. Cannot add comment.');
                //     }
                //   } else {
                //     // User is not signed in
                //     debugPrint('User not authenticated. Please log in.');
                //     _showSignInDialog(); // Show the sign-in dialog
                //   }
                // },
                controller: commentController,
                textAlign: TextAlign.right,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'https?://')),
                  FilteringTextInputFormatter.deny(
                    RegExp(
                        r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])'),
                  ),
                ],
                decoration: InputDecoration(
                  hintText: '... اكتب تعليقك ',
                  suffixIcon: IconButton(
                    icon: Icon(MdiIcons.send),
                    onPressed: () {
                      if (commentController.text.trim().isEmpty) return;
                      // if (commentController.text.isEmpty) return;
                      // Check if the user is signed in before adding a comment
                      if (FirebaseAuth.instance.currentUser != null) {
                        if (postId.isNotEmpty ) {
                          _addComment(postId, commentController.text);
                          commentController.clear();
                        } else {
                          debugPrint('Post ID is null. Cannot add comment.');
                        }
                      } else {
                        // User is not signed in
                        debugPrint('User not authenticated. Please log in.');
                        _showSignInDialog(); // Show the sign-in dialog
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildColumnChildren(
    Map<String, dynamic> post,
    String postId,
    List<DocumentSnapshot<Object?>>? postComments,
    TextEditingController commentController,
      int index,
  ) {
    debugPrint((post['description'] as String).length.toString());
    commentController.text = commentsList[index];

    return [
      Text(
        post['title'] ?? '',
        style: TextStyle(
          fontSize: 30.sp,
          fontWeight: FontWeight.bold,
        ),
        textDirection: TextDirection.rtl,
      ),
      SizedBox(height: 4.h),
      Container(
        width: double.infinity,
        // height: 250.h,
        padding: EdgeInsets.symmetric(horizontal: 8.sp),
        child: Text(
          post['description'] ?? '',
          maxLines: post['description'].length < 250 ? 4 : null,
          // overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w500,
          ),
          textDirection: TextDirection.rtl,
        ),
      ),
      Row(
        children: [
          IconButton(
            icon: Icon(MdiIcons.share),
            onPressed: () async => _sharePostLink(Constants.webLink),
          ),
          IconButton(
            icon: Icon(MdiIcons.comment),
            onPressed: () {
              // Add your comment logic here
              debugPrint('Commenting on post ${post['title']}');
            },
          ),
        ],
      ),
      Expanded(
        child: Container(
          width: 840.w,
          // height: 185.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey),
          ),
          child: _buildCommentList(postComments),
        ),
      ),
      SizedBox(height: 8.h),
      SizedBox(
        width: 840.w,
        child: TextFormField(
          maxLength: 200,
          textInputAction: TextInputAction.done,
          onChanged: (value) {
            commentsList[index] = value;
          },
          // onTap: () {
          //   // Check if the user is signed in before adding a comment
          //   if (FirebaseAuth.instance.currentUser != null) {
          //     if (postId.isNotEmpty) {
          //       // _addComment(postId);
          //       // commentController.clear();
          //     } else {
          //       debugPrint('Post ID is null. Cannot add comment.');
          //     }
          //   } else {
          //     // User is not signed in
          //     debugPrint('User not authenticated. Please log in.');
          //     _showSignInDialog(); // Show the sign-in dialog
          //   }
          // },
          onFieldSubmitted: (value) {
            if (commentController.text.trim().isEmpty) return;
            // Check if the user is signed in before adding a comment
            if (FirebaseAuth.instance.currentUser != null) {
              if (postId.isNotEmpty) {
                _addComment(postId, commentController.text);
                commentController.clear();
                commentsList[index] = '';
              } else {
                debugPrint('Post ID is null. Cannot add comment.');
              }
            } else {
              // User is not signed in
              debugPrint('User not authenticated. Please log in.');
              _showSignInDialog(); // Show the sign-in dialog
            }
          },
          controller: commentController,
          enableInteractiveSelection: true,
          textAlign: TextAlign.right,
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'https?://')),
            FilteringTextInputFormatter.deny(
              RegExp(
                  r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])'),
            ),
          ],
          decoration: InputDecoration(
            hintText: '... اكتب تعليقك ',
            suffixIcon: IconButton(
              icon: Icon(MdiIcons.send),
              onPressed: () {
                if (commentController.text.trim().isEmpty) return;
                // Check if the user is signed in before adding a comment
                if (FirebaseAuth.instance.currentUser != null) {
                  if (postId.isNotEmpty) {
                    _addComment(postId, commentController.text);
                    commentController.clear();
                  } else {
                    debugPrint('Post ID is null. Cannot add comment.');
                  }
                } else {
                  // User is not signed in
                  debugPrint('User not authenticated. Please log in.');
                  _showSignInDialog(); // Show the sign-in dialog
                }
              },
            ),
          ),
        ),
      ),
    ];
  }

  String? POSTID;

  Widget _buildPostList(List<QueryDocumentSnapshot> posts) {
    _filteredPosts = _selectedFilter == null
        ? posts
        : posts
        .where((QueryDocumentSnapshot post) =>
    (post.data() as Map<String, dynamic>).containsKey('title') &&
        post.get('title') == _selectedFilter)
        .toList();
    commentsControllers = List<TextEditingController>.generate(_filteredPosts?.length ?? 0, (index) => TextEditingController());
    commentsList = List<String>.generate(_filteredPosts?.length ?? 0, (index) => '');

    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.horizontal,
      itemCount: ((_filteredPosts?.length ?? 0) / 2).ceil() * 3,
      // itemCount: _filteredPosts?.length ?? 0,
      itemBuilder: (context, index) {
        if (_filteredPosts!.length > 1) {
          if (index % 3 == 2) {
            return AdSenseAdUnit(addUnit: kadamaDisplayApp, viewID: 'KadamaDisplayAdd$index',);
          }
        }
        final post = _filteredPosts![index].data() as Map<String, dynamic>;
        POSTID = _filteredPosts![index].id;

        debugPrint('Post ID: $POSTID');
        debugPrint('Length: ${index % 3}');
        debugPrint("Index:: ${(6 ~/ 3) * 2 + (6 % 3)}");



        int newIndex = (index ~/ 3) * 2 + (index % 3);
        debugPrint("Index : $newIndex");

        return FutureBuilder<List<DocumentSnapshot<Object?>>>(
          future: FirebaseFirestore.instance
              .collection('posts')
              .doc(POSTID)
              .collection('comments')
              .get()
              .then((value) => value.docs),
          builder: (context, snapshot) {
            // if (snapshot.connectionState == ConnectionState.waiting) {
            //   return const Center(child: CircularProgressIndicator());
            // }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final postComments = snapshot.data ?? [];

            return _buildPostCard(
                post, POSTID!, postComments, commentsControllers[newIndex], newIndex);
          },
        );
      },
    );
  }
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _carouselController = CarouselController();

  int _initialPage = 0;
  final List<String> images = [
    "assets/main1.jpg",
    "assets/main2.jpg",
    "assets/main3.jpg",
    "assets/main4.jpg",
    "assets/main5.jpg",
    "assets/main6.jpg",
  ];
  void onPageChange(int value, CarouselPageChangedReason r) {
    setState(() {
      _initialPage = value;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey,
      appBar: Responsive.screenWidth >= Responsive.maxMobileWidth ? AppBar(
        // title: const Text("استثمر في سوق الخضار وانت بيبيتك", textDirection: TextDirection.rtl,),
        automaticallyImplyLeading: false,
        actions: [
          SizedBox(
            width: 10.w,
          ),
          ElevatedButton(
            onPressed: _navigateToContactUs,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(6.r),
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            child: const Text(
              'اتصل بنا',
              textDirection: TextDirection.rtl,
            ),
          ),
          SizedBox(
            width: 10.w,
          ),
          ElevatedButton(
            onPressed: _navigateToAboutUs,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(6.r),
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            child: const Text(
              'معلومات عنا',
              textDirection: TextDirection.rtl,
            ),
          ),
          SizedBox(
            width: 10.w,
          ),
          ElevatedButton(
            onPressed: _navigateToAddPost,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(6.r),
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            child: const Text(
              'اضف منشور',
              textDirection: TextDirection.rtl,
            ),
          ),
          SizedBox(
            width: 10.w,
          ),
          ElevatedButton(
            onPressed: _navigateToTermsAndConditions,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(8.r),
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            child: const Text(
              'الشروط و الاحكام',
              textDirection: TextDirection.rtl,
            ),
          ),
          SizedBox(
            width: 10.w,
          ),
          ElevatedButton(
            onPressed: () => _showSignOutConfirmationDialog(context),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(6.r),
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            child: const Text(
              'تسجيل خروج',
              textDirection: TextDirection.rtl,
            ),
          ),
          SizedBox(
            width: 10.w,
          ),
          // if (user == null)
          ElevatedButton(
            onPressed: _navigateToSignUp,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(6.r),
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            child: const Text(
              'تسجيل',
              textDirection: TextDirection.rtl,
            ),
          ),
          // if (user == null)
          SizedBox(
            width: 10.w,
          ),
        ],
      ) : AppBar(elevation: 0, title: const Text("استثمر في سوق الخضار وانت بيبيتك", textDirection: TextDirection.rtl,), leading: IconButton(icon: Icon(MdiIcons.menu), onPressed: () => _scaffoldKey.currentState!.openDrawer(),),),
      drawer: Responsive.screenWidth >= Responsive.maxMobileWidth ? null : Drawer(
        width: MediaQuery.of(context).size.width * 0.5,
        child: Column(
          children: [
            SizedBox(height: 50.h,),
            ListTile(
              onTap: _navigateToAddPost,
              contentPadding: EdgeInsets.only(top: 10.h, right: 10.w),
              title: const Text(
                'اضف منشور',
                textDirection: TextDirection.rtl,
                style: TextStyle(color: Colors.teal),
              ),
            ),
            const Divider(),
            ListTile(
              onTap: _navigateToAboutUs,
              contentPadding: EdgeInsets.only(top: 10.h, right: 10.w),
              title: const Text(
                'معلومات عنا',
                textDirection: TextDirection.rtl,
                style: TextStyle(color: Colors.teal),
              ),
            ),
            const Divider(),
            ListTile(
              onTap: _navigateToTermsAndConditions,
              contentPadding: EdgeInsets.only(top: 10.h, right: 10.w),
              title: const Text(
                'الشروط و الاحكام',
                textDirection: TextDirection.rtl,
                style: TextStyle(color: Colors.teal),
              ),
            ),
            const Divider(),
            ListTile(
              onTap: _navigateToContactUs,
              contentPadding: EdgeInsets.only(top: 10.h, right: 10.w),
              title: const Text(
                'اتصل بنا',
                textDirection: TextDirection.rtl,
                style: TextStyle(color: Colors.teal),
              ),
            ),
            const Divider(),
            ListTile(
              onTap: _navigateToSignUp,
              contentPadding: EdgeInsets.only(top: 10.h, right: 10.w),
              title: const Text(
                'تسجيل',
                textDirection: TextDirection.rtl,
                style: TextStyle(color: Colors.teal),
              ),
            ),
            const Divider(),
            ListTile(
              onTap: () => _showSignOutConfirmationDialog(context),
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
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0.r),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CarouselSlider(
                carouselController: _carouselController,
                // disableGesture: true,
                options: CarouselOptions(autoPlay: true, initialPage: _initialPage, height: Responsive.screenWidth >= Responsive.maxMobileWidth ? 1224.h : 512.h, aspectRatio: 16/9,
                  onPageChanged: onPageChange,
                  viewportFraction: 0.9,),
                items: images.map((i) {
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
              // Container(
              //   width: Responsive.webWidth,
              //   height: 700.h,
              //   decoration: const BoxDecoration(
              //       color: Color(0xFFE57373),
              //       image: DecorationImage(
              //           // fit: BoxFit.fill,
              //           image: AssetImage("assets/main.jpg"))),
              // ),
              SizedBox(height: 16.h),
              Text(
                Constants.firstHeading,
                style: TextStyle(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.normal,
                ),
                textDirection: TextDirection.rtl,
              ),
              SizedBox(height: 16.h),
              Text(
                Constants.secondHeading,
                style: TextStyle(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.normal,
                ),
                textDirection: TextDirection.rtl,
              ),
              SizedBox(height: 16.h),
              /*Text(
                'يوجد عاملات منزليات نقل خدمات جميع الجنسيات',
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.normal,
                ),
                textDirection: TextDirection.rtl,
              ),
              SizedBox(height: 16.h),
              Text(
                'عقود نضامية - جهة مرخصة - وفق مساند السعودية',
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.normal,
                ),
                textDirection: TextDirection.rtl,
              ),
              SizedBox(height: 16.h),*/
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      launchURL(
                          'https://youtu.be/LHHtiU9Skq4?si=E3OOefM6cSAzu1Gt');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(4.r),
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    child:
                        const Text('يوتيوب', textDirection: TextDirection.rtl),
                  ),
                  Text(
                    'الشرح المفصل تعال يوتيوب :',
                    style:
                        TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _launchDialer('+966557346096'); // +966557346096
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(4.r),
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        child: const Text('رقم الهاتف',
                            textDirection: TextDirection.rtl),
                      ),
                      SizedBox(width: 6.w),
                      ElevatedButton(
                        onPressed: () {
                          // _launchURL('https://t.me/kadematt');
                          launchURL('https://t.me/kaademaa');
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(4.r),
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        child: const Text('تيليجرام',
                            textDirection: TextDirection.rtl),
                      ),
                      SizedBox(width: 6.w),
                      ElevatedButton(
                        onPressed: () {
                          // _launchURL(
                          //     'https://whatsapp.com/channel/0029Va8gHCE3WHTSeCMSU005');
                          launchURL(
                              'https://whatsapp.com/channel/0029VaS3E8FEawdlcgOjux3u');
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(4.r),
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        child: const Text('واتساب',
                            textDirection: TextDirection.rtl),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      'للتواصل:',
                      style: TextStyle(
                          fontSize: 32.sp, fontWeight: FontWeight.bold),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 530.w,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        alignment: AlignmentDirectional.centerEnd,
                        items: Constants.dropdownItems.map((String value) {
                          return DropdownMenuItem<String>(
                            alignment: AlignmentDirectional.centerEnd,
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? selectedValue) {
                          setState(() {
                            _selectedFilter = selectedValue;
                          });
                          // fetchPostsData();
                        },
                        padding: EdgeInsets.symmetric(horizontal: 8.sp),
                        value: _selectedFilter,
                        hint: const Text(
                          'اضغط للاختيار',
                          style: TextStyle(),
                        ),
                        icon: Icon(
                          MdiIcons.chevronDown,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // if (_filteredPosts != null && _filteredPosts!.isNotEmpty)
              SizedBox(
                height: Responsive.screenWidth >= Responsive.maxMobileWidth
                    ? 900.h
                    : 1200.h,
                child: FutureBuilder<QuerySnapshot<Map<String,dynamic>>>(
                  future: myFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.error.toString()),
                      );
                    }

                    if (snapshot.hasData && snapshot.data == null) {
                      return const Center(
                        child: Text("Empty"),
                      );
                    }

                    if (snapshot.hasData && snapshot.data != null) {
                      final posts = snapshot.data!.docs;
                      return _buildPostList(posts);
                    }


                    return const Center(child: CircularProgressIndicator(),);
                  },
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _navigateToPreviousPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    child:
                        const Text('السابق', textDirection: TextDirection.rtl),
                  ),
                  SizedBox(width: 16.w),
                  ElevatedButton(
                    onPressed: _navigateToNextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    child:
                        const Text('التالي', textDirection: TextDirection.rtl),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
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
      ),
    );
  }
}
