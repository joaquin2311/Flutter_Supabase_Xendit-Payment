import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

const supabaseUrl = 'https://ywxqcmkjmuoiavzlfcwq.supabase.co';
const supabaseAnonKey = 'sb_publishable_BYvXHvE175mfrCAt6HJitQ_9dtoVCh5';

SupabaseClient get supabase => Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  runApp(const ShopApp());
}

class Product {
  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.imageUrl,
  });

  final int id;
  final String title;
  final double price;
  final String description;
  final String imageUrl;
}

const List<Product> products = [
  Product(
    id: 1,
    title: 'POWERBANK',
    price: 1500,
    description: 'A power bank is a portable, external rechargeable battery that stores electrical energy to charge electronic devices like smartphones, tablets, and laptops when a wall outlet is not available.',
    imageUrl: 'https://wsrv.nl/?url=www.belkin.com/dw/image/v2/BGBH_PRD/on/demandware.static/-/Sites-master-product-catalog-blk/default/dw8fa7cdd9/images/hi-res/5/181bff24182357d0_BPB039hqBK-boostcharge-powerbank-25k-with-integrated-cable-webgg-01-hero.jpg%3Fsfrm%3Dpng',
  ),
  Product(
    id: 2,
    title: 'AIRPODS',
    price: 170,
    description: 'AirPods deliver an unparalleled wireless headphone experience, from magical setup to high-quality sound. Available with free engraving.',
    imageUrl: 'https://d1rlzxa98cyc61.cloudfront.net/catalog/product/1/6/165727.jpg?auto=webp&format=pjpg&width=640',
  ),
  Product(
    id: 3,
    title: 'CHARGER',
    price: 120,
    description: 'A charger is a device that converts electrical mains power into a safe voltage and current to replenish the energy stored inside a battery.',
    imageUrl: 'https://m.media-amazon.com/images/I/51VM2jCx6kL.jpg',
  ),
  Product(
    id: 4,
    title: 'CASE PHONE',
    price: 60,
    description: 'A phone case is a protective and decorative accessory designed to fit around a mobile phone to shield it from drops, scratches, dust, and daily wear.',
    imageUrl: 'https://cdn.shopify.com/s/files/1/2986/1172/files/iPhone-Gnar-Primary.jpg?v=1787958823&width=1200&height=1500&crop=center',
  ),
];

class CartModel extends ChangeNotifier {
  final Map<Product, int> _items = {};

  Map<Product, int> get items => Map.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  int get count => _items.values.fold(0, (a, b) => a + b);
  double get total =>
      _items.entries.fold(0.0, (sum, e) => sum + e.key.price * e.value);

  void add(Product p) {
    _items[p] = (_items[p] ?? 0) + 1;
    notifyListeners();
  }

  void setQty(Product p, int qty) {
    if (qty <= 0) {
      _items.remove(p);
    } else {
      _items[p] = math.min(qty, 99);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

final CartModel cart = CartModel();

String peso(double v) => '₱${v.toStringAsFixed(2)}';

// Wireframe theme colors
const kBackgroundRed = Color(0xFFFF5252);
const kHeaderOrange = Color(0xFFFFB74D);
const kPillPurple = Color(0xFFCE93D8);
const kLimeGreen = Color(0xFFCCFF90);
const kDeepBlue = Color(0xFF1565C0);
const kGreyBox = Color(0xFF757575);
const kInk = Color(0xFF1A1A1A);

class ShopApp extends StatelessWidget {
  const ShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ecommerce Wireframe App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: kBackgroundRed,
        scaffoldBackgroundColor: kBackgroundRed,
        textTheme: ThemeData.light().textTheme.apply(
              bodyColor: kInk,
              displayColor: kInk,
            ),
      ),
      home: const ProductListScreen(),
    );
  }
}

class ImagePlaceholder extends StatelessWidget {
  const ImagePlaceholder({super.key, this.imageUrl, this.iconSize = 48});

  final String? imageUrl;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: kGreyBox,
      alignment: Alignment.center,
      child: Icon(Icons.image_outlined, size: iconSize, color: const Color(0xFFD0D0D0)),
    );

    if (imageUrl == null) return placeholder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox.expand(
        child: Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => placeholder,
        ),
      ),
    );
  }
}

class CartButton extends StatelessWidget {
  const CartButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: cart,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Badge(
            isLabelVisible: cart.count > 0,
            backgroundColor: Colors.red,
            label: Text('${cart.count}'),
            child: IconButton.filled(
              style: IconButton.styleFrom(backgroundColor: Colors.white, foregroundColor: kInk),
              tooltip: 'Cart / Confirmation',
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OrderConfirmationScreen()),
              ),
            ),
          ),
        );
      },
    );
  }
}

class BackCircle extends StatelessWidget {
  const BackCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: IconButton.filled(
        style: IconButton.styleFrom(backgroundColor: Colors.white, foregroundColor: kInk),
        tooltip: 'Back',
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
    );
  }
}

class DirectionalPillClipper extends CustomClipper<Path> {
  final bool pointLeft;

  DirectionalPillClipper({required this.pointLeft});

  @override
  Path getClip(Size size) {
    final path = Path();
    if (pointLeft) {
      path.moveTo(size.height / 2, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(size.height / 2, size.height);
      path.lineTo(0, size.height / 2);
      path.close();
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width - size.height / 2, 0);
      path.lineTo(size.width, size.height / 2);
      path.lineTo(size.width - size.height / 2, size.height);
      path.lineTo(0, size.height);
      path.close();
    }
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kHeaderOrange,
        centerTitle: true,
        title: const Text('Tech Out', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        actions: const [CartButton()],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final bool pointLeft = index % 2 == 0;

          void open() => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
              );

          final pill = Expanded(
            child: GestureDetector(
              onTap: open,
              child: ClipPath(
                clipper: DirectionalPillClipper(pointLeft: pointLeft),
                child: Container(
                  height: 70,
                  color: kPillPurple,
                  alignment: Alignment.center,
                  child: Text(product.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kInk)),
                ),
              ),
            ),
          );

          final imageBox = GestureDetector(
            onTap: open,
            child: SizedBox(
              width: 130,
              height: 130,
              child: Card(
                elevation: 4,
                color: kGreyBox,
                margin: EdgeInsets.zero,
                child: ImagePlaceholder(imageUrl: product.imageUrl, iconSize: 40),
              ),
            ),
          );

          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              children: pointLeft
                  ? [imageBox, const SizedBox(width: 12), pill]
                  : [pill, const SizedBox(width: 12), imageBox],
            ),
          );
        },
      ),
    );
  }
}

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLimeGreen,
      appBar: AppBar(
        backgroundColor: kHeaderOrange,
        leading: const BackCircle(),
        leadingWidth: 60,
        centerTitle: true,
        title: const Text('Product Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        actions: const [CartButton()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  Expanded(
                    child: Card(
                      color: kGreyBox,
                      child: ImagePlaceholder(imageUrl: product.imageUrl, iconSize: 50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBackgroundRed,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () {
                        cart.add(product);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentIntegrationScreen()));
                      },
                      child: const Text('Purchase Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE0E0E0),
                        foregroundColor: kInk,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () {
                        cart.add(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Added ${product.title} to cart!')),
                        );
                      },
                      child: const Text('ADD TO CART', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kHeaderOrange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(peso(product.price), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                    const Divider(height: 24, color: Colors.black26),
                    Text(product.description, style: const TextStyle(fontSize: 15, height: 1.4)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPillPurple,
      appBar: AppBar(
        backgroundColor: kHeaderOrange,
        leading: const BackCircle(),
        leadingWidth: 60,
        centerTitle: true,
        title: const Text('Order Confirmation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
      ),
      body: ListenableBuilder(
        listenable: cart,
        builder: (context, _) {
          if (cart.isEmpty) {
            return const Center(
              child: Text('Your cart is empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            );
          }

          final entries = cart.items.entries.toList();

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final product = entry.key;
                    final qty = entry.value;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: ImagePlaceholder(imageUrl: product.imageUrl, iconSize: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(peso(product.price), style: const TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton.filled(
                                  style: IconButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                                  icon: const Icon(Icons.remove, size: 18),
                                  onPressed: () => cart.setQty(product, qty - 1),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text('$qty', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                ),
                                IconButton.filled(
                                  style: IconButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                                  icon: const Icon(Icons.add, size: 18),
                                  onPressed: () => cart.setQty(product, qty + 1),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                color: kHeaderOrange,
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total: ${peso(cart.total)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentIntegrationScreen()));
                        },
                        child: const Text('Proceed to Payment'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class PaymentIntegrationScreen extends StatefulWidget {
  const PaymentIntegrationScreen({super.key});

  @override
  State<PaymentIntegrationScreen> createState() => _PaymentIntegrationScreenState();
}

class _PaymentIntegrationScreenState extends State<PaymentIntegrationScreen> {
  bool _loading = false;

  /// Calls the Supabase Edge Function "create-invoice", which talks to Xendit
  /// using the secret key stored on the server (never inside the app).
  Future<void> _pay() async {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty')),
      );
      return;
    }

    setState(() => _loading = true);

    final externalId = 'order-${DateTime.now().millisecondsSinceEpoch}';
    final total = cart.total;
    final items = cart.items.entries
        .map((e) => {
              'name': e.key.title,
              'quantity': e.value,
              'price': e.key.price,
              'category': 'Tech',
            })
        .toList();

    try {
      final res = await supabase.functions.invoke(
        'create-invoice',
        body: {
          'external_id': externalId,
          'amount': total,
          'items': items,
          'customer': {
            'given_names': 'Juan',
            'surname': 'Delacruz',
            'email': 'juan@example.com',
          },
        },
      );

      final data = res.data;
      final invoiceUrl = data is Map ? data['invoice_url'] as String? : null;
      if (invoiceUrl == null) {
        throw 'Xendit did not return an invoice URL';
      }

      // Save the order in Supabase (non-fatal if it fails).
      try {
        await supabase.from('orders').insert({
          'external_id': externalId,
          'total': total,
          'items': items,
          'invoice_url': invoiceUrl,
          'status': 'PENDING',
        });
      } catch (e) {
        debugPrint('Could not save order: $e');
      }

      final opened = await launchUrl(
        Uri.parse(invoiceUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!opened) throw 'Could not open the payment page';

      if (mounted) _showSuccessDialog();
    } catch (e) {
      debugPrint('Payment error: $e');
      if (mounted) _showErrorDialog(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Payment page opened'),
        content: const Text(
          'Your Xendit invoice was created and saved. Complete the payment with GCash or Instapay in the page that just opened.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              cart.clear();
              Navigator.of(ctx).pop();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Payment Error'),
        content: Text('Could not complete the payment request: $error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDeepBlue,
      appBar: AppBar(
        backgroundColor: kHeaderOrange,
        leading: const BackCircle(),
        leadingWidth: 60,
        centerTitle: true,
        title: const Text('Payment Integration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: kHeaderOrange,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFCFD8DC),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: const Text('QR', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: kInk)),
              ),
              const SizedBox(height: 16),
              Text('Total: ${peso(cart.total)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kDeepBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _loading ? null : _pay,
                  child: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                        )
                      : const Text('GCash or Instapay (Xendit)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}