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

class ProductDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> product;
  final FavoriteController favoriteController = Get.find<FavoriteController>();

  ProductDetailsScreen({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AddProductController _addProductController = Get.find<AddProductController>();
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                product["name"] ?? 'Product Details',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontSize: 24,
                ),
              ),
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              actions: [
                StreamBuilder<bool>(
                  stream: favoriteController.isFavorite(product['id'].toString()),
                  builder: (context, snapshot) {
                    bool isFavorite = snapshot.data ?? false;
                    return IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.redAccent : Colors.black87,
                      ),
                      onPressed: () async {
                        if (isFavorite) {
                          await favoriteController.removeFromFavorites(product['id'].toString());
                        } else {
                          await favoriteController.addToFavorites(product);
                        }
                      },
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.black87),
                  onPressed: () {
                    _showShareBottomSheet(context);
                  },
                ),
              ],
              pinned: true,
              expandedHeight: 350,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildImageCarousel(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProductDetails(context),
                      const SizedBox(height: 24),
                      if (product["video_url"] != null && product["video_url"].isNotEmpty)
                        _buildVideoSection(_addProductController),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showShareBottomSheet(BuildContext context) {
    final String productName = product["name"] ?? 'Product';
    final String productDescription = product["description"] ?? 'Check out this amazing product!';
    final String productPrice = 'DT${product["sale_price"]?.toStringAsFixed(2) ?? '0.00'}';
    final String productLink = product["product_url"] ?? 'https://carthagestore.com/product/${product["id"] ?? ''}';
    
    final String shareText = '''
$productName
Price: $productPrice
$productDescription
Check it out: $productLink
''';

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share $productName',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(
                  icon: Icons.message,
                  label: 'Message',
                  onTap: () {
                    Share.share(shareText, subject: 'Check out $productName on Carthage Store!');
                    Navigator.pop(context);
                  },
                ),
                _buildShareOption(
                  icon: Icons.email,
                  label: 'Email',
                  onTap: () {
                    Share.share(shareText, subject: 'Check out $productName on Carthage Store!');
                    Navigator.pop(context);
                  },
                ),
                _buildShareOption(
                  icon: Icons.copy,
                  label: 'Copy Link',
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: productLink));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Link copied to clipboard!')),
                    );
                    Navigator.pop(context);
                  },
                ),
                _buildShareOption(
                  icon: Icons.share,
                  label: 'More',
                  onTap: () {
                    Share.share(shareText, subject: 'Check out $productName on Carthage Store!');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Center(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey.shade200,
            child: Icon(icon, size: 30, color: Color(0xFF93441A)),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    final List<String> imageUrls = (product["image_urls"] as List<dynamic>?)?.cast<String>() ?? [];
    print('Image URLs for ${product["name"]}: $imageUrls');

    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 800),
      child: imageUrls.isNotEmpty
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
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'Media unavailable',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildImage(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey.shade200,
          height: 350,
          width: double.infinity,
          child: Center(
            child: CircularProgressIndicator(
              color: const Color(0xFF93441A),
              strokeWidth: 3,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print('Error loading image for ${product["name"]}: $error, URL: $url');
        return Container(
          color: Colors.grey.shade200,
          height: 350,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'Image unavailable',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVideoSection(AddProductController controller) {
    final String convertedVideoUrl = controller.convertUrl(product["video_url"]);
    print('Displaying video for ${product["name"]}: $convertedVideoUrl');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product Video',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: VideoPlayerWidget(videoUrl: convertedVideoUrl),
        ),
      ],
    );
  }

  Widget _buildProductDetails(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product["name"] ?? 'Unnamed Product',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.star, size: 22, color: Color(0xFF93441A)),
                const SizedBox(width: 6),
                Text(
                  product["rating"]?.toString() ?? 'N/A',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                ),
                const SizedBox(width: 16),
                Text(
                  '(${product["reviews"]?.toString() ?? '0'} reviews)',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Sold by: ${product["name_seller"] ?? 'Unknown Seller'}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'DT${product["sale_price"]?.toStringAsFixed(2) ?? '0.00'}',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xFF93441A),
              ),
            ),
            if (product["discount"] != null && product["discount"] > 0) ...[
              const SizedBox(height: 8),
              Text(
                'DT${((product["sale_price"] / (1 - product["discount"] / 100))).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product["description"] ??
                  'This is a high-quality product designed to meet your needs. Check out the features and enjoy the best shopping experience with Carthage Store!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            _AnimatedButton(
              text: 'Buy Now',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckoutScreen(product: product),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

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

  Future<void> _initializeVideoPlayer() async {
    try {
      print('Initializing video player for URL: ${widget.videoUrl}');
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
          errorBuilder: (context, errorMessage) {
            print('Video player error: $errorMessage, URL: ${widget.videoUrl}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 100, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(
                    'Video unavailable: $errorMessage',
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _hasError = false;
                        _isInitialized = false;
                      });
                      _initializeVideoPlayer();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          },
        );
        _isInitialized = true;
      });
    } catch (e, stackTrace) {
      print('Error initializing video player for ${widget.videoUrl}: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _hasError = true;
      });
    }
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
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 100, color: Colors.grey),
            const SizedBox(height: 8),
            const Text(
              'Video unavailable',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isInitialized = false;
                });
                _initializeVideoPlayer();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        color: Colors.grey.shade200,
        height: 350,
        width: double.infinity,
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF93441A),
            strokeWidth: 3,
          ),
        ),
      );
    }

    return SizedBox(
      height: 350,
      width: double.infinity,
      child: Chewie(controller: _chewieController!),
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;

  const _AnimatedButton({
    required this.text,
    this.onPressed,
  });

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
            gradient: const LinearGradient(
              colors: [Color(0xFF93441A), Color(0xFFB3592A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              widget.text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}