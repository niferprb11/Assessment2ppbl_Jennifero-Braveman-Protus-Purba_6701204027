import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await openDatabase(
    'opangatimin.db',
    version: 1,
    onCreate: (Database db, int version) async {
      await db.execute('''
        CREATE TABLE tukangojek (
          id INTEGER PRIMARY KEY,
          nama TEXT,
          nopol TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE transaksi (
          id INTEGER PRIMARY KEY,
          tukangojek_id INTEGER,
          harga INTEGER,
          timestamp TEXT
        )
      ''');
    },
  );

  runApp(MyApp(database));
}

class MyApp extends StatelessWidget {
  final Database database;

  MyApp(this.database);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OPANGATIMIN',
      home: MainPage(database),
    );
  }
}

class MainPage extends StatelessWidget {
  final Database database;

  MainPage(this.database);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OPANGATIMIN'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddTukangOjekPage(database)),
                );
              },
              child: Text('Tambah Tukang Ojek'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddTransaksiPage(database)),
                );
              },
              child: Text('Tambah Transaksi'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LaporanHarianPage(database)),
                );
              },
              child: Text('Laporan Harian'),
            ),
          ],
        ),
      ),
    );
  }
}

class TukangOjek {
  // Define the TukangOjek class members
}

class Transaksi {
  // Define the Transaksi class members
}

class AddTukangOjekPage extends StatelessWidget {
  final Database database;

  AddTukangOjekPage(this.database);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Tukang Ojek'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TukangOjekForm(database),
          ],
        ),
      ),
    );
  }
}

class AddTransaksiPage extends StatelessWidget {
  final Database database;

  AddTransaksiPage(this.database);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Transaksi'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TransaksiForm(database),
          ],
        ),
      ),
    );
  }
}

class LaporanHarianPage extends StatelessWidget {
  final Database database;

  LaporanHarianPage(this.database);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laporan Harian'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add your code for Laporan Harian page here
          ],
        ),
      ),
    );
  }
}

class TukangOjekForm extends StatefulWidget {
  final Database database;

  TukangOjekForm(this.database);

  @override
  _TukangOjekFormState createState() => _TukangOjekFormState();
}

class _TukangOjekFormState extends State<TukangOjekForm> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nopolController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _namaController,
          decoration: InputDecoration(labelText: 'Nama'),
        ),
        TextField(
          controller: _nopolController,
          decoration: InputDecoration(labelText: 'Nomor Polisi'),
        ),
        ElevatedButton(
          onPressed: () {
            _tambahTukangOjek();
          },
          child: Text('Simpan'),
        ),
      ],
    );
  }

  void _tambahTukangOjek() async {
    String nama = _namaController.text;
    String nopol = _nopolController.text;

    if (nama.isNotEmpty && nopol.isNotEmpty) {
      await widget.database.insert(
        'tukangojek',
        {'nama': nama, 'nopol': nopol},
      );

      _clearForm();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tukang Ojek berhasil ditambahkan.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Harap isi semua field.'),
        ),
      );
    }
  }

  void _clearForm() {
    _namaController.clear();
    _nopolController.clear();
  }
}

class TransaksiForm extends StatefulWidget {
  final Database database;

  TransaksiForm(this.database);

  @override
  _TransaksiFormState createState() => _TransaksiFormState();
}

class _TransaksiFormState extends State<TransaksiForm> {
  final TextEditingController _hargaController = TextEditingController();
  List<Map<String, dynamic>> _tukangOjekList = [];
  int _selectedTukangOjekId = -1;

  @override
  void initState() {
    super.initState();
    _loadTukangOjekList();
  }

  void _loadTukangOjekList() async {
    final tukangOjekList = await widget.database.query('tukangojek');
    setState(() {
      _tukangOjekList = tukangOjekList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<int>(
          value: _selectedTukangOjekId,
          onChanged: (int? value) {
            setState(() {
              _selectedTukangOjekId = value!;
            });
          },
          items: _tukangOjekList.map<DropdownMenuItem<int>>((tukangOjek) {
            return DropdownMenuItem<int>(
              value: tukangOjek['id'],
              child: Text(tukangOjek['nama']),
            );
          }).toList(),
          decoration: InputDecoration(labelText: 'Tukang Ojek'),
        ),
        TextField(
          controller: _hargaController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Harga'),
        ),
        ElevatedButton(
          onPressed: () {
            _tambahTransaksi();
          },
          child: Text('Simpan'),
        ),
      ],
    );
  }

  void _tambahTransaksi() async {
    int harga = int.tryParse(_hargaController.text) ?? 0;

    if (_selectedTukangOjekId != -1 && harga > 0) {
      await widget.database.insert(
        'transaksi',
        {
          'tukangojek_id': _selectedTukangOjekId,
          'harga': harga,
          'timestamp': DateTime.now().toString(),
        },
      );

      _clearForm();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaksi berhasil ditambahkan.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Harap isi semua field.'),
        ),
      );
    }
  }

  void _clearForm() {
    _hargaController.clear();
    _selectedTukangOjekId = -1;
  }
}
