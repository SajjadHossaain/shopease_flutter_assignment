import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';
import 'product_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadInitial();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 350) {
      context.read<ProductProvider>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ShopEase', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -.5)),
          Text('Find something you love', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
        ]),
        actions: [
          IconButton(
            tooltip: 'Add product',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductFormScreen())),
            icon: const Icon(Icons.add_circle_outline_rounded, size: 28),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                child: TextField(
                  onChanged: provider.setSearch,
                  decoration: const InputDecoration(
                    hintText: 'Search products, categories...',
                    prefixIcon: Icon(Icons.search_rounded),
                    suffixIcon: Icon(Icons.tune_rounded),
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: provider.refresh,
                  child: Builder(builder: (context) {
                    if (provider.isLoading && provider.products.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (provider.hasError && provider.products.isEmpty) {
                      return _MessageState(
                        icon: Icons.wifi_off_rounded,
                        title: 'You are offline',
                        message: provider.errorMessage,
                        buttonText: 'Try again',
                        onPressed: provider.loadInitial,
                      );
                    }
                    if (provider.products.isEmpty) {
                      return _MessageState(
                        icon: Icons.search_off_rounded,
                        title: 'No products found',
                        message: 'Try another search or add a new product.',
                        buttonText: 'Clear search',
                        onPressed: () => provider.setSearch(''),
                      );
                    }
                    return LayoutBuilder(builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final columns = width >= 850 ? 4 : width >= 600 ? 3 : 2;
                      return GridView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: width < 380 ? .64 : .70,
                        ),
                        itemCount: provider.products.length + (provider.isLoadingMore ? columns : 0),
                        itemBuilder: (context, index) {
                          if (index >= provider.products.length) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final product = provider.products[index];
                          return ProductCard(
                            product: product,
                            onTap: () => Navigator.push(context, MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(productId: product.id),
                            )),
                          );
                        },
                      );
                    });
                  }),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductFormScreen())),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add product'),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.icon, required this.title, required this.message, required this.buttonText, required this.onPressed});
  final IconData icon;
  final String title, message, buttonText;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    children: [
      const SizedBox(height: 100),
      Icon(icon, size: 54, color: Theme.of(context).colorScheme.primary),
      const SizedBox(height: 16),
      Center(child: Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold))),
      const SizedBox(height: 8),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 35), child: Text(message, textAlign: TextAlign.center)),
      const SizedBox(height: 18),
      Center(child: FilledButton(onPressed: onPressed, child: Text(buttonText))),
    ],
  );
}
