import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../constants/files.dart';
import 'plant_info.dart';

class PlantHomePage extends StatefulWidget {
  @override
  _PlantHomePageState createState() => _PlantHomePageState();
}

class _PlantHomePageState extends State<PlantHomePage> {
  List<AssetEntity> bitbilImages = [];
  bool isLoadingImages = true;

  @override
  void initState() {
    super.initState();
    _loadBitbilImages();
  }

  Future<void> _loadBitbilImages() async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth) {
      setState(() => isLoadingImages = false);
      return;
    }

    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
    );

    final List<AssetEntity> allImages = [];

    for (final album in albums) {
      final count = await album.assetCountAsync;
      final images = await album.getAssetListPaged(page: 0, size: count);
      allImages.addAll(images);
    }

    final uniqueImages = {
      for (var img in allImages) img.id: img,
    }.values.toList();

    bitbilImages = uniqueImages
        .where((img) => img.title?.startsWith('Bitbil_IMG') ?? false)
        .toList();

    setState(() {
      isLoadingImages = false;
    });
  }

  Future<Map<String, String>?> readPlantInfoFromJson(String imagePath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(path.join(directory.path, Files.jsonDB));

      if (await file.exists()) {
        String contents = await file.readAsString();
        Map<String, dynamic> data = jsonDecode(contents);
        print(imagePath);
        print(data);
        if (data.containsKey(imagePath)) {
          return (data[imagePath] as Map).cast<String, String>();
        }
      }
      return null;
    } catch (e) {
      print('JSON dosyasından okuma hatası: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          'Raporlar',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        )),
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 59, 182, 110),
                Color.fromARGB(255, 89, 205, 137),
                Color.fromARGB(255, 135, 229, 174)
              ],
              begin: Alignment.center,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoadingImages
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: bitbilImages.length,
                    itemBuilder: (context, index) {
                      final img = bitbilImages[index];
                      return FutureBuilder<File?>(
                        future: img.file,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return SizedBox();
                          } else if (snapshot.hasData &&
                              snapshot.data != null) {
                            final imagePath = snapshot.data!.path;
                            return FutureBuilder<Map<String, String>?>(
                              future: readPlantInfoFromJson(img.title!),
                              builder: (context, infoSnapshot) {
                                if (infoSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return SizedBox();
                                } else if (infoSnapshot.hasData &&
                                    infoSnapshot.data != null) {
                                  final plantInfo = infoSnapshot.data!;
                                  return _buildPlantItem(
                                    name: plantInfo['Plant_Name_Turkish'] ??
                                        'Bilinmeyen Bitki',
                                    date: plantInfo['Date'] ?? "02.05.2025",
                                    summary: plantInfo['Summary'] ??
                                        'Özet bilgi yok.',
                                    rating: double.tryParse(
                                            plantInfo['Point'] ?? '0.0') ??
                                        0.0,
                                    yieldCondition:
                                        plantInfo['Yield'] ?? 'Bilinmiyor',
                                    isValid: double.tryParse(
                                            plantInfo['Point'] ?? '0.0')! >
                                        50.0,
                                    imagePath: imagePath,
                                    diseaseStatus:
                                        plantInfo['Health'] ?? 'Bilinmiyor',
                                  );
                                } else {
                                  return _buildPlantItem(
                                      name: 'Bilgi Yok',
                                      date: "Bilinmiyor",
                                      summary: 'Bitki bilgisi bulunamadı.',
                                      rating: 0.0,
                                      yieldCondition: 'Bilinmiyor',
                                      isValid: false,
                                      imagePath: imagePath,
                                      diseaseStatus: "Kötü");
                                }
                              },
                            );
                          } else {
                            return SizedBox();
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantItem({
    required String name,
    required double rating,
    required String yieldCondition,
    required bool isValid,
    required String imagePath,
    required String date,
    required String summary,
    required String diseaseStatus,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlantDetailPage(
            plantName: name,
            date: date,
            imageUrl: imagePath,
            summary: summary,
            yieldStatus: yieldCondition == "5/5" || yieldCondition == "5/5"
                ? "İyi"
                : yieldCondition == "3/5"
                    ? "Orta"
                    : "Kötü",
            diseaseScoreLabel: rating.toStringAsFixed(1),
            diseaseStatus: diseaseStatus,
          ),
        ),
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[200],
                  image: DecorationImage(
                    image: FileImage(File(imagePath)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Verim: $yieldCondition',
                      style: TextStyle(
                        color: _getConditionColor(yieldCondition),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isValid ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isValid ? Colors.green : Colors.red,
                    ),
                  ),
                  child: Text(
                    rating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isValid ? Colors.green[800] : Colors.red[800],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'iyi':
        return Colors.green;
      case 'orta':
        return Colors.orange;
      case 'kötü':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
