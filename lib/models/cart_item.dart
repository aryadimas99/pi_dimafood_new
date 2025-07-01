class CartItem {
  final String id;
  final String title;
  final String image;
  final String price;
  final String size;
  final String notes;
  int quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
    required this.size,
    required this.notes,
    this.quantity = 1,
  });
}
