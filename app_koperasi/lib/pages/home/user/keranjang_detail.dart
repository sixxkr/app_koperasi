import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CartPage(),
    );
  }
}

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Daftar item keranjang
  List<CartItem> cartItems = [];

  // Menambah item ke keranjang
  void addItemToCart(String name, double price) {
    setState(() {
      cartItems.add(CartItem(name: name, price: price));
    });
  }

  // Menghapus item dari keranjang
  void removeItemFromCart(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = cartItems.fold(0, (sum, item) => sum + item.price);

    return Scaffold(
      appBar: AppBar(
        title: Text('Keranjang Belanja'),
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Text('Keranjang Anda kosong!'),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text('Rp ${item.price.toStringAsFixed(2)}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => removeItemFromCart(index),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total: Rp ${totalPrice.toStringAsFixed(2)}'),
                      ElevatedButton(
                        onPressed: () {
                          // Aksi untuk checkout atau lanjut ke pembayaran
                        },
                        child: Text('Checkout'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class CartItem {
  final String name;
  final double price;

  CartItem({required this.name, required this.price});
}
