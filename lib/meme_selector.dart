import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Meme {
  final String name;
  final String img;

  const Meme({required this.name, required this.img});

  factory Meme.fromName(String name) {
    String img = 'assets/images/$name.jpeg';
    return Meme(name: name, img: img);
  }
}

Future<List<Meme>> getMemes() async {
  final String response = await rootBundle.loadString('assets/list.json');
  List<dynamic> data = jsonDecode(response);

  List<Meme> results = [];

  for (var i = 0; i < data.length; i++) {
    final String entry = data[i];
    results.add(Meme.fromName(entry));
  }
  inspect(results);
  return results;
}

typedef void MemeCallback(Meme val);

class MemeSelector extends StatefulWidget {
  final MemeCallback memeSelected;
  Meme? selectedMeme;

  MemeSelector({Key? key, required this.memeSelected, this.selectedMeme});

  @override
  _MemeSelectorState createState() => _MemeSelectorState();
}

class _MemeSelectorState extends State<MemeSelector> {
  late Future<List<Meme>> memes;

  @override
  void initState() {
    super.initState();
    memes = getMemes();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: memes,
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Select your Meme',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Divider(
                      height: 20,
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        Meme item = snapshot.data[index];

                        return Container(
                          decoration: BoxDecoration(
                              border: widget.selectedMeme?.name == item.name
                                  ? Border.all(width: 4, color: Colors.indigo)
                                  : null),
                          child: IconButton(
                              iconSize: 50,
                              icon: Image.asset(item.img),
                              onPressed: () {
                                setState(() {
                                  widget.selectedMeme = item;
                                });
                                widget.memeSelected(item);
                              }),
                        );
                      },
                    )
                  ],
                ));
          }
        });
  }
}
