import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyAyfY-t5eQYhU6drcq-5EwxT9fWBK2J0sI',
        authDomain: 'nudgemind-ai.firebaseapp.com',
        projectId: 'nudgemind-ai',
        storageBucket: 'nudgemind-ai.appspot.com',
        messagingSenderId: '240518705556',
        appId: '1:240518705556:web:da896a94509dac92081f81',
        measurementId: 'G-2FJQF1CTRE',
      ),
    );

    debugPrint('Firebase connected successfully!');
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  runApp(const NudgeMindApp());
}

class NudgeMindApp extends StatelessWidget {
  const NudgeMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NudgeMind.AI',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xff121212),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff00c853),
          brightness: Brightness.dark,
        ),
      ),
      // Use a StreamBuilder to check if the user is already logged in 👇
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. While Firebase checks secure storage, show a dark loading indicator
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xff00c853)),
              ),
            );
          }

          // 2. If user data exists, skip login and jump straight to Screen 2!
          if (snapshot.hasData) {
            return const PermissionScreen();
          }

          // 3. If no user is logged in, show the green button screen
          return const WelcomeScreen();
        },
      ),
    );
  }
}
// =============================================================================
// SCREEN 1: WELCOME SCREEN
// =============================================================================

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'NudgeMind.AI',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Let's beat the scroll and smash your exam together!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Color(0xffb3b3b3)),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff00c853),
                    foregroundColor: const Color(0xff121212),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      final GoogleAuthProvider googleProvider =
                          GoogleAuthProvider();

                      final UserCredential userCredential = await FirebaseAuth
                          .instance
                          .signInWithPopup(googleProvider);

                      final User? user = userCredential.user;

                      if (user == null || !context.mounted) {
                        return;
                      }

                      debugPrint('Google login successful');
                      debugPrint('User email: ${user.email}');

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PermissionScreen(),
                        ),
                      );
                    } on FirebaseAuthException catch (e) {
                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Google login failed\nCode: ${e.code}\nMessage: ${e.message}',
                          ),
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Google login failed\nError: $e'),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Log In with Google',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// SCREEN 2: PERMISSION SCREEN
// =============================================================================

class PermissionScreen extends StatelessWidget {
  final User? user; // 👈 1. Added user field to hold the Google profile data

  const PermissionScreen({super.key, this.user}); // 👈 2. Updated constructor

  @override
  Widget build(BuildContext context) {
    // 1. Define the current user first! 👇
    final user = FirebaseAuth.instance.currentUser;

    // 2. Fetch the name from the Google provider data array
    String fullDisplayName = 'User';
    if (user != null && user.providerData.isNotEmpty) {
      for (var profile in user.providerData) {
        if (profile.displayName != null) {
          fullDisplayName = profile.displayName!;
          break;
        }
      }
    } else if (user != null && user.displayName != null) {
      fullDisplayName = user.displayName!;
    }

    // 3. Get just the first name
    final String firstName = fullDisplayName.split(' ').first;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 4. New Personalized Greeting text widget 👇
              Text(
                'Hey $firstName, welcome to NudgeMind.AI!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff00c853), // NudgeMind green
                ),
              ),
              const SizedBox(height: 32),

              const Icon(Icons.security, size: 64, color: Color(0xff00c853)),
              const SizedBox(height: 24),
              const Text(
                'Activate Focus Shield',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'To act as your study guardian, NudgeMind.AI needs '
                'permission to notice when distracting apps open. '
                'We never look at your private messages or personal data.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xffb3b3b3),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff00c853),
                    foregroundColor: const Color(0xff121212),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AnalysisScannerScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Grant Permission & Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// SCREEN 3: AI SCANNER
// =============================================================================

class AnalysisScannerScreen extends StatefulWidget {
  const AnalysisScannerScreen({super.key});

  @override
  State<AnalysisScannerScreen> createState() => _AnalysisScannerScreenState();
}

class _AnalysisScannerScreenState extends State<AnalysisScannerScreen> {
  double _scanProgress = 0.0;

  String _scanStatusText = 'Initializing AI Guardian core configuration...';

  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();
    _startScanningEngine();
  }

  void _startScanningEngine() {
    _scanTimer?.cancel();

    _scanTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_scanProgress < 1.0) {
          _scanProgress += 0.01;

          if (_scanProgress > 0.3 && _scanProgress < 0.6) {
            _scanStatusText =
                'Scanning ecosystem packages for active scroll triggers...';
          } else if (_scanProgress >= 0.6 && _scanProgress < 0.85) {
            _scanStatusText =
                'Calibrating real-time database synchronization modules...';
          } else if (_scanProgress >= 0.85) {
            _scanStatusText =
                'Shield successfully compiled! Finalizing links...';
          }
        } else {
          timer.cancel();
        }
      });

      if (_scanProgress >= 1.0) {
        _navigateToCustomizer();
      }
    });
  }

  void _navigateToCustomizer() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CustomizerScreen()),
    );
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  color: Color(0xff00c853),
                  strokeWidth: 5,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'NudgeMind Shield Core',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _scanStatusText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.white60),
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _scanProgress,
                  backgroundColor: Colors.white10,
                  color: const Color(0xff00c853),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${(_scanProgress * 100).toInt()}% Analysis Complete',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff00c853),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// SCREEN 4: CUSTOMIZER
// =============================================================================

// =============================================================================
// SCREEN 4: CUSTOMIZER / STUDY SETUP
// =============================================================================

class CustomizerScreen extends StatefulWidget {
  const CustomizerScreen({super.key});

  @override
  State<CustomizerScreen> createState() => _CustomizerScreenState();
}

class _CustomizerScreenState extends State<CustomizerScreen> {
  bool _isSaving = false;

  // ---------------------------------------------------------------------------
  // EXAM INFORMATION
  // ---------------------------------------------------------------------------

  final TextEditingController _examInputController = TextEditingController();

  final TextEditingController _targetController = TextEditingController();

  final TextEditingController _availableHoursController = TextEditingController(
    text: '6',
  );

  DateTime? _examDate;

  // ---------------------------------------------------------------------------
  // SUBJECTS
  // ---------------------------------------------------------------------------

  final List<Map<String, String>> _userSubjects = [];

  @override
  void dispose() {
    _examInputController.dispose();
    _targetController.dispose();
    _availableHoursController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // SELECT EXAM DATE
  // ===========================================================================

  Future<void> _selectExamDate() async {
    final DateTime now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _examDate ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: DateTime(now.year + 10),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xff00c853),
              onPrimary: Colors.black,
              surface: Color(0xff1e1e1e),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _examDate = pickedDate;
      });
    }
  }

  // ===========================================================================
  // ADD / EDIT SUBJECT
  // ===========================================================================

  void _showSubjectDialog({int? editIndex}) {
    final bool isEditing = editIndex != null;

    final TextEditingController subjectController = TextEditingController(
      text: isEditing ? _userSubjects[editIndex!]['name'] ?? '' : '',
    );

    String selectedLevel = isEditing
        ? _userSubjects[editIndex!]['status'] ?? 'Average'
        : 'Average';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xff1e1e1e),
              title: Text(isEditing ? 'Edit Subject' : 'Add Subject'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: subjectController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Subject Name',
                      hintText: 'e.g. Physics',
                      prefixIcon: Icon(Icons.book),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  DropdownButtonFormField<String>(
                    value: selectedLevel,
                    decoration: const InputDecoration(
                      labelText: 'Knowledge Level',
                      prefixIcon: Icon(Icons.school),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Weak', child: Text('Weak')),
                      DropdownMenuItem(
                        value: 'Average',
                        child: Text('Average'),
                      ),
                      DropdownMenuItem(value: 'Strong', child: Text('Strong')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedLevel = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff00c853),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    final String subjectName = subjectController.text.trim();

                    if (subjectName.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a subject name.'),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      if (isEditing) {
                        _userSubjects[editIndex!] = {
                          'name': subjectName,
                          'status': selectedLevel,
                        };
                      } else {
                        _userSubjects.add({
                          'name': subjectName,
                          'status': selectedLevel,
                        });
                      }
                    });

                    Navigator.pop(dialogContext);
                  },
                  child: Text(isEditing ? 'Save Changes' : 'Add Subject'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ===========================================================================
  // DELETE SUBJECT
  // ===========================================================================

  void _deleteSubject(int index) {
    final String subjectName = _userSubjects[index]['name'] ?? 'Subject';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xff1e1e1e),
          title: const Text('Delete Subject?'),
          content: Text(
            'Do you want to remove "$subjectName" from your study plan?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _userSubjects.removeAt(index);
                });

                Navigator.pop(dialogContext);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // KNOWLEDGE LEVEL COLOR
  // ===========================================================================

  Color _levelColor(String level) {
    switch (level) {
      case 'Weak':
        return Colors.redAccent;

      case 'Average':
        return Colors.orangeAccent;

      case 'Strong':
        return const Color(0xff00c853);

      default:
        return Colors.grey;
    }
  }

  // ===========================================================================
  // FORMAT DATE
  // ===========================================================================

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // ===========================================================================
  // SAVE AND LAUNCH
  // ===========================================================================

  Future<void> _saveAndLaunch() async {
    final String examName = _examInputController.text.trim();
    final String target = _targetController.text.trim();

    final int? availableHours = int.tryParse(
      _availableHoursController.text.trim(),
    );

    // -------------------------------------------------------------------------
    // VALIDATION
    // -------------------------------------------------------------------------

    if (examName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your exam name.')),
      );
      return;
    }

    if (_examDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your exam date.')),
      );
      return;
    }

    if (target.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your target score or percentage.'),
        ),
      );
      return;
    }

    if (availableHours == null || availableHours < 1 || availableHours > 24) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Available study hours must be between 1 and 24.'),
        ),
      );
      return;
    }

    if (_userSubjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one subject.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // -------------------------------------------------------------------------
    // SAVE TO FIREBASE
    // -------------------------------------------------------------------------

    try {
      // Save the new study plan
      await FirebaseFirestore.instance
          .collection('user_budgets')
          .doc('bhavana_session')
          .set({
            'exam': examName,
            'exam_date': Timestamp.fromDate(_examDate!),
            'target': target,
            'available_hours_per_day': availableHours,
            'subjects': _userSubjects,
            'last_updated': FieldValue.serverTimestamp(),
          });

      // IMPORTANT:
      // Start a fresh timer using the hours entered by the user.
      await FirebaseFirestore.instance
          .collection('user_sessions')
          .doc('live_runtime')
          .set({
            'examName': examName,
            'remainingSeconds': availableHours * 3600,
            'timestamp': FieldValue.serverTimestamp(),
          });

      debugPrint(
        'Study plan saved. New timer started with $availableHours hours.',
      );
    } catch (e) {
      debugPrint('Firebase save skipped: $e');
    }

    // -------------------------------------------------------------------------
    // LAUNCH DASHBOARD
    // -------------------------------------------------------------------------

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => DashboardScreen(
          allocatedHours: availableHours,
          examName: examName,
          subjects: List<Map<String, String>>.from(_userSubjects),
        ),
      ),
      (route) => false,
    );
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Study Setup'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),

            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===========================================================
                  // HEADER
                  // ===========================================================

                  const Text(
                    'Tell NudgeMind about your exam',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'This information will be used to create your personalized study plan.',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),

                  const SizedBox(height: 30),

                  // ===========================================================
                  // EXAM NAME
                  // ===========================================================
                  const Text(
                    'Exam Name',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: _examInputController,
                    decoration: const InputDecoration(
                      labelText: 'Target Exam',
                      hintText: 'e.g. NEET 2027 / SSC CGL / Board Exam',
                      prefixIcon: Icon(Icons.school),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ===========================================================
                  // EXAM DATE
                  // ===========================================================
                  const Text(
                    'Exam Date',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  InkWell(
                    onTap: _selectExamDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_month,
                            color: Color(0xff00c853),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Text(
                              _examDate == null
                                  ? 'Select your exam date'
                                  : _formatDate(_examDate!),
                              style: TextStyle(
                                color: _examDate == null
                                    ? Colors.white54
                                    : Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),

                          const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white54,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ===========================================================
                  // TARGET SCORE
                  // ===========================================================
                  const Text(
                    'Target Score / Percentage',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: _targetController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      labelText: 'Your Target',
                      hintText: 'e.g. 90% or 650/720',
                      prefixIcon: Icon(Icons.flag),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ===========================================================
                  // AVAILABLE HOURS
                  // ===========================================================
                  const Text(
                    'Available Study Time',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: _availableHoursController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Hours available per day',
                      hintText: 'e.g. 6',
                      prefixIcon: Icon(Icons.access_time),
                      suffixText: 'hours/day',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 35),

                  // ===========================================================
                  // SUBJECT HEADER
                  // ===========================================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Your Subjects',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff00c853),
                          foregroundColor: const Color(0xff121212),
                        ),
                        onPressed: () {
                          _showSubjectDialog();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Subject'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Tell NudgeMind how strong you currently are in each subject.',
                    style: TextStyle(color: Colors.white54),
                  ),

                  const SizedBox(height: 18),

                  // ===========================================================
                  // SUBJECT LIST
                  // ===========================================================
                  if (_userSubjects.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: const Color(0xff1e1e1e),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.menu_book_outlined,
                            size: 45,
                            color: Colors.white38,
                          ),

                          SizedBox(height: 12),

                          Text(
                            'No subjects added yet.',
                            style: TextStyle(color: Colors.white60),
                          ),

                          SizedBox(height: 5),

                          Text(
                            'Tap "Add Subject" to add one.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white38),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _userSubjects.length,
                      itemBuilder: (context, index) {
                        final subject = _userSubjects[index];

                        final String name = subject['name'] ?? '';

                        final String level = subject['status'] ?? 'Average';

                        final Color levelColor = _levelColor(level);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xff1e1e1e),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ),

                            leading: CircleAvatar(
                              backgroundColor: levelColor.withOpacity(0.15),
                              child: Icon(Icons.menu_book, color: levelColor),
                            ),

                            title: Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            subtitle: const Text(
                              'Knowledge Level',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),

                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: levelColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: levelColor.withOpacity(0.4),
                                    ),
                                  ),
                                  child: Text(
                                    level,
                                    style: TextStyle(
                                      color: levelColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _showSubjectDialog(editIndex: index);
                                    }

                                    if (value == 'delete') {
                                      _deleteSubject(index);
                                    }
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit),
                                          SizedBox(width: 10),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, color: Colors.red),
                                          SizedBox(width: 10),
                                          Text('Delete'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 35),

                  // ===========================================================
                  // LAUNCH
                  // ===========================================================
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff00c853),
                        foregroundColor: const Color(0xff121212),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _isSaving ? null : _saveAndLaunch,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Icon(Icons.auto_awesome),
                      label: Text(
                        _isSaving
                            ? 'Creating Study Plan...'
                            : 'Create My AI Study Plan',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Center(
                    child: Text(
                      'NudgeMind will use these details to personalize your study plan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white30, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// SCREEN 5: REAL-TIME TIMER DASHBOARD
// =============================================================================

// =============================================================================
// SCREEN 5: REAL-TIME TIMER DASHBOARD
// =============================================================================

class DashboardScreen extends StatefulWidget {
  final int allocatedHours;
  final String examName;
  final List<Map<String, String>> subjects;

  const DashboardScreen({
    super.key,
    required this.allocatedHours,
    required this.examName,
    required this.subjects,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late int _remainingSeconds;

  Timer? _countdownTimer;

  bool _isRunning = true;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadSavedTimer();
  }

  // ---------------------------------------------------------------------------
  // LOAD SAVED TIMER
  // ---------------------------------------------------------------------------

  Future<void> _loadSavedTimer() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('user_sessions')
          .doc('live_runtime')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;

        final savedExamName = data['examName'];

        final savedSeconds = data['remainingSeconds'];

        if (savedExamName == widget.examName && savedSeconds is int) {
          _remainingSeconds = savedSeconds;
        } else {
          _remainingSeconds = widget.allocatedHours * 3600;
        }
      } else {
        _remainingSeconds = widget.allocatedHours * 3600;
      }
    } catch (e) {
      debugPrint('Could not load saved timer: $e');

      _remainingSeconds = widget.allocatedHours * 3600;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    _startTimer();
  }

  // ---------------------------------------------------------------------------
  // START TIMER
  // ---------------------------------------------------------------------------

  void _startTimer() {
    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });

        // Save every 10 seconds.
        if (_remainingSeconds % 10 == 0) {
          _syncRemainingTimeToCloud();
        }
      } else {
        timer.cancel();

        setState(() {
          _isRunning = false;
        });

        _syncRemainingTimeToCloud();
      }
    });
  }

  // ---------------------------------------------------------------------------
  // PAUSE / RESUME
  // ---------------------------------------------------------------------------

  void _toggleTimer() {
    if (_remainingSeconds <= 0) {
      return;
    }

    if (_isRunning) {
      _countdownTimer?.cancel();

      setState(() {
        _isRunning = false;
      });

      _syncRemainingTimeToCloud();
    } else {
      setState(() {
        _isRunning = true;
      });

      _startTimer();
    }
  }

  // ---------------------------------------------------------------------------
  // FIREBASE SYNC
  // ---------------------------------------------------------------------------

  Future<void> _syncRemainingTimeToCloud() async {
    try {
      await FirebaseFirestore.instance
          .collection('user_sessions')
          .doc('live_runtime')
          .set({
            'examName': widget.examName,
            'remainingSeconds': _remainingSeconds,
            'timestamp': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firebase timer sync skipped: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // FORMAT TIMER
  // ---------------------------------------------------------------------------

  String _formatDuration(int totalSeconds) {
    final int hours = totalSeconds ~/ 3600;

    final int minutes = (totalSeconds % 3600) ~/ 60;

    final int seconds = totalSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xff00c853)),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // -----------------------------------------------------------
                  // EXAM
                  // -----------------------------------------------------------

                  Text(
                    widget.examName.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff00c853),
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Remaining Focus Time',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // -----------------------------------------------------------
                  // TIMER CARD
                  // -----------------------------------------------------------
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 45,
                      horizontal: 25,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xff1d1d1d), Color(0xff242424)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xff00c853).withOpacity(0.25),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff00c853).withOpacity(0.08),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          color: Color(0xff00c853),
                          size: 36,
                        ),

                        const SizedBox(height: 18),

                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _formatDuration(_remainingSeconds),
                            style: const TextStyle(
                              fontSize: 82,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 3,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          _isRunning
                              ? 'FOCUS SESSION ACTIVE'
                              : 'FOCUS SESSION PAUSED',
                          style: TextStyle(
                            color: _isRunning
                                ? const Color(0xff00c853)
                                : Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  // -----------------------------------------------------------
                  // BUTTONS
                  // -----------------------------------------------------------
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isRunning
                                ? Colors.amber
                                : const Color(0xff00c853),
                            foregroundColor: const Color(0xff121212),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _remainingSeconds > 0
                              ? _toggleTimer
                              : null,
                          icon: Icon(
                            _isRunning ? Icons.pause : Icons.play_arrow,
                          ),
                          label: Text(
                            _isRunning ? 'Pause Focus' : 'Resume Focus',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white12,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProgressScreen(
                                  allocatedHours: widget.allocatedHours,
                                  examName: widget.examName,
                                  subjects: widget.subjects,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.analytics_outlined),
                          label: const Text(
                            'View Progress',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      // -------------------------------------------------------
                      // NEW EXAM
                      // -------------------------------------------------------

                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white12,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () async {
                            final bool? confirm = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) {
                                return AlertDialog(
                                  backgroundColor: const Color(0xff1e1e1e),
                                  title: const Text('Start a New Exam?'),
                                  content: const Text(
                                    'Your current study session will be replaced by the new study plan.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(dialogContext, false);
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(dialogContext, true);
                                      },
                                      child: const Text('New Exam'),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirm != true || !mounted) {
                              return;
                            }

                            _countdownTimer?.cancel();

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CustomizerScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text(
                            'New Exam',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      // -------------------------------------------------------
                      // EXIT
                      // -------------------------------------------------------

                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent.withOpacity(0.15),
                            foregroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () async {
                            final bool? confirm = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) {
                                return AlertDialog(
                                  backgroundColor: const Color(0xff1e1e1e),
                                  title: const Text('Exit Study Session?'),
                                  content: const Text(
                                    'Are you sure you want to leave this study session?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(dialogContext, false);
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(dialogContext, true);
                                      },
                                      child: const Text('Exit'),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirm != true || !mounted) {
                              return;
                            }

                            _countdownTimer?.cancel();

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const WelcomeScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          icon: const Icon(Icons.exit_to_app),
                          label: const Text(
                            'Exit',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // -----------------------------------------------------------
                  // SUBJECT SUMMARY
                  // -----------------------------------------------------------
                  Text(
                    '${widget.subjects.length} subjects in your study plan',
                    style: const TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DISPOSE
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
// =============================================================================
// SCREEN 6: PROGRESS ANALYTICS
// =============================================================================

class ProgressScreen extends StatefulWidget {
  final int allocatedHours;
  final String examName;
  final List<Map<String, String>> subjects;

  const ProgressScreen({
    super.key,
    required this.allocatedHours,
    required this.examName,
    required this.subjects,
  });

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  Widget build(BuildContext context) {
    final double totalWeight = widget.subjects.isEmpty
        ? 1.0
        : widget.subjects.length.toDouble();

    final double hourPerSubject = widget.allocatedHours / totalWeight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Analytics'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Target: ${widget.examName}',
                style: const TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                'Total Budget Time: ${widget.allocatedHours} hrs',
                style: const TextStyle(fontSize: 14, color: Colors.white38),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: widget.subjects.isEmpty
                    ? const Center(child: Text('No items available'))
                    : ListView.builder(
                        itemCount: widget.subjects.length,
                        itemBuilder: (context, index) {
                          final currentSubject = widget.subjects[index];

                          return Card(
                            color: const Color(0xff1e1e1e),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(
                                currentSubject['name'] ?? 'Unknown Subject',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Allocated Time: '
                                '${hourPerSubject.toStringAsFixed(1)} Hours',
                                style: const TextStyle(color: Colors.white30),
                              ),
                              trailing: Chip(
                                label: Text(
                                  currentSubject['status'] ?? 'Average',
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
