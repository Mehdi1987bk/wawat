import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'iap_catalog.dart';
import 'iap_service.dart';

/// App Store / Google Play promotion products development screen.
///
/// Backend-siz işləyir: `ios/Runner/WawatProducts.storekit` yerli StoreKit
/// konfiqurasiyası sayəsində simulyatorda Apple-ın həqiqi alış pəncərəsi açılır.
/// Bu ekran `lib/dev_iap.dart` giriş nöqtəsindən açılır — tətbiqə girmədən.
class IapDemoScreen extends StatefulWidget {
  const IapDemoScreen({super.key});

  @override
  State<IapDemoScreen> createState() => _IapDemoScreenState();
}

class _IapDemoScreenState extends State<IapDemoScreen> {
  final _iap = IapService.instance;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await _iap.init();
    await _iap.loadProducts();
    if (mounted) setState(() => _loading = false);
  }

  String _resultText(IapResult? r) {
    if (r == null) return 'Hələ alış yoxdur';
    switch (r.outcome) {
      case IapOutcome.pending:
        return '⏳ Gözlənilir…';
      case IapOutcome.purchased:
        return '✅ Alındı — ${r.productId}';
      case IapOutcome.restored:
        return '♻️ Bərpa olundu — ${r.productId}';
      case IapOutcome.canceled:
        return '✖️ Ləğv edildi';
      case IapOutcome.error:
        return '⚠️ Xəta: ${r.message ?? r.productId}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IAP · Promosyonlar (sınaq)'),
        backgroundColor: const Color(0xFF017BFE),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _StatusBar(iap: _iap),
                const Divider(height: 1),
                Expanded(
                  child: ValueListenableBuilder<List<ProductDetails>>(
                    valueListenable: _iap.products,
                    builder: (_, products, __) {
                      if (products.isEmpty) {
                        return _EmptyState(iap: _iap);
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: products.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _PackTile(
                          product: products[i],
                          iap: _iap,
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: OutlinedButton.icon(
                      onPressed: _iap.restore,
                      icon: const Icon(Icons.restore),
                      label: const Text('Alışları bərpa et'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  final IapService iap;
  const _StatusBar({required this.iap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF1F5F9),
      padding: const EdgeInsets.all(14),
      child: ValueListenableBuilder<IapResult?>(
        valueListenable: iap.lastResult,
        builder: (_, result, __) {
          final state = context.findAncestorStateOfType<_IapDemoScreenState>();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    iap.isAvailable ? Icons.check_circle : Icons.cancel,
                    color: iap.isAvailable ? Colors.green : Colors.red,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(iap.isAvailable
                      ? 'Mağaza əlçatandır'
                      : 'Mağaza əlçatan deyil'),
                ],
              ),
              const SizedBox(height: 6),
              Text(state?._resultText(result) ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          );
        },
      ),
    );
  }
}

class _PackTile extends StatelessWidget {
  final ProductDetails product;
  final IapService iap;
  const _PackTile({required this.product, required this.iap});

  @override
  Widget build(BuildContext context) {
    final catalogProduct = iap.catalogProductFor(product.id);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 2),
                Text(
                  catalogProduct == null
                      ? product.description
                      : catalogProduct.kind == IapProductKind.vip
                          ? 'VİP · ${catalogProduct.durationDays} gün'
                          : 'Önə çıxarılan · ${catalogProduct.boostPackage}',
                  style:
                      const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                ),
              ],
            ),
          ),
          ValueListenableBuilder<String?>(
            valueListenable: iap.purchasing,
            builder: (_, buyingId, __) {
              final busy = buyingId == product.id;
              return SizedBox(
                width: 96,
                height: 40,
                child: ElevatedButton(
                  onPressed: buyingId != null ? null : () => iap.buy(product),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF017BFE),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                  ),
                  child: busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(product.price),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IapService iap;
  const _EmptyState({required this.iap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inventory_2_outlined,
                size: 48, color: Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            const Text('Məhsul tapılmadı',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(
              iap.notFoundIds.isEmpty
                  ? 'StoreKit konfiqurasiyası qoşulmayıb. Xcode-da Runner\nsxemində StoreKit Configuration = WawatProducts.storekit seç.'
                  : 'Tapılmadı: ${iap.notFoundIds.join(", ")}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
