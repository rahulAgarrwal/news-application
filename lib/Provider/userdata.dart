import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
String anonymousimageurl='https://imgs.search.brave.com/8eTLlpDmlrE1XA4R4A6bqsfOaDA9texAnYIeoxqZrlQ/rs:fit:860:0:0/g:ce/aHR0cHM6Ly90My5m/dGNkbi5uZXQvanBn/LzAwLzU3LzA0LzU4/LzM2MF9GXzU3MDQ1/ODg3X0hISm1sNkRK/VnhOQk1xTWVEcVZK/MFpRRG5vdHA1ckdE/LmpwZw';
class UserDataFetcher{
  static String username='';
  static String profileUrl='';
  static String uid='';
  List savednews=[];
  static Future<void> init ()async{
    uid=FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore db=FirebaseFirestore.instance;
    final userDocument=await db.collection('Users').doc(uid).get();
    username=userDocument.get('name')??'Anonymus';
    profileUrl=userDocument.get('profileurl')??anonymousimageurl;
    print('Details init successfully');
  }
 
}