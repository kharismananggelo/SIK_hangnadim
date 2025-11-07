import 'package:flutter/material.dart';

class RolePage extends StatefulWidget {
  const RolePage({super.key});

  @override
  State<RolePage> createState() => _RolePageState();
}

class _RolePageState extends State<RolePage> {
  final List<Map<String, dynamic>> _roles = []; // Tabel kosong
  List<Map<String, dynamic>> _filteredRoles = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  int? _editingIndex;
  int _entriesPerPage = 10;
  final List<int> _entriesOptions = [10, 25, 50, 100];

  // data untuk hak akses
  final Map<String, List<String>> _hakAksesOptions = {
    'APPROVAL': ['Delete', 'Edit', 'View'],
    'APPROVER': ['Create', 'Delete', 'Edit', 'View'],
    'COPY': ['Create', 'Delete', 'Edit', 'View'],
    'DASHBOARD': ['Edit', 'View'],
    'LETTER FUNDAMENTAL': ['Create', 'Delete', 'Edit', 'View'],
    'MENU ACCES': ['Application', 'Management'],
    'PERMISSION': ['Create', 'Delete', 'Edit', 'View'],
    'ROLE': ['Create', 'Delete', 'Edit', 'View'],
    'USER': ['Create', 'Delete', 'Edit', 'View'],
    'VENDOR': ['Create', 'Edit', 'View'],
    'WORK LOCATION': ['Create', 'Delete', 'Edit', 'View'],
    'WORK PERMIT LETTER': [
      'Completion',
      'Create',
      'Delete',
      'Edit',
      'Export-exel',
      'Export-pdf',
      'View',
    ],
    'WORK TYPE': ['Create', 'Delete', 'Edit', 'View'],
  };

  @override
  void initState() {
    super.initState();
    _filteredRoles = _roles;
    _searchController.addListener(_filterData);
  }

  void _filterData() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredRoles = _roles;
      } else {
        _filteredRoles = _roles.where((role) {
          final name = role['name']!.toLowerCase();
          final hakAkses = role['hakAkses']!.toLowerCase();
          return name.contains(query) || hakAkses.contains(query);
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
          'Role',
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
          // header pencarian
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
                        hintText: 'Cari Nama atau Hak Akses...',
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
                            child: Text('$value Entri perhalaman'),
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

          // table header
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
                  flex: 5,
                  child: Text(
                    'HAK AKSES',
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
            child: _filteredRoles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_ind,
                          size: 64,
                          color: Colors.grey[300],
                        ),
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
                      final role = _getPaginatedData()[index];
                      final actualIndex = _filteredRoles.indexOf(role);
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
                                role['name']!,
                                style: TextStyle(color: Colors.grey[700]),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Text(
                                role['hakAkses']!,
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

          // pagination Info
          if (_filteredRoles.isNotEmpty)
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Menampilkan ${_getPaginatedData().length} dari ${_filteredRoles.length} data',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  if (_filteredRoles.length > _entriesPerPage)
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios, size: 16),
                          onPressed: () {},
                        ),
                        Text(
                          '1 of ${(_filteredRoles.length / _entriesPerPage).ceil()}',
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
          _showTambahRoleDialog(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }

  List<Map<String, dynamic>> _getPaginatedData() {
    final startIndex = 0;
    final endIndex = startIndex + _entriesPerPage;
    return _filteredRoles.sublist(
      0,
      endIndex > _filteredRoles.length ? _filteredRoles.length : endIndex,
    );
  }

  List<int> _calculateDynamicEntriesOptions() {
    final totalItems = _filteredRoles.length;
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

  void _showTambahRoleDialog(BuildContext context) {
    _nameController.clear();
    _editingIndex = null;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoleFormPage(
          nameController: _nameController,
          hakAksesOptions: _hakAksesOptions,
          isEditing: false,
          onSave: (name, hakAksesMap) {
            _tambahRole(name, hakAksesMap);
          },
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, int index) {
    final role = _roles[index];
    _nameController.text = role['name']!;
    _editingIndex = index;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoleFormPage(
          nameController: _nameController,
          hakAksesOptions: _hakAksesOptions,
          initialHakAkses: role['hakAksesMap'],
          isEditing: true,
          onSave: (name, hakAksesMap) {
            _editRole(name, hakAksesMap);
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hapus Role'),
          content: Text(
            'Apakah Anda yakin ingin menghapus role "${_roles[index]['name']}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                _hapusRole(index);
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

  void _tambahRole(String name, Map<String, Map<String, bool>> hakAksesMap) {
    final hakAksesString = _convertHakAksesToString(hakAksesMap);

    setState(() {
      _roles.add({
        'name': name,
        'hakAkses': hakAksesString,
        'hakAksesMap': hakAksesMap,
      });
      _filterData();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Role berhasil ditambahkan!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _editRole(String name, Map<String, Map<String, bool>> hakAksesMap) {
    if (_editingIndex != null) {
      final hakAksesString = _convertHakAksesToString(hakAksesMap);

      setState(() {
        _roles[_editingIndex!] = {
          'name': name,
          'hakAkses': hakAksesString,
          'hakAksesMap': hakAksesMap,
        };
        _filterData();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Role berhasil diubah!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _hapusRole(int index) {
    setState(() {
      _roles.removeAt(index);
      _filterData();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Role berhasil dihapus!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _convertHakAksesToString(Map<String, Map<String, bool>> hakAksesMap) {
    List<String> selectedHakAkses = [];

    hakAksesMap.forEach((category, actions) {
      actions.forEach((action, isSelected) {
        if (isSelected) {
          selectedHakAkses.add('$category $action');
        }
      });
    });

    return selectedHakAkses.join(', ');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

// halaman form role
class RoleFormPage extends StatefulWidget {
  final TextEditingController nameController;
  final Map<String, List<String>> hakAksesOptions;
  final Map<String, Map<String, bool>>? initialHakAkses;
  final bool isEditing;
  final Function(String, Map<String, Map<String, bool>>) onSave;

  const RoleFormPage({
    Key? key,
    required this.nameController,
    required this.hakAksesOptions,
    this.initialHakAkses,
    required this.isEditing,
    required this.onSave,
  }) : super(key: key);

  @override
  State<RoleFormPage> createState() => _RoleFormPageState();
}

class _RoleFormPageState extends State<RoleFormPage> {
  late TextEditingController _nameController;
  bool _selectAll = false;
  Map<String, Map<String, bool>> _selectedHakAkses = {};
  Map<String, bool> _expandedCategories = {};

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.nameController.text);

    // inisialisasi hak akses
    widget.hakAksesOptions.forEach((category, _) {
      _expandedCategories[category] = false;
    });

    if (widget.initialHakAkses != null) {
      _selectedHakAkses = _deepCopyHakAkses(widget.initialHakAkses!);
      _updateSelectAllStatus();
    } else {
      widget.hakAksesOptions.forEach((key, actions) {
        _selectedHakAkses[key] = {for (var act in actions) act: false};
      });
    }
  }

  Map<String, Map<String, bool>> _deepCopyHakAkses(
    Map<String, Map<String, bool>> original,
  ) {
    final copy = <String, Map<String, bool>>{};
    original.forEach((key, value) {
      copy[key] = Map<String, bool>.from(value);
    });
    return copy;
  }

  void _updateSelectAllStatus() {
    setState(() {
      _selectAll = _selectedHakAkses.values.every(
        (categoryActions) => categoryActions.values.every((v) => v == true),
      );
    });
  }

  void _toggleSelectAll(bool value) {
    setState(() {
      _selectAll = value;
      _selectedHakAkses.forEach((category, actions) {
        actions.forEach((action, _) {
          _selectedHakAkses[category]![action] = value;
        });
      });
    });
  }

  void _toggleCategoryExpansion(String category) {
    setState(() {
      _expandedCategories[category] = !_expandedCategories[category]!;
    });
  }

  void _submitForm() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nama Role harus diisi!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    widget.onSave(_nameController.text, _selectedHakAkses);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Role' : 'Tambah Role',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue[900],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.blue[900]),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: _submitForm,
            child: Text(
              'Submit',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // nama section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NAMA ROLE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Masukkan nama role',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // hak akses section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HAK AKSES',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    SizedBox(height: 16),

                    //centang smua
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Row(
                        children: [
                          Switch(
                            value: _selectAll,
                            onChanged: _toggleSelectAll,
                            activeColor: Colors.green,
                            activeTrackColor: Colors.green[100],
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Centang Semua Hak Akses',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),
                    // expansion untuk setiap kategori
                    ...widget.hakAksesOptions.entries.map((entry) {
                      final category = entry.key;
                      final actions = entry.value;
                      final isExpanded = _expandedCategories[category] ?? false;

                      return Container(
                        margin: EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ExpansionTile(
                          key: Key(category),
                          initiallyExpanded: isExpanded,
                          onExpansionChanged: (expanded) {
                            _toggleCategoryExpansion(category);
                          },
                          leading: Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: Colors.blue[700],
                          ),
                          title: Text(
                            category,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          trailing: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_getSelectedCount(category)}/${actions.length}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Column(
                                children: actions.map((action) {
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 8),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ListTile(
                                        dense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        leading: Switch(
                                          value:
                                              _selectedHakAkses[category]![action] ??
                                              false,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedHakAkses[category]![action] =
                                                  value;
                                              _updateSelectAllStatus();
                                            });
                                          },
                                          activeColor: Colors.blue,
                                          activeTrackColor: Colors.blue[100],
                                        ),
                                        title: Text(
                                          action,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        trailing:
                                            _selectedHakAkses[category]![action] ??
                                                false
                                            ? Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                                size: 20,
                                              )
                                            : Icon(
                                                Icons.radio_button_unchecked,
                                                color: Colors.grey[400],
                                                size: 20,
                                              ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // summary
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${_getTotalSelected()} hak akses dipilih dari ${_getTotalAvailable()} total hak akses',
                      style: TextStyle(fontSize: 14, color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getSelectedCount(String category) {
    final actions = _selectedHakAkses[category] ?? {};
    return actions.values.where((isSelected) => isSelected).length;
  }

  int _getTotalSelected() {
    int total = 0;
    _selectedHakAkses.forEach((category, actions) {
      total += actions.values.where((isSelected) => isSelected).length;
    });
    return total;
  }

  int _getTotalAvailable() {
    int total = 0;
    widget.hakAksesOptions.forEach((category, actions) {
      total += actions.length;
    });
    return total;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
