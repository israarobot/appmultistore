import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:carthage_store/controllers/add_product_controller.dart';
import 'package:carthage_store/controllers/favorite_controller.dart';
import 'checkout_screen.dart';

// Displays detailed product information with image carousel, video, and actions
class ProductDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> product;
  final FavoriteController favoriteController = Get.find<FavoriteController>();

  ProductDetailsScreen({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AddProductController addProductController = Get.find<AddProductController>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFF5F5F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // App bar with back button, title, favorite, and share actions
            SliverAppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                product["name"] ?? 'Product Details',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 24),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              actions: [
                // Favorite button with toggle functionality
                StreamBuilder<bool>(
                  stream: favoriteController.isFavorite(product['id'].toString()),
                  builder: (context, snapshot) {
                    bool isFavorite = snapshot.data ?? false;
                    return IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.redAccent : Colors.black87,
                      ),
                      onPressed: () => isFavorite
                          ? favoriteController.removeFromFavorites(product['id'].toString())
                          : favoriteController.addToFavorites(product),
                    );
                  },
                ),
                // Share button to open share options
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.black87),
                  onPressed: () => _showShareBottomSheet(context),
                ),
              ],
              pinned: true,
              expandedHeight: 350,
              flexibleSpace: FlexibleSpaceBar(background: _buildImageCarousel()),
            ),
            // Product details and video section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductDetails(context),
                    if (product["video_url"]?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 24),
                      _buildVideoSection(addProductController),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Shows a bottom sheet with share options (Message, Email, Copy Link, More)
  void _showShareBottomSheet(BuildContext context) {
    final String productName = product["name"] ?? 'Product';
    final String productDescription = product["description"] ?? 'Check out this amazing product!';
    final String productPrice = 'DT${product["sale_price"]?.toStringAsFixed(2) ?? '0.00'}';
    final String productLink = product["product_url"] ?? 'https://carthagestore.com/product/${product["id"] ?? ''}';
    final String shareText = '$productName\nPrice: $productPrice\n$productDescription\nCheck it out: $productLink';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Share $productName', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(
                  icon: Icons.message,
                  label: 'Message',
                  onTap: () => Share.share(shareText, subject: 'Check out $productName on Carthage Store!').then((_) => Navigator.pop(context)),
                ),
                _buildShareOption(
                  icon: Icons.email,
                  label: 'Email',
                  onTap: () => Share.share(shareText, subject: 'Check out $productName on Carthage Store!').then((_) => Navigator.pop(context)),
                ),
                _buildShareOption(
                  icon: Icons.copy,
                  label: 'Copy Link',
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: productLink));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied to clipboard!')));
                    Navigator.pop(context);
                  },
                ),
                _buildShareOption(
                  icon: Icons.share,
                  label: 'More',
                  onTap: () => Share.share(shareText, subject: 'Check out $productName on Carthage Store!').then((_) => Navigator.pop(context)),
                ),
              ],
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Center(child: Text('Cancel', style: TextStyle(fontSize: 16, color: Colors.grey))),
            ),
          ],
        ),
      ),
    );
  }

  // Builds a share option widget with icon and label
  Widget _buildShareOption({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 30, backgroundColor: Colors.grey.shade200, child: Icon(icon, size: 30, color: const Color(0xFF93441A))),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }

  // Builds image carousel for product images
  Widget _buildImageCarousel() {
    final List<String> imageUrls = (product["image_urls"] as List<dynamic>?)?.cast<String>() ?? [];
    return imageUrls.isNotEmpty
        ? CarouselSlider(
            options: CarouselOptions(
              height: 350,
              autoPlay: true,
              enlargeCenterPage: true,
              aspectRatio: 16 / 9,
              autoPlayInterval: const Duration(seconds: 5),
              viewportFraction: 1.0,
            ),
            items: imageUrls.map((url) => _buildImage(url)).toList(),
          )
        : Container(
            color: Colors.grey.shade200,
            height: 350,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
                Text('Media unavailable', style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          );
  }

  // Builds individual image widget with loading and error handling
  Widget _buildImage(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      loadingBuilder: (context, child, loadingProgress) => loadingProgress == null
          ? child
          : Container(
              color: Colors.grey.shade200,
              height: 350,
              child: const Center(child: CircularProgressIndicator(color: Color(0xFF93441A), strokeWidth: 3)),
            ),
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey.shade200,
        height: 350,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
            Text('Image unavailable', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  // Builds video section with product video
  Widget _buildVideoSection(AddProductController controller) {
    final String convertedVideoUrl = controller.convertUrl(product["video_url"]);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Product Video', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 8),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: VideoPlayerWidget(videoUrl: convertedVideoUrl),
        ),
      ],
    );
  }

  // Builds product details card with name, rating, price, and description
  Widget _buildProductDetails(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product["name"] ?? 'Unnamed Product', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.star, size: 22, color: Color(0xFF93441A)),
                const SizedBox(width: 6),
                Text(product["rating"]?.toString() ?? 'N/A', style: const TextStyle(fontSize: 18, color: Colors.grey)),
                const SizedBox(width: 16),
                Text('(${product["reviews"]?.toString() ?? '0'} reviews)', style: const TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            Text('Sold by: ${product["name_seller"] ?? 'Unknown Seller'}', style: const TextStyle(fontSize: 16, color: Colors.grey, fontStyle: FontStyle.italic)),
            const SizedBox(height: 16),
            Text('DT${product["sale_price"]?.toStringAsFixed(2) ?? '0.00'}', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF93441A))),
            if (product["discount"] != null && product["discount"] > 0)
              Text(
                'DT${((product["sale_price"] / (1 - product["discount"] / 100))).toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, color: Colors.grey, decoration: TextDecoration.lineThrough),
              ),
            const SizedBox(height: 16),
            const Text('Description', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 8),
            Text(
              product["description"] ?? 'This is a high-quality product designed to meet your needs. Check out the features and enjoy the best shopping experience with Carthage Store!',
              style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.6),
            ),
            const SizedBox(height: 24),
            _AnimatedButton(
              text: 'Buy Now',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CheckoutScreen(product: product))),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget to handle video playback with error and loading states
class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  // Initializes video player with error handling
  Future<void> _initializeVideoPlayer() async {
    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await _controller.initialize();
      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _controller,
          aspectRatio: _controller.value.aspectRatio,
          autoPlay: false,
          looping: false,
          allowMuting: true,
          showControls: true,
          errorBuilder: (context, errorMessage) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 100, color: Colors.grey),
                Text('Video unavailable: $errorMessage', style: const TextStyle(color: Colors.grey, fontSize: 16), textAlign: TextAlign.center),
                ElevatedButton(onPressed: _retry, child: const Text('Retry')),
              ],
            ),
          ),
        );
        _isInitialized = true;
      });
    } catch (e) {
      setState(() => _hasError = true);
    }
  }

  // Retries video initialization
  void _retry() {
    setState(() {
      _hasError = false;
      _isInitialized = false;
    });
    _initializeVideoPlayer();
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: Colors.grey.shade200,
        height: 350,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 100, color: Colors.grey),
            const Text('Video unavailable', style: TextStyle(color: Colors.grey, fontSize: 16)),
            ElevatedButton(onPressed: _retry, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        color: Colors.grey.shade200,
        height: 350,
        child: const Center(child: CircularProgressIndicator(color: Color(0xFF93441A), strokeWidth: 3)),
      );
    }

    return SizedBox(height: 350, width: double.infinity, child: Chewie(controller: _chewieController!));
  }
}

// Animated button with scale animation on tap
class _AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;

  const _AnimatedButton({required this.text, this.onPressed});

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF93441A), Color(0xFFB3592A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
          ),
          child: ElevatedButton(
            onPressed: widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: Text(widget.text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}