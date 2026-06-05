import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {

  static const apiKey =
      "AQ.Ab8RN6LhXCPP661VwqjtcIEMaTk4hAXtNCTxx806YfHbjsp46A";

  static Future<String> askAI(
      String prompt) async {

    final model =
        GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );

    final response =
        await model.generateContent(
      [Content.text(prompt)],
    );

    return response.text ??
        "No response";
  }
}
