class MenuModel {
  final String id;
  final String nama;
  final int harga;
  final String jenis;
  final String kategori;
  final String imageUrl;
  final String status;
  final String description;
  final String rating;
  final bool isPopuler;

  MenuModel({
    required this.id,
    required this.nama,
    required this.harga,
    required this.jenis,
    required this.kategori,
    required this.imageUrl,
    required this.status,
    required this.description,
    required this.rating,
    required this.isPopuler,
  });

  factory MenuModel.fromFirestore(String id, Map<String, dynamic> data) {
    return MenuModel(
      id: id,
      nama: data['nama'] ?? '',
      harga: data['harga'] ?? 0,
      jenis: data['jenis'] ?? '',
      kategori: data['kategori'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      status: data['status'] ?? '',
      description: data['description'] ?? '',
      rating: data['rating'] ?? '',
      isPopuler: data['isPopuler'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'jenis': jenis,
      'kategori': kategori,
      'harga': harga,
      'imageUrl': imageUrl,
      'status': status,
      'description': description,
      'rating': rating,
      'isPopuler': isPopuler,
    };
  }
}
