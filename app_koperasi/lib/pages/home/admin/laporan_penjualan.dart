import 'dart:math';
import 'package:app_koperasi/services/api.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LaporanPenjualanPage extends StatefulWidget {
  const LaporanPenjualanPage({Key? key}) : super(key: key);

  @override
  _LaporanPenjualanPageState createState() => _LaporanPenjualanPageState();
}

class _LaporanPenjualanPageState extends State<LaporanPenjualanPage> {
  final List<String> opsiLaporan = ['Harian', 'Mingguan', 'Bulanan', 'Tahunan'];
  String selectedLaporan = 'Harian';
  late Future<List<Map<String, dynamic>>> _penjualanData;
  late Future<List<Map<String, dynamic>>> _produkTerlaris;

  @override
  void initState() {
    super.initState();
    _loadData();
    _produkTerlaris = fetchProdukTerlaris();
  }

  void _loadData() {
    setState(() {
      _penjualanData = fetchLaporanPenjualan(selectedLaporan.toLowerCase());
    });
  }

  Future<List<Map<String, dynamic>>> fetchLaporanPenjualan(String tipe) async {
    try {
      final response =
          await http.get(Uri.parse("$baseUrl/laporan/penjualan_$tipe"));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception("Gagal memuat data laporan penjualan");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<List<Map<String, dynamic>>> fetchProdukTerlaris() async {
    try {
      final response =
          await http.get(Uri.parse("$baseUrl/laporan/produk_terlaris"));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception("Gagal memuat produk terlaris");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Color _getRandomColor(String key) {
    final random = Random(key.hashCode);
    return Color.fromARGB(
        255, random.nextInt(256), random.nextInt(256), random.nextInt(256));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Laporan Penjualan")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("Pilih Jenis Laporan: ",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(width: 16),
                DropdownButton<String>(
                  value: selectedLaporan,
                  items: opsiLaporan.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        selectedLaporan = val;
                      });
                      _loadData();
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 24),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _penjualanData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text("Tidak ada data penjualan.");
                }

                final penjualanData = snapshot.data!;
                return AspectRatio(
                  aspectRatio: 1.5,
                  child: BarChart(
                    BarChartData(
                      minY: 0,
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, _) {
                              final index = value.toInt();
                              if (index >= 0 && index < penjualanData.length) {
                                final key = selectedLaporan == "Harian"
                                    ? penjualanData[index]["tanggal"]
                                    : selectedLaporan == "Tahunan"
                                        ? penjualanData[index]["tahun"]
                                        : penjualanData[index]["minggu"] ??
                                            penjualanData[index]["bulan"];
                                return Text(key,
                                    style: TextStyle(fontSize: 10));
                              }
                              return Text("");
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      barGroups: penjualanData.asMap().entries.map((entry) {
                        int index = entry.key;
                        var data = entry.value;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: double.tryParse(data["total"].toString()) ??
                                  0,
                              color: Colors.blue,
                              width: 20,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 32),
            Text("Produk Terlaris",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _produkTerlaris,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text("Tidak ada data produk terlaris.");
                }

                final data = snapshot.data!;
                final totalJumlah = data.fold<int>(0, (sum, item) {
                  return sum + int.parse(item["jumlah"]);
                });

                return Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 1.3,
                      child: PieChart(
                        PieChartData(
                          sections: data.map((item) {
                            final color = _getRandomColor(item["produk"]);
                            final jumlah = int.parse(item["jumlah"]);
                            final percent = (jumlah / totalJumlah) * 100;

                            return PieChartSectionData(
                              color: color,
                              value: jumlah.toDouble(),
                              title: "${percent.toStringAsFixed(1)}%",
                              radius: 80,
                              titleStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: data.map((item) {
                        final color = _getRandomColor(item["produk"]);
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 12, height: 12, color: color),
                            SizedBox(width: 6),
                            Text(item["produk"]),
                          ],
                        );
                      }).toList(),
                    )
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
