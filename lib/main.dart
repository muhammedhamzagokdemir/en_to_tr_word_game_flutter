import 'package:flutter/material.dart';

import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'services/theme_service.dart';
import 'multiplayer_page.dart';
import 'profile_page.dart';
import 'puzzle_page.dart';
import 'quiz_page.dart';
import 'register_page.dart';
import 'study_page.dart';
import 'tasks_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.instance.loadTheme();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService.instance.isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        final darkColorScheme = ColorScheme.fromSeed(
          seedColor: const Color(0xFF265D66),
          brightness: Brightness.dark,
        );
        final lightColorScheme = ColorScheme.fromSeed(
          seedColor: const Color(0xFF265D66),
          brightness: Brightness.light,
        );

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Kelime Öğren',
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            colorScheme: lightColorScheme,
            scaffoldBackgroundColor: Colors.white,
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF0F172A),
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            cardTheme: CardThemeData(
              color: const Color(0xF7FFFFFF),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: Color(0x1A0F172A)),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: const Color(0xFF163B43),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                foregroundColor: const Color(0xFF163B43),
                side: const BorderSide(color: Color(0x260F172A)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xF7FFFFFF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0x220F172A)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0x220F172A)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: lightColorScheme.primary,
                  width: 1.3,
                ),
              ),
            ),
            chipTheme: ChipThemeData(
              backgroundColor: const Color(0xF7FFFFFF),
              selectedColor: const Color(0xFFE0EEEB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
                side: const BorderSide(color: Color(0x160F172A)),
              ),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: darkColorScheme,
            scaffoldBackgroundColor: Colors.black,
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            cardTheme: CardThemeData(
              color: const Color(0xFF111827),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: Color(0xFF374151)),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: const Color(0xFF163B43),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFF4B5563)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF1F2937),
              labelStyle: const TextStyle(color: Color(0xFFD1D5DB)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFF374151)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFF374151)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: darkColorScheme.primary,
                  width: 1.3,
                ),
              ),
            ),
            chipTheme: ChipThemeData(
              backgroundColor: const Color(0xFF111827),
              selectedColor: const Color(0xFF1F2937),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
                side: const BorderSide(color: Color(0xFF374151)),
              ),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          ),
          home: const AppStartPage(),
        );
      },
    );
  }
}

class AppStartPage extends StatefulWidget {
  const AppStartPage({super.key});

  @override
  State<AppStartPage> createState() => _AppStartPageState();
}

class _AppStartPageState extends State<AppStartPage> {
  final AuthService _authService = AuthService();

  Future<String?> _loadToken() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (!isLoggedIn) {
      return null;
    }

    return await _authService.getToken();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _loadToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final token = snapshot.data;
        if (token != null && token.isNotEmpty) {
          return HomePage(token: token);
        }

        return const LoginPage();
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String _resultText = 'API yanıtı burada görünecek.';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: const Color(0xFFEAEAEA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF8B1E1E), width: 1.2),
      ),
    );
  }

  Widget _socialButton({required Widget child}) {
    return Container(
      width: 72,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _dbService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _resultText = result.toString();
      });

      final message =
          result['message']?.toString() ??
          (result['success'] == true ? 'Giriş başarılı' : 'Giriş başarısız');

      if (result['success'] != true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
        return;
      }

      final token =
          (result['data'] is Map<String, dynamic>
              ? (result['data'] as Map<String, dynamic>)['token']?.toString()
              : null) ??
          await _dbService.getSavedToken();
      if (!mounted || token == null || token.isEmpty) {
        return;
      }

      await _authService.saveSession(token);
      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(token: token)),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openRegisterPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final minHeight = constraints.maxHeight > screenHeight
                ? constraints.maxHeight
                : screenHeight;

            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                24 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.lock,
                                size: 84,
                                color: Colors.black87,
                              ),
                              const SizedBox(height: 28),
                              const Text(
                                'Tekrar hoş geldin, seni özledik!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 36),
                              TextFormField(
                                controller: _emailController,
                                decoration: _inputDecoration('E-posta'),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: _inputDecoration('Şifre'),
                              ),
                              const SizedBox(height: 10),
                              const Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'Şifremi Unuttum',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF7A1C1C),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Giriş Yap',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              Row(
                                children: const [
                                  Expanded(
                                    child: Divider(color: Color(0xFFD0D0D0)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      'Veya şununla devam et',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(color: Color(0xFFD0D0D0)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _socialButton(
                                    child: const Icon(
                                      Icons.g_mobiledata_rounded,
                                      size: 40,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  _socialButton(
                                    child: const Icon(
                                      Icons.apple,
                                      size: 28,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text(
                                    'Üye değil misin? ',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _isLoading
                                        ? null
                                        : _openRegisterPage,
                                    child: const Text(
                                      'Şimdi kayıt ol',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x12000000),
                                      blurRadius: 8,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  _resultText,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.token});

  final String token;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseService _dbService = DatabaseService();
  bool _isLoading = true;
  int _totalCorrect = 0;
  int _totalWrong = 0;
  int _totalPlayTime = 0;
  int _streak = 0;
  int _dailyQuestionCount = 0;
  int _dailyPlayTime = 0;
  bool _tasksCompleted = false;
  String _infoText = 'Yükleniyor...';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final statisticsResult = await _dbService.getStatistics(widget.token);
    final tasksResult = await _dbService.getTasks(widget.token);

    if (!mounted) {
      return;
    }

    if (statisticsResult['success'] == true) {
      final statistics = _extractFirstMap(statisticsResult);
      setState(() {
        _totalCorrect = _readInt(statistics, 'total_correct');
        _totalWrong = _readInt(statistics, 'total_wrong');
        _totalPlayTime = _readInt(statistics, 'total_play_time');
        _streak = _readInt(statistics, 'streak');
      });
    }

    if (tasksResult['success'] == true) {
      final tasks = _extractFirstMap(tasksResult);
      setState(() {
        _dailyQuestionCount = _readInt(tasks, 'daily_question_count');
        _dailyPlayTime = _readInt(tasks, 'daily_play_time');
        _tasksCompleted = _readBool(tasks, 'completed');
      });
    }

    setState(() {
      _isLoading = false;
      _infoText =
          statisticsResult['success'] == true || tasksResult['success'] == true
          ? 'Veriler başarıyla yüklendi.'
          : (statisticsResult['message']?.toString() ??
                tasksResult['message']?.toString() ??
                'İstek başarısız');
    });
  }

  Map<String, dynamic> _extractFirstMap(Map<String, dynamic> source) {
    if (source['data'] is Map<String, dynamic>) {
      return source['data'] as Map<String, dynamic>;
    }

    if (source['statistics'] is Map<String, dynamic>) {
      return source['statistics'] as Map<String, dynamic>;
    }

    if (source['task'] is Map<String, dynamic>) {
      return source['task'] as Map<String, dynamic>;
    }

    if (source['tasks'] is List && (source['tasks'] as List).isNotEmpty) {
      final item = (source['tasks'] as List).first;
      if (item is Map<String, dynamic>) {
        return item;
      }
    }

    return source;
  }

  int _readInt(Map<String, dynamic> source, String key) {
    final value = source[key];
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  bool _readBool(Map<String, dynamic> source, String key) {
    final value = source[key];
    if (value is bool) {
      return value;
    }
    if (value is int) {
      return value == 1;
    }
    if (value is String) {
      return value == '1' || value.toLowerCase() == 'true';
    }
    return false;
  }

  Future<void> _openProfilePage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(
          totalCorrect: _totalCorrect,
          totalWrong: _totalWrong,
          totalPlayTimeInSeconds: _totalPlayTime,
          currentStreak: _streak,
        ),
      ),
    );
  }

  Future<void> _openTasksPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TasksPage(
          todaySolvedQuestions: _dailyQuestionCount,
          todayPlayTimeInSeconds: _dailyPlayTime,
        ),
      ),
    );
  }

  void _handleQuizCorrect() {
    setState(() {
      _totalCorrect++;
      _dailyQuestionCount++;
      _refreshTaskStatus();
    });
  }

  void _handleQuizWrong() {
    setState(() {
      _totalWrong++;
      _dailyQuestionCount++;
      _refreshTaskStatus();
    });
  }

  void _handleQuizPlayTime(int seconds) {
    setState(() {
      _totalPlayTime += seconds;
      _dailyPlayTime += seconds;
      _refreshTaskStatus();
    });
  }

  void _refreshTaskStatus() {
    _tasksCompleted = _dailyQuestionCount >= 10 && _dailyPlayTime >= 300;
  }

  Future<void> _openQuizPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizPage(
          onCorrect: _handleQuizCorrect,
          onWrong: _handleQuizWrong,
          onPlayTimeUpdate: _handleQuizPlayTime,
        ),
      ),
    );
  }

  Future<void> _openPuzzlePage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PuzzlePage()),
    );
  }

  Future<void> _openStudyPage() async {
    try {
      debugPrint('Opening StudyPage');
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const StudyPage()),
      );
    } catch (error, stackTrace) {
      debugPrint('StudyPage navigation error: $error');
      debugPrint('$stackTrace');

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Çalışma sayfası açılırken hata oluştu: $error'),
        ),
      );
    }
  }

  Future<void> _openMultiplayerPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MultiplayerPage()),
    );
  }

  Future<void> _updateTaskProgress() async {
    final result = await _dbService.updateTasks(
      widget.token,
      _dailyQuestionCount,
      _dailyPlayTime,
      _tasksCompleted,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['message']?.toString() ??
              (result['success'] == true
                  ? 'Görevler güncellendi'
                  : 'Güncelleme başarısız'),
        ),
      ),
    );
  }

  Future<void> _updateStatistics() async {
    final result = await _dbService.updateStatistics(
      widget.token,
      _totalCorrect,
      _totalWrong,
      _totalPlayTime,
      _streak,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['message']?.toString() ??
              (result['success'] == true
                  ? 'İstatistikler güncellendi'
                  : 'Güncelleme başarısız'),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await _dbService.clearToken();
    await AuthService().clearSession();

    if (!mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelime Öğren'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadData,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ana İstatistikler',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Toplam Doğru: $_totalCorrect'),
                    const SizedBox(height: 6),
                    Text('Toplam Yanlış: $_totalWrong'),
                    const SizedBox(height: 6),
                    Text('Toplam Oynama Süresi: $_totalPlayTime'),
                    const SizedBox(height: 6),
                    Text('Seri: $_streak'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tasks',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Günlük Soru Sayısı: $_dailyQuestionCount'),
                    const SizedBox(height: 6),
                    Text('Günlük Oynama Süresi: $_dailyPlayTime'),
                    const SizedBox(height: 6),
                    Text(
                      _tasksCompleted
                          ? 'Durum: Tamamlandı'
                          : 'Durum: Devam Ediyor',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _openQuizPage,
                  child: const Text('Quiz Başlat'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _openMultiplayerPage,
                  child: const Text('Çok Oyunculu'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _openPuzzlePage,
                  child: const Text('Kelime Bulmacası'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _openStudyPage,
                  child: const Text('Kelime Çalış'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _openProfilePage,
                  child: const Text('Profili Aç'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _openTasksPage,
                  child: const Text('Görevleri Aç'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _updateStatistics,
                  child: const Text('İstatistikleri Güncelle'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _updateTaskProgress,
                  child: const Text('Görevleri Güncelle'),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  _isLoading ? 'Yükleniyor...' : _infoText,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
