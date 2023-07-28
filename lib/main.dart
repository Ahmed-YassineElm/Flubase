import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
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
import 'package:image_picker/image_picker.dart';
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
  final String? userEmail; // Add the userEmail property
  MyHomePage({required this.userEmail});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void initState() {
    super.initState(); // Assign the userEmail from the widget
  }

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
    if (widget.userEmail == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      Widget page;
      switch (selectedIndex) {
        case 0:
          page = GeneratorPage();
          break;
        case 1:
          page = FavoritesPage();
          break;
        case 2:
          page = ViewPage(
            userEmail: widget.userEmail!,
          );
          break;
        case 3:
          page = ProfilePage();
          break;
        case 4:
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
                    icon: Icon(Icons.person),
                    label: Text('Profile'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.logout),
                    label: Text('Log Out'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    if (value == 4) {
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
  int selectedIndex = 0;
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
    if (isEmailVerified) {
      timer?.cancel();
      navigateToCreateProfilePage();
    }
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
      ? MyHomePage(userEmail: FirebaseAuth.instance.currentUser!.email!)
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
                  ),
                ],
              )));
  Future<void> navigateToCreateProfilePage() async {
    int selectedIndex = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateProfilePage(),
      ),
    );

    setState(() {
      this.selectedIndex = selectedIndex;
    });
  }
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

class CreateItemPage extends StatefulWidget {
  final int selectedIndex;
  final String userEmail;
  CreateItemPage({required this.selectedIndex, required this.userEmail});

  @override
  State<CreateItemPage> createState() => _CreateItemPageState();
}

class _CreateItemPageState extends State<CreateItemPage> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Add Item'),
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
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              child: Text('Create'),
              onPressed: () async {
                final item = Item(
                  name: nameController.text,
                  description: descriptionController.text,
                  price: double.parse(priceController.text),
                  creationDate: DateTime.now(),
                  createdBy: widget
                      .userEmail, // You can set the user who created it here
                );

                try {
                  await createItem(item);
                  Navigator.pop(context, widget.selectedIndex);
                  // Pass the selectedIndex back
                } catch (e) {
                  print('Error creating item: $e');
                  // Handle any errors that occurred during item creation.
                }
              },
            ),
          ],
        ),
      );

  Future createItem(Item item) async {
    final docItem =
        FirebaseFirestore.instance.collection('items').doc(item.name);
    final json = item.toJson();
    await docItem.set(json);
  }
}

class ViewPage extends StatefulWidget {
  final String userEmail; // Add the userEmail property
  ViewPage({required this.userEmail});
  @override
  State<ViewPage> createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  Map<String, bool> showMoreMap = {}; //added

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text("All Items"),
        ),
        body: StreamBuilder<List<Item>>(
          stream: readItems(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text("Something went wrong $snapshot");
            } else if (snapshot.hasData) {
              final items = snapshot.data!;
              return ListView(
                children: items.map(buildItem).toList(),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: navigateToCreatePage,
        ),
      );

  Widget buildItem(Item item) {
    bool isExpanded = showMoreMap[item.name] ?? false; // modified
    return Column(
      children: [
        ListTile(
          title: Text(item.name),
          subtitle: Text(item.creationDate.toIso8601String()),
          trailing: PopupMenuButton(
            onSelected: (value) {
              if (value == 'delete') {
                // Perform the delete operation for the item here
                deleteItem(item.name);
              } else if (value == 'edit') {
                // Navigate to the edit page to modify the item here
                navigateToEditPage(item);
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
        if (isExpanded) // Render additional item info if isExpanded is true
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Description: ${item.description}"),
                Text("Price: ${item.price}"),
                Text("Created by: ${item.createdBy}")
                // Add more information as needed...
                // For example, Text("CreatedByUser: ${item.createdByUser}"),
              ],
            ),
          ),
        TextButton(
          onPressed: () {
            setState(() {
              showMoreMap[item.name] = !isExpanded; // modified
            });
          },
          child: Text(isExpanded ? "Show Less" : "Show More"),
        ),
        Divider(), // Add a divider for visual separation between items
      ],
    );
  }

  /*Stream<List<Item>> readItems() => FirebaseFirestore.instance
      .collection('items')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Item.fromJson(doc.data() as Map<String, dynamic>))
          .toList());*/
  Stream<List<Item>> readItems() {
    return FirebaseFirestore.instance.collection('items').snapshots().transform(
          StreamTransformer<QuerySnapshot<Map<String, dynamic>>,
              List<Item>>.fromHandlers(
            handleData: (QuerySnapshot<Map<String, dynamic>> snapshot,
                EventSink<List<Item>> sink) {
              final items = snapshot.docs.map((doc) {
                final data = doc.data();
                return Item(
                  name: data['name'] ??
                      '', // Replace '' with a default value if necessary
                  description: data['description'] ??
                      '', // Replace '' with a default value if necessary
                  creationDate: DateTime.parse(data['creationDate'] ??
                      '1970-01-01'), // Replace with a default value if necessary
                  price: data['price'] ??
                      0.0, // Replace 0.0 with a default value if necessary
                  createdBy: data['createdBy'] ??
                      '', // Replace '' with a default value if necessary
                );
              }).toList();
              sink.add(items);
            },
            handleError: (error, stackTrace, sink) {
              print("Error fetching items: $error");
              sink.addError("Something went wrong");
            },
          ),
        );
  }

  Future<void> navigateToCreatePage() async {
    User? user = FirebaseAuth.instance.currentUser;
    String? userEmail = user?.email!;
    int selectedIndex = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateItemPage(
          selectedIndex: this.selectedIndex,
          userEmail: widget.userEmail,
        ),
      ),
    );
    // When the CreatePage is dismissed, update the selectedIndex
    setState(() {
      this.selectedIndex = selectedIndex;
    });
  }

  void deleteItem(String itemName) {
    FirebaseFirestore.instance.collection('items').doc(itemName).delete();
  }

  // To navigate to the edit page, you can use the following method:
  void navigateToEditPage(Item item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPage(
          item: item,
          userEmail: widget.userEmail,
        ),
      ),
    );
  }
}

class EditPage extends StatefulWidget {
  final Item item;
  final String userEmail;
  EditPage({required this.item, required this.userEmail});

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.item.name;
    descriptionController.text = widget.item.description;
    priceController.text = widget.item.price.toString();
    selectedDate = widget.item.creationDate;
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
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
        title: Text('Edit Item'),
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
            controller: descriptionController,
            decoration: InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Price'),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Creation Date',
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
              final updatedItem = Item(
                name: nameController.text,
                description: descriptionController.text,
                price: double.parse(priceController.text),
                creationDate: selectedDate ?? DateTime.now(),
                createdBy: widget.userEmail,
              );

              try {
                await updateItem(updatedItem);
                Navigator.pop(context);
              } catch (e) {
                print('Error updating item: $e');
                // Handle any errors that occurred during item update.
              }
            },
          ),
        ],
      ),
    );
  }

  Future updateItem(Item item) async {
    final docItem =
        FirebaseFirestore.instance.collection('items').doc(item.name);
    final json = item.toJson();
    await docItem.update(json);
  }
}

class CreateProfilePage extends StatefulWidget {
  @override
  State<CreateProfilePage> createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  DateTime? selectedDate;
  File? _imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Profile')),
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
            child: Text('Save Profile'),
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                final profile = Users(
                  email: user.email!, // Use the email directly as the ID
                  name: nameController.text,
                  age: int.parse(ageController.text),
                  birthday: selectedDate ?? DateTime.now(),
                );
                try {
                  await createUserProfile(profile);
                  Navigator.pop(context); // Go back to the previous page
                } catch (e) {
                  print('Error creating profile: $e');
                  // Handle any errors that occurred during profile creation.
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> createUserProfile(Users profile) async {
    final docUser =
        FirebaseFirestore.instance.collection('users').doc(profile.email);
    final json = profile.toJson();
    await docUser.set(json);
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
}

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<_ProfilePageState> _profilePageKey =
      GlobalKey<_ProfilePageState>();
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  DateTime? selectedDate;
  File? _imageFile;
  String _imageUrl = "";

  @override
  void initState() {
    super.initState();
    // Fetch the user profile data and populate the fields
    fetchUserProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  Future<void> fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docUser =
          FirebaseFirestore.instance.collection('users').doc(user.email);
      final userData = await docUser.get();
      if (userData.exists) {
        final profile = Users.fromJson(userData.data() as Map<String, dynamic>);
        setState(() {
          nameController.text = profile.name;
          ageController.text = profile.age.toString();
          selectedDate = profile.birthday;
          _imageUrl = profile.imageUrl;
        });
      }
    }
  }

  Future<void> updateUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docUser =
          FirebaseFirestore.instance.collection('users').doc(user.email);
      final profile = Users(
        email: user.email!,
        name: nameController.text,
        age: int.parse(ageController.text),
        birthday: selectedDate ?? DateTime.now(),
      );
      await docUser.set(profile.toJson());
    }
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
      appBar: AppBar(title: Text('Profile')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: <Widget>[
          TextFormField(
            readOnly: true,
            initialValue: FirebaseAuth.instance.currentUser?.email,
            decoration: InputDecoration(
              labelText: 'Email',
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: ageController,
            decoration: InputDecoration(
              labelText: 'Age',
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Birthday',
                hintText: "Select a date",
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              child: Text(
                selectedDate != null
                    ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                    : 'Select a date',
              ),
            ),
          ),
          const SizedBox(height: 32),
          if (_imageUrl.isEmpty)
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey),
              ),
              child: _imageFile != null
                  ? ClipOval(
                      child: Image.file(
                        _imageFile!,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(Icons.person, size: 100, color: Colors.grey),
            ),
          SizedBox(height: 24),
          _imageUrl.isNotEmpty
              ? Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Image.network(
                        _imageUrl,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: IconButton(
                        onPressed: _removeImage,
                        icon: Icon(Icons.delete),
                        color: Colors.red,
                      ),
                    ),
                  ],
                )
              : ElevatedButton(
                  onPressed: () {
                    // Show a dialog to choose between camera and gallery
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Choose an option'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _pickImage(ImageSource.camera);
                            },
                            child: Text('Camera'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _pickImage(ImageSource.gallery);
                            },
                            child: Text('Gallery'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text('Upload Image'),
                ),
          ElevatedButton(
            onPressed: () async {
              // Create the user profile object
              Users userProfile = Users(
                email: FirebaseAuth.instance.currentUser?.email ?? '',
                name: nameController.text,
                age: int.parse(ageController.text),
                birthday: selectedDate ?? DateTime.now(),
                imageUrl: _imageUrl, // Pass the current imageUrl
              );

              // Call the saveUserProfile function to update the profile
              await saveUserProfile(userProfile, _imageFile);

              // Show a snackbar to indicate success
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Profile updated successfully')),
              );
              fetchUserProfile();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _removeImage() async {
    // Check if the profile has an existing image
    if (_imageUrl.isNotEmpty) {
      try {
        // Get the reference to the image in Firebase Storage
        firebase_storage.Reference ref =
            firebase_storage.FirebaseStorage.instance.refFromURL(_imageUrl);

        // Delete the image from Firebase Storage
        await ref.delete();

        setState(() {
          // Set the image file and URL to null as it has been deleted
          _imageFile = null;
          _imageUrl = '';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile picture removed')),
        );
      } catch (e) {
        // Handle any errors that occur during the process
        print("Error removing profile picture: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove profile picture')),
        );
      }
    } else {
      // If there is no image URL, simply reset the image file
      setState(() {
        _imageFile = null;
      });
    }
  }

  Future<void> saveUserProfile(
    Users userProfile,
    File? imageFile, // Optional image file parameter
  ) async {
    try {
      // Step 1: Upload the image to Firebase Storage (if provided)
      if (imageFile != null) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        firebase_storage.Reference ref = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child(fileName);

        // Upload the image file
        await ref.putFile(imageFile);

        // Get the download URL of the uploaded image
        String imageUrl = await ref.getDownloadURL();

        // Assign the download URL to the userProfile object
        userProfile.imageUrl = imageUrl;
      }

      // Step 2: Save the user profile data to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userProfile
              .email) // Assuming you have a userId property in the Users class
          .set(userProfile.toJson());
    } catch (e) {
      // Handle any errors that occur during the process
      print("Error saving user profile: $e");
    }
  }
}

class Users {
  final String name;
  final String email;
  final int age;
  final DateTime birthday;
  String imageUrl;

  Users({
    required this.email,
    required this.name,
    required this.age,
    required this.birthday,
    this.imageUrl = '',
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'name': name,
        'age': age,
        'birthday': birthday,
        'imageUrl': imageUrl,
      };

  static Users fromJson(Map<String, dynamic> json) => Users(
        email: json['email'],
        name: json['name'],
        age: json['age'],
        birthday: (json['birthday'] as Timestamp).toDate(),
        imageUrl: json['imageUrl'],
      );
}

class Item {
  String name;
  String description;
  DateTime creationDate;
  double price;
  String createdBy;

  Item({
    required this.name,
    required this.description,
    required this.creationDate,
    required this.price,
    required this.createdBy,
  });

  // You can add more methods or properties to the class as needed

  // Convert the item to a JSON format for storage in Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'creationDate': creationDate.toIso8601String(),
      'price': price,
      'createdBy': createdBy,
    };
  }

  // Create an item object from a JSON map retrieved from Firestore
  static Item fromJson(Map<String, dynamic> json) {
    return Item(
      name: json['name'],
      description: json['description'],
      creationDate: DateTime.parse(json['creationDate']),
      price: json['price'],
      createdBy: json['createdBy'],
    );
  }
}
