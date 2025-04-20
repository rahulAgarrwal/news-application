
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:newsapp2/Screens/MainScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
class GptPreview extends StatelessWidget {
  const GptPreview({super.key});
  setval()async{
    final prefs=await SharedPreferences.getInstance();
              prefs.setBool('preview',true);
  }
  @override
  Widget build(BuildContext context) {
    final mediaObj = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: mediaObj.height * 0.06,
            decoration: const BoxDecoration(
                color: Color(0xff02011D),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15))),
          ),
          Container(
            margin: EdgeInsets.symmetric(
                horizontal: mediaObj.width * 0.1,
                vertical: mediaObj.height * 0.05),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SvgPicture.asset(
                  'assets/Icons/robotsleep.svg',
                 color: Colors.black,
                  height: mediaObj.height * 0.064,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  'AskGPT',
                  style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: mediaObj.height * 0.05,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: mediaObj.width * 0.03),
            child:  Text(
              'Using this application you can ask your questions and receive articles using AI assistant technology',
              strutStyle: const StrutStyle(),
              textAlign: TextAlign.center,
              style: TextStyle(
                
                color: Colors.black.withOpacity(0.71),
                fontFamily: 'Outfit',
                fontSize: 18,
                wordSpacing:
                    4.0, // Increase this value to increase space between words
              ),
            ),
          ),
          SizedBox(height: mediaObj.height*0.03,),
          Container(
            
            height: mediaObj.height*0.4,
            width:double.infinity,
            margin: EdgeInsets.symmetric(horizontal: mediaObj.width*0.03,vertical: mediaObj.height*0.03),
            child:SvgPicture.asset('assets/Icons/previewgpt.svg',),
          ),
          GestureDetector(
            onTap: ()async{
              setval();
              curremtIndex=2;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const MainScreen()));
            },
            child: Container(
              height: mediaObj.height*0.07,
              width: mediaObj.width*0.9,
              margin: EdgeInsets.symmetric(horizontal:mediaObj.width*0.03,vertical: mediaObj.height*0.02),
              decoration: BoxDecoration(
                color: const Color(0xff02011D),
                borderRadius: BorderRadius.circular(40)
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: mediaObj.width*0.3,),
                  const Text('Continue',style: TextStyle(fontSize: 25,color: Colors.white,fontWeight: FontWeight.bold),),
                  const Spacer(),
                  const Icon(Icons.arrow_forward,color: Colors.white,)
                  ,const SizedBox(width: 10,)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
