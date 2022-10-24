import 'package:flutter/material.dart';

import 'nav_drawer.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: Colors.indigo,
      ),
      drawer: const NavDrawer(
        selected: DrawerSelection.about,
      ),
      body: const Center(child: Text('ABOUT')),
    );
  }
}
