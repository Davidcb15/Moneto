import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

// Importamos las bases de datos
import 'Databases/DatabaseMoney.dart'; // Para ingresos
import 'Databases/DatabaseHome.dart'; // Para gastos del hogar
import 'Databases/DatabaseCar.dart'; // Para gastos de coche
import 'Databases/DatabaseHobbies.dart'; // Para gastos de hobbies
import 'Databases/DatabaseTravel.dart'; // Para gastos de viajes
import 'Databases/DatabasePublicTransport.dart'; // Para gastos de transporte público
import 'Databases/DatabaseSaveMoney.dart'; // Para mostrar los ahorros
import 'package:intl/intl.dart'; // Para formatear fechas y números

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late SharedPreferences prefs;
  double _totalIngresos = 0.0;
  double _totalGastos = 0.0;
  bool showChart = false;
  GlobalKey _chartKey = GlobalKey();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  BarChartData? _chartData;

  @override
  void initState() {
    super.initState();
    _loadData().then((_) {
      _loadChartData();
    });
  }

  Future<void> _loadData() async {
    prefs = await SharedPreferences.getInstance();
    _totalIngresos = prefs.getDouble('total_ingresos') ?? 0.0;
    _totalGastos = prefs.getDouble('total_gastos') ?? 0.0;
  }

  Future<void> _loadChartData() async {
    final List<Map<String, dynamic>> gastosCoche = await DatabaseCar.database.then((db) => db.query('gastos'));
    final List<Map<String, dynamic>> gastosHobbies = await DatabaseHelper.instance.database.then((db) => db.query('expenses'));
    final List<Map<String, dynamic>> gastosHogar = await DatabaseHome.instance.database.then((db) => db.query(DatabaseHome.tableGastos));
    final List<Map<String, dynamic>> gastosTransportePublico = await DatabasePublicTransport.database.then((db) => db.query('gastos'));
    final List<Map<String, dynamic>> gastosViajes = await DatabaseTravel.database.then((db) => db.query('gastos'));
    final double? totalIngresosCalculado = await DatabaseMoney.getTotalIngresos();

    double totalGastosCalculado = 0;
    for (var gasto in gastosHogar) {
      totalGastosCalculado += (gasto[DatabaseHome.columnAmount] as num).toDouble();
    }
    for (var gasto in gastosCoche) {
      totalGastosCalculado += (gasto['importe'] as num).toDouble();
    }
    for (var gasto in gastosHobbies) {
      totalGastosCalculado += (gasto['amount'] as num).toDouble();
    }
    for (var gasto in gastosViajes) {
      totalGastosCalculado += (gasto['importe'] as num).toDouble();
    }
    for (var gasto in gastosTransportePublico) {
      totalGastosCalculado += (gasto['importe'] as num).toDouble();
    }

    setState(() {
      _totalIngresos = totalIngresosCalculado ?? 0.0;
      _totalGastos = totalGastosCalculado;
      _chartData = BarChartData(
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(show: true),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(toY: _totalIngresos, color: Colors.blue, width: 25, borderRadius: BorderRadius.zero),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(toY: _totalGastos, color: Colors.red, width: 25, borderRadius: BorderRadius.zero),
            ],
          ),
        ],
      );
    });
  }

  Future<void> _generatePDF() async {
    final pdf = pw.Document();

    final fontData = await rootBundle.load('assets/Roboto-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

// Algunas bases de datos usan un singleton con instancia para gestionar la conexión,
// otras usan un getter estático que devuelve directamente el Future<Database>.
    final List<Map<String, dynamic>> gastosCoche = await DatabaseCar.database.then((db) => db.query('gastos'));
    final List<Map<String, dynamic>> gastosHobbies = await DatabaseHelper.instance.database.then((db) => db.query('expenses'));
    final List<Map<String, dynamic>> gastosHogar = await DatabaseHome.instance.database.then((db) => db.query(DatabaseHome.tableGastos));
    final List<Map<String, dynamic>> gastosTransportePublico = await DatabasePublicTransport.database.then((db) => db.query('gastos'));
    final List<Map<String, dynamic>> gastosViajes = await DatabaseTravel.database.then((db) => db.query('gastos'));
    final double? totalIngresosPDF = await DatabaseMoney.getTotalIngresos();
    final double totalAhorrosPDF = await DatabaseSaveMoney.getTotalAhorros();

// Suma total de todos los gastos
    double totalGastosPDF = 0.0;
    for (var gasto in gastosHogar) {
      totalGastosPDF += (gasto[DatabaseHome.columnAmount] as num).toDouble();
    }
    for (var gasto in gastosCoche) {
      totalGastosPDF += (gasto['importe'] as num).toDouble();
    }
    for (var gasto in gastosHobbies) {
      totalGastosPDF += (gasto['amount'] as num).toDouble();
    }
    for (var gasto in gastosViajes) {
      totalGastosPDF += (gasto['importe'] as num).toDouble();
    }
    for (var gasto in gastosTransportePublico) {
      totalGastosPDF += (gasto['importe'] as num).toDouble();
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Reporte Detallado de Gastos', style: pw.TextStyle(font: ttf, fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              if (totalIngresosPDF != null)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 10),
                  child: pw.Text('Ingresos Totales: €${totalIngresosPDF.toStringAsFixed(2)}', style: pw.TextStyle(font: ttf, fontSize: 16)),
                ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 10),
                child: pw.Text('Ahorros Totales: €${totalAhorrosPDF.toStringAsFixed(2)}', style: pw.TextStyle(font: ttf, fontSize: 16)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 20),
                child: pw.Text('Gastos Totales: €${totalGastosPDF.toStringAsFixed(2)}', style: pw.TextStyle(font: ttf, fontSize: 16)),
              ),

              pw.Text('Gastos del Hogar', style: pw.TextStyle(font: ttf, fontSize: 20, fontWeight: pw.FontWeight.bold)),
              if (gastosHogar.isNotEmpty)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: gastosHogar.map((gasto) {
                    return pw.Text(
                        'Fecha: ${_dateFormat.format(DateTime.parse(gasto[DatabaseHome.columnDate]))}, Importe: €${(gasto[DatabaseHome.columnAmount] as num).toDouble().toStringAsFixed(2)}, Categoría: ${gasto[DatabaseHome.columnCategory]}',
                        style: pw.TextStyle(font: ttf));
                  }).toList(),
                )
              else
                pw.Text('No hay gastos del hogar registrados.', style: pw.TextStyle(font: ttf)),
              pw.SizedBox(height: 10),

              pw.Text('Gastos de Coche', style: pw.TextStyle(font: ttf, fontSize: 20, fontWeight: pw.FontWeight.bold)),
              if (gastosCoche.isNotEmpty)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: gastosCoche.map((gasto) {
                    return pw.Text(
                        'Fecha: ${_dateFormat.format(DateTime.parse(gasto['fecha']))}, Importe: €${(gasto['importe'] as num).toDouble().toStringAsFixed(2)}, Categoría: ${gasto['categoria']}',
                        style: pw.TextStyle(font: ttf));
                  }).toList(),
                )
              else
                pw.Text('No hay gastos de coche registrados.', style: pw.TextStyle(font: ttf)),
              pw.SizedBox(height: 10),

              pw.Text('Gastos de Hobbies', style: pw.TextStyle(font: ttf, fontSize: 20, fontWeight: pw.FontWeight.bold)),
              if (gastosHobbies.isNotEmpty)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: gastosHobbies.map((gasto) {
                    return pw.Text(
                        'Fecha: ${_dateFormat.format(DateTime.parse(gasto['date']))}, Importe: €${(gasto['amount'] as num).toDouble().toStringAsFixed(2)}, Hobby: ${gasto['hobby']}, Descripción: ${gasto['description']}',
                        style: pw.TextStyle(font: ttf));
                  }).toList(),
                )
              else
                pw.Text('No hay gastos de hobbies registrados.', style: pw.TextStyle(font: ttf)),
              pw.SizedBox(height: 10),

              pw.Text('Gastos de Viajes', style: pw.TextStyle(font: ttf, fontSize: 20, fontWeight: pw.FontWeight.bold)),
              if (gastosViajes.isNotEmpty)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: gastosViajes.map((gasto) {
                    return pw.Text(
                        'Fecha: ${_dateFormat.format(DateTime.parse(gasto['fecha']))}, Importe: €${(gasto['importe'] as num).toDouble().toStringAsFixed(2)}, Categoría: ${gasto['categoria']}, Detalle: ${gasto['detalle']}',
                        style: pw.TextStyle(font: ttf));
                  }).toList(),
                )
              else
                pw.Text('No hay gastos de viajes registrados.', style: pw.TextStyle(font: ttf)),
              pw.SizedBox(height: 10),

              pw.Text('Gastos de Transporte Público', style: pw.TextStyle(font: ttf, fontSize: 20, fontWeight: pw.FontWeight.bold)),
              if (gastosTransportePublico.isNotEmpty)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: gastosTransportePublico.map((gasto) {
                    return pw.Text(
                        'Fecha: ${_dateFormat.format(DateTime.parse(gasto['fecha']))}, Importe: €${(gasto['importe'] as num).toDouble().toStringAsFixed(2)}, Categoría: ${gasto['categoria']}',
                        style: pw.TextStyle(font: ttf));
                  }).toList(),
                )
              else
                pw.Text('No hay gastos de transporte público registrados.', style: pw.TextStyle(font: ttf)),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/reporte_detallado.pdf");
    await file.writeAsBytes(await pdf.save());
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  Widget _generateChart() {
    return _chartData != null
        ? BarChart(_chartData!)
        : const CircularProgressIndicator();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generar Reportes')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset('assets/report.png', height: 100, fit: BoxFit.contain),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generatePDF,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Generar PDF'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  showChart = !showChart;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Generar gráfico'),
            ),
            const SizedBox(height: 20),
            if (showChart)
              Column(
                children: [
                  const Text(
                    'Comparación de Ingresos y Gastos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  RepaintBoundary(
                    key: _chartKey,
                    child: SizedBox(height: 300, child: _generateChart()),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}