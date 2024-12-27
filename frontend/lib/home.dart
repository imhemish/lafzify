import 'package:adwaita_icons/adwaita_icons.dart';
import 'package:flutter/material.dart';
import 'package:frontend/jobs.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _pages = [
    const JobsPage(),
    const Center(child: Text("Secrets Page"))
  ];

  static const _navigationBarItems = [
    BottomNavigationBarItem(icon: AdwaitaIcon(AdwaitaIcons.document_properties), label: "Jobs"),
    BottomNavigationBarItem(icon: AdwaitaIcon(AdwaitaIcons.dialog_password), label: "Secrets")
  ];

  var _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _pages[_selectedIndex]),
        BottomNavigationBar(items: _navigationBarItems, currentIndex: _selectedIndex, onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },),
      ],
    );
  }
}