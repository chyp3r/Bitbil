import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../constants/files.dart';
import '../constants/roots.dart';
import '../utils/context.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraScreen({super.key, required this.cameras});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  bool isCameraReady = false;
  bool isLoading = false;
  final apiKey = dotenv.env['API_KEY'] ?? "";

  @override
  void initState() {
    super.initState();
    initCamera();
    _requestStoragePermissionOnLoad();
  }

  Future<void> _requestStoragePermissionOnLoad() async {
    var status = await Permission.storage.status;
    if (status.isDenied) {
      await _showPermissionDialog();
    }
  }

  Future<void> initCamera() async {
    controller = CameraController(widget.cameras[0], ResolutionPreset.high);
    try {
      await controller.initialize();
      setState(() {
        isCameraReady = true;
      });
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _handleTakePicture() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await _showPermissionDialog();
      return;
    }
    await _takeAndAnalyzePicture();
  }

  Future<void> _showPermissionDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('İzin Ver'),
          content: const Text(
              'Uygulamanın fotoğrafı işleyebilmesi için izninlere ihtiyacı var. İzin vermek ister misiniz?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hayır'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _requestPermission();
              },
              child: const Text('İzin'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _requestPermission() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      await _takeAndAnalyzePicture();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    } else {
      await Permission.storage.request();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Depolama izni verilmedi.')),
      );
    }
  }

  Future<void> _takeAndAnalyzePicture() async {
    if (!controller.value.isInitialized || isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final XFile picture = await controller.takePicture();
      print('Picture taken at: ${picture.path}');

      final bytes = await picture.readAsBytes();
      final base64Image = base64Encode(bytes);

      String result = await analyzePlantHealth(base64Image);
      print('Analysis Result: $result');

      if (result.trim() == 'Bitki tespit edilememiştir.') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bitki tespit edilemedi.')),
        );
      } else {
        final AssetEntity? savedAsset = await _savePictureToGallery(picture);
        if (savedAsset != null) {
          final plantInfo = trimPlantInfo(result);
          await savePlantInfoToJson(savedAsset.title!, plantInfo);

          _showAnalysisDialog(result);
        }
      }
    } catch (e) {
      print('Error taking or analyzing picture: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Bir hata oluştu lütfen daha sonra tekrar deneyiniz')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _showAnalysisDialog(String result) async {
    context.navigate(Roots.home);
  }

  Future<AssetEntity?> _savePictureToGallery(XFile picture) async {
    try {
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = 'Bitbil_IMG_$timestamp.jpg';

      final AssetEntity? result = await PhotoManager.editor.saveImage(
        await picture.readAsBytes(),
        title: fileName,
        filename: fileName,
      );

      if (result != null) {
        print('Photo saved to gallery: $fileName');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fotoğraf alındı.')),
        );
        return result;
      } else {
        print('Failed to save photo to gallery.');
        return null;
      }
    } catch (e) {
      print('Error saving picture to gallery: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fotoğraf alınırken hata oluştu.')),
      );
      return null;
    }
  }

  Future<String> analyzePlantHealth(String base64Image) async {
    final model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
    );

    final prompt = ''' 
    Bu fotoğrafta bitki ara. Eğer bitki bulamazsan, sadece "Bitki tespit edilememiştir." mesajı ile yanıt ver. Bitki bulursan ise bu fotoğraftaki bitki hakkında bilgi ver. Türkçe ismini söyle. Bitki sağlıklı mı hasta mı yoksa hastalık potansiyeli var mı? Eğer bitki hasta ise olası nedenlerini ve ne yapmam gerektiğini detaylı olarak belirt. Eğer bitki sağlıklı ise sadece 'sağlıklı' de. Eğer bitkide hastalık potansiyeli varsa sebepleri ve erken aşamada bu durumun önüne geçmek için ne yapılcağını belirt.
format: eğer bitki varsa şunu yaz: Fotoğrafta görünen bitki {bitkinin türkçe ismi (bitkinin latince ismi)} bitkisidir.
eğer yaprak veya çiçek veya meyve veya sebze var ise şunu yaz: gördüğün meyve, sebze yaprak ve çiçeklerin sağlık, renk, olgunlaşma durumu.
bitkiye yönelik sağlık analizin
eğer hasta ya da hastalık potansiyeli tespit edersen şunu yaz: hastalık sebepleri ve çözüm yolları, gerekli olabilecek ek analiz ve türkiyede olan kurum başvuruları.
Unutma bitki yoksa sadece "Bitki tespit edilememiştir." mesajı yeterli. Başlık gibi yazı formatları kullanma, sanki txt dosyasına her kelimesi aynı formatta yazı yazıyormuşsun gibi yaz. İmla kurallarına dikkat et, geniş zaman kullan, edilgen yapıda fiiller kullan ve konu konu yeni satırlara böl. Önemli bir detay! İlk satır tam olarak şöyle olmalı."Bitki puanı:{100 üzerinden puan} Sağlık_Derecesi:{iyi/orta/kötü} Verim_Puanı{1/5 or 2/5 or 3/5 or 4/5 or 5/5} Bitki_İsmi{Türkçe isim(latince isim)}. Gereksiz açıklama ve uzatmaları kesinlikle yapma!
    ''';

    final content = [
      Content.multi([
        TextPart(prompt),
        DataPart('image/jpeg', base64Decode(base64Image)),
      ])
    ];

    final response = await model.generateContent(content);
    return response.text ?? 'Yanıtsız döndü';
  }

  Future<void> savePlantInfoToJson(
      String imagePath, Map<String, String> plantInfo) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(path.join(directory.path, Files.jsonDB));
      print(imagePath);
      String contents = await file.exists() ? await file.readAsString() : '{}';
      Map<String, dynamic> data = jsonDecode(contents);

      data[imagePath] = plantInfo;

      String jsonData = jsonEncode(data);
      await file.writeAsString(jsonData);

      print('Bitki bilgileri JSON dosyasına kaydedildi: ${file.path}');
    } catch (e) {
      print('JSON dosyasına yazma hatası: $e');
    }
  }

  Map<String, String> trimPlantInfo(String metin) {
    Map<String, String> bitkiBilgisi = {};
    String kalanMetin = metin.trim();

    List<String> anahtarlar = [
      "Bitki puanı:",
      "Sağlık_Derecesi:",
      "Verim_Puanı:",
      "Bitki_İsmi:"
    ];
    Map<String, String> degerler = {};
    int sonIslenenIndex = 0;

    for (String anahtar in anahtarlar) {
      int anahtarIndex = kalanMetin.indexOf(anahtar, sonIslenenIndex);
      if (anahtarIndex != -1 && anahtarIndex >= sonIslenenIndex) {
        int baslangicIndex = anahtarIndex + anahtar.length;
        int bitisIndex;

        if (anahtar == "Bitki_İsmi:") {
          int parantezBaslangic = kalanMetin.indexOf('(', baslangicIndex);
          int parantezBitis = kalanMetin.indexOf(')', parantezBaslangic + 1);
          if (parantezBaslangic != -1 && parantezBitis != -1) {
            degerler["Plant_Name_Turkish"] =
                kalanMetin.substring(baslangicIndex, parantezBaslangic).trim();
            degerler["Plant_Name_Latin"] = kalanMetin
                .substring(parantezBaslangic + 1, parantezBitis)
                .trim();
            bitisIndex = parantezBitis + 1;
          } else {
            int sonrakiAnahtarIndex = kalanMetin.length;
            for (int i = anahtarlar.indexOf(anahtar) + 1;
                i < anahtarlar.length;
                i++) {
              int index = kalanMetin.indexOf(anahtarlar[i], anahtarIndex);
              if (index != -1 && index < sonrakiAnahtarIndex) {
                sonrakiAnahtarIndex = index;
              }
            }
            degerler["Plant_Name_Turkish"] = kalanMetin
                .substring(baslangicIndex, sonrakiAnahtarIndex)
                .trim();
            bitisIndex = sonrakiAnahtarIndex;
          }
        } else {
          int sonrakiAnahtarIndex = kalanMetin.length;
          for (int i = anahtarlar.indexOf(anahtar) + 1;
              i < anahtarlar.length;
              i++) {
            int index = kalanMetin.indexOf(anahtarlar[i], anahtarIndex);
            if (index != -1 && index < sonrakiAnahtarIndex) {
              sonrakiAnahtarIndex = index;
            }
          }
          String deger =
              kalanMetin.substring(baslangicIndex, sonrakiAnahtarIndex).trim();
          if (anahtar == "Bitki puanı:") {
            degerler["Point"] = deger.replaceAll('Bitki puanı:', '').trim();
          } else if (anahtar == "Sağlık_Derecesi:") {
            degerler["Health"] =
                deger.replaceAll('Sağlık_Derecesi:', '').trim();
          } else if (anahtar == "Verim_Puanı:") {
            degerler["Yield"] = deger.replaceAll('Verim_Puanı:', '').trim();
          }
          bitisIndex = sonrakiAnahtarIndex;
        }
        sonIslenenIndex = bitisIndex;
      }
    }

    if (degerler.isNotEmpty) {
      int ilkAnahtarIndex = kalanMetin.indexOf(anahtarlar.first);
      if (ilkAnahtarIndex != -1) {
        int bitis = sonIslenenIndex;
        degerler.forEach((key, value) {
          int index = kalanMetin.indexOf(value);
          if (index != -1 && index + value.length > bitis) {
            bitis = index + value.length;
          }
        });
        if (bitis < kalanMetin.length) {
          bitkiBilgisi["Summary"] = kalanMetin.substring(bitis).trim();
        } else {
          bitkiBilgisi["Summary"] = "";
        }
      }

      DateTime now = DateTime.now();
      String formattedDate = DateFormat('dd.MM.yyyy').format(now);
      degerler["Date"] = formattedDate;

      bitkiBilgisi.addAll(degerler);
    }

    return bitkiBilgisi;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isCameraReady
          ? Stack(
              children: [
                Center(
                  child: SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: controller.value.previewSize!.height,
                        height: controller.value.previewSize!.width,
                        child: CameraPreview(controller),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: MediaQuery.of(context).size.width / 2 - 30,
                  child: FloatingActionButton(
                    onPressed: _handleTakePicture,
                    child: const Icon(Icons.camera_alt),
                  ),
                ),
                if (isLoading) const Center(child: CircularProgressIndicator()),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
