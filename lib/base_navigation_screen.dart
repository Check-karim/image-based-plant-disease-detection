import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart'; // Import HomeScreen
import 'login_screen.dart'; // Import LoginScreen
import 'register_screen.dart'; // Import RegisterScreen
import 'admin_screen.dart'; // Import AdminScreen
import 'users_screen.dart'; // Import UsersScreen

class BaseNavigationScreen extends StatefulWidget {
  @override
  _BaseNavigationScreenState createState() => _BaseNavigationScreenState();
}

class _BaseNavigationScreenState extends State<BaseNavigationScreen> {
  int _selectedIndex = 0;
  bool _isLoggedIn = false;
  String _username = '';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? '';
      _isLoggedIn = _username.isNotEmpty;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color lightBlue = Colors.lightBlue;
    final Color darkBlue = Colors.blue;

    return Scaffold(
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: darkBlue,
        unselectedItemColor: lightBlue,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          if (!_isLoggedIn) ...[
            BottomNavigationBarItem(
              icon: Icon(Icons.login),
              label: 'Login',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.app_registration),
              label: 'Register',
            ),
          ],
          if (_isLoggedIn) ...[
            BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings),
              label: _username,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.logout),
              label: 'Logout',
            ),
          ],
        ],
      ),
    );
  }

  // This method returns the correct body based on the selected index
  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return HomeScreen();
      case 1:
        return LoginScreen();
      case 2:
        return RegisterScreen();
      case 3:
        return _username == 'admin' ? AdminScreen() : UsersScreen();
      case 4:
        _logout();
        return HomeScreen(); // Log out, but keep the HomeScreen as fallback
      default:
        return HomeScreen();
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username'); // Clear the username
    setState(() {
      _isLoggedIn = false;
      _selectedIndex = 0; // Redirect to HomeScreen after logout
    });
  }
}
