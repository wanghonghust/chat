import 'package:flutter/material.dart';
import 'package:ollama_dart/ollama_dart.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ModelsResponse? modelsResponse;
  final ollamClient = OllamaClient();
  String? ollamVersion;

  @override
  void initState() {
    super.initState();
    getOllamVersion();
    getOllamaModels();
  }

  @override
  Widget build(BuildContext context) {
    String text;
    if (ollamVersion != null) {
      text = "Ollama Version: $ollamVersion";
    } else {
      text = "Ollama not initialized";
    }
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text(
              text,
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.green,
                  fontWeight: FontWeight.bold),
            ),
            if (modelsResponse != null)
              Expanded(
                  child: ListView.builder(
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(modelsResponse!.models![index].model!),
                  );
                },
                itemCount: modelsResponse?.models?.length ?? 0,
              ))
          ],
        ),
      ),
    );
  }

  void getOllamVersion() {
    ollamClient.getVersion().then((versionResponse) {
      setState(() {
        ollamVersion = versionResponse.version;
      });
    }).catchError((err){
    });
  }

  void getOllamaModels() async {
    var res = await ollamClient.listModels();
    setState(() {
      modelsResponse = res;
    });
  }
}
