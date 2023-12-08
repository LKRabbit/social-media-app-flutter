// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/MainPage.dart';
import 'package:social_media_app/LoginWithUsername.dart';
import 'package:social_media_app/appdata/GlobalLibrary.dart';
import 'package:social_media_app/class/SharedPreferencesClass.dart';
import 'package:social_media_app/class/UserSocialClass.dart';
import 'package:social_media_app/custom/CustomButton.dart';
import 'package:social_media_app/state/main.dart';
import 'package:social_media_app/transition/RightToLeftTransition.dart';
import 'class/UserDataClass.dart';
import 'styles/AppStyles.dart';

var dio = Dio();

class LoginWithEmailStateless extends StatelessWidget {
  const LoginWithEmailStateless({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginWithEmailStateful();
  }
}

class LoginWithEmailStateful extends StatefulWidget {
  const LoginWithEmailStateful({super.key});

  @override
  State<LoginWithEmailStateful> createState() => _LoginWithEmailStatefulState();
}

class _LoginWithEmailStatefulState extends State<LoginWithEmailStateful> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  ValueNotifier<bool> verifyEmailFormat = ValueNotifier(false);
  ValueNotifier<bool> verifyPasswordFormat = ValueNotifier(false);
  final int passwordCharacterMinLimit = profileInputMinLimit['password'];
  final int passwordCharacterMaxLimit = profileInputMaxLimit['password'];
  ValueNotifier<bool> isLoading = ValueNotifier(false);

  @override
  void initState(){
    super.initState();
    emailController.addListener(() {
      if(mounted){
        String emailText = emailController.text;
        verifyEmailFormat.value = emailText.isNotEmpty && checkEmailValid(emailText);
      }
    });
    passwordController.addListener(() {
      if(mounted){
        String passwordText = passwordController.text;
        verifyPasswordFormat.value = passwordText.isNotEmpty && passwordText.length >= passwordCharacterMinLimit
        && passwordText.length <= passwordCharacterMaxLimit;
      }
    });
  }

  @override void dispose(){
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    verifyEmailFormat.dispose();
    verifyPasswordFormat.dispose();
    isLoading.dispose();
  }
  

  void loginWithEmail() async{
    try {
      if(!isLoading.value){
        if(checkEmailValid(emailController.text.trim()) == false){
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Alert!!!', style: TextStyle(fontSize: defaultTextFontSize)),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: [
                      Text('Email format is invalid.', style: TextStyle(fontSize: defaultTextFontSize)),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Ok', style: TextStyle(fontSize: defaultTextFontSize)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }else{  
          String stringified = jsonEncode({
            'email': emailController.text.trim(),
            'password': passwordController.text.trim(),
          });
          if(mounted){
            isLoading.value = true;
            var res = await dio.post('$serverDomainAddress/users/loginWithEmail', data: stringified);
            if(res.data.isNotEmpty){
              if(res.data['message'] == 'Login successful'){
                appStateClass.currentID = res.data['userID'];
                Map userProfileData = (res.data['userProfileData']);
                UserDataClass userProfileDataClass = UserDataClass(
                  userProfileData['user_id'], userProfileData['name'], userProfileData['username'], userProfileData['profile_picture_link'], 
                  userProfileData['date_joined'], userProfileData['birth_date'], userProfileData['bio'], 
                  false, false, false, userProfileData['private'], false, false, userProfileData['verified'], false, false
                );
                UserSocialClass userSocialClass = UserSocialClass(
                  0, 0, false, false
                );
                if(mounted){
                  updateUserData(userProfileDataClass, context);
                  updateUserSocials(userProfileDataClass, userSocialClass, context);
                }
                SharedPreferencesClass().updateCurrentUser(res.data['userID'], AppLifecycleState.resumed);
                runDelay(() => Navigator.pushAndRemoveUntil(
                  context,
                  SliderRightToLeftRoute(
                    page: const MainPageWidget()),
                  (Route<dynamic> route) => false
                ), navigatorDelayTime);
              }else{
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Alert!!!', style: TextStyle(fontSize: defaultTextFontSize)),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: [
                            Text(res.data['message'], style: TextStyle(fontSize: defaultTextFontSize)),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Continue', style: TextStyle(fontSize: defaultTextFontSize)),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }
              if(mounted){
                isLoading.value = false;
              }
            }
          }
        }
      }
    } on Exception catch (e) {
      doSomethingWithException(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: defaultLeadingWidget(context),
        title: const Text('Login With Email'), 
        titleSpacing: defaultAppBarTitleSpacing,
        flexibleSpace: Container(
          decoration: defaultAppBarDecoration
        )
      ),
      body: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: defaultFrontPageDecoration,
          child: Stack(
            children: [
              Positioned(
                      left: -getScreenWidth() * 0.45,
                      top: -getScreenWidth() * 0.25,
                      child: Container(
                        width: getScreenWidth(),
                        height: getScreenWidth(),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(200),
                          color: Colors.amber.withOpacity(0.65)
                        ),
                      ),
                    ),
              Positioned(
                right: -getScreenWidth() * 0.55,
                top: getScreenWidth() * 0.85,
                child: Container(
                  width: getScreenWidth(),
                  height: getScreenWidth(),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(200),
                    color: Colors.blue.withOpacity(0.8)
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: defaultHorizontalPadding),
                child: ListView(
                  children: <Widget>[
                    SizedBox(
                      height: defaultVerticalPadding
                    ),
                    containerMargin(
                      textFieldWithDescription(
                        TextField(
                          controller: emailController,
                          decoration: generateProfileTextFieldDecoration('your email', Icons.mail),
                        ),
                        'Email',
                        ''
                      ),
                      EdgeInsets.symmetric(vertical: defaultTextFieldVerticalMargin)
                    ),
                    containerMargin(
                      Column(
                        children: [
                          textFieldWithDescription(
                            TextField(
                              controller: passwordController,
                              decoration: generateProfileTextFieldDecoration('your password', Icons.lock),
                              keyboardType: TextInputType.visiblePassword,
                              maxLength: passwordCharacterMaxLimit
                            ),
                            'Password',
                            "Your password should be between $passwordCharacterMinLimit and $passwordCharacterMaxLimit characters",
                          ),
                          SizedBox(
                            height: getScreenHeight() * 0.001,
                          ),
                        ]
                      ),
                      EdgeInsets.symmetric(vertical: defaultTextFieldVerticalMargin)
                    ),
                    SizedBox(
                      height: textFieldToButtonMargin
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ValueListenableBuilder(
                          valueListenable: verifyEmailFormat,
                          builder: (context, emailVerified, child) {
                            return ValueListenableBuilder(
                              valueListenable: verifyPasswordFormat,
                              builder: (context, passwordVerified, child) {
                                return ValueListenableBuilder(
                                  valueListenable: isLoading,
                                  builder: (context, isLoadingValue, child) {
                                    return CustomButton(
                                      width: defaultTextFieldButtonSize.width, height: defaultTextFieldButtonSize.height,
                                      buttonColor: emailVerified && passwordVerified && !isLoadingValue ? Colors.red : Colors.grey, buttonText: 'Login', 
                                      onTapped: emailVerified && passwordVerified && !isLoadingValue ? loginWithEmail : (){},
                                      setBorderRadius: true,
                                    );
                                  }
                                );
                              }
                            );
                          }
                        )
                      ]
                    ),
                    SizedBox(
                      height: defaultVerticalPadding
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: (){
                            runDelay(() => Navigator.pushReplacement(
                              context,
                              SliderRightToLeftRoute(
                                page: const LoginWithUsernameStateless()
                              )
                            ), navigatorDelayTime);
                          },
                          child: Text('Login with username instead', style: TextStyle(fontSize: defaultLoginAlternativeTextFontSize, color: Colors.amberAccent,))
                        )
                      ]
                    ),
                  ],
                ),
              ),
              ValueListenableBuilder(
                valueListenable: isLoading,
                builder: (context, isLoadingValue, child) {
                  return isLoadingValue ?
                    loadingPageWidget()
                  : Container();
                } 
              )
            ]
          )
        )
      ),
    );
  }
}
