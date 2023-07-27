import 'dart:async';

import 'package:date_field/date_field.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
//import 'package:flutter_datetime_picker/flutter_datetime_picker.dart' as dt;
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart' hide DatePickerTheme;
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';

import 'main.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(FutureBuilder(
    future: Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAGS1GTp4oZX1x1CrQPmt8JN7g7e2Ugmdk",
        appId: "1:240430843694:android:be73abf2e362101e519cbf",
        messagingSenderId: "240430843694",
        projectId: "flutter-application-d5015",
      ),
    ),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        return MyApp();
      } else {
        return Center(child: CircularProgressIndicator());
      }
    },
  ));
}
/*void main() async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
    // Replace with actual values
          options: const FirebaseOptions(
        apiKey:
            "BH5MFDgJL6ksYxwTcK53EYKT2ESC7-mD0kSKWj9KPOGaUA9MJEPGpDAlUSHQqSXKWE02pXVw7",
        appId: "1:240430843694:android:be73abf2e362101e519cbf",
        messagingSenderId: "240430843694",
        projectId: "flutter-application-d5015",
      ));
      runApp(MyApp());
    }*/

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MainPage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];
  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  void _showLogoutOverlay(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Log Out'),
          content: Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                // Manually trigger a rebuild of the StreamBuilder
                setState(() {});
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Log Out'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      case 2:
        page = ViewPage();
        break;
      case 3:
        page = LogOut();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: false,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite),
                  label: Text('Favorites'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.view_list),
                  label: Text('Create'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.logout),
                  label: Text('Log Out'),
                ),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  if (value == 3) {
                    _showLogoutOverlay(context);
                  } else {
                    selectedIndex = value;
                  }
                });
              },
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
          ),
        ],
      ),
    );
  }
}

class LogOut extends StatelessWidget {
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Log Out'),
      content: Text('Are you sure you want to log out?'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () => FirebaseAuth.instance.signOut(),
          child: Text('Log Out'),
        ),
      ],
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: pair.asPascalCase,
        ),
      ),
    );
  }
}

class LoginWidget extends StatefulWidget {
  final VoidCallback onClickedSignUp;
  const LoginWidget({
    Key? key,
    required this.onClickedSignUp,
  }) : super(key: key);
  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 60,
            ),
            Image.asset(
              'assets/images/download.png',
              height: 200,
              width: 200,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Hey There,\n Welcome Back',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 40,
            ),
            TextField(
              controller: emailController,
              cursorColor: Colors.white,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 4),
            TextField(
              controller: passwordController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(50)),
              icon: Icon(Icons.lock_open, size: 32),
              label: Text('Sign In', style: TextStyle(fontSize: 24)),
              onPressed: signIn,
            ),
            SizedBox(
              height: 24,
            ),
            GestureDetector(
              child: Text(
                "Forgot password?",
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 20),
              ),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ForgotPasswordPage(),
              )),
            ),
            SizedBox(height: 16),
            RichText(
                text: TextSpan(
                    style: TextStyle(color: Colors.black, fontSize: 20),
                    text: 'No account?',
                    children: [
                  TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = widget.onClickedSignUp,
                      text: "Sign Up",
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Theme.of(context).colorScheme.secondary))
                ]))
          ],
        ),
      );
  Future signIn() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return VerifyEmailPage();
            } else {
              return AuthPage();
            }
          }));
}

class VerifyEmailPage extends StatefulWidget {
  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;
  @override
  void initState() {
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    if (!isEmailVerified) {
      sendVerificationEmail();
      timer = Timer.periodic(
        Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });
    if (isEmailVerified) timer?.cancel();
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
      setState(() => canResendEmail = false);
      await Future.delayed(Duration(seconds: 5));
      setState(() => canResendEmail = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(e
                .toString())), // Show the error message from the FirebaseAuthException
      );
    }
  }

  @override
  Widget build(BuildContext context) => isEmailVerified
      ? MyHomePage()
      : Scaffold(
          appBar: AppBar(
            title: Text('Verify Email'),
          ),
          body: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'A verification email has been sent to your email',
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  ElevatedButton.icon(
                    onPressed: canResendEmail ? sendVerificationEmail : null,
                    icon: Icon(Icons.email, size: 32),
                    label: Text(
                      'Resend Email',
                      style: TextStyle(fontSize: 24),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(50),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  TextButton(
                    onPressed: () => FirebaseAuth.instance.signOut(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(fontSize: 24),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(50),
                    ),
                  )
                ],
              )));
}

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  @override
  Widget build(BuildContext context) => isLogin
      ? LoginWidget(
          onClickedSignUp: toggle,
        )
      : SignUpWidget(onClickedSignIn: toggle);

  void toggle() => setState(() => isLogin = !isLogin);
}

class SignUpWidget extends StatefulWidget {
  final Function() onClickedSignIn;
  const SignUpWidget({
    Key? key,
    required this.onClickedSignIn,
  }) : super(key: key);
  @override
  _SignUpWidgetState createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  final formKey = GlobalKey<FormState>();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 60,
            ),
            Image.asset(
              'assets/images/download.png',
              height: 200,
              width: 200,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Hey There,\n Welcome Back',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            TextField(
              controller: emailController,
              cursorColor: Colors.white,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(
              height: 4,
            ),
            TextField(
              controller: passwordController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(
              height: 24,
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(50)),
              icon: Icon(Icons.arrow_forward, size: 32),
              label: Text(
                'Sign Up',
                style: TextStyle(fontSize: 24),
              ),
              onPressed: signUp,
            ),
            SizedBox(
              height: 20,
            ),
            RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 20),
                text: 'Already have an account?',
                children: [
                  TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = widget.onClickedSignIn,
                    text: 'Log In',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      );
  Future signUp() async {
    //final isValid = formKey.currentState!.validate();
    //if (!isValid) return;
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
      setState(() {
        // Manually trigger a rebuild of the StreamBuilder
      });
    } on FirebaseAuthException catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Sign up failed. ${e.message}'), // Show the error message from the FirebaseAuthException
        ),
      );
    }
  }
}

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Reset Password'),
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Receive an email to \nreset your password',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: emailController,
                    cursorColor: Colors.white,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'Email',
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (email) =>
                        email != null && !EmailValidator.validate(email)
                            ? 'Enter a valid email'
                            : null,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton.icon(
                    onPressed: resetPassword,
                    icon: Icon(Icons.email_outlined),
                    label: Text(
                      'Reset Password',
                      style: TextStyle(fontSize: 24),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(50),
                    ),
                  ),
                ],
              )),
        ),
      );
  Future resetPassword() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password email sent'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Sign up failed. ${e.message}'), // Show the error message from the FirebaseAuthException
        ),
      );
    }
  }
}

class CreatePage extends StatefulWidget {
  final int selectedIndex;

  CreatePage({required this.selectedIndex});
  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  DateTime? selectedDate;
  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Add User'),
        ),
        body: ListView(
          padding: EdgeInsets.all(16),
          children: <Widget>[
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 24),
            TextField(
              decoration: InputDecoration(labelText: 'Age'),
              controller: ageController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Birthday',
                  hintText: 'Select a date',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  selectedDate != null
                      ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                      : 'Select a date',
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              child: Text('Create'),
              onPressed: () async {
                final user = Users(
                  name: nameController.text,
                  age: int.parse(ageController.text),
                  birthday: selectedDate ?? DateTime.now(),
                );

                try {
                  await createUser(user);
                  Navigator.pop(context,
                      widget.selectedIndex); // Pass the selectedIndex back
                } catch (e) {
                  print('Error creating user: $e');
                  // Handle any errors that occurred during user creation.
                }
              },
            ),
          ],
        ),
      );

  Future createUser(Users user) async {
    final docUser = FirebaseFirestore.instance.collection('users').doc();
    user.id = docUser.id;

    final json = user.toJson();
    await docUser.set(json);
  }
}

class ViewPage extends StatefulWidget {
  @override
  State<ViewPage> createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  final controller = TextEditingController();
  Map<String, bool> showMoreMap = {}; //added
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text("All Users"),
        ),
        body: StreamBuilder<List<Users>>(
            stream: readUsers(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text("Something went wrong");
              } else if (snapshot.hasData) {
                final users = snapshot.data!;
                return ListView(
                  children: users.map(buildUser).toList(),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: navigateToCreatePage,
        ),
      );
  Widget buildUser(Users user) {
    bool isExpanded = showMoreMap[user.id] ?? false;

    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(child: Text('${user.age}')),
          title: Text(user.name),
          subtitle: Text(user.birthday.toIso8601String()),
          trailing: PopupMenuButton(
            onSelected: (value) {
              if (value == 'delete') {
                // Perform the delete operation for the user here
                deleteUser(user.id);
              } else if (value == 'edit') {
                // Navigate to the edit page to modify the user here
                navigateToEditPage(user);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Text('Edit'),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
        ),

        if (isExpanded) // Render additional user info if isExpanded is true
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("ID: ${user.id}"),
                // Add more information as needed...
                // For example, Text("Email: ${user.email}"),
                // Text("Address: ${user.address}"),
              ],
            ),
          ),
        TextButton(
          onPressed: () {
            setState(() {
              showMoreMap[user.id] = !isExpanded;
            });
          },
          child: Text(isExpanded ? "Show Less" : "Show More"),
        ),
        Divider(), // Add a divider for visual separation between users
      ],
    );
  }

  Stream<List<Users>> readUsers() => FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Users.fromJson(doc.data() as Map<String, dynamic>))
          .toList());
  Future<void> navigateToCreatePage() async {
    int selectedIndex = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePage(selectedIndex: this.selectedIndex),
      ),
    );

    // When the CreatePage is dismissed, update the selectedIndex
    setState(() {
      this.selectedIndex = selectedIndex;
    });
  }

  void deleteUser(String userId) {
    FirebaseFirestore.instance.collection('users').doc(userId).delete();
  }

  // To navigate to the edit page, you can use the following method:
  void navigateToEditPage(Users user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPage(user: user),
      ),
    );
  }
}

class EditPage extends StatefulWidget {
  final Users user;

  EditPage({required this.user});

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.user.name;
    ageController.text = widget.user.age.toString();
    selectedDate = widget.user.birthday;
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit User'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: <Widget>[
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 24),
          TextField(
            decoration: InputDecoration(labelText: 'Age'),
            controller: ageController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Birthday',
                hintText: 'Select a date',
                border: OutlineInputBorder(),
              ),
              child: Text(
                selectedDate != null
                    ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                    : 'Select a date',
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            child: Text('Save Changes'),
            onPressed: () async {
              final updatedUser = Users(
                id: widget.user.id,
                name: nameController.text,
                age: int.parse(ageController.text),
                birthday: selectedDate ?? DateTime.now(),
              );

              try {
                await updateUser(updatedUser);
                Navigator.pop(context);
              } catch (e) {
                print('Error updating user: $e');
                // Handle any errors that occurred during user update.
              }
            },
          ),
        ],
      ),
    );
  }

  Future updateUser(Users user) async {
    final docUser = FirebaseFirestore.instance.collection('users').doc(user.id);
    final json = user.toJson();
    await docUser.update(json);
  }
}

class Users {
  String id;
  final String name;
  final int age;
  final DateTime birthday;
  Users({
    this.id = '',
    required this.name,
    required this.age,
    required this.birthday,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'age': age,
        'birthday': birthday,
      };

  static Users fromJson(Map<String, dynamic> json) => Users(
        id: json['id'] ?? '',
        name: json['name'],
        age: json['age'],
        birthday: (json['birthday'] as Timestamp).toDate(),
      );
}
