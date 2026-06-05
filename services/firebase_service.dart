import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  static final DatabaseReference db =
      FirebaseDatabase.instance.ref();

  static Future<String> getGeneralWaste() async {
    try {
      final snapshot = await db.child("generalWaste").get();

      if (snapshot.exists) {
        return snapshot.value.toString();
      }

      return "No Data";
    } catch (e) {
      return "Error";
    }
  }
}
