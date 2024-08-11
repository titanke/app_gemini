import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:app_gemini/widgets/AddTopic.dart';


class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  OnBoardingPageState createState() => OnBoardingPageState();
}

class OnBoardingPageState extends State<IntroPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => AddTopic()),
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
  

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset('assets/$assetName', width: width);
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);

    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Colors.white,
      allowImplicitScrolling: false,
      autoScrollDuration: null,
      infiniteAutoScroll: false,
      globalHeader: Align(
        alignment: Alignment.topRight,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 16, right: 16),
           // child: _buildImage('sq.png', 100),
          ),
        ),
      ),
 
      pages: [
        PageViewModel(
          title: "Would you like to quickly recall your notes?",
          body:
              "This app will take care of everything, just upload your notes (photos, pdfs) and we will prepare a quiz and a personalized chat for you.",
          image: _buildImage('sq.png'),
          decoration: pageDecoration,
        ),
            PageViewModel(
          title: "Multiple Topics",
          body:
              "You can have multiple topics, each of them will have a personalized quiz, and you can add your favorites to the main screen.",
          image: _buildImage('sq.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Custom quiz based on your notes",
          body:
              "Based on your notes, the application will generate a quiz with different types of questions",
          image: _buildImage('sq.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Study Companion",
          body:
              "Custom chat that responds to you, based on the topic of your choice",
          image: _buildImage('sq.png'),
          decoration: pageDecoration,
        ),
    
    
        PageViewModel(
          title: "Are you ready?, start uploading the notes of your first topic",
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
      skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
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

