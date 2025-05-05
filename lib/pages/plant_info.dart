import 'package:flutter/material.dart';
import 'dart:io';

class PlantDetailPage extends StatelessWidget {
  final String plantName;
  final String date;
  final String imageUrl;
  final String summary;
  final String diseaseScoreLabel;
  final String diseaseStatus;
  final String yieldStatus;

  const PlantDetailPage({
    super.key,
    required this.plantName,
    required this.date,
    required this.imageUrl,
    required this.summary,
    required this.diseaseScoreLabel,
    required this.diseaseStatus,
    required this.yieldStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
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
          title: Stack(
            children: [
              // Sol taraftaki geri butonu
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              // Tam ortalanmış başlık
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Rapor Sonucu",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top image and back button
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: FileImage(File(imageUrl)), // Now dynamic
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Title and Date
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      plantName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              // Disease Score
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      diseaseScoreLabel,
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Disease Status
              _buildSectionTitle('Hastalık Durumu'),
              const SizedBox(height: 6),
              _buildButtonGroup(selectedStatus: diseaseStatus),
              const SizedBox(height: 24),
              // Yield Status
              _buildSectionTitle('Verim'),
              const SizedBox(height: 6),
              _buildButtonGroup(selectedStatus: yieldStatus),
              const SizedBox(height: 24),
              // Summary
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Özet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        summary,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static Widget _buildButtonGroup({required String selectedStatus}) {
    List<String> options = ['Kötü', 'Orta', 'İyi'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: options.map((status) {
          bool isSelected =
              status.toLowerCase() == selectedStatus.toLowerCase();
          return _buildSelectableButton(status, isSelected: isSelected);
        }).toList(),
      ),
    );
  }

  static Widget _buildSelectableButton(String label,
      {required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.brown[300] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
