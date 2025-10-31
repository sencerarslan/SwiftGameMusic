# 🎶 SwiftGameMusic

**SwiftGameMusic**, SwiftUI ile geliştirilen etkileşimli bir mini müzik oyunudur.  
Kullanıcının etkileşimlerine tepki veren dinamik ses efektleri ve fizik tabanlı hareketlerle müzik üretir.  
SwiftUI, Combine ve AVFoundation kullanılarak sıfırdan oluşturulmuştur.

---

## 🕹️ Gameplay Preview

### 🎥 Video

🔗 [Game Play Video İzle](https://github.com/sencerarslan/SwiftGameMusic/blob/main/screenrecording.mp4)

### 🌀 GIF Önizleme

![SwiftGameMusic Gameplay](https://github.com/sencerarslan/SwiftGameMusic/blob/main/screenshot.gif)

---

## ✨ Özellikler

- 🎵 Gerçek zamanlı müzik & ses senkronizasyonu
- ⚙️ Basit ama genişletilebilir fizik motoru
- 🕹️ SwiftUI + Combine temelli oyun döngüsü
- 🔊 AVFoundation ile dinamik ses efektleri
- 🎨 Renk geçişleri, animasyonlu sahne
- 📱 iOS 16+ için optimize edilmiş Swift kod yapısı

---

## 🧱 Kullanılan Teknolojiler

| Teknoloji        | Açıklama                          |
| ---------------- | --------------------------------- |
| **SwiftUI**      | Arayüz ve oyun sahnesi oluşturma  |
| **Combine**      | Reaktif oyun döngüsü ve zamanlama |
| **AVFoundation** | Ses & müzik kontrolü              |
| **Xcode 16+**    | Geliştirme ortamı                 |
| **iOS 16+**      | Minimum desteklenen sürüm         |

---

## 🚀 Kurulum

1. Depoyu klonla:
   ```bash
   git clone https://github.com/sencerarslan/SwiftGameMusic.git
   cd SwiftGameMusic
   ```
2. Xcode 16 veya üzeri ile aç:
   ```bash
   open SwiftGameMusic.xcodeproj
   ```
3. Çalıştır (⌘ + R)  
   Simülatör veya gerçek cihazda oyunu başlat.

---

## 📁 Proje Yapısı

```
SwiftGameMusic/
 ├── GameView.swift
 ├── MusicManager.swift
 ├── GameLogic/
 │    ├── GamePhysicsManager.swift
 │    ├── PlayerPhysics.swift
 │    ├── BallPhysics.swift
 │    └── PhysicsUpdates.swift
 ├── Sounds/
 │    ├── background.mp3
 │    ├── goal.wav
 │    └── hit.wav
 ├── Assets.xcassets
 ├── Preview Content/
 ├── LICENSE
 └── README.md
```

---

## 📜 Lisans

Bu proje [MIT Lisansı](./LICENSE) altında yayınlanmıştır.  
Dilediğiniz gibi kullanabilir, geliştirebilir ve paylaşabilirsiniz.
