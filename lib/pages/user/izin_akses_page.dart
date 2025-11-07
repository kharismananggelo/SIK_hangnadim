import 'package:flutter/material.dart';

class IzinAksesPage extends StatefulWidget {
  const IzinAksesPage({super.key});

  @override
  State<IzinAksesPage> createState() => _IzinAksesPageState();
}

class _IzinAksesPageState extends State<IzinAksesPage> {
  final List<Map<String, String>> _permissions = []; // Tabel kosong
  List<Map<String, String>> _filteredPermissions = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _groupController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  int? _editingIndex;
  int _entriesPerPage = 10;
  final List<int> _entriesOptions = [10, 25, 50, 100];

  @override
  void initState() {
    super.initState();
    _filteredPermissions = _permissions;
    _searchController.addListener(_filterData);
  }

  void _filterData() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredPermissions = _permissions;
      } else {
        _filteredPermissions = _permissions.where((permission) {
          final name = permission['name']!.toLowerCase();
          final description = permission['description']!.toLowerCase();
          return name.contains(query) || description.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dynamicEntriesOptions = _calculateDynamicEntriesOptions();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Izin Akses',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue[900],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.blue[900]),
      ),
      body: Column(
        children: [
          // Header dengan pencarian
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari Nama atau Group...',
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _entriesPerPage,
                      items: dynamicEntriesOptions.map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('$value entrie perhalaman'),
                          ),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setState(() {
                          _entriesPerPage = newValue!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 1),

          //table header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.blue[50],
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'No',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'NAMA',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'GROUP',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // table content
          Expanded(
            child: _filteredPermissions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.list_alt, size: 64, color: Colors.grey[300]),
                        SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'Tidak ada data'
                              : 'Data tidak ditemukan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                          ),
                        ),
                        Text(
                          _searchController.text.isEmpty
                              ? 'Tambahkan data dengan tombol + di bawah'
                              : 'Coba dengan kata kunci lain',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _getPaginatedData().length,
                    itemBuilder: (context, index) {
                      final permission = _getPaginatedData()[index];
                      final actualIndex = _filteredPermissions.indexOf(
                        permission,
                      );
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[200]!),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                '${actualIndex + 1}',
                                style: TextStyle(color: Colors.grey[700]),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                permission['name']!,
                                style: TextStyle(color: Colors.grey[700]),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                permission['description']!,
                                style: TextStyle(color: Colors.grey[700]),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: IconButton(
                                icon: Icon(Icons.more_vert, color: Colors.grey),
                                onPressed: () {
                                  _showActionMenu(context, actualIndex);
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // pagination info
          if (_filteredPermissions.isNotEmpty)
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Menampilkan ${_getPaginatedData().length} dari ${_filteredPermissions.length} data',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  if (_filteredPermissions.length > _entriesPerPage)
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios, size: 16),
                          onPressed: () {},
                        ),
                        Text(
                          '1 of ${(_filteredPermissions.length / _entriesPerPage).ceil()}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_forward_ios, size: 16),
                          onPressed: () {},
                        ),
                      ],
                    ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showTambahHakAksesDialog(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  List<Map<String, String>> _getPaginatedData() {
    final startIndex = 0;
    final endIndex = startIndex + _entriesPerPage;
    return _filteredPermissions.sublist(
      0,
      endIndex > _filteredPermissions.length
          ? _filteredPermissions.length
          : endIndex,
    );
  }

  List<int> _calculateDynamicEntriesOptions() {
    final totalItems = _filteredPermissions.length;
    final options = List<int>.from(_entriesOptions);

    if (totalItems > 100) {
      int nextOption = 100;
      while (nextOption < totalItems) {
        nextOption *= 2;
        if (!options.contains(nextOption)) {
          options.add(nextOption);
        }
      }
      if (!options.contains(totalItems)) {
        options.add(totalItems);
      }
    }

    options.sort();
    return options;
  }

  void _showActionMenu(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit, color: Colors.blue),
                title: Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditDialog(context, index);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context, index);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTambahHakAksesDialog(BuildContext context) {
    _nameController.clear();
    _groupController.clear();
    _editingIndex = null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Tambah Hak Akses'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Hak Akses',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _groupController,
                decoration: InputDecoration(
                  labelText: 'Group',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty &&
                    _groupController.text.isNotEmpty) {
                  _tambahHakAkses();
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Nama dan Group harus diisi!'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, int index) {
    final permission = _permissions[index];
    _nameController.text = permission['name']!;
    _groupController.text = permission['description']!;
    _editingIndex = index;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Hak Akses'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Hak Akses',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _groupController,
                decoration: InputDecoration(
                  labelText: 'Group',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty &&
                    _groupController.text.isNotEmpty) {
                  _editHakAkses();
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Nama dan Group harus diisi!'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text('Simpan Perubahan'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hapus Hak Akses'),
          content: Text(
            'Apakah Anda yakin ingin menghapus hak akses "${_permissions[index]['name']}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                _hapusHakAkses(index);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void _tambahHakAkses() {
    setState(() {
      _permissions.add({
        'name': _nameController.text,
        'description': _groupController.text,
      });
      _filterData();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Hak akses berhasil ditambahkan!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _editHakAkses() {
    if (_editingIndex != null) {
      setState(() {
        _permissions[_editingIndex!] = {
          'name': _nameController.text,
          'description': _groupController.text,
        };
        _filterData();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hak akses berhasil diubah!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _hapusHakAkses(int index) {
    setState(() {
      _permissions.removeAt(index);
      _filterData();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Hak akses berhasil dihapus!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _groupController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
