import 'package:flutter/material.dart';
import '../../common/ui_state.dart';
import '../../common/resource.dart';
import '../data/repository/gig_repository.dart';
import '../domain/model/gig.dart';

class GigExtra {
  final String id;
  final String name;
  int quantity;

  GigExtra({
    required this.id,
    required this.name,
    this.quantity = 1,
  });
}

class GigPaymentScreen extends StatefulWidget {
  final String title;
  final String description;
  final String? category;
  final String? image;
  final List<String> tags;
  final VoidCallback? onGigCreated;
  final VoidCallback? onBack;

  const GigPaymentScreen({
    super.key,
    required this.title,
    required this.description,
    this.category,
    this.image,
    this.tags = const [],
    this.onGigCreated,
    this.onBack,
  });

  @override
  State<GigPaymentScreen> createState() => _GigPaymentScreenState();
}

class _GigPaymentScreenState extends State<GigPaymentScreen> {
  final repo = GigRepository();
  final priceCtrl = TextEditingController();
  final couponCtrl = TextEditingController();
  final deliveryFeeCtrl = TextEditingController(text: '5.00');
  final extraNameCtrl = TextEditingController();

  List<GigExtra> extras = [];
  UIState<Resource<Gig>> state = UIState.idle();

  double get basePrice {
    final price = double.tryParse(priceCtrl.text) ?? 0.0;
    return price;
  }

  double get extrasTotal {
    // Cada extra aumenta el total en 5%
    double total = 0.0;
    for (var extra in extras) {
      total += basePrice * 0.05 * extra.quantity;
    }
    return total;
  }

  double get subtotal {
    return basePrice + extrasTotal;
  }

  double get couponDiscount {
    final discount = double.tryParse(couponCtrl.text) ?? 0.0;
    return discount;
  }

  double get deliveryFee {
    final fee = double.tryParse(deliveryFeeCtrl.text) ?? 5.0;
    return fee;
  }

  double get totalAmount {
    return subtotal - couponDiscount + deliveryFee;
  }

  @override
  void dispose() {
    priceCtrl.dispose();
    couponCtrl.dispose();
    deliveryFeeCtrl.dispose();
    extraNameCtrl.dispose();
    super.dispose();
  }

  void _addExtra() {
    if (extraNameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un nombre para el extra')),
      );
      return;
    }

    setState(() {
      extras.add(GigExtra(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: extraNameCtrl.text.trim(),
        quantity: 1,
      ));
      extraNameCtrl.clear();
    });
  }

  void _removeExtra(String id) {
    setState(() {
      extras.removeWhere((e) => e.id == id);
    });
  }

  void _updateExtraQuantity(String id, int delta) {
    setState(() {
      final extra = extras.firstWhere((e) => e.id == id);
      extra.quantity = (extra.quantity + delta).clamp(0, 99);
      if (extra.quantity == 0) {
        _removeExtra(id);
      }
    });
  }

  Future<void> _createGig() async {
    if (priceCtrl.text.trim().isEmpty || basePrice <= 0) {
      setState(() => state = UIState.errorState('El precio debe ser mayor a 0'));
      return;
    }

    setState(() => state = UIState.loadingState());
    try {
      final gig = await repo.createGig(
        title: widget.title,
        description: widget.description,
        category: widget.category,
        image: widget.image,
        tags: widget.tags,
        price: basePrice,
      );

      setState(() => state = UIState.dataState(Success(gig)));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gig creado exitosamente')),
        );
        widget.onGigCreated?.call();
      }
    } catch (e, st) {
      setState(() => state = UIState.dataState(ErrorRes<Gig>(e, st)));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = state.loading;
    final res = state.data;
    String? errText;
    if (res is ErrorRes<Gig>) {
      errText = res.error.toString();
    } else if (state.message != null) {
      errText = state.message;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'New Gig',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.normal,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A5F), // Azul oscuro
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: isLoading ? null : widget.onBack,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Gig Items/Extras Section
              if (extras.isNotEmpty) ...[
                ...extras.map((extra) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                extra.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: isLoading
                                      ? null
                                      : () => _updateExtraQuantity(extra.id, -1),
                                  icon: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.remove, size: 18),
                                  ),
                                ),
                                SizedBox(
                                  width: 40,
                                  child: Text(
                                    extra.quantity.toString().padLeft(2, '0'),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: isLoading
                                      ? null
                                      : () => _updateExtraQuantity(extra.id, 1),
                                  icon: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.add, size: 18, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(height: 8),
              ],

              // Add Extra Button
              OutlinedButton.icon(
                onPressed: isLoading ? null : _addExtra,
                icon: const Icon(Icons.add),
                label: const Text('Add Extra'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 8),

              // Extra Name Input (shown when adding)
              TextField(
                controller: extraNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre del extra',
                  border: OutlineInputBorder(),
                  hintText: 'Ej: Custom Animation',
                ),
                enabled: !isLoading,
                onSubmitted: (_) => _addExtra(),
              ),
              const SizedBox(height: 24),

              // Payment Calculator Section
              const Text(
                'Payment Calculator',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Price Input
              TextField(
                controller: priceCtrl,
                decoration: const InputDecoration(
                  labelText: 'Precio Base',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                enabled: !isLoading,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // Subtotal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal'),
                  Text(
                    '\$${subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Coupon Discount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Coupon discount'),
                  Text(
                    '-\$${couponDiscount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Coupon Input
              TextField(
                controller: couponCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descuento (opcional)',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                enabled: !isLoading,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),

              // Delivery Fee
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Delivery Fee'),
                  Text(
                    '\$${deliveryFee.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Delivery Fee Input
              TextField(
                controller: deliveryFeeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Delivery Fee',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                enabled: !isLoading,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // Total Amount
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Error Message
              if (errText != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    errText,
                    style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Create Gig Button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isLoading ? null : _createGig,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create Gig'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

