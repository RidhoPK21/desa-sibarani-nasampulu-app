import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/network/api_client.dart';
import '../providers/admin_dashboard_provider.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  // State UI
  String _perangkatView = 'list';
  String _bannerView = 'list';

  // Form Controllers
  final _sambutanController = TextEditingController();
  final _visiController = TextEditingController();
  final _misiController = TextEditingController();

  final _pNamaController = TextEditingController();
  final _pJabatanController = TextEditingController();

  final _bNamaController = TextEditingController();
  final _bUrutanController = TextEditingController();
  bool _bShown = true;

  String? _selectedId;
  PlatformFile? _selectedFile;

  @override
  void initState() {
    super.initState();
    _loadInitialTextData(); // Tarik data lama dari server saat layar dibuka
  }

  @override
  void dispose() {
    _sambutanController.dispose();
    _visiController.dispose();
    _misiController.dispose();
    _pNamaController.dispose();
    _pJabatanController.dispose();
    _bNamaController.dispose();
    _bUrutanController.dispose();
    super.dispose();
  }

  // Taktik mengambil data Sambutan & Visi Misi yang sudah ada di database
  Future<void> _loadInitialTextData() async {
    try {
      final resSambutan = await api.get('/info/profil/kata-sambutan');
      if (resSambutan.data['data'] != null && resSambutan.data['data'].isNotEmpty) {
        setState(() => _sambutanController.text = resSambutan.data['data'][0]['kata'] ?? '');
      }

      final resVisiMisi = await api.get('/info/profil/visi-misi');
      if (resVisiMisi.data['data'] != null && resVisiMisi.data['data'].isNotEmpty) {
        setState(() {
          _visiController.text = resVisiMisi.data['data'][0]['visi'] ?? '';
          _misiController.text = resVisiMisi.data['data'][0]['misi'] ?? '';
        });
      }
    } catch (e) {
      debugPrint("Gagal load teks awal: $e");
    }
  }

  String _formatImg(String? url) {
    if (url == null) return '';
    if (url.startsWith('http') && !url.contains('localhost')) return url;
    String host = kIsWeb ? "localhost" : "10.0.2.2";
    return "http://$host:9000/${url.replaceFirst(RegExp(r'^/'), '')}";
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result != null) {
      setState(() => _selectedFile = result.files.first);
    }
  }

  // Fungsi Global untuk Hapus Data + Konfirmasi (MENGGUNAKAN dynamic)
  Future<void> _handleDeleteData(String endpoint, String id, dynamic provider, String itemType) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus $itemType?'),
        content: Text('Yakin ingin menghapus $itemType ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref.read(adminDashboardControllerProvider).deleteData(endpoint, id);
      if (mounted) {
        final err = ref.read(adminDashboardControllerProvider).errorMessage;
        if (err != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: Colors.red));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$itemType berhasil dihapus!'), backgroundColor: Colors.green));
          ref.refresh(provider);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pantau status loading dari controller
    final isLoading = ref.watch(adminDashboardControllerProvider).isLoading;

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text('Dashboard Admin', style: TextStyle(fontWeight: FontWeight.w900)),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF064E3B),
          elevation: 0,
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Color(0xFF064E3B),
            indicatorColor: Color(0xFF10B981),
            tabs: [
              Tab(icon: Icon(Icons.dashboard), text: "Ringkasan"),
              Tab(icon: Icon(Icons.description), text: "Sambutan"),
              Tab(icon: Icon(Icons.track_changes), text: "Visi Misi"),
              Tab(icon: Icon(Icons.people), text: "Perangkat"),
              Tab(icon: Icon(Icons.image), text: "Banner"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRingkasan(),
            _buildSambutan(isLoading),
            _buildVisiMisi(isLoading),
            _perangkatView == 'list' ? _buildTabPerangkatList() : _buildPerangkatForm(isLoading),
            _bannerView == 'list' ? _buildTabBannerList() : _buildBannerForm(isLoading),
          ],
        ),
      ),
    );
  }

  // --- TAB 1: RINGKASAN ---
  Widget _buildRingkasan() {
    final summary = ref.watch(adminSummaryProvider);
    return summary.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Gagal: $e')),
      data: (data) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _statTile("Total Penduduk", "${data['totalPenduduk']}", "Jiwa", Colors.teal), // <-- Diganti ke teal
          _statTile("Status IDM (${data['tahunIdm']})", "${data['statusIdm']}", "", Colors.blue),
          _statTile("Aparatur Desa", "${data['totalPerangkat']}", "Orang", Colors.orange),
        ],
      ),
    );
  }

  Widget _statTile(String title, String val, String unit, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(border: Border(left: BorderSide(color: color, width: 6)), borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(val, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color.withOpacity(0.8))),
            ]),
            if (unit.isNotEmpty) Text(unit, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black26)),
          ],
        ),
      ),
    );
  }

  // --- TAB 2: SAMBUTAN ---
  Widget _buildSambutan(bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text("Edit Kata Sambutan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        TextField(controller: _sambutanController, maxLines: 8, decoration: const InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder())),
        const SizedBox(height: 20),

        ElevatedButton.icon(
          onPressed: isLoading ? null : () async {
            await ref.read(adminDashboardControllerProvider).updateTextData(
                '/info/profil/kata-sambutan',
                {"kata": _sambutanController.text},
                _selectedId
            );

            if (mounted) {
              final err = ref.read(adminDashboardControllerProvider).errorMessage;
              if (err != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: Colors.red));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kata Sambutan Berhasil Disimpan!'), backgroundColor: Colors.green));
              }
            }
          },
          icon: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.check_circle),
          label: const Text("Simpan Sambutan"),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
        )
      ]),
    );
  }

  // --- TAB 3: VISI MISI ---
  Widget _buildVisiMisi(bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text("Visi Desa", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(controller: _visiController, maxLines: 2, decoration: const InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder())),
        const SizedBox(height: 20),
        const Text("Misi Desa", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(controller: _misiController, maxLines: 5, decoration: const InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder())),
        const SizedBox(height: 24),

        ElevatedButton.icon(
          onPressed: isLoading ? null : () async {
            await ref.read(adminDashboardControllerProvider).updateTextData(
                '/info/profil/visi-misi',
                {"visi": _visiController.text, "misi": _misiController.text},
                _selectedId
            );

            if (mounted) {
              final err = ref.read(adminDashboardControllerProvider).errorMessage;
              if (err != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: Colors.red));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Visi & Misi Berhasil Disimpan!'), backgroundColor: Colors.green));
              }
            }
          },
          icon: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.check_circle),
          label: const Text("Simpan Visi & Misi"),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
        )
      ]),
    );
  }

  // --- TAB 4: PERANGKAT ---
  Widget _buildTabPerangkatList() {
    final list = ref.watch(adminPerangkatProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF10B981),
        onPressed: () => setState(() { _perangkatView = 'form'; _selectedId = null; _pNamaController.clear(); _pJabatanController.clear(); _selectedFile = null; }),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Tambah Aparatur", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: list.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (items) {
          if (items.isEmpty) return const Center(child: Text('Belum ada Aparatur Desa.'));
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.8, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: Column(children: [
                  Expanded(child: Image.network(_formatImg(item['foto_url']), fit: BoxFit.cover, width: double.infinity, errorBuilder: (_,__,___) => const Icon(Icons.person, size: 50, color: Colors.grey))),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(item['nama'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1),
                  ),
                  Text(item['jabatan'] ?? '-', style: const TextStyle(fontSize: 12, color: Colors.teal), maxLines: 1),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    IconButton(icon: const Icon(Icons.edit, size: 18, color: Colors.blue), onPressed: () => setState(() { _perangkatView = 'form'; _selectedId = item['id'].toString(); _pNamaController.text = item['nama'] ?? ''; _pJabatanController.text = item['jabatan'] ?? ''; _selectedFile = null; })),
                    IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: () => _handleDeleteData('/info/profil/perangkat-desa', item['id'].toString(), adminPerangkatProvider, 'Aparatur Desa')),
                  ]),
                ]),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPerangkatForm(bool isLoading) {
    return ListView(padding: const EdgeInsets.all(24), children: [
      Text(_selectedId == null ? "Tambah Aparatur" : "Edit Aparatur", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 20),

      InkWell(
        onTap: _pickImage,
        child: Container(
          height: 150,
          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
          child: _selectedFile != null
              ? ClipRRect(borderRadius: BorderRadius.circular(12), child: kIsWeb ? Image.memory(_selectedFile!.bytes!, fit: BoxFit.cover) : const Center(child: Text("Foto terpilih")))
              : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.upload, size: 40, color: Colors.grey), Text('Upload Foto Baru')]),
        ),
      ),
      const SizedBox(height: 16),

      TextField(controller: _pNamaController, decoration: const InputDecoration(labelText: "Nama Lengkap", filled: true)),
      const SizedBox(height: 16),
      TextField(controller: _pJabatanController, decoration: const InputDecoration(labelText: "Jabatan", filled: true)),
      const SizedBox(height: 24),

      ElevatedButton.icon(
        onPressed: isLoading ? null : () async {
          if (_pNamaController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama wajib diisi!')));
            return;
          }
          await ref.read(adminDashboardControllerProvider).saveMultipart(endpoint: '/info/profil/perangkat-desa', fields: {"nama": _pNamaController.text, "jabatan": _pJabatanController.text}, id: _selectedId, file: _selectedFile);

          if (mounted) {
            final err = ref.read(adminDashboardControllerProvider).errorMessage;
            if (err != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: Colors.red));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aparatur Berhasil Disimpan!'), backgroundColor: Colors.green));
              setState(() => _perangkatView = 'list');
              ref.refresh(adminPerangkatProvider);
            }
          }
        },
        icon: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.check),
        label: const Text("Simpan Aparatur"),
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
      ),
      const SizedBox(height: 12),
      TextButton(onPressed: () => setState(() => _perangkatView = 'list'), child: const Text("Batal"))
    ]);
  }

  // --- TAB 5: BANNER ---
  Widget _buildTabBannerList() {
    final list = ref.watch(adminBannerProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF10B981),
        onPressed: () => setState(() { _bannerView = 'form'; _selectedId = null; _bNamaController.clear(); _bUrutanController.clear(); _selectedFile = null; _bShown = true; }),
        icon: const Icon(Icons.add_photo_alternate, color: Colors.white),
        label: const Text("Tambah Banner", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: list.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (items) {
            if (items.isEmpty) return const Center(child: Text('Belum ada Banner.'));
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];
                return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.network(_formatImg(item['gambar_url']), width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.image))),
                      title: Text(item['nama_banner'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Urutan: ${item['urutan']} | Tampil: ${item['shown'] == 1 || item['shown'] == true ? 'Ya' : 'Tidak'}", style: const TextStyle(fontSize: 12)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => setState(() { _bannerView = 'form'; _selectedId = item['id'].toString(); _bNamaController.text = item['nama_banner'] ?? ''; _bUrutanController.text = item['urutan']?.toString() ?? ''; _bShown = item['shown'] == 1 || item['shown'] == true; _selectedFile = null; })),
                          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _handleDeleteData('/content/banner', item['id'].toString(), adminBannerProvider, 'Banner')),
                        ],
                      ),
                    )
                );
              },
            );
          }
      ),
    );
  }

  Widget _buildBannerForm(bool isLoading) {
    return ListView(padding: const EdgeInsets.all(24), children: [
      Text(_selectedId == null ? "Tambah Banner Baru" : "Edit Banner", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 20),

      InkWell(
        onTap: _pickImage,
        child: Container(
          height: 180,
          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
          child: _selectedFile != null
              ? ClipRRect(borderRadius: BorderRadius.circular(12), child: kIsWeb ? Image.memory(_selectedFile!.bytes!, fit: BoxFit.cover) : const Center(child: Text("Foto terpilih")))
              : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.upload, size: 40, color: Colors.grey), Text('Upload Banner (Horizontal)')]),
        ),
      ),
      const SizedBox(height: 16),

      TextField(controller: _bNamaController, decoration: const InputDecoration(labelText: "Nama Banner", filled: true)),
      const SizedBox(height: 16),
      TextField(controller: _bUrutanController, decoration: const InputDecoration(labelText: "Urutan Tampil (Misal: 1)", filled: true), keyboardType: TextInputType.number),
      const SizedBox(height: 16),
      SwitchListTile(title: const Text("Tampilkan di Web", style: TextStyle(fontWeight: FontWeight.bold)), value: _bShown, activeColor: Colors.teal, onChanged: (v) => setState(() => _bShown = v)),
      const SizedBox(height: 24),

      ElevatedButton.icon(
        onPressed: isLoading ? null : () async {
          if (_bNamaController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama Banner wajib diisi!')));
            return;
          }
          await ref.read(adminDashboardControllerProvider).saveMultipart(endpoint: '/content/banner', fields: {"nama_banner": _bNamaController.text, "urutan": _bUrutanController.text, "shown": _bShown ? 1 : 0}, id: _selectedId, file: _selectedFile, fileKey: 'gambar_banner');

          if (mounted) {
            final err = ref.read(adminDashboardControllerProvider).errorMessage;
            if (err != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: Colors.red));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Banner Berhasil Disimpan!'), backgroundColor: Colors.green));
              setState(() => _bannerView = 'list');
              ref.refresh(adminBannerProvider);
            }
          }
        },
        icon: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.check),
        label: const Text("Simpan Banner"),
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
      ),
      const SizedBox(height: 12),
      TextButton(onPressed: () => setState(() => _bannerView = 'list'), child: const Text("Batal"))
    ]);
  }
}