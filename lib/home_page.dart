
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:gpt_app/feature_box.dart';
import 'package:gpt_app/open_ai_services.dart';
import 'package:gpt_app/pallete.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final speechToText = SpeechToText();
  final FlutterTts flutterTts = FlutterTts();
  String lastWords = "";
  OpenAIServices openAIService = OpenAIServices();
  String? generatedContent;
  String? generatedImageUrl;
  int start = 200;
  int delay = 200;
  bool loadingAnimationOn = false;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    // initTextToSpeech();
  }

  // Future<void> initTextToSpeech() async {
  // }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();

    setState(() {});
  }

  Future<void> _startListening() async {
    await speechToText.listen(onResult: _onSpeechResult, listenFor: const Duration(seconds: 60));
    setState(() {});
  }

  Future<void> _stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  Future<void> _onSpeechResult(SpeechRecognitionResult result) async {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  Future<void> saveImageToDownloads(String url) async {
    var response = await Dio().get(
        url,
        options: Options(responseType: ResponseType.bytes));

    if(response.statusCode == 200){
      await ImageGallerySaver.saveImage(
          Uint8List.fromList(response.data),
          quality: 60,
          name: "image"
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image Saved to Gallery!'))
      );
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('image Not Saved: Some Error occurred'))
      );
    }
    // print(result);
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(child: const Text('Maya Ai')),
        centerTitle: true,
        leading: const Icon(Icons.menu),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // <====== Maya Assistant profile picture ======>
            ZoomIn(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade800,
                        shape: BoxShape.circle
                      ),
                    ),
                  ),
                  Container(
                    height: 140,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(image: AssetImage('assets/images/Maya-ancient.png'))
                    ),
                  )
                ],
              ),
            ),
            // <====== Voice input Animation ======>
            if(speechToText.isListening && loadingAnimationOn == false)
              Padding(
                padding: const EdgeInsets.only(top: 35.0, bottom: 10.0),
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Pallete.secondSuggestionBoxColor,
                  size: 40,
                ),
              ),

            // <====== Loading Animation ======>
            if(loadingAnimationOn == true)
              Padding(
                padding: const EdgeInsets.only(top: 35.0, bottom: 10.0),
                child: LoadingAnimationWidget.flickr(
                  leftDotColor: Colors.yellow.shade800,
                  rightDotColor: Colors.yellow,
                  size: 40,
                ),
              ),

            // <============ Chat Bubble =============>
            FadeInRight(
              child: Visibility(
                visible: generatedImageUrl == null && speechToText.isNotListening && loadingAnimationOn == false,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(
                    top: 30
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Pallete.borderColor,
                    ),
                    borderRadius: BorderRadius.circular(20).copyWith(
                      topLeft: Radius.zero
                    )
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      generatedContent == null ? 'Good Morning, what task can I do for you?'
                      : generatedContent!,
                    style: TextStyle(
                      color: Pallete.mainFontColor,
                      fontSize: generatedContent == null ? 25 : 18,
                      fontFamily: 'Cera'
                    ),),
                  ),
                ),
              ),
            ),
            // <============ Image generated by Dall-E =============>
            if (generatedImageUrl != null)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextButton(
                  onPressed: (){},
                  onLongPress: () {
                    saveImageToDownloads(
                        generatedImageUrl!);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Pallete.mainFontColor,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(generatedImageUrl!),
                    ),
                  ),
                ),
              ),

            // <============ Suggestion List =============>
            SlideInLeft(
              child: Visibility(
                visible: generatedContent == null && generatedImageUrl == null && loadingAnimationOn == false && speechToText.isNotListening,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16).copyWith(
                    left: 32
                  ),
                  alignment: Alignment.centerLeft,
                  child: const Text('Here are a few features', style: TextStyle(
                    fontFamily: 'Cera',
                    color: Pallete.mainFontColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),),
                ),
              ),
            ),
            //<============ Feature Box list =============>
            Visibility(
              visible: generatedContent == null && generatedImageUrl == null && loadingAnimationOn == false && speechToText.isNotListening,
              child: Column(
                children: [
                  SlideInLeft(
                    delay: Duration(milliseconds: start),
                    child: const FeatureBox(
                        color: Pallete.firstSuggestionBoxColor,
                        headerText: 'ChatGPT',
                        descriptionText: 'A smart way to stay organized and informed with ChatGPT'),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start + delay),
                    child: const FeatureBox(
                      color: Pallete.secondSuggestionBoxColor,
                      headerText: 'Dall-E',
                      descriptionText:
                      'Get inspired and stay creative with your personal assistant powered by Dall-E',
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start + 2 * delay),
                    child: const FeatureBox(
                      color: Pallete.thirdSuggestionBoxColor,
                      headerText: 'Smart Voice Assistant',
                      descriptionText:
                      'Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT',
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: ZoomIn(
        delay: Duration(milliseconds: start + 3 * delay),
        child: FloatingActionButton(
          backgroundColor: Pallete.firstSuggestionBoxColor,
          onPressed: () async {
            if(await speechToText.hasPermission && speechToText.isNotListening){
              await _startListening();
            } else if(speechToText.isListening){
              setState(() {
                loadingAnimationOn = true;
              });
              await Future.delayed(const Duration(seconds: 1));
              print(lastWords);
              final speech = await openAIService.isArtPrompt(lastWords);

              if(speech.contains('https')){
                generatedImageUrl = speech;
                generatedContent = null;
                loadingAnimationOn = false;
                setState(() {});
              } else {
                generatedImageUrl = null;
                generatedContent = speech;
                loadingAnimationOn = false;
                setState(() {});
                await systemSpeak(speech);
              }
              // print(speech);
              await _stopListening();
            } else {
              await initSpeechToText();
            }
          },
          child: Icon(speechToText.isListening ? Icons.stop : Icons.mic),
        ),
      ),
    );
  }
}
