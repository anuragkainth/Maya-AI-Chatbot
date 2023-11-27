import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gpt_app/pages/sign_in_page.dart';
import 'package:gpt_app/pages/create_account_page.dart';
import 'package:gpt_app/utilities/auth_button.dart';

import '../constants/colors.dart';
import '../constants/images.dart';


class SignInOrSignUpPage extends StatelessWidget {
  const SignInOrSignUpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CircleAvatar(
              radius: MediaQuery.of(context).size.width / 3,
              backgroundColor: Colors.grey,
              child: ClipOval(
                child: Image.asset(
                  'assets/images/maya-anime-1-4.jpg',
                  fit: BoxFit.cover, // Ensure the image covers the entire circle
                  width: double.infinity, // Make the image width take the entire circular area
                  height: double.infinity, // Make the image height take the entire circular area
                ),
              ),
            ),
            Text(
              'Maya AI',
              style: GoogleFonts.orbitron(
                  textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 75,
                      fontWeight: FontWeight.w100
                  )
              ),
            ),
            Column(
              children: [
                AuthButton(text: 'Sign in with Email', onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>  SignInPage(),
                    ),
                  );
                },color: Colors.deepOrange.shade700, overlayColor: kDefaultBackgroundBlack),
                SizedBox(height: 18,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account? ',
                      style: GoogleFonts.nunito(
                          textStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 14
                          )
                      ),
                    ),
                    TextButton(
                      onPressed: (){
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>  MakeAccount(),
                          ),
                        );
                      },
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.nunito(
                            textStyle: TextStyle(
                                color: kDefaultRedColor,
                                fontSize: 14
                            )
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}