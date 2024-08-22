import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyBubF6mkxdgS4gapGDQ8uyxYGGkjR769Pg",
      authDomain: "fitproapp-87709.firebaseapp.com",
      projectId: "fitproapp-87709",
      storageBucket: "fitproapp-87709.appspot.com",
      messagingSenderId: "208462250228",
      appId: "1:208462250228:web:129b11c2d5d2e2850b1ea1",
      measurementId: "G-KQGRZJT86D",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FitOfProfit',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.hindTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: AdminPanel(),
    );
  }
}

class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  bool isSidebarOpen = true;
  Widget currentScreen = UsersScreen(); // Default screen

  void toggleSidebar() {
    setState(() {
      isSidebarOpen = !isSidebarOpen;
    });
  }

  void changeScreen(Widget screen) {
    setState(() {
      currentScreen = screen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          if (isSidebarOpen)
            Sidebar(
              
              onMenuTap: (Widget screen) {
                changeScreen(screen);
                toggleSidebar();
              },
            ),
          Expanded(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.white,
                  leading: IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: toggleSidebar,
                  ),
              
                ),
                Expanded(
                  child: currentScreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Sidebar extends StatelessWidget {
  final Function(Widget) onMenuTap;

  Sidebar({required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          DrawerHeader(
            child: Column(
              children: [
                Image.asset('assets/images/logo.png',height: 120,width: 120,),
               
              ],
            ),
          ),
        
         ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 10,),
                    Text('Users', style: TextStyle(color: Colors.black)),
                  ],
                ),
                onTap: () => onMenuTap(UsersScreen()),
              ),
         
        ],
      ),
    );
  }
}

class UsersScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (error) {
      print('Error deleting user: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final users = snapshot.data!.docs;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width,
                ),
                child: DataTable(
                  columnSpacing: 20.0,
                  columns: [
                    DataColumn(label: Expanded(child: Text('Index', style: GoogleFonts.hind(fontWeight: FontWeight.w600)))),
                    DataColumn(label: Expanded(child: Text('Email', style: GoogleFonts.hind(fontWeight: FontWeight.w600)))),
                    DataColumn(label: Expanded(child: Text('Action', style: GoogleFonts.hind(fontWeight: FontWeight.w600)))),
                  ],
                  rows: List.generate(users.length, (index) {
                    final user = users[index];
                    return DataRow(
                      cells: [
                        DataCell(
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 150),
                            child: Text((index + 1).toString(), style: GoogleFonts.hind(), overflow: TextOverflow.ellipsis),
                          ),
                        ),
                        DataCell(
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 250),
                            child: Text(user['email'], style: GoogleFonts.hind(), overflow: TextOverflow.ellipsis),
                          ),
                        ),
                        DataCell(
                          IconButton(
                            icon: Icon(Icons.delete, color: Color(0xFFf37c3e),),
                            onPressed: () => _deleteUser(user.id),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
