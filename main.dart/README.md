import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';
import 'services/gemini_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SmartDustbinApp());
}



class SmartDustbinApp extends StatelessWidget {
  const SmartDustbinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Smart Dustbin",
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const LoadingScreen(),
    );
  }
}

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardPage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete,
              size: 100,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            Text(
              "Smart Dustbin",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState 
      extends State<DashboardPage> {

String detectedObject = "No Object Detected";
String wasteCategory = "--";
String aiRecommendation = "--";

Future<void> analyzeWaste() async {

  String reply =
      await GeminiService.askAI(
    """
Identify the waste.

Plastic water bottle.

Provide:
1. Object
2. Category
3. Recommendation
"""
  );

  print(reply);
}
          String getHealthStatus() {

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(15),
  ),
  child: Column(
    children: [

      const Text(
        "Smart Dustbin Status",
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 10),

   const Text(
        "AI Waste Recognition",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 15),

      Text(
        "Detected Object: $detectedObject",
        style: const TextStyle(fontSize: 18),
      ),

      Text(
        "Waste Category: $wasteCategory",
        style: const TextStyle(fontSize: 18),
      ),

      Text(
        "AI Recommendation: $aiRecommendation",
        style: const TextStyle(fontSize: 18),
      ),


      Text(
        getHealthStatus(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),

    ],
  ),
);

  int general =
      int.tryParse(generalWaste) ?? 0;

  int recycle =
      int.tryParse(recyclableWaste) ?? 0;

  if(general >= 80 || recycle >= 80){
    return "Needs Collection";
  }

  return "Operating Normally";
}

            bool firebaseConnected = true;
Future<void> reconnectFirebase() async {
  try {
    final snapshot = await db.get();

    if (!snapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No data found in Firebase"),
        ),
      );
      return;
    }

    final data = Map<String, dynamic>.from(
      snapshot.value as Map,
    );

    setState(() {
      generalWaste =
          data["generalWaste"]?.toString() ?? "--";

      recyclableWaste =
          data["recyclableWaste"]?.toString() ?? "--";

      smellLevel =
          data["smellLevel"]?.toString() ?? "--";

      gasLevel =
          data["gasLevel"]?.toString() ?? "--";

      powerLevel =
          data["powerLevel"]?.toString() ?? "--";

      cameraUrl =
          data["cameraUrl"]?.toString() ?? "";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Firebase Reconnected"),
      ),
    );

  } catch (e) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Connection Error: $e",
        ),
      ),
    );

  }
}

String getWasteStatus(String value) {

  int level =
      int.tryParse(value) ?? 0;

  if(level >= 80){
    return "FULL";
  }

  if(level >= 60){
    return "WARNING";
  }

  return "NORMAL";
}

        String getStatus(String value) {

  int level = int.tryParse(value) ?? 0;

  if(level >= 80){
    return "FULL";
  }

  if(level >= 60){
    return "WARNING";
  }

  return "NORMAL";
}

        Color getStatusColor(String value) {

  int level = int.tryParse(value) ?? 0;

  if(level >= 80){
    return Colors.red;
  }

  if(level >= 60){
    return Colors.orange;
  }

  return Colors.green;
}

        bool alertShown = false;

void checkAlerts() {

print("Checking Alerts");

  int general =
      int.tryParse(generalWaste) ?? 0;

  int recycle =
      int.tryParse(recyclableWaste) ?? 0;

  int gas =
      int.tryParse(gasLevel) ?? 0;

  int power =
      int.tryParse(powerLevel) ?? 0;


  print("General: $general");
  print("Recycle: $recycle");
  print("Gas: $gas");
  print("Power: $power");

  if ((general >= 80 || recycle >= 80)
      && !alertShown) {

    alertShown = true;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Dustbin Alert"),
        content: const Text(
          "Waste level exceeded 80%"
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  if (general < 80 && recycle < 80) {
    alertShown = false;
  }

if (gas >= 400) {

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Gas Warning"),
      content: const Text(
        "High gas concentration detected!"
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}


}
  final DatabaseReference db =
      FirebaseDatabase.instance.ref("smartDustbin");

  String generalWaste = "--";
  String recyclableWaste = "--";
  String smellLevel = "--";
  String gasLevel = "--";
  String powerLevel = "--";
  String cameraUrl = "";

@override
void initState() {
  super.initState();

  db.onValue.listen((event) {

setState(() {
  firebaseConnected = true;
});
    if (!event.snapshot.exists) return;

    final data = Map<String, dynamic>.from(
      event.snapshot.value as Map,
    );

    setState(() {

      generalWaste =
          data["generalWaste"]?.toString() ?? "--";

      recyclableWaste =
          data["recyclableWaste"]?.toString() ?? "--";

      smellLevel =
          data["smellLevel"]?.toString() ?? "--";

      gasLevel =
          data["gasLevel"]?.toString() ?? "--";

      powerLevel =
          data["powerLevel"]?.toString() ?? "--";

      cameraUrl =
          data["cameraUrl"]?.toString() ?? "";


    });

    checkAlerts();

  });
}

  void listenData() {
    db.onValue.listen((event) {
      final snapshot = event.snapshot;
      if (!snapshot.exists) return;

      final data = Map<String, dynamic>.from(snapshot.value as Map);

      setState(() {
        generalWaste = data["generalWaste"]?.toString() ?? "--";
        recyclableWaste = data["recyclableWaste"]?.toString() ?? "--";
        smellLevel = data["smellLevel"]?.toString() ?? "--";
        gasLevel = data["gasLevel"]?.toString() ?? "--";
        powerLevel = data["powerLevel"]?.toString() ?? "--";
        cameraUrl = data["cameraUrl"]?.toString() ?? "";
      });

      checkAlerts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      appBar: AppBar(
        title: const Text(
          "Smart Dustbin Dashboard",
        ),
        centerTitle: true,
        actions: [

            IconButton(
    icon: const Icon(Icons.refresh),
    onPressed: reconnectFirebase,
  ),



          IconButton(
            icon: const Icon(Icons.smart_toy),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) {
                  return const SizedBox(
                    height: 650,
                    child: AIChatDrawer(),
                  );
                },
              );
            },
          ),
        ],
      ),

      body: RefreshIndicator(
  onRefresh: reconnectFirebase,
  child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),



        child: Column(
          children: [
            Container(
  width: double.infinity,
  padding: const EdgeInsets.all(15),
  decoration: BoxDecoration(
    color: firebaseConnected
        ? Colors.green
        : Colors.red,
    borderRadius: BorderRadius.circular(15),
  ),
  child: Row(
    mainAxisAlignment:
        MainAxisAlignment.center,
    children: [

      Icon(
        firebaseConnected
            ? Icons.cloud_done
            : Icons.cloud_off,
        color: Colors.white,
      ),

      const SizedBox(width: 10),

      Text(
        firebaseConnected
            ? "Firebase Connected"
            : "Firebase Disconnected",
        style: const TextStyle(
          color: Colors.white,
          fontWeight:
              FontWeight.bold,
        ),
      ),

    ],
  ),
),

const SizedBox(height: 20),
            buildCard(
              "General Waste",
              generalWaste,
              Icons.delete,
              Colors.red,
            ),

            const SizedBox(height: 15),

            buildCard(
              "Recyclable Waste",
              recyclableWaste,
              Icons.recycling,
              Colors.green,
            ),

            const SizedBox(height: 15),

            buildCard(
              "Smell Level",
              smellLevel,
              Icons.air,
              Colors.blue,
            ),

            const SizedBox(height: 15),

            buildCard(
              "Gas Level",
              gasLevel,
              Icons.warning,
              Colors.orange,
            ),

            const SizedBox(height: 15),

            buildCard(
              "Power Level",
              powerLevel,
              Icons.power,
              Colors.purple,
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              
                child: ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: Image.network(
      cameraUrl,
      fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
  ScaffoldMessenger.of(context)
      .showSnackBar(
    const SnackBar(
      content: Text(
        "Realtime monitoring active",
      ),
    ),
  );
},
                icon: const Icon(Icons.refresh),
                label: const Text("Refresh Data"),
              ),
            ),
          ],
        ),
      ),
    )
    );
  }

  Widget buildCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        children: [
          Icon(
            icon,
            size: 60,
            color: color,
          ),

          const SizedBox(height: 10),

          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            title.contains("Waste") ? "$value%" : value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 45, 44, 44),
            ),
          ),

          if (title.contains("Waste"))
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: LinearProgressIndicator(
                value: (double.tryParse(value) ?? 0) / 100,
                minHeight: 10,
              ),
            ),

            if(title.contains("Waste"))
  Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Chip(
      backgroundColor:
          getStatusColor(value),
      label: Text(
        getStatus(value),
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    ),
  ),

          if (title.contains("Waste"))
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Chip(
                backgroundColor: getStatusColor(value),
                label: Text(
                  getStatus(value),
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AIChatDrawer extends StatefulWidget {
  const AIChatDrawer({super.key});

  @override
  State<AIChatDrawer> createState() =>
      _AIChatDrawerState();
}

class _AIChatDrawerState
    extends State<AIChatDrawer> {
  final TextEditingController controller =
      TextEditingController();

  final List<String> messages = [
    "AI: Hello. I can assist with Smart Dustbin monitoring."
  ];


  Future<void> sendMessage() async {
    if (controller.text.trim().isEmpty) return;

    final text = controller.text;

    setState(() {
      messages.add("You: $text");
      controller.clear();
    });

    final String reply = await GeminiService.askAI(text);

    setState(() {
      messages.add("AI: $reply");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(20),
              color: Colors.green,

              child: const Column(
                children: [
                  Icon(
                    Icons.smart_toy,
                    size: 70,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Smart Dustbin AI",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (_, index) {
                  return ListTile(
                    title: Text(
                      messages[index],
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding:
                  const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller:
                          controller,
                      decoration:
                          const InputDecoration(
                        hintText:
                            "Ask AI...",
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed:
                        sendMessage,
                    icon:
                        const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
