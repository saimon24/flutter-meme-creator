import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:meme_creator/meme_selector.dart';
import 'package:path_provider/path_provider.dart';

import 'nav_drawer.dart';
import 'package:http/http.dart' as http;

class CreatorPage extends StatefulWidget {
  Meme? selectedMeme;

  CreatorPage(
      {Key? key,
      this.selectedMeme =
          const Meme(name: '10-Guy', img: 'assets/images/10-Guy.jpeg')});

  @override
  _CreatorPageState createState() => _CreatorPageState();
}

class _CreatorPageState extends State<CreatorPage> {
  final topController = TextEditingController();
  final bottomController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create your Meme'),
        backgroundColor: Colors.indigo,
      ),
      drawer: const NavDrawer(
        selected: DrawerSelection.creator,
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Form(
                      child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: TextField(
                          controller: topController,
                          decoration: const InputDecoration(
                              hintText: 'Top text',
                              border: OutlineInputBorder()),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: TextField(
                          controller: bottomController,
                          decoration: const InputDecoration(
                              hintText: 'Bottom text',
                              border: OutlineInputBorder()),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(8),
                          child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                  minimumSize: const Size.fromHeight(40)),
                              onPressed: () {
                                createMeme();
                              },
                              icon: const Icon(Icons.design_services),
                              label: const Text('Generate Meme')))
                    ],
                  ))),
              Expanded(flex: 2, child: Image.asset(widget.selectedMeme!.img)),
            ],
          ),
          MemeSelector(
              selectedMeme: widget.selectedMeme,
              memeSelected: (val) => memeSelected(val))
        ],
      )),
    );
  }

  void memeSelected(Meme meme) {
    setState(() {
      widget.selectedMeme = meme;
    });
  }

  void createMeme() async {
    final queryParameters = {
      'top': topController.text,
      'bottom': bottomController.text,
      'meme': widget.selectedMeme!.name
    };

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  CircularProgressIndicator(),
                  Text(
                    'Creating Meme...',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  )
                ]),
          );
        });

    final response = await http.get(
        Uri.https('ronreiter-meme-generator.p.rapidapi.com', '/meme',
            queryParameters),
        headers: {
          'X-RapidAPI-Key':
              '72af18a58dmshce39c5be599fa81p1f7d0cjsn5e187ff75993',
          'X-RapidAPI-Host': 'ronreiter-meme-generator.p.rapidapi.com'
        });

    // var response = await http.get(Uri.parse(
    //     'https://upload.wikimedia.org/wikipedia/commons/b/b4/JPEG_example_JPG_RIP_100.jpg'));
    Uint8List image = Uint8List.fromList(response.bodyBytes);
    await Future.delayed(const Duration(seconds: 2));
    Navigator.pop(context);
    showResult(image);
  }

  showResult(Uint8List image) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Your Meme'),
            content: Image.memory(image),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    saveImage(image);
                    Navigator.pop(context);
                  },
                  child: const Text('Download'))
            ],
          );
        });
  }

  saveImage(Uint8List image) async {
    var documentDirectory = await getApplicationDocumentsDirectory();
    var firstPath = '${documentDirectory.path}/images';
    var filePathAndName = '${documentDirectory.path}/images/meme.jpeg';

    await Directory(firstPath).create(recursive: true);
    File file = File(filePathAndName);
    file.writeAsBytesSync(image);

    await GallerySaver.saveImage(file.path);

    const snackbar = SnackBar(content: Text('Meme saved to your gallery!'));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
}
