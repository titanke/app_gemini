import 'package:app_gemini/main.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:app_gemini/widgets/AddTopic.dart';
import 'package:app_gemini/pages/HomePage.dart';


class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  OnBoardingPageState createState() => OnBoardingPageState();
}

class OnBoardingPageState extends State<IntroPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => Menu()),
    );
  }

  Widget _buildFullscreenImage() {
    return Image.asset(
      'assets/sq.png',
      fit: BoxFit.cover,
      height: double.infinity,
      width: double.infinity,
      alignment: Alignment.center,
    );
  }
  

  Widget _buildImage(String assetName, [double width = 350,double height = 350]) {
    return Image.asset('assets/$assetName', width: width,height: height);
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);

    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      allowImplicitScrolling: false,
      autoScrollDuration: null,
      infiniteAutoScroll: false,
 
      pages: [
        PageViewModel(
          title: "Would you like to quickly recall your notes?".tr(),
          body:
              "This app will take care of everything, just upload your notes (photos, pdfs) and we will prepare a quiz and a personalized chat for you.".tr(),
          image: _buildImage('Add.jpg'),
          decoration: pageDecoration,
        ),
            PageViewModel(
          title: "Multiple Topics".tr(),
          body:
              "You can have multiple topics, each of them will have a personalized quiz, just tap on the topic and it will show you a page where you can take the quiz or see your notes".tr(),
          image: _buildImage('top.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Custom quiz based on your notes".tr(),
          body:
              "Based on your notes, the application will generate a quiz with different types of questions".tr(),
          image: _buildImage('quiz.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Study Companion".tr(),
          body:
              "Custom chat that responds to you, based on the topic of your choice".tr(),
          image: _buildImage('chat.png'),
          decoration: pageDecoration,
        ),
    
    
        PageViewModel(
          title: "Are you ready?, start uploading the notes of your first topic".tr(),
          bodyWidget: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            
          ),
          decoration: pageDecoration.copyWith(
            bodyFlex: 2,
            imageFlex: 4,
            bodyAlignment: Alignment.bottomCenter,
            imageAlignment: Alignment.topCenter,
          ),
          image: _buildImage('sq.png'),
          reverse: true,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context), 
      showSkipButton: false,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: false,
      back: const Icon(Icons.arrow_back),
      skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)).tr(),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)).tr(),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: kIsWeb
          ? const EdgeInsets.all(12.0)
          : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: const ShapeDecoration(
        color: Color.fromARGB(0, 0, 0, 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }
}

