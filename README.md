# İngiliz - İngilizce Öğrenme Uygulaması

![Flutter Version](https://img.shields.io/badge/Flutter-3.10.7+-blue.svg)
![Dart Version](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## 📋 Amaç (Purpose)

**İngiliz**, kullanıcıların İngilizce kelime dağarcığını geliştirmelerine yardımcı olan kapsamlı bir mobil öğrenme uygulamasıdır. Uygulama; quizler, flashcard'lar, bulmacalar ve çok oyunculu modlar aracılığıyla interaktif ve eğlenceli bir öğrenme deneyimi sunar.

### Temel Hedefler
- 🎯 Kelime bilgisini pratik yöntemlerle pekiştirmek
- 📊 Öğrenme ilerlemesini takip etmek
- 🏆 Günlük görevler ve başarımlarla motivasyon sağlamak
- 👥 Sosyal öğrenme için çok oyunculu quiz modu
- 📱 Çevrimdışı (offline) çalışabilirlik

---

## 🚀 Özellikler (Features)

### 1. Quiz Sistemi
- Seviye bazlı sorular (Kolay, Orta, Zor, Uzman)
- Çoktan seçmeli sorular
- Anlık sonuç gösterimi
- İlerleme kaydetme

### 2. Kelime Kartları (Flashcards)
- İngilizce-Türkçe kelime çalışması
- Zorluk seviyesine göre filtreleme
- İleri/geri navigasyon
- Çeviri göster/gizle özelliği

### 3. Kelime Bulmacası (Word Puzzle)
- Harfleri sürükleyip kelime oluşturma
- İpucu sistemi
- Puanlama ve seviye atlama
- Eğlenceli oyun mekanikleri

### 4. Çok Oyunculu Mod (Multiplayer)
- Real-time quiz yarışması
- Oda oluşturma ve katılma
- Skor tablosu ve sıralama
- Anlık sonuç gösterimi

### 5. Günlük Görevler
- Günlük quiz hedefleri
- Oynama süresi takibi
- Görev tamamlama ödülleri

### 6. İstatistikler ve Profil
- Doğru/yanlış oranları
- Toplam oynama süresi
- Seviye ve puan takibi
- Günlük seri (streak) sayacı

---

## 🛠️ Teknoloji Stack (Technology Stack)

### Frontend
| Teknoloji | Açıklama |
|-----------|----------|
| **Flutter** | UI framework (Dart) |
| **Dart** | Programlama dili |
| **Material Design 3** | UI bileşenleri |

### Backend (Opsiyonel)
| Teknoloji | Açıklama |
|-----------|----------|
| **Laravel** | PHP API framework (opsiyonel API modu) |
| **REST API** | HTTP iletişimi |

### Yerel Depolama (Local Storage)
| Paket | Açıklama |
|-------|----------|
| **sqflite** | SQLite veritabanı (Android/iOS) |
| **shared_preferences** | Basit anahtar-değer depolama |
| **path_provider** | Dosya sistemi yolları |

### Ağ (Networking)
| Paket | Açıklama |
|-------|----------|
| **http** | HTTP istekleri |

### Geliştirme Araçları
| Paket | Açıklama |
|-------|----------|
| **flutter_lints** | Kod kalite kuralları |
| **flutter_launcher_icons** | Uygulama ikonu oluşturma |

---

## 📱 Ekranlar (Screens)

```
lib/
├── main.dart                 # Ana uygulama ve giriş
├── login_page.dart           # Giriş ekranı
├── register_page.dart        # Kayıt ekranı
├── quiz_page.dart            # Quiz oyun ekranı
├── study_page.dart           # Kelime çalışma ekranı
├── flashcard_page.dart       # Flashcard ekranı
├── flashcard_intro_page.dart # Flashcard intro
├── puzzle_page.dart          # Bulmaca ana ekran
├── word_puzzle_page.dart     # Kelime bulmacası
├── section_select_page.dart  # Bölüm seçimi
├── question_page.dart        # Soru ekranı
├── result_page.dart          # Sonuç ekranı
├── tasks_page.dart           # Günlük görevler
├── profile_page.dart         # Profil
├── multiplayer_page.dart     # Çok oyunculu ana ekran
├── host_game_page.dart       # Oyun oluşturma
├── join_game_page.dart       # Oyuna katılma
├── multiplayer_quiz_page.dart# Çok oyunculu quiz
├── multiplayer_result_page.dart # Çok oyunculu sonuç
├── api_service.dart          # API servisi
├── models/                   # Veri modelleri
├── services/                 # İş mantığı servisleri
├── data/                     # Statik veriler
└── widgets/                  # Yeniden kullanılabilir widget'lar
```

---

## ⚙️ Kurulum (Installation)

### Gereksinimler
- Flutter SDK 3.10.7 veya üzeri
- Dart SDK 3.0 veya üzeri
- Android Studio / VS Code
- Android SDK / Xcode (iOS için)

### Adımlar

1. **Projeyi klonlayın:**
```bash
git clone <repo-url>
cd ingiliz
```

2. **Bağımlılıkları yükleyin:**
```bash
flutter pub get
```

3. **Uygulamayı çalıştırın:**
```bash
# Android Emulator
flutter run

# iOS Simulator
flutter run -d ios

# Web
flutter run -d chrome

# Windows
flutter run -d windows
```

---

## 🏗️ Proje Yapısı (Project Structure)

```
ingiliz/
├── android/              # Android konfigürasyonu
├── ios/                  # iOS konfigürasyonu
├── lib/                  # Ana kaynak kod
│   ├── models/           # Veri modelleri
│   │   ├── question_model.dart
│   │   ├── word_model.dart
│   │   └── ...
│   ├── services/         # Servis katmanı
│   │   ├── database_service.dart
│   │   ├── level_service.dart
│   │   ├── quiz_service.dart
│   │   └── word_filter_service.dart
│   ├── data/             # Yerel veri
│   │   └── word_puzzle_data.dart
│   ├── widgets/          # UI bileşenleri
│   │   ├── app_surfaces.dart
│   │   └── word_card.dart
│   └── ...sayfalar
├── backend/              # Laravel API (opsiyonel)
├── test/                 # Test dosyaları
├── pubspec.yaml          # Bağımlılıklar
└── README.md             # Bu dosya
```

---

## 🔌 API Yapılandırması (API Configuration)

Uygulama hem çevrimdışı (SQLite) hem de çevrimiçi (Laravel API) modda çalışabilir.

### Laravel API Kullanımı
```dart
// api_service.dart
static String get baseUrl {
  if (kIsWeb) {
    return 'http://127.0.0.1:8000/api';  // Web
  } else {
    return 'http://10.0.2.2:8000/api';   // Android Emulator
  }
}
```

### Çevrimdışı Mod
```dart
// database_service.dart
// SQLite ile tam çevrimdışı çalışma desteği
// Web'de in-memory storage kullanılır
```

---

## 📦 Bağımlılıklar (Dependencies)

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  sqflite: ^2.4.2           # SQLite veritabanı
  path: ^1.9.1              # Dosya yolu işlemleri
  path_provider: ^2.1.5     # Sistem yolları
  shared_preferences: ^2.5.3 # Basit depolama
  http: ^1.2.2              # HTTP istekleri

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  flutter_launcher_icons: ^0.14.3
```

---

## 🎮 Kullanım (Usage)

### 1. Kayıt ve Giriş
- Uygulamayı açın
- E-posta ve şifre ile kaydolun
- Giriş yapın

### 2. Quiz Oynama
- Ana menüden "Quiz" seçeneğine tıklayın
- Seviye seçin (Kolay/Orta/Zor/Uzman)
- Soruları yanıtlayın
- Sonuçları görüntüleyin

### 3. Kelime Çalışma
- "Kelime Çalış" butonuna tıklayın
- Filtreleme için zorluk seviyesi seçin
- İngilizce kelimeleri görüntüleyin
- "Türkçeyi Göster" ile anlamları öğrenin

### 4. Çok Oyunculu
- "Çok Oyunculu" sekmesine gidin
- Oda oluşturun veya mevcut odaya katılın
- Arkadaşlarınızla yarışın

---

## 🔧 Geliştirme (Development)

### Kod Stili
- Dart formatlama kuralları
- Material Design 3 prensipleri
- Null safety kullanımı

### Test Etme
```bash
flutter test
```

### Build Alma
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle

# iOS
flutter build ios

# Web
flutter build web

# Windows
flutter build windows
```

---

## 🐛 Hata Ayıklama (Debugging)

### Loglama
```dart
// API isteklerini izleme
debugPrint('Login URL: $url');
debugPrint('Response: ${response.body}');
```

### Yaygın Sorunlar

| Sorun | Çözüm |
|-------|-------|
| `MissingPluginException` | `flutter clean` + `flutter pub get` |
| Web'de SQLite hatası | Web'de in-memory mod otomatik aktif |
| Derleme hatası | `flutter doctor` ile kontrol edin |

---

## 📝 Katkıda Bulunma (Contributing)

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişiklikleri commit edin (`git commit -m 'Add amazing feature'`)
4. Branch'e push yapın (`git push origin feature/amazing-feature`)
5. Pull Request açın

---

## 📄 Lisans (License)

Bu proje MIT Lisansı altında lisanslanmıştır.

---

## 👥 Yazarlar (Authors)

- **Emin** - *Proje Sahibi*

---

## 🙏 Teşekkürler (Acknowledgments)

- Flutter ekosistemi
- Material Design 3
- sqflite paketi
- Laravel framework

---

## 📞 İletişim (Contact)

Sorularınız veya önerileriniz için:
- GitHub Issues
- E-posta: [email@example.com]

---

**Made with ❤️ and Flutter**
