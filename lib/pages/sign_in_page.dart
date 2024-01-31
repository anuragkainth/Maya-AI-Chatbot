import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gpt_app/constants/images.dart';
import 'package:gpt_app/constants/colors.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:gpt_app/utilities/auth_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';
import 'package:gpt_app/utilities/utils.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {

  bool _obscureText = true;

  bool isChecked = true;
  bool isDisabled = false;

  bool? valueFirst = false;

  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final userNameController = TextEditingController();

  String? password;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 30.0),
                            child: Row(
                              children: [
                                Text(
                                  'Hey, Sign In here ',
                                  style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 30,
                                      )),
                                ),
                                // SizedBox(
                                //     height: 45,
                                //     width: 45,
                                //     child: Image.asset('images/$accountLockLogo'))
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 30.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Enter your Email',
                                  style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15
                                      )),
                                ),
                                SizedBox(height: 5,),
                                TextFormField(
                                  autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                                  validator: (email) => email != null &&
                                      !EmailValidator.validate(email)
                                      ? 'Enter a valid email'
                                      : null,
                                  controller: emailController,
                                  style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        color: Colors.black,
                                      )),
                                  decoration: InputDecoration(
                                    hintText: 'abc@gmail.com',
                                    hintStyle: GoogleFonts.poppins(
                                        textStyle:
                                        TextStyle(color: Colors.black38)),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                      BorderSide(color: kDefaultRedColor),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                      BorderSide(color: kDefaultRedColor),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top:12, bottom: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Enter your password',
                                  style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15
                                      )),
                                ),
                                SizedBox(height: 5,),
                                TextFormField(
                                  autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                                  validator: (value) =>
                                  value != null && value.length < 6
                                      ? 'Enter min. 6 characters'
                                      : null,
                                  controller: passwordController,
                                  onChanged: (value) {
                                    password = value;
                                  },
                                  obscureText: _obscureText,
                                  style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        color: Colors.black38,
                                      )),
                                  decoration: InputDecoration(
                                    suffixIcon: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _obscureText = !_obscureText;
                                        });
                                      },
                                      child: Icon(
                                        _obscureText
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    hintText: 'password',
                                    hintStyle: GoogleFonts.poppins(
                                        textStyle:
                                        TextStyle(color: Colors.black38)),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                      BorderSide(color: kDefaultRedColor),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                      BorderSide(color: kDefaultRedColor),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.start,
                          //   children: [
                          //     MSHCheckbox(
                          //       style: MSHCheckboxStyle.stroke,
                          //       size: 20,
                          //       value: isChecked,
                          //       isDisabled: isDisabled,
                          //       colorConfig:
                          //       MSHColorConfig.fromCheckedUncheckedDisabled(
                          //         checkedColor: kDefaultRedColor,
                          //       ),
                          //       // style: style,
                          //       onChanged: (selected) {
                          //         setState(() {
                          //           isChecked = selected;
                          //         });
                          //       },
                          //     ),
                          //     SizedBox(width: 8),
                          //     TextButton(
                          //       style: ButtonStyle(
                          //         overlayColor:
                          //         MaterialStateProperty.resolveWith<Color>(
                          //               (Set<MaterialState> states) {
                          //             return kDefaultBackgroundBlack; // No overlay color
                          //           },
                          //         ),
                          //       ),
                          //       onPressed: () {
                          //         setState(() {
                          //           isChecked = !isChecked;
                          //         });
                          //       },
                          //       child: Text(
                          //         'Remember me',
                          //         style: GoogleFonts.poppins(
                          //             textStyle: TextStyle(
                          //                 color: Colors.black, fontSize: 16)),
                          //       ),
                          //     )
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  // color: kDefaultGreyColor,
                  child: AuthButton(
                    overlayColor: kDefaultGreyColor,
                    onPressed: signIn,
                    text: 'Log In',
                    color: Colors.deepOrange.shade700,
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Future signIn() async {

    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator(),)
    );

    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      Navigator.popUntil(context, (route) => route.isFirst);

    } on FirebaseAuthException catch (e) {
      print(e);

      Navigator.pop(context);
      Utils.showSnackBar(e.message);
    }
  }
}
