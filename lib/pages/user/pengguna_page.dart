import 'package:flutter/material.dart';

class PenggunaPage extends StatefulWidget {
  const PenggunaPage({super.key});

  @override
  State<PenggunaPage> createState() => _PenggunaPageState();
}

class _PenggunaPageState extends State<PenggunaPage> {
  final List<Map<String, String>> _users = [];
  List<Map<String, String>> _filteredUsers = [];

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  int? _editingIndex;
  int _entriesPerPage = 10;
  final List<int> _entriesOptions = [10, 25, 50, 100];

  @override
  void initState() {
    super.initState();
    _filteredUsers = _users;
    _searchController.addListener(_filterData);
  }

  void _filterData() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _users;
      } else {
        _filteredUsers = _users.where((user) {
          final nama = user['nama']!.toLowerCase();
          final email = user['email']!.toLowerCase();
          final role = user['role']!.toLowerCase();
          return nama.contains(query) ||
              email.contains(query) ||
              role.contains(query);
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
          'Tambah Pengguna',
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
          // pencarian dan entries perpage
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
                        hintText: 'Search...',
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
                  padding: EdgeInsets.symmetric(horizontal: 12),
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
                          child: Text('$value entries perpage'),
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

          // kolom untuk tombol titik 3
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.blue[50],
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'NO',
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
                  flex: 3,
                  child: Text(
                    'EMAIL',
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
                    'ROLE',
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

          Expanded(
            child: _filteredUsers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people, size: 64, color: Colors.grey[300]),
                        SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'Tidak ada data pengguna'
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
                      final user = _getPaginatedData()[index];
                      final actualIndex = _filteredUsers.indexOf(user);
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
                                user['nama']!,
                                style: TextStyle(color: Colors.grey[700]),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                user['email']!,
                                style: TextStyle(color: Colors.grey[700]),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                user['role']!,
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
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${_getPaginatedData().length} of ${_filteredUsers.length} entries',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                if (_filteredUsers.length > _entriesPerPage)
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios, size: 16),
                        onPressed: () {},
                      ),
                      Text(
                        '1 of ${(_filteredUsers.length / _entriesPerPage).ceil()}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
          _showTambahPenggunaDialog(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.orange,
      ),
    );
  }

  List<Map<String, String>> _getPaginatedData() {
    final startIndex = 0;
    final endIndex = startIndex + _entriesPerPage;
    return _filteredUsers.sublist(
      0,
      endIndex > _filteredUsers.length ? _filteredUsers.length : endIndex,
    );
  }

  List<int> _calculateDynamicEntriesOptions() {
    final totalItems = _filteredUsers.length;
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
                  _showEditPenggunaDialog(context, index);
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

  void _showTambahPenggunaDialog(BuildContext context) {
    _clearForm();
    _editingIndex = null;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tambah Pengguna',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _namaController,
                  decoration: InputDecoration(
                    labelText: 'Nama',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi Password',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items:
                      [
                        'Super User',
                        'Verifikator',
                        'Admin',
                        'User',
                        'View Only',
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    _roleController.text = newValue!;
                  },
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Batal'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_namaController.text.isNotEmpty &&
                            _emailController.text.isNotEmpty &&
                            _passwordController.text.isNotEmpty &&
                            _confirmPasswordController.text.isNotEmpty &&
                            _roleController.text.isNotEmpty) {
                          if (_passwordController.text ==
                              _confirmPasswordController.text) {
                            _tambahPengguna();
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Password dan Konfirmasi Password tidak sama!',
                                ),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Semua field harus diisi!'),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: Text('Simpan'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // fungsi edit pengguna
  void _showEditPenggunaDialog(BuildContext context, int index) {
    final user = _users[index];
    _namaController.text = user['nama']!;
    _emailController.text = user['email']!;
    _roleController.text = user['role']!;
    _editingIndex = index;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Edit Pengguna',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _namaController,
                  decoration: InputDecoration(
                    labelText: 'Nama',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password (kosongkan jika tidak ingin mengubah)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi Password',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _roleController.text,
                  decoration: InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items:
                      [
                        'Super User',
                        'Verifikator',
                        'Admin',
                        'User',
                        'View Only',
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    _roleController.text = newValue!;
                  },
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Batal'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_namaController.text.isNotEmpty &&
                            _emailController.text.isNotEmpty &&
                            _roleController.text.isNotEmpty) {
                          if (_passwordController.text.isEmpty ||
                              _passwordController.text ==
                                  _confirmPasswordController.text) {
                            _editPengguna();
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Password dan Konfirmasi Password tidak sama!',
                                ),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Nama, Email, dan Role harus diisi!',
                              ),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: Text('Simpan Perubahan'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // konfirmasi delete
  void _showDeleteConfirmation(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hapus Pengguna'),
          content: Text(
            'Apakah Anda yakin ingin menghapus pengguna "${_users[index]['nama']}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                _hapusPengguna(index);
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

  void _tambahPengguna() {
    setState(() {
      _users.add({
        'nama': _namaController.text,
        'email': _emailController.text,
        'role': _roleController.text,
      });
      _filterData();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pengguna berhasil ditambahkan!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _editPengguna() {
    if (_editingIndex != null) {
      setState(() {
        _users[_editingIndex!] = {
          'nama': _namaController.text,
          'email': _emailController.text,
          'role': _roleController.text,
        };
        _filterData();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pengguna berhasil diubah!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _hapusPengguna(int index) {
    setState(() {
      _users.removeAt(index);
      _filterData();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pengguna berhasil dihapus!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _clearForm() {
    _namaController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _roleController.clear();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _roleController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
