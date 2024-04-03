import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:responsive/pages/privacypolicy.dart';
import 'package:responsive/pages/regiter%20page.dart';
import 'package:responsive/pages/userprovider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Aboutus.dart';
import 'constants.dart';
import 'dashboardpage.dart';
import 'faqpage.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: PreferredSize(
      //   preferredSize: Size(screenSize.width, 77.0),
      //   child: AppBar(
      //     automaticallyImplyLeading: false,
      //     backgroundColor: Colors.black,
      //     title: Padding(
      //       padding: const EdgeInsets.only(left: 50.0, top: 20.0),
      //       child: Row(
      //         crossAxisAlignment: CrossAxisAlignment.center,
      //         children: <Widget>[
      //           Text("Order Tracking : ",
      //               style: TextStyle(fontSize: 20.0, color: Colors.white)),
      //           // ShaderMask(
      //           //   shaderCallback: (bounds) =>
      //           //       LinearGradient(colors: [Colors.white, Color(0xffD8D8D8)])
      //           //           .createShader(bounds),
      //           //   child:
      //           Text(
      //               "Take advantage of our time to save event | Satisfaction guaranteed * ",
      //               style: TextStyle(fontSize: 14.0, color: Colors.white)),
      //           // )
      //         ],
      //       ),
      //     ),
      //     actions: [
      //       Padding(
      //         padding: const EdgeInsets.only(left: 50.0, top: 20.0),
      //         child: IntrinsicHeight(
      //           child: Row(
      //             children: [
      //               TextButton(
      //                 onPressed: () {},
      //                 child: Text("Language",
      //                     style: TextStyle(
      //                       color: Colors.white,
      //                       fontSize: 20,
      //                     )),
      //               ),
      //               SizedBox(
      //                 width: 14.0,
      //               ),
      //               Container(
      //                   height: 30,
      //                   color: Colors.white,
      //                   child: VerticalDivider(width: 2, color: Colors.white)),
      //               SizedBox(
      //                 width: 14.0,
      //               ),
      //               IconButton(
      //                   icon: const Icon(
      //                     Icons.location_on_outlined,
      //                     color: Colors.white,
      //                   ),
      //                   // tooltip: 'Show Snackbar',
      //                   onPressed: () {}),
      //               SizedBox(
      //                 width: 14.0,
      //               ),
      //               Container(
      //                   height: 30,
      //                   color: Colors.white,
      //                   child: VerticalDivider(width: 2, color: Colors.white)),
      //               SizedBox(
      //                 width: 14.0,
      //               ),
      //               TextButton(
      //                 onPressed: () {},
      //                 child: Text("Account",
      //                     style: TextStyle(
      //                       color: Colors.white,
      //                       fontSize: 20,
      //                     )),
      //               ),
      //               IconButton(
      //                   icon: const Icon(
      //                     Icons.person_outline,
      //                     color: Colors.white,
      //                   ),
      //                   // tooltip: 'Show Snackbar',
      //                   onPressed: () {}),
      //               SizedBox(
      //                 width: 50.0,
      //               ),
      //             ],
      //           ),
      //         ),
      //       )
      //     ],
      //   ),
      // ),
      body: MyScrollableColumn(), // Assuming RegisterPage contains the widget
    );
  }
}

class MyScrollableColumn extends StatefulWidget {
  @override
  _MyScrollableColumnState createState() => _MyScrollableColumnState();
}

class _MyScrollableColumnState extends State<MyScrollableColumn> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  final TextEditingController _pass = TextEditingController();

  void showToastMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

//   void showToast() {
//     Fluttertoast.showToast(
//       msg: 'This is a toast message',
//       toastLength: Toast.LENGTH_SHORT,
//       gravity: ToastGravity.CENTER,
//       timeInSecForIosWeb: 1,
//       backgroundColor: Colors.grey,
//       textColor: Colors.white,
//       fontSize: 16.0,
//     );
//   }
// }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter an email address.";
    }
    RegExp emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return "Please enter a valid email address.";
    }
    return null;
  }

  String? validatePassword(String? Passvalue) {
    if (Passvalue == null || Passvalue.isEmpty) {
      return "Please enter a password.";
    }
    if (Passvalue.length < 8) {
      return "Password must be atleast 8 characters long.";
    }
    return null;
  }

  late bool _isobscured1 = true;
  bool isChecked = false;
  late dynamic userId;

  Color getColor(Set<MaterialState> states) {
    return Color(0x2bef8f21);
  }

  final AuthService authService = AuthService();

  String errorMessage = '';

  bool _isLoading = false;
  Future<void> postData(String email, String password) async {
    final url = Uri.parse(Constants.ipBaseUrl + 'user/login');

    final Map<String, dynamic> data = {
      'email': email,
      'password': password,
    };

    try {
      final response = await http.post(
        url,
        body: jsonEncode(data),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      final responseData = jsonDecode(response.body);
      print('Output for login: $responseData');

      if (response.statusCode == 200) {
        final token = responseData['token'];
        final userId = responseData['id'];

        if (userId != null && (userId is int || userId is String)) {
          final parsedUserId = (userId is int) ? userId : int.tryParse(userId);

          if (parsedUserId != null) {
            print('Token: $token');
            print('userId: $parsedUserId');

            // Save userId in SharedPreferences
            await saveUserId(parsedUserId);

            await authService.login();

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DashboardPage()),
            );
          } else {
            print('Invalid or missing user ID in the response');
          }
        } else {
          print('Invalid or missing user ID in the response');
        }
      } else if (response.statusCode == 401) {
        // Email already exists or unauthorized
        final responseData = json.decode(response.body);
        errorMessage = responseData[
            'Message']; // Assuming error message is in 'message' key

        showToast();
      } else {
        print('Failed to post data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    var a = MediaQuery.of(context).size;

    var screenSize = MediaQuery.of(context).size;
    print(screenSize);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Other widgets in the Column
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 50.0, vertical: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DashboardPage()),
                              );
                            },
                            child: Image.asset(
                              "images/image 46.png",
                              width: 100,
                              height: 100,
                            ),
                          ),
                          // SizedBox(
                          //   width: 1120.0,
                          // ),

                          Container(
                            // height: a.height*0.1,
                            // width: a.width*0.2,
                            // decoration: BoxDecoration(border: Border.all(width: 1)),
                            child: Row(
                              children: [
                                Text("Home",
                                    style: TextStyle(
                                        fontSize: a.width * 0.01,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                                SizedBox(
                                  width: 10.0,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.arrow_forward_ios),
                                  // tooltip: 'Show Snackbar',
                                  onPressed: () {}, iconSize: a.width * 0.01,
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Text("Login",
                                    style: TextStyle(
                                        fontSize: a.width * 0.01,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 50.0, vertical: 30.0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 50.0,
                            ),
                            child: Row(
                              children: [
                                Text("Login on ",
                                    style: TextStyle(
                                      fontSize: 24,
                                    )),
                                Text("KK BAZAR",
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold))
                              ],
                            ),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.only(left: 50.0, top: 10.0),
                          //   child: Divider(
                          //     height: 10,
                          //     thickness: 2,
                          //     endIndent: 1280,
                          //     color: Color(0xffEF8F21),
                          //   ),
                          // ),
                          // FractionallySizedBox(
                          //   widthFactor: 0.93, // Adjust this value as needed
                          //   child: Divider(
                          //     height: 10,
                          //     thickness: 2,
                          //     endIndent: MediaQuery.of(context).size.width *
                          //         0.8, // Adjust this value as needed
                          //     color: Color(0xffEF8F21),
                          //   ),
                          // ),
                          SizedBox(height: 20.0),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 503,
                                height: 415,
                                child: Card(
                                  elevation: 10,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: const BorderSide(
                                          width: 1, color: Color(0xffEF8F21))),
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30.0, vertical: 42.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Email",
                                            style: TextStyle(
                                                fontSize: 24,
                                                color: Colors.black)),
                                        SizedBox(height: 20.0),
                                        Container(
                                          width: 417,
                                          height: 50,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              color: Color(0x2bef8f21)),
                                          child: TextFormField(
                                            controller: emailController,

                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return "Please enter an email address.";
                                              }
                                              RegExp emailRegExp = RegExp(
                                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                              if (!emailRegExp
                                                  .hasMatch(value)) {
                                                return "Please enter a valid email address.";
                                              }
                                              return null;
                                            },
                                            decoration: InputDecoration(
                                              hintText: 'Email',
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                              ),
                                            ), // controller: emailController,
                                            // validator: validateEmail,
                                            // contentPadding:
                                            //     EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                                          ),
                                        ),
                                        SizedBox(height: 20.0),
                                        Text("Password",
                                            style: TextStyle(
                                                fontSize: 24,
                                                color: Colors.black)),
                                        SizedBox(height: 20.0),
                                        Container(
                                          width: 417,
                                          height: 50,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              color: Color(0x2bef8f21)),
                                          child: TextFormField(
                                            // validator: validatePassword,

                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return "Please enter a password.";
                                              }
                                              if (value.length < 8) {
                                                return "Password must be atleast 8 characters long.";
                                              }
                                              return null;
                                            },
                                            obscureText: _isobscured1,
                                            controller: _pass,
                                            decoration: InputDecoration(
                                              hintText: 'Password',
                                              suffixIcon: IconButton(
                                                padding: EdgeInsetsDirectional
                                                    .symmetric(
                                                        horizontal: 12.0,
                                                        vertical: 5.0),
                                                icon: _isobscured1
                                                    ? const Icon(
                                                        Icons.visibility)
                                                    : const Icon(
                                                        Icons.visibility_off),
                                                onPressed: () => setState(() {
                                                  _isobscured1 = !_isobscured1;
                                                }),
                                              ),
                                              border: const OutlineInputBorder(
                                                  borderSide: BorderSide.none),
                                              // contentPadding: EdgeInsets.symmetric(
                                              //   vertical: 12.0,
                                              //   horizontal: 5.0,
                                              // ),
                                            ),
                                            // style: TextStyle(fontSize: 18),
                                          ),
                                        ),
                                        SizedBox(height: 39.0),
                                        Center(
                                          // child: Obx(
                                          //   () => apiController.isLoading.value
                                          //       ? CircularProgressIndicator()
                                          child: Container(
                                            width: 315,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Color(
                                                    0xffEF8F21), // Background color
                                              ),
                                              onPressed: () {
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  setState(() {
                                                    _isLoading =
                                                        true; // Set loading state to true
                                                  });
                                                  String email = emailController
                                                      .text
                                                      .trim();
                                                  String password =
                                                      _pass.text.trim();
                                                  postData(email, password);
                                                  print("processing data");

                                                  setState(() {
                                                    _isLoading =
                                                        false; // Set loading state to false
                                                  });
                                                }
                                              },
                                              child: Text("SUBMIT",
                                                  style: TextStyle(
                                                      fontSize: 24,
                                                      color: Colors.white)),
                                            ),
                                          ),
                                          // ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Loading indicator
                              if (_isLoading)
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xffEF8F21)),
                                ),
                            ],
                          ),
                          SizedBox(height: 40.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              
                              InkWell(
                                  onTap: () {
                                    // print('Text Clicked');
                                  },
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Are you new to KK BAZAR?',
                                      style: TextStyle(
                                        fontSize: a.width * 0.01,
                                        color: Colors.black,
                                      ),
                                    ),
                                  )),
                              InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                RegisterPage()));
                                  },
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      ' create account',
                                      style: TextStyle(
                                        fontSize: a.width * 0.01,
                                        color: Color(0xFFEF8F21),
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                          // SizedBox(height: 40.0),
                          // Center(
                          //   child: Text("OR",
                          //       style: TextStyle(
                          //         fontSize: 24,
                          //       )),
                          // ),
                          // SizedBox(height: 40.0),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: [
                          //     Container(
                          //       width: 315,
                          //       height: 50,
                          //       decoration: BoxDecoration(
                          //           borderRadius: BorderRadius.circular(10),
                          //           color: Color(0xff4285f4)),
                          //       child: Row(
                          //         children: [
                          //           Stack(
                          //             children: [
                          //               Padding(
                          //                 padding: const EdgeInsets.all(8.0),
                          //                 child: Container(
                          //                     width: 46,
                          //                     height: 38,
                          //                     decoration: BoxDecoration(
                          //                         borderRadius:
                          //                             BorderRadius.circular(10),
                          //                         color: Colors.white)),
                          //               ),
                          //               Positioned(
                          //                   left: 22.0,
                          //                   top: 15.0,
                          //                   child: Image.asset(
                          //                       'images/Google.png')),
                          //             ],
                          //           ),
                          //           SizedBox(
                          //             width: 30.0,
                          //           ),
                          //           Text("Continue with Google",
                          //               style: TextStyle(
                          //                 fontSize: 19,
                          //               ))
                          //         ],
                          //       ),
                          //     ),
                          //     SizedBox(
                          //       width: 20.0,
                          //     ),
                          //     Image.asset(
                          //       "images/Line 6.png",
                          //       color: Colors.black,
                          //     ),
                          //     SizedBox(
                          //       width: 20.0,
                          //     ),
                          //     Container(
                          //       width: 320,
                          //       height: 50,
                          //       decoration: BoxDecoration(
                          //           borderRadius: BorderRadius.circular(10),
                          //           color: Color(0xff3b5998)),
                          //       child: Row(
                          //         children: [
                          //           Stack(
                          //             children: [
                          //               Padding(
                          //                 padding: const EdgeInsets.all(8.0),
                          //                 child: Container(
                          //                     width: 46,
                          //                     height: 38,
                          //                     decoration: BoxDecoration(
                          //                         borderRadius:
                          //                             BorderRadius.circular(10),
                          //                         color: Colors.white)),
                          //               ),
                          //               Positioned(
                          //                   left: 18.0,
                          //                   top: 12.0,
                          //                   child: Image.asset(
                          //                     'images/Facebook App Symbol.png',
                          //                     width: 25,
                          //                     height: 25,
                          //                   )),
                          //             ],
                          //           ),
                          //           SizedBox(
                          //             width: 20.0,
                          //           ),
                          //           Text("Continue with Facebook",
                          //               style: TextStyle(
                          //                 color: Colors.white,
                          //                 fontSize: 19,
                          //               )),
                          //         ],
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Container(
                      width: screenSize.width / 1,
                      height: 350,
                      decoration: BoxDecoration(color: Color(0xe5ef8f21)),
                      child: Padding(
                        padding: const EdgeInsets.all(50.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("KK BAZAR",
                                    style: TextStyle(
                                        fontSize: a.width * 0.02,
                                        color: Colors.white)),
                                Container(
                                  width: a.width*0.18,
                                  height:a.height*0.15,
                                  // decoration: BoxDecoration(border: Border.all(width: 1)),
                                  child: Text(
                                      "Lorem ipsum dolor sit amet consectetur. Volutpat suspendisse nulla elementum sed. Consectetur phasellus tortor pretium netus",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: a.width * 0.01,
                                        
                                      ),
                                      textAlign: TextAlign.left,
                                      ),
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 27.0,
                                      height: 27.0,
                                      child: Image.asset(
                                        "images/Instagram.png",
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    SizedBox(
                                      width: 27.0,
                                      height: 27.0,
                                      child: Image.asset(
                                        "images/Whatsapp.png",
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    SizedBox(
                                      width: 27.0,
                                      height: 27.0,
                                      child: Image.asset(
                                        "images/Youtube.png",
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    SizedBox(
                                      width: 27.0,
                                      height: 27.0,
                                      child: Image.asset(
                                        "images/Twitter.png",
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 20.0,
                                      ),
                                      Text("Information",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: a.width * 0.02,
                                          )),
                                      SizedBox(
                                        height: 30.0,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AboutUsPage()));
                                        },
                                        child: Text("About us",
                                            style: TextStyle(
                                                fontSize: a.width * 0.01,
                                                color: Colors.white)),
                                      ),
                                      SizedBox(
                                        height: 20.0,
                                      ),
                                      Text("Delivery Information",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: a.width * 0.01,
                                          )),
                                      SizedBox(
                                        height: 20.0,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      privacyPolicyPage()));
                                        },
                                        child: Text("Privacy Policy",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: a.width * 0.01,
                                            )),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 20.0,
                                      ),
                                      Text("Contact info",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: a.width * 0.02,
                                          )),
                                      SizedBox(
                                        height: 30.0,
                                      ),
                                      Text("phone: 9876543212",
                                          style: TextStyle(
                                              fontSize: a.width * 0.01,
                                              color: Colors.white)),
                                      SizedBox(
                                        height: 20.0,
                                      ),
                                      Text("Email: kkbazar@gmail.com",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: a.width * 0.01,
                                          )),
                                      SizedBox(
                                        height: 20.0,
                                      ),
                                      Text("www.kkbazar.com",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: a.width * 0.01,
                                          )),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 20.0,
                                      ),
                                      Text("Need Help?",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: a.width * 0.02,
                                          )),
                                      SizedBox(
                                        height: 20.0,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      faqPage()));
                                        },
                                        child: Text("FAQ",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: a.width * 0.01,
                                            )),
                                      ),
                                      SizedBox(
                                        height: 20.0,
                                      ),
                                      Text("Contact Us",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: a.width * 0.01,
                                          )),
                                    ],
                                  )
                                ],
                              ),
                            ),
                    ),
                    Container(
                      width: screenSize.width,
                      height: 240,
                      decoration: BoxDecoration(color: Color(0x21ef8f21)),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 50.0,
                          ),
                          Text(
                              "Our Store | Shippping | Payments | Checkout | Discount | Term & Condition | Policy Shipping",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black)),
                          SizedBox(
                            height: 30.0,
                          ),
                          Image.asset(
                            "images/image 1.png",
                            width: 144,
                            height: 15.75,
                          ),
                          SizedBox(
                            height: 30.0,
                          ),
                          Text("© 2022 copyrights reserved",
                             style:
                                  TextStyle(fontSize: 20, color: Colors.black))
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          // Other widgets after the scrollable content
        ],
      ),
    );
  }

  Future<void> saveUserId(int userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('userId', userId);
    print('saved login userId: $userId');
  }

  void showToast() {
    Fluttertoast.showToast(
      msg: errorMessage,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      webBgColor: '#3D3B40',
      timeInSecForIosWeb: 3,
      // backgroundColor: Color(0x2bef8f21),
      textColor: Colors.white,
      fontSize: 20.0,
    );
  }
}
