# 🌾 Bitbili - Akıllı Tarım Asistanı

Bitbili, sürdürülebilir tarımı destekleyen ve çiftçilerin tarımsal karar süreçlerini kolaylaştırmak için geliştirilen mobil bir tarım asistanıdır. Yapay zeka destekli öneriler sunarak hastalık belirtilerinin analizini yapar ve çiftçilere zamanında bilgi sağlar. Uygulama, Google Gemini modeliyle doğal dil işleme kabiliyetine sahiptir, bu sayede çiftçiler doğru kararlar alarak daha verimli ve çevre dostu tarım uygulamaları gerçekleştirebilir.

## 🎯 Amaç

Bitbili, özellikle küçük ve orta ölçekli çiftçilere:

- Bitki sağlığı hakkında bilgi sunmayı,
- Tarımsal farkındalık oluşturmayı,
- Üretimde verimliliği ve bilinçli müdahaleyi artırmayı,
- Sürdürülebilir tarım uygulamaları ile çevresel etkileri azaltmayı amaçlar.


## 🚀 Özellikler

- 📱 Flutter tabanlı kullanıcı dostu mobil uygulama
- 📸 Kamera ile bitki fotoğrafı çekme
- 🧠 Gemini AI ile görsel analiz ve doğal dilde açıklama
- 🔔 Firebase üzerinden bildirim ve kullanıcı verisi yönetimi
- 🌿 Bitki hastalıkları hakkında öneriler ve açıklayıcı içerikler

## 🛠️ Kullanılan Teknolojiler

- **Flutter**: Uygulamanın mobil arayüzü
- **Firebase**: Kimlik doğrulama, veri tabanı ve bildirim yönetimi
- **Google Gemini**: Görsel girdiye dayalı doğal dilde açıklama ve analiz (LLM entegrasyonu)

> Not: Görsel analiz modeli, Gemini Vision tarafından sağlanmaktadır. Model tarafında özel bir eğitim süreci tarafımızca gerçekleştirilmemiştir.

## 🔧 Kurulum

```bash
# Flutter ortamını kurduktan sonra:
git clone https://github.com/chyp3r/Bitbil.git
cd Bitbil
flutter pub get
flutter run
 ```
 
## ⚙️ API Anahtarı Ayarı

Uygulamayı çalıştırabilmek için, `.env` dosyasına `API_KEY` değişkenini eklemeniz gerekmektedir. Aşağıdaki adımları izleyin:

1. Ana dizine bir `.env` dosyası oluşturun.
2. `.env` dosyasına şu satırı ekleyin:

   ```bash
   API_KEY=your_gemini_api_key
   ```

## 🔥 Firebase Yapılandırması

Uygulama Firebase hizmetlerini kullandığı için `firebase_options.dart` dosyasının oluşturulmuş olması gerekmektedir.

1. Firebase CLI ve FlutterFire CLI araçlarının kurulu olduğundan emin olun.
2. Aşağıdaki komutu çalıştırarak kendi `firebase_options.dart` dosyanızı oluşturun:

   ```bash
   flutterfire configure
   ```

## 👨‍🌾 Hedef Kitle

- Tarım ile uğraşan bireysel çiftçiler  
- Tarım danışmanları ve kooperatifler  
- Gençler ve öğrenciler (tarıma teşvik amaçlı)  

## 📌 Yol Haritası

- [x] Flutter mobil arayüzü  
- [x] Gemini API entegrasyonu  
- [x] Fotoğraf ile hastalık tespiti  
- [ ] Offline kullanım desteği  
- [ ] Bölgesel öneriler (hava durumu, iklim verisi)  

## 📄 Lisans

Bu proje MIT Lisansı ile lisanslanmıştır.
