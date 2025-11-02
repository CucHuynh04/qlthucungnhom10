// lib/charts_stats_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'pet_service.dart';
import 'dart:io';

class ChartsStatsScreen extends StatefulWidget {
  const ChartsStatsScreen({super.key});

  @override
  State<ChartsStatsScreen> createState() => _ChartsStatsScreenState();
}

class _ChartsStatsScreenState extends State<ChartsStatsScreen> {
  String? _selectedPetId;
  String _selectedChartType = 'weight'; // 'weight' hoặc 'cost'

  @override
  Widget build(BuildContext context) {
    final petService = context.watch<PetService>();
    final pets = petService.pets;
    
    // Force rebuild when data changes
    if (_selectedPetId != null) {
      final pet = petService.getPetById(_selectedPetId!);
      if (pet != null) {
        // Trigger rebuild by accessing the data
        pet.weightHistory.length;
        pet.careHistory.length;
      }
    }

    return Scaffold(
      extendBody: true,
      body: Column(
        children: [
          // Bộ chọn thú cưng và loại biểu đồ
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Các button loại biểu đồ
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedChartType = 'weight';
                          });
                        },
                        icon: const Icon(Icons.monitor_weight),
                        label: Text('weight'.tr()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedChartType == 'weight' ? Colors.teal[700] : Colors.grey[300],
                          foregroundColor: _selectedChartType == 'weight' ? Colors.white : Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedChartType = 'cost';
                          });
                        },
                        icon: const Icon(Icons.account_balance_wallet),
                        label: Text('cost'.tr()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedChartType == 'cost' ? Colors.teal[700] : Colors.grey[300],
                          foregroundColor: _selectedChartType == 'cost' ? Colors.white : Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Hiển thị danh sách thú cưng hoặc biểu đồ
          Expanded(
            child: _selectedPetId == null
                // Hiển thị danh sách thú cưng để chọn
                ? Container(
                    color: Colors.grey[50],
                    child: pets.isEmpty
                        ? const Center(
                            child: Text('Bạn chưa có thú cưng nào'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 100),
                            itemCount: pets.length,
                            itemBuilder: (context, index) {
                              final pet = pets[index];
                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.teal[100],
                                    backgroundImage: pet.imageUrl != null ? FileImage(File(pet.imageUrl!)) : null,
                                    child: pet.imageUrl == null
                                        ? const Icon(Icons.pets, color: Colors.teal)
                                        : null,
                                  ),
                                  title: Text(
                                    pet.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text('${pet.species} - ${pet.breed}'),
                                  onTap: () {
                                    setState(() {
                                      _selectedPetId = pet.id;
                                    });
                                  },
                                  trailing: const Icon(Icons.chevron_right),
                                ),
                              );
                            },
                          ),
                  )
                // Hiển thị biểu đồ
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 250),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nút quay lại
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedPetId = null;
                            });
                          },
                          icon: const Icon(Icons.arrow_back),
                          label: Text('back_to_pet_selection'.tr()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          ),
                        )
                            .animate(), const SizedBox(height: 16),
                        // Thống kê tổng quan
                        _buildStatisticsCards(),
                        const SizedBox(height: 24),
                        
                        // Biểu đồ
                        _buildChart(),
                        const SizedBox(height: 24),
                        
                        // Bảng dữ liệu chi tiết
                        _buildDataTable(),
                        const SizedBox(height: 150), // Thêm khoảng cách lớn ở cuối để tránh bị che bởi FABs và bottomNavBar
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    if (_selectedPetId == null) return const SizedBox.shrink();
    
    final petService = context.read<PetService>();
    final pet = petService.getPetById(_selectedPetId!);
    
    if (pet == null) return const SizedBox.shrink();

    if (_selectedChartType == 'weight') {
      final stats = petService.getWeightStatistics(_selectedPetId!);
      return Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Cân nặng hiện tại',
              '${stats['current']!.toStringAsFixed(1)} kg',
              Icons.monitor_weight,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Cân nặng trung bình',
              '${stats['avg']!.toStringAsFixed(1)} kg',
              Icons.trending_up,
              Colors.green,
            ),
          ),
        ],
      );
    } else {
      final stats = petService.getCareCostStatistics(_selectedPetId!);
      return Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Tổng chi phí',
              '${stats['total']!.toStringAsFixed(0)} VNĐ',
              Icons.account_balance_wallet,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Chi phí tháng này',
              '${stats['thisMonth']!.toStringAsFixed(0)} VNĐ',
              Icons.calendar_month,
              Colors.red,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    if (_selectedPetId == null) return const SizedBox.shrink();
    
    final petService = context.read<PetService>();
    final pet = petService.getPetById(_selectedPetId!);
    
    if (pet == null) return const SizedBox.shrink();

    if (_selectedChartType == 'weight') {
      return _buildWeightChart(pet);
    } else {
      return _buildCostChart(pet);
    }
  }

  Widget _buildWeightChart(Pet pet) {
    if (pet.weightHistory.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text('Chưa có dữ liệu cân nặng'),
          ),
        ),
      );
    }

    // Sắp xếp dữ liệu theo thời gian và tạo spots
    final sortedHistory = List<WeightRecord>.from(pet.weightHistory)
      ..sort((a, b) => a.date.compareTo(b.date));
    
    final spots = sortedHistory.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.weight);
    }).toList();

    // Tính min và max cho trục Y với các bậc đều nhau (cách 2kg)
    final weights = sortedHistory.map((record) => record.weight).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    
    // Làm tròn xuống bội số của 2 cho min và lên bội số của 2 cho max
    final yMin = ((minWeight.floor() ~/ 2) * 2).clamp(0, double.infinity).toDouble();
    final yMax = ((maxWeight.ceil() ~/ 2 + 1) * 2).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Biểu đồ cân nặng theo thời gian',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: LineChart(
                LineChartData(
                  minY: yMin.toDouble(),
                  maxY: yMax.toDouble(),
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        interval: 2.0, // Cách đều 2kg để tránh đè
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()} kg',
                            style: const TextStyle(fontSize: 11),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 1.0, // Hiển thị mỗi điểm dữ liệu
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < sortedHistory.length) {
                            final date = sortedHistory[value.toInt()].date;
                            return Text(
                              '${date.day}/${date.month}',
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.teal,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.teal.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildCostChart(Pet pet) {
    if (pet.careHistory.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text('Chưa có dữ liệu chi phí'),
          ),
        ),
      );
    }

    // Nhóm chi phí theo tháng
    final Map<String, double> monthlyCosts = {};
    for (final care in pet.careHistory) {
      if (care.cost != null) {
        final monthKey = '${care.date.year}-${care.date.month.toString().padLeft(2, '0')}';
        monthlyCosts[monthKey] = (monthlyCosts[monthKey] ?? 0) + care.cost!;
      }
    }

    if (monthlyCosts.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text('Chưa có dữ liệu chi phí'),
          ),
        ),
      );
    }

    final sortedMonths = monthlyCosts.keys.toList()..sort();
    final spots = sortedMonths.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), monthlyCosts[entry.value]!);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Biểu đồ chi phí theo tháng',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('${(value / 1000).toStringAsFixed(0)}k');
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < sortedMonths.length) {
                            final monthKey = sortedMonths[value.toInt()];
                            final parts = monthKey.split('-');
                            return Text('${parts[1]}/${parts[0].substring(2)}');
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: spots.map((spot) {
                    return BarChartGroupData(
                      x: spot.x.toInt(),
                      barRods: [
                        BarChartRodData(
                          toY: spot.y,
                          color: Colors.teal,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildDataTable() {
    if (_selectedPetId == null) return const SizedBox.shrink();
    
    final petService = context.read<PetService>();
    final pet = petService.getPetById(_selectedPetId!);
    
    if (pet == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedChartType == 'weight' ? 'Lịch sử cân nặng' : 'Lịch sử chi phí',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (_selectedChartType == 'weight')
          _buildWeightTable(pet)
        else
          _buildCostTable(pet),
      ],
    );
  }

  Widget _buildWeightTable(Pet pet) {
    if (pet.weightHistory.isEmpty) {
      return Text('no_data_available'.tr());
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 600),
        child: DataTable(
          columnSpacing: 20,
          columns: [
            const DataColumn(label: SizedBox(width: 80, child: Text('Ngày', style: TextStyle(fontSize: 12)))),
            const DataColumn(label: SizedBox(width: 80, child: Text('Cân nặng', style: TextStyle(fontSize: 12)))),
            const DataColumn(label: SizedBox(width: 120, child: Text('Ghi chú', style: TextStyle(fontSize: 12)))),
          ],
          rows: pet.weightHistory.map((record) {
            return DataRow(
              cells: [
                DataCell(SizedBox(width: 80, child: Text('${record.date.day}/${record.date.month}/${record.date.year}', style: const TextStyle(fontSize: 12)))),
                DataCell(SizedBox(width: 80, child: Text(record.weight.toStringAsFixed(1), style: const TextStyle(fontSize: 12)))),
                DataCell(SizedBox(width: 120, child: Text(record.notes ?? '', style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis, maxLines: 2))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCostTable(Pet pet) {
    final careRecords = pet.careHistory.where((c) => c.cost != null).toList();
    if (careRecords.isEmpty) {
      return Text('no_data_available'.tr());
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 700),
        child: DataTable(
          columnSpacing: 16,
          columns: [
            const DataColumn(label: SizedBox(width: 80, child: Text('Ngày', style: TextStyle(fontSize: 12)))),
            const DataColumn(label: SizedBox(width: 100, child: Text('Loại', style: TextStyle(fontSize: 12)))),
            const DataColumn(label: SizedBox(width: 100, child: Text('Chi phí', style: TextStyle(fontSize: 12)))),
            const DataColumn(label: SizedBox(width: 120, child: Text('Ghi chú', style: TextStyle(fontSize: 12)))),
          ],
          rows: careRecords.map((record) {
            return DataRow(
              cells: [
                DataCell(SizedBox(width: 80, child: Text('${record.date.day}/${record.date.month}/${record.date.year}', style: const TextStyle(fontSize: 12)))),
                DataCell(SizedBox(width: 100, child: Text(record.type, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis))),
                DataCell(SizedBox(width: 100, child: Text(record.cost!.toStringAsFixed(0), style: const TextStyle(fontSize: 12)))),
                DataCell(SizedBox(width: 120, child: Text(record.notes ?? '', style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis, maxLines: 2))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}






