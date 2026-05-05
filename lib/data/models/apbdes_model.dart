class ApbdesModel {
  final int? id;
  final String namaDesa;
  final int tahun;
  final int? versi;
  final bool? isAktif;
  final String? alasanPerubahan;

  // Pendapatan
  final double pendapatanAsliDesa;
  final double danaDesa;
  final double alokasiDanaDesa;
  final double bagiHasilPajakRetribusi;
  final double lainLainPendapatanSah;

  // Bidang 1 - Pemerintahan
  final double siltapKepalaDesa;
  final double siltapPerangkatDesa;
  final double jaminanSosialAparatur;
  final double operasionalPemerintahanDesa;
  final double tunjanganBpd;
  final double operasionalBpd;
  final double operasionalDanaDesa;
  final double saranaPrasaranaKantor;
  final double pengisianMutasiPerangkat;

  // Bidang 2 - Pembangunan
  final double penyuluhanPendidikan;
  final double saranaPrasaranaPendidikan;
  final double saranaPrasaranaPerpustakaan;
  final double pengelolaanPerpustakaan;
  final double penyelenggaraanPosyandu;
  final double penyuluhanKesehatan;
  final double pemeliharaanJalanLingkungan;
  final double pembangunanJalanDesa;
  final double pembangunanJalanUsahaTani;
  final double dokumenTataRuang;
  final double taludIrigasi;
  final double sanitasiPemukiman;
  final double fasilitasPengelolaanSampah;
  final double jaringanInternetDesa;

  // Bidang 3, 4, 5
  final double pembinaanPkk;
  final double pelatihanPertanianPeternakan;
  final double pelatihanAparaturDesa;
  final double penyusunanRencanaProgram;
  final double insentifKaderPembangunan;
  final double insentifKaderKesehatanPaud;
  final double penanggulanganBencana;
  final double keadaanMendesak;

  // Pembiayaan
  final double silpaTahunSebelumnya;
  final double penyertaanModalDesa;

  // Computed
  final double? totalPendapatan;
  final double? totalBelanja;

  ApbdesModel({
    this.id,
    this.namaDesa = 'Desa Sibarani Nasampulu',
    required this.tahun,
    this.versi,
    this.isAktif,
    this.alasanPerubahan,
    this.pendapatanAsliDesa = 0,
    this.danaDesa = 0,
    this.alokasiDanaDesa = 0,
    this.bagiHasilPajakRetribusi = 0,
    this.lainLainPendapatanSah = 0,
    this.siltapKepalaDesa = 0,
    this.siltapPerangkatDesa = 0,
    this.jaminanSosialAparatur = 0,
    this.operasionalPemerintahanDesa = 0,
    this.tunjanganBpd = 0,
    this.operasionalBpd = 0,
    this.operasionalDanaDesa = 0,
    this.saranaPrasaranaKantor = 0,
    this.pengisianMutasiPerangkat = 0,
    this.penyuluhanPendidikan = 0,
    this.saranaPrasaranaPendidikan = 0,
    this.saranaPrasaranaPerpustakaan = 0,
    this.pengelolaanPerpustakaan = 0,
    this.penyelenggaraanPosyandu = 0,
    this.penyuluhanKesehatan = 0,
    this.pemeliharaanJalanLingkungan = 0,
    this.pembangunanJalanDesa = 0,
    this.pembangunanJalanUsahaTani = 0,
    this.dokumenTataRuang = 0,
    this.taludIrigasi = 0,
    this.sanitasiPemukiman = 0,
    this.fasilitasPengelolaanSampah = 0,
    this.jaringanInternetDesa = 0,
    this.pembinaanPkk = 0,
    this.pelatihanPertanianPeternakan = 0,
    this.pelatihanAparaturDesa = 0,
    this.penyusunanRencanaProgram = 0,
    this.insentifKaderPembangunan = 0,
    this.insentifKaderKesehatanPaud = 0,
    this.penanggulanganBencana = 0,
    this.keadaanMendesak = 0,
    this.silpaTahunSebelumnya = 0,
    this.penyertaanModalDesa = 0,
    this.totalPendapatan,
    this.totalBelanja,
  });

  double get pembiayaanNetto => silpaTahunSebelumnya - penyertaanModalDesa;
  double get surplusDefisit =>
      (totalPendapatan ?? 0) - (totalBelanja ?? 0);

  factory ApbdesModel.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) =>
        v == null ? 0.0 : double.tryParse(v.toString()) ?? 0.0;

    return ApbdesModel(
      id: json['id'],
      namaDesa: json['nama_desa'] ?? 'Desa Sibarani Nasampulu',
      tahun: json['tahun'] ?? DateTime.now().year,
      versi: json['versi'],
      isAktif: json['is_aktif'] == true || json['is_aktif'] == 1,
      alasanPerubahan: json['alasan_perubahan'],
      pendapatanAsliDesa: toDouble(json['pendapatan_asli_desa']),
      danaDesa: toDouble(json['dana_desa']),
      alokasiDanaDesa: toDouble(json['alokasi_dana_desa']),
      bagiHasilPajakRetribusi: toDouble(json['bagi_hasil_pajak_retribusi']),
      lainLainPendapatanSah: toDouble(json['lain_lain_pendapatan_sah']),
      siltapKepalaDesa: toDouble(json['siltap_kepala_desa']),
      siltapPerangkatDesa: toDouble(json['siltap_perangkat_desa']),
      jaminanSosialAparatur: toDouble(json['jaminan_sosial_aparatur']),
      operasionalPemerintahanDesa:
          toDouble(json['operasional_pemerintahan_desa']),
      tunjanganBpd: toDouble(json['tunjangan_bpd']),
      operasionalBpd: toDouble(json['operasional_bpd']),
      operasionalDanaDesa: toDouble(json['operasional_dana_desa']),
      saranaPrasaranaKantor: toDouble(json['sarana_prasarana_kantor']),
      pengisianMutasiPerangkat: toDouble(json['pengisian_mutasi_perangkat']),
      penyuluhanPendidikan: toDouble(json['penyuluhan_pendidikan']),
      saranaPrasaranaPendidikan: toDouble(json['sarana_prasarana_pendidikan']),
      saranaPrasaranaPerpustakaan:
          toDouble(json['sarana_prasarana_perpustakaan']),
      pengelolaanPerpustakaan: toDouble(json['pengelolaan_perpustakaan']),
      penyelenggaraanPosyandu: toDouble(json['penyelenggaraan_posyandu']),
      penyuluhanKesehatan: toDouble(json['penyuluhan_kesehatan']),
      pemeliharaanJalanLingkungan:
          toDouble(json['pemeliharaan_jalan_lingkungan']),
      pembangunanJalanDesa: toDouble(json['pembangunan_jalan_desa']),
      pembangunanJalanUsahaTani: toDouble(json['pembangunan_jalan_usaha_tani']),
      dokumenTataRuang: toDouble(json['dokumen_tata_ruang']),
      taludIrigasi: toDouble(json['talud_irigasi']),
      sanitasiPemukiman: toDouble(json['sanitasi_pemukiman']),
      fasilitasPengelolaanSampah:
          toDouble(json['fasilitas_pengelolaan_sampah']),
      jaringanInternetDesa: toDouble(json['jaringan_internet_desa']),
      pembinaanPkk: toDouble(json['pembinaan_pkk']),
      pelatihanPertanianPeternakan:
          toDouble(json['pelatihan_pertanian_peternakan']),
      pelatihanAparaturDesa: toDouble(json['pelatihan_aparatur_desa']),
      penyusunanRencanaProgram: toDouble(json['penyusunan_rencana_program']),
      insentifKaderPembangunan: toDouble(json['insentif_kader_pembangunan']),
      insentifKaderKesehatanPaud:
          toDouble(json['insentif_kader_kesehatan_paud']),
      penanggulanganBencana: toDouble(json['penanggulangan_bencana']),
      keadaanMendesak: toDouble(json['keadaan_mendesak']),
      silpaTahunSebelumnya: toDouble(json['silpa_tahun_sebelumnya']),
      penyertaanModalDesa: toDouble(json['penyertaan_modal_desa']),
      totalPendapatan: toDouble(json['total_pendapatan']),
      totalBelanja: toDouble(json['total_belanja']),
    );
  }

  Map<String, dynamic> toJson() => {
        'nama_desa': namaDesa,
        'tahun': tahun,
        if (alasanPerubahan != null) 'alasan_perubahan': alasanPerubahan,
        'pendapatan_asli_desa': pendapatanAsliDesa,
        'dana_desa': danaDesa,
        'alokasi_dana_desa': alokasiDanaDesa,
        'bagi_hasil_pajak_retribusi': bagiHasilPajakRetribusi,
        'lain_lain_pendapatan_sah': lainLainPendapatanSah,
        'siltap_kepala_desa': siltapKepalaDesa,
        'siltap_perangkat_desa': siltapPerangkatDesa,
        'jaminan_sosial_aparatur': jaminanSosialAparatur,
        'operasional_pemerintahan_desa': operasionalPemerintahanDesa,
        'tunjangan_bpd': tunjanganBpd,
        'operasional_bpd': operasionalBpd,
        'operasional_dana_desa': operasionalDanaDesa,
        'sarana_prasarana_kantor': saranaPrasaranaKantor,
        'pengisian_mutasi_perangkat': pengisianMutasiPerangkat,
        'penyuluhan_pendidikan': penyuluhanPendidikan,
        'sarana_prasarana_pendidikan': saranaPrasaranaPendidikan,
        'sarana_prasarana_perpustakaan': saranaPrasaranaPerpustakaan,
        'pengelolaan_perpustakaan': pengelolaanPerpustakaan,
        'penyelenggaraan_posyandu': penyelenggaraanPosyandu,
        'penyuluhan_kesehatan': penyuluhanKesehatan,
        'pemeliharaan_jalan_lingkungan': pemeliharaanJalanLingkungan,
        'pembangunan_jalan_desa': pembangunanJalanDesa,
        'pembangunan_jalan_usaha_tani': pembangunanJalanUsahaTani,
        'dokumen_tata_ruang': dokumenTataRuang,
        'talud_irigasi': taludIrigasi,
        'sanitasi_pemukiman': sanitasiPemukiman,
        'fasilitas_pengelolaan_sampah': fasilitasPengelolaanSampah,
        'jaringan_internet_desa': jaringanInternetDesa,
        'pembinaan_pkk': pembinaanPkk,
        'pelatihan_pertanian_peternakan': pelatihanPertanianPeternakan,
        'pelatihan_aparatur_desa': pelatihanAparaturDesa,
        'penyusunan_rencana_program': penyusunanRencanaProgram,
        'insentif_kader_pembangunan': insentifKaderPembangunan,
        'insentif_kader_kesehatan_paud': insentifKaderKesehatanPaud,
        'penanggulangan_bencana': penanggulanganBencana,
        'keadaan_mendesak': keadaanMendesak,
        'silpa_tahun_sebelumnya': silpaTahunSebelumnya,
        'penyertaan_modal_desa': penyertaanModalDesa,
      };

  ApbdesModel copyWith({
    int? id,
    String? namaDesa,
    int? tahun,
    int? versi,
    bool? isAktif,
    String? alasanPerubahan,
    double? pendapatanAsliDesa,
    double? danaDesa,
    double? alokasiDanaDesa,
    double? bagiHasilPajakRetribusi,
    double? lainLainPendapatanSah,
    double? siltapKepalaDesa,
    double? siltapPerangkatDesa,
    double? jaminanSosialAparatur,
    double? operasionalPemerintahanDesa,
    double? tunjanganBpd,
    double? operasionalBpd,
    double? operasionalDanaDesa,
    double? saranaPrasaranaKantor,
    double? pengisianMutasiPerangkat,
    double? penyuluhanPendidikan,
    double? saranaPrasaranaPendidikan,
    double? saranaPrasaranaPerpustakaan,
    double? pengelolaanPerpustakaan,
    double? penyelenggaraanPosyandu,
    double? penyuluhanKesehatan,
    double? pemeliharaanJalanLingkungan,
    double? pembangunanJalanDesa,
    double? pembangunanJalanUsahaTani,
    double? dokumenTataRuang,
    double? taludIrigasi,
    double? sanitasiPemukiman,
    double? fasilitasPengelolaanSampah,
    double? jaringanInternetDesa,
    double? pembinaanPkk,
    double? pelatihanPertanianPeternakan,
    double? pelatihanAparaturDesa,
    double? penyusunanRencanaProgram,
    double? insentifKaderPembangunan,
    double? insentifKaderKesehatanPaud,
    double? penanggulanganBencana,
    double? keadaanMendesak,
    double? silpaTahunSebelumnya,
    double? penyertaanModalDesa,
    double? totalPendapatan,
    double? totalBelanja,
  }) =>
      ApbdesModel(
        id: id ?? this.id,
        namaDesa: namaDesa ?? this.namaDesa,
        tahun: tahun ?? this.tahun,
        versi: versi ?? this.versi,
        isAktif: isAktif ?? this.isAktif,
        alasanPerubahan: alasanPerubahan ?? this.alasanPerubahan,
        pendapatanAsliDesa: pendapatanAsliDesa ?? this.pendapatanAsliDesa,
        danaDesa: danaDesa ?? this.danaDesa,
        alokasiDanaDesa: alokasiDanaDesa ?? this.alokasiDanaDesa,
        bagiHasilPajakRetribusi:
            bagiHasilPajakRetribusi ?? this.bagiHasilPajakRetribusi,
        lainLainPendapatanSah:
            lainLainPendapatanSah ?? this.lainLainPendapatanSah,
        siltapKepalaDesa: siltapKepalaDesa ?? this.siltapKepalaDesa,
        siltapPerangkatDesa: siltapPerangkatDesa ?? this.siltapPerangkatDesa,
        jaminanSosialAparatur:
            jaminanSosialAparatur ?? this.jaminanSosialAparatur,
        operasionalPemerintahanDesa:
            operasionalPemerintahanDesa ?? this.operasionalPemerintahanDesa,
        tunjanganBpd: tunjanganBpd ?? this.tunjanganBpd,
        operasionalBpd: operasionalBpd ?? this.operasionalBpd,
        operasionalDanaDesa: operasionalDanaDesa ?? this.operasionalDanaDesa,
        saranaPrasaranaKantor:
            saranaPrasaranaKantor ?? this.saranaPrasaranaKantor,
        pengisianMutasiPerangkat:
            pengisianMutasiPerangkat ?? this.pengisianMutasiPerangkat,
        penyuluhanPendidikan: penyuluhanPendidikan ?? this.penyuluhanPendidikan,
        saranaPrasaranaPendidikan:
            saranaPrasaranaPendidikan ?? this.saranaPrasaranaPendidikan,
        saranaPrasaranaPerpustakaan:
            saranaPrasaranaPerpustakaan ?? this.saranaPrasaranaPerpustakaan,
        pengelolaanPerpustakaan:
            pengelolaanPerpustakaan ?? this.pengelolaanPerpustakaan,
        penyelenggaraanPosyandu:
            penyelenggaraanPosyandu ?? this.penyelenggaraanPosyandu,
        penyuluhanKesehatan: penyuluhanKesehatan ?? this.penyuluhanKesehatan,
        pemeliharaanJalanLingkungan:
            pemeliharaanJalanLingkungan ?? this.pemeliharaanJalanLingkungan,
        pembangunanJalanDesa: pembangunanJalanDesa ?? this.pembangunanJalanDesa,
        pembangunanJalanUsahaTani:
            pembangunanJalanUsahaTani ?? this.pembangunanJalanUsahaTani,
        dokumenTataRuang: dokumenTataRuang ?? this.dokumenTataRuang,
        taludIrigasi: taludIrigasi ?? this.taludIrigasi,
        sanitasiPemukiman: sanitasiPemukiman ?? this.sanitasiPemukiman,
        fasilitasPengelolaanSampah:
            fasilitasPengelolaanSampah ?? this.fasilitasPengelolaanSampah,
        jaringanInternetDesa: jaringanInternetDesa ?? this.jaringanInternetDesa,
        pembinaanPkk: pembinaanPkk ?? this.pembinaanPkk,
        pelatihanPertanianPeternakan:
            pelatihanPertanianPeternakan ?? this.pelatihanPertanianPeternakan,
        pelatihanAparaturDesa:
            pelatihanAparaturDesa ?? this.pelatihanAparaturDesa,
        penyusunanRencanaProgram:
            penyusunanRencanaProgram ?? this.penyusunanRencanaProgram,
        insentifKaderPembangunan:
            insentifKaderPembangunan ?? this.insentifKaderPembangunan,
        insentifKaderKesehatanPaud:
            insentifKaderKesehatanPaud ?? this.insentifKaderKesehatanPaud,
        penanggulanganBencana:
            penanggulanganBencana ?? this.penanggulanganBencana,
        keadaanMendesak: keadaanMendesak ?? this.keadaanMendesak,
        silpaTahunSebelumnya: silpaTahunSebelumnya ?? this.silpaTahunSebelumnya,
        penyertaanModalDesa: penyertaanModalDesa ?? this.penyertaanModalDesa,
        totalPendapatan: totalPendapatan ?? this.totalPendapatan,
        totalBelanja: totalBelanja ?? this.totalBelanja,
      );
}
