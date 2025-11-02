// lib/export_share_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'pet_service.dart';

class ExportShareScreen extends StatefulWidget {
  const ExportShareScreen({super.key});

  @override
  State<ExportShareScreen> createState() => _ExportShareScreenState();
}

class _ExportShareScreenState extends State<ExportShareScreen> {
  String? _selectedPetId;
  bool _isGenerating = false;

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
        pet.vaccinationHistory.length;
        pet.accessoryHistory.length;
        pet.foodHistory.length;
      }
    }

    return Scaffold(
      extendBody: true,
      body: Column(
        children: [
          // Hiển thị danh sách thú cưng hoặc nội dung
          Expanded(
            child: _selectedPetId == null
                // Hiển thị danh sách thú cưng để chọn
                ? Container(
                    color: Colors.grey[50],
                    child: pets.isEmpty
                        ? Center(
                            child: Text('no_pets_yet'.tr()),
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
                // Hiển thị nội dung xuất dữ liệu
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
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
                        ),
                        const SizedBox(height: 16),
                        // Thông tin thú cưng
                        _buildPetInfoCard(),
                        const SizedBox(height: 24),
                        
                        // Các tùy chọn xuất/chia sẻ
                        _buildExportOptions(),
                        const SizedBox(height: 24),
                        
                        // Trạng thái
                        if (_isGenerating)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  const CircularProgressIndicator(),
                                  const SizedBox(width: 16),
                                  Text('generating_file'.tr()),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetInfoCard() {
    if (_selectedPetId == null) return const SizedBox.shrink();
    
    final petService = context.read<PetService>();
    final pet = petService.getPetById(_selectedPetId!);
    
    if (pet == null) return const SizedBox.shrink();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.teal[100],
              child: pet.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.network(
                        pet.imageUrl!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.pets,
                            size: 30,
                            color: Colors.teal[700],
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.pets,
                      size: 30,
                      color: Colors.teal[700],
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${pet.species} - ${pet.breed}'),
                  Text('${'gender'.tr()}: ${pet.gender}'),
                  Text('${'birth_date'.tr()}: ${pet.birthDate}'),
                  if (pet.weight != null)
                    Text('${'weight'.tr()}: ${pet.weight!.toStringAsFixed(1)} kg'),
                  const SizedBox(height: 8),
                  Text('📊 ${'stats'.tr()}:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[700])),
                  Text('• ${'weight'.tr()}: ${pet.weightHistory.length} ${'times_recorded'.tr()}'),
                  Text('• ${'care'.tr()}: ${pet.careHistory.length} ${'care_count'.tr()}'),
                  Text('• ${'vaccination'.tr()}: ${pet.vaccinationHistory.length} ${'vaccination_count'.tr()}'),
                  Text('• ${'accessories'.tr()}: ${pet.accessoryHistory.length} ${'accessories_count'.tr()}'),
                  Text('• ${'food'.tr()}: ${pet.foodHistory.length} ${'food_count'.tr()}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOptions() {
    return Column(
      children: [
        // Xuất hồ sơ PDF
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(Icons.picture_as_pdf, color: Colors.red[600]),
            title: Text('export_pdf_profile'.tr()),
            subtitle: Text('export_profile_desc'.tr()),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _isGenerating ? null : _exportPetProfilePDF,
          ),
        ),
        const SizedBox(height: 12),
        
        // Xuất lịch tiêm chủng PDF
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(Icons.medical_services, color: Colors.blue[600]),
            title: Text('export_vaccination_pdf'.tr()),
            subtitle: Text('export_vaccination_desc'.tr()),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _isGenerating ? null : _exportVaccinationPDF,
          ),
        ),
        const SizedBox(height: 12),
        
        // Chia sẻ thông tin
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(Icons.share, color: Colors.green[600]),
            title: Text('share_info'.tr()),
            subtitle: Text('share_info'.tr()),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _isGenerating ? null : _sharePetInfo,
          ),
        ),
      ],
    );
  }

  Future<void> _exportPetProfilePDF() async {
    if (_selectedPetId == null) return;
    
    setState(() {
      _isGenerating = true;
    });

    try {
      final petService = context.read<PetService>();
      final pet = petService.getPetById(_selectedPetId!);
      
      if (pet == null) return;

      final pdf = pw.Document();
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text(
                    'HỒ SƠ THÚ CƯNG',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(height: 20),
                
                // Thông tin cơ bản
                pw.Text(
                  'THÔNG TIN CƠ BẢN',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Text('Tên: ${pet.name}'),
                pw.Text('Loài: ${pet.species}'),
                pw.Text('Giống: ${pet.breed}'),
                pw.Text('Giới tính: ${pet.gender}'),
                pw.Text('Ngày sinh: ${pet.birthDate}'),
                if (pet.weight != null)
                  pw.Text('Cân nặng hiện tại: ${pet.weight!.toStringAsFixed(1)} kg'),
                pw.SizedBox(height: 20),
                
                // Lịch sử cân nặng
                if (pet.weightHistory.isNotEmpty) ...[
                  pw.Text(
                    'LỊCH SỬ CÂN NẶNG',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Table(
                    border: pw.TableBorder.all(),
                    children: [
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Ngày', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Cân nặng (kg)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Ghi chú', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ),
                        ],
                      ),
                      ...pet.weightHistory.map((record) => pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('${record.date.day}/${record.date.month}/${record.date.year}'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(record.weight.toStringAsFixed(1)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(record.notes ?? ''),
                          ),
                        ],
                      )),
                    ],
                  ),
                  pw.SizedBox(height: 20),
                ],
                
                // Lịch sử chăm sóc
                if (pet.careHistory.isNotEmpty) ...[
                  pw.Text(
                    'LỊCH SỬ CHĂM SÓC',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Table(
                    border: pw.TableBorder.all(),
                    children: [
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Ngày', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Loại', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Chi phí (VNĐ)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Ghi chú', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ),
                        ],
                      ),
                      ...pet.careHistory.map((record) => pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('${record.date.day}/${record.date.month}/${record.date.year}'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(record.type),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(record.cost?.toStringAsFixed(0) ?? '0'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(record.notes ?? ''),
                          ),
                        ],
                      )),
                    ],
                  ),
                ],
              ],
            );
          },
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/pet_profile_${pet.name}_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles([XFile(file.path)], text: 'Hồ sơ thú cưng ${pet.name}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('export_pdf_success'.tr())),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'export_pdf_error'.tr()}: $e')),
        );
      }
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  Future<void> _exportVaccinationPDF() async {
    if (_selectedPetId == null) return;
    
    setState(() {
      _isGenerating = true;
    });

    try {
      final petService = context.read<PetService>();
      final pet = petService.getPetById(_selectedPetId!);
      
      if (pet == null) return;

      final pdf = pw.Document();
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text(
                    'LỊCH TIÊM CHỦNG - ${pet.name.toUpperCase()}',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(height: 20),
                
                // Thông tin thú cưng
                pw.Text(
                  'THÔNG TIN THÚ CƯNG',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Text('Tên: ${pet.name}'),
                pw.Text('Loài: ${pet.species}'),
                pw.Text('Giống: ${pet.breed}'),
                pw.Text('Ngày sinh: ${pet.birthDate}'),
                pw.SizedBox(height: 20),
                
                // Lịch sử tiêm chủng
                if (pet.vaccinationHistory.isNotEmpty) ...[
                  pw.Text(
                    'LỊCH SỬ TIÊM CHỦNG',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Table(
                    border: pw.TableBorder.all(),
                    children: [
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Ngày tiêm', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Tên vaccine', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Ngày tiêm tiếp theo', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Ghi chú', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ),
                        ],
                      ),
                      ...pet.vaccinationHistory.map((record) => pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('${record.date.day}/${record.date.month}/${record.date.year}'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(record.vaccineName),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(record.nextDueDate != null 
                                ? '${record.nextDueDate!.day}/${record.nextDueDate!.month}/${record.nextDueDate!.year}'
                                : 'Chưa xác định'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(record.notes ?? ''),
                          ),
                        ],
                      )),
                    ],
                  ),
                ] else ...[
                  pw.Text(
                    'Chưa có lịch sử tiêm chủng',
                    style: pw.TextStyle(fontSize: 16, fontStyle: pw.FontStyle.italic),
                  ),
                ],
              ],
            );
          },
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/vaccination_${pet.name}_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles([XFile(file.path)], text: 'Lịch tiêm chủng ${pet.name}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('export_vaccination_pdf_success'.tr())),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'export_pdf_error'.tr()}: $e')),
        );
      }
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  Future<void> _sharePetInfo() async {
    if (_selectedPetId == null) return;
    
    final petService = context.read<PetService>();
    final pet = petService.getPetById(_selectedPetId!);
    
    if (pet == null) return;

    final shareText = '''
🐾 ${'share_pet_info'.tr()}: ${pet.name}

📋 ${'basic_info'.tr()}:
• ${'species'.tr()}: ${pet.species}
• ${'breed'.tr()}: ${pet.breed}
• ${'gender'.tr()}: ${pet.gender}
• ${'birth_date'.tr()}: ${pet.birthDate}
${pet.weight != null ? '• ${'weight'.tr()}: ${pet.weight!.toStringAsFixed(1)} kg' : ''}

📊 ${'stats'.tr()}:
• ${'weight'.tr()}: ${pet.weightHistory.length} ${'times_recorded'.tr()}
• ${'care'.tr()}: ${pet.careHistory.length} ${'care_count'.tr()}
• ${'vaccination'.tr()}: ${pet.vaccinationHistory.length} ${'vaccination_count'.tr()}

${'shared_from_app'.tr()} 🐕🐱
''';

    await Share.share(shareText);
  }
}





