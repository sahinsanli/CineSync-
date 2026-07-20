# 🎬 CineSync

CineSync, modern tasarımı ve **Temiz Mimari (Clean Architecture)** prensipleriyle geliştirilmiş, TMDB (The Movie Database) API ve Firebase entegrasyonuna sahip gelişmiş bir Flutter film keşif ve takip uygulamasıdır. 

Kullanıcılar popüler ve güncel filmleri keşfedebilir, arama yapabilir, filmleri izleme listelerine (Watchlist) veya favorilerine ekleyebilir, ayrıca filmlere puan verip yorum yapabilirler.

---

## 🚀 Özellikler

*   **🔒 Kimlik Doğrulama (Authentication):**
    *   E-posta ve Şifre ile güvenli kayıt ve giriş.
    *   **Google Sign-In** entegrasyonu ile tek tıkla hızlı giriş yapabilme.
    *   Güvenli oturum kontrolü (`AuthGate`) ile otomatik yönlendirme.
*   **🔍 Keşfet & Arama:**
    *   TMDB API üzerinden canlı çekilen popüler ve güncel filmler.
    *   **Sonsuz Kaydırma (Infinite Scroll / Lazy Loading)** desteği ile kesintisiz gezinme.
    *   Gerçek zamanlı film arama fonksiyonu.
*   **📑 Detay Sayfası:**
    *   Görsel film posteri, başlık, açıklama ve IMDb/TMDB puanı.
    *   Favorilere ekleme (Kalp ikonu) ve İzleme Listesine ekleme (Bookmark ikonu).
*   **💬 Puanlama ve Yorumlar (Reviews & Ratings):**
    *   Kullanıcıların filmlere yıldız puanı verip kendi yorumlarını yazabilmesi.
    *   Cloud Firestore entegrasyonu ile gerçek zamanlı yorum listeleme.
*   **👤 Profil & Canlı İstatistikler:**
    *   Kullanıcı profil resmi, adı ve e-posta bilgisi.
    *   Kullanıcının **İzlediği (Favori)**, **Listelediği** ve **Yorum Yaptığı** film sayılarını canlı gösteren istatistik paneli.
    *   Güvenli çıkış yapma (Sign Out) seçeneği.

---

## 🛠️ Kullanılan Teknolojiler & Kütüphaneler

*   **Framework:** [Flutter](https://flutter.dev) (Dart)
*   **Mimari Yapı:** Clean Architecture (Temiz Mimari) + MVVM (Model-View-ViewModel)
*   **Durum Yönetimi (State Management):** [Provider](https://pub.dev/packages/provider)
*   **Bağımlılık Enjeksiyonu (Dependency Injection):** [Get_it](https://pub.dev/packages/get_it) (Service Locator)
*   **Veri Tabanı ve Servisler:**
    *   [Firebase Core](https://pub.dev/packages/firebase_core) & [Firebase Auth](https://pub.dev/packages/firebase_auth) (Giriş/Kayıt işlemleri)
    *   [Cloud Firestore](https://pub.dev/packages/cloud_firestore) (Watchlist, Favoriler ve Yorum verilerinin gerçek zamanlı takibi)
    *   [Google Sign-In](https://pub.dev/packages/google_sign_in) (Google ile oturum açma)
*   **Ağ İletişimi (Network):** [Dio](https://pub.dev/packages/dio) (TMDB API istekleri için gelişmiş HTTP istemcisi)
*   **Çevre Değişkenleri:** [Flutter Dotenv](https://pub.dev/packages/flutter_dotenv) (.env dosyası üzerinden API key güvenliği)

---

## 📂 Klasör Yapısı (Architecture)

Proje, kodun test edilebilirliğini ve sürdürülebilirliğini maksimuma çıkarmak için **Temiz Mimari** standartlarına uygun şekilde katmanlara ayrılmıştır:

```text
lib/
├── main.dart                       # Uygulama başlangıç noktası ve Auth yönetimi
├── firebase_options.dart           # Firebase otomatik yapılandırma dosyası
│
├── auth/                           # Kimlik doğrulama modülü
│   └── screens/                    # Login ve Register ekranları
│
├── core/                           # Uygulama genelinde paylaşılan çekirdek yapı
│   ├── di/                         # Bağımlılıkların enjekte edildiği Service Locator (get_it)
│   ├── error/                      # Hata yakalama sınıfları
│   ├── network/                    # Dio Client ve API yapılandırmaları
│   └── services/                   # Firebase/Firestore servis entegrasyonları
│
└── features/
    └── movies/                     # Filmler özelliği (Clean Architecture katmanları)
        ├── data/                   # Veri Katmanı
        │   ├── models/             # API'den gelen JSON verilerini nesneleştiren modeller
        │   └── repositories/       # Domain arayüzlerini uygulayan veri sınıfları (Firestore & TMDB)
        │
        ├── domain/                 # İş Mantığı (Business Logic) Katmanı
        │   ├── entities/           # Saf Dart nesneleri (Movie, Review)
        │   └── repositories/       # Veri erişim kurallarını tanımlayan soyut sınıflar (Interface)
        │
        └── presentation/           # Sunum Katmanı
            ├── screens/            # UI Sayfaları (Keşfet, Detay, İzleme Listesi, Profil)
            └── viewmodels/         # UI durumunu yöneten ve iş mantığına bağlayan ViewModels
```

---

## ⚙️ Kurulum ve Çalıştırma

### 1. Gereksinimler
*   Flutter SDK (v3.10.8 veya üzeri tavsiye edilir)
*   Dart SDK
*   Bir TMDB Geliştirici Hesabı (API Key almak için)
*   Bir Firebase Projesi

### 2. Projeyi Klonlayın
```bash
git clone https://github.com/kullanici_adi/cinesync.git
cd cinesync
```

### 3. Paketleri Yükleyin
```bash
flutter pub get
```

### 4. Çevre Değişkenlerini Tanımlayın (.env)
Proje kök dizininde `.env` adında bir dosya oluşturun ve `.env.example` içeriğine göre TMDB API anahtarlarınızı girin:

```env
TMDB_API_KEY=your_api_key_here
TMDB_BEARER_TOKEN=your_bearer_token_here
```

### 5. Firebase Yapılandırması
1.  [Firebase Console](https://console.firebase.google.com/) üzerinden yeni bir proje oluşturun.
2.  Android ve iOS uygulamalarını ekleyin.
3.  `google-services.json` (Android için) ve `GoogleService-Info.plist` (iOS için) dosyalarını ilgili platform klasörlerine yerleştirin veya FlutterFire CLI kullanarak yapılandırın:
    ```bash
    flutterfire configure
    ```
4.  Firebase Authentication'da **E-posta/Şifre** ve **Google** yöntemlerini etkinleştirin.
5.  **Cloud Firestore** veritabanını oluşturun.

### 6. Uygulamayı Başlatın
```bash
flutter run
```

---

## 🤝 Katkıda Bulunma

1.  Bu depoyu forklayın (`fork`).
2.  Yeni bir özellik dalı oluşturun (`git checkout -b yeni-ozellik`).
3.  Değişikliklerinizi commitleyin (`git commit -m 'Yeni özellik eklendi'`).
4.  Dalı pushlayın (`git push origin yeni-ozellik`).
5.  Bir **Pull Request** açın.

---

## 📄 Lisans
Bu proje [MIT Lisansı](LICENSE) altında lisanslanmıştır. Daha fazla bilgi için lisans dosyasına göz atabilirsiniz.
