import 'package:flutter/material.dart';

import 'services/theme_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.totalCorrect,
    required this.totalWrong,
    required this.totalPlayTimeInSeconds,
    required this.currentStreak,
  });

  final int totalCorrect;
  final int totalWrong;
  final int totalPlayTimeInSeconds;
  final int currentStreak;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService.instance.isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        final backgroundColor = isDarkMode ? Colors.black : Colors.white;
        final textColor = isDarkMode ? Colors.white : Colors.black;
        final secondaryTextColor = isDarkMode
            ? const Color(0xFFD1D5DB)
            : const Color(0xFF4B5563);
        final cardColor = isDarkMode ? const Color(0xFF111827) : Colors.white;

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(title: const Text('Profil'), centerTitle: true),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: cardColor,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profil',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Toplam Doğru Sayısı: $totalCorrect',
                          style: TextStyle(fontSize: 18, color: textColor),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Toplam Yanlış Sayısı: $totalWrong',
                          style: TextStyle(fontSize: 18, color: textColor),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Toplam Oynama Süresi: $totalPlayTimeInSeconds saniye',
                          style: TextStyle(fontSize: 18, color: textColor),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Günlük Seri: $currentStreak gün',
                          style: TextStyle(fontSize: 18, color: textColor),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  color: cardColor,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tema Ayarı',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Arka plan rengini seç',
                          style: TextStyle(
                            fontSize: 14,
                            color: secondaryTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.light_mode_outlined),
                          title: Text(
                            'Açık Tema',
                            style: TextStyle(color: textColor),
                          ),
                          trailing: !isDarkMode
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF163B43),
                                )
                              : null,
                          onTap: () {
                            ThemeService.instance.setDarkMode(false);
                          },
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.dark_mode_outlined),
                          title: Text(
                            'Koyu Tema',
                            style: TextStyle(color: textColor),
                          ),
                          trailing: isDarkMode
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF60A5FA),
                                )
                              : null,
                          onTap: () {
                            ThemeService.instance.setDarkMode(true);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
