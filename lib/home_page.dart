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

  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    initSpeechToText();

    flutterTts.setStartHandler(() {
      setState(() {
        isPlaying = true;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        isPlaying = false;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        isPlaying = false;
      });
    });

    // initTextToSpeech();
  }

  // Future<void> initTextToSpeech() async {
  // }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();

    setState(() {});
  }

  Future<void> _startListening() async {
    await speechToText.listen(
        onResult: _onSpeechResult, listenFor: const Duration(seconds: 60));
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

    setState(() {
      loadingAnimationOn = true;
    });
    var response = await Dio()
        .get(url, options: Options(responseType: ResponseType.bytes));

    if (response.statusCode == 200) {
      await ImageGallerySaver.saveImage(Uint8List.fromList(response.data),
          quality: 60, name: "image");

      setState(() {
        loadingAnimationOn = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image Saved to Photos!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('image Not Saved: Some Error occurred')));
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
    Future.delayed(Duration(seconds: 4));
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
                      height: 180,
                      width: 180,
                      // margin: const EdgeInsets.only(top: 0),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.shade100.withOpacity(1),
                            spreadRadius: 15,
                            blurRadius: 40,
                            offset: const Offset(0, 0), // changes position of shadow
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 165,
                    margin: const EdgeInsets.only(top: 7.5),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: AssetImage(isPlaying
                                ? 'assets/images/maya-speak.gif'
                                : 'assets/images/maya-anime-1-4.jpg'))),
                  )
                ],
              ),
            ),
            // <====== Voice input Animation ======>
            if (speechToText.isListening && loadingAnimationOn == false)
              Padding(
                padding: const EdgeInsets.only(top: 35.0, bottom: 10.0),
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Colors.yellow.shade800,
                  size: 40,
                ),
              ),

            // <====== Loading Animation ======>
            if (loadingAnimationOn == true)
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
                visible: generatedImageUrl == null &&
                    speechToText.isNotListening &&
                    loadingAnimationOn == false,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  margin: const EdgeInsets.symmetric(horizontal: 40)
                      .copyWith(top: 30),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Pallete.borderColor,
                      ),
                      borderRadius: BorderRadius.circular(20)
                          .copyWith(topLeft: Radius.zero)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      generatedContent == null
                          ? "🙏 Anurag, I'm Maya💫!!\nIs there anything I can do for you?"
                          : generatedContent!,
                      style: TextStyle(
                          color: Pallete.mainFontColor,
                          fontSize: generatedContent == null ? 25 : 18,
                          fontFamily: 'Cera'),
                    ),
                  ),
                ),
              ),
            ),
            // <============ Image generated by Dall-E =============>
            if (generatedImageUrl != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 25.0),
                    child: Text(
                      'Your Image is ready, have a look!!',
                      style: TextStyle(
                        fontFamily: 'Cera',
                        color: Color(0xff271a2b),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
                    child: TextButton(
                      onPressed: () {},
                      onLongPress: () {
                        saveImageToDownloads(generatedImageUrl!);
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
                  TextButton(
                    onPressed: (){
                      saveImageToDownloads(generatedImageUrl!);
                    },
                    child: Container(
                      width: 140,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xff271a2b),
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Save',
                            style: TextStyle(
                              fontFamily: 'Cera',
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(Icons.download, color: Colors.white,size: 27,)
                        ],
                      ),
                    ),
                  )
                ],
              ),

            // <============ Suggestion List =============>
            SlideInLeft(
              child: Visibility(
                visible: generatedContent == null &&
                    generatedImageUrl == null &&
                    loadingAnimationOn == false &&
                    speechToText.isNotListening,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16)
                      .copyWith(left: 36),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Here are few things I can do 😎 👇',
                    style: TextStyle(
                      fontFamily: 'Cera',
                      color: Pallete.mainFontColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //<============ Feature Box list =============>
            Visibility(
              visible: generatedContent == null &&
                  generatedImageUrl == null &&
                  loadingAnimationOn == false &&
                  speechToText.isNotListening,
              child: Column(
                children: [
                  SlideInLeft(
                    delay: Duration(milliseconds: start),
                    child: const FeatureBox(
                        color: Color(0xff514852),
                        // color: Colors.yellow,
                        textColor: Colors.white,
                        headerText: 'Ask me Anything 🔥',
                        descriptionText:
                            'A smart way to stay organized and informed with MAYA X GPT'),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start + delay),
                    child: const FeatureBox(
                      color: Color(0xff772926),
                      // color: Pallete.secondSuggestionBoxColor,
                      textColor: Colors.white,
                      headerText: 'Creative Images ✨',
                      descriptionText:
                          'Get inspired and stay creative, your own voice to image with MAYA X Dall-E',
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start + 2 * delay),
                    child: const FeatureBox(
                      color: Color(0xff6c9393),
                      // color: Pallete.thirdSuggestionBoxColor,
                      textColor: Colors.white,
                      headerText: 'Smart Voice Assistant 🧠',
                      descriptionText:
                          'Get the best of both worlds with a voice assistant powered by Dall-E X ChatGPT',
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
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xff271a2b),
          onPressed: () async {
            if (await speechToText.hasPermission &&
                speechToText.isNotListening) {
              setState(() {
                isPlaying = false;
                flutterTts.stop();
              });
              await _startListening();
            } else if (speechToText.isListening) {
              setState(() {
                loadingAnimationOn = true;
              });
              await Future.delayed(const Duration(seconds: 1));
              print(lastWords);
              final speech = await openAIService.isArtPrompt(lastWords);

              if (speech.contains('https')) {
                generatedImageUrl = speech;
                generatedContent = null;
                loadingAnimationOn = false;
                setState(() {});
              } else {
                generatedImageUrl = null;
                generatedContent = speech;
                loadingAnimationOn = false;
                setState(() {});
              }
              if(generatedContent == null){
                await systemSpeak("Offcourse, here is your AI generated Image");
              }else {
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
