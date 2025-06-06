import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(const TourismApp());

class TourismApp extends StatelessWidget {
  const TourismApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
      theme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const TourismHomePage(),
    const ParallaxGalleryPage(),
    const Fantasy3DPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.flip), label: 'Flip Cards'),
          BottomNavigationBarItem(
            icon: Icon(Icons.panorama),
            label: 'Parallax',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_in_ar),
            label: '3D Fantasy',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class TourismHomePage extends StatefulWidget {
  const TourismHomePage({super.key});

  @override
  State<TourismHomePage> createState() => _TourismHomePageState();
}

class _TourismHomePageState extends State<TourismHomePage> {
  List<Widget> cards = [
    FlipCard(
      title: 'Santorini, Greece',
      imagePath: 'assets/santorini.jpg',
      description: 'Sunsets, sea breeze, and blue domes.',
    ),
    FlipCard(
      title: 'Kyoto, Japan',
      imagePath: 'assets/kyoto.jpg',
      description: 'Temples, blossoms, and peace.',
    ),
    FlipCard(
      title: 'Cappadocia, Turkey',
      imagePath: 'assets/cappadocia.jpg',
      description: 'Hot air balloon rides, cave hotels, and fairy chimneys.',
    ),
    FlipCard(
      title: 'Banff, Canada',
      imagePath: 'assets/banff.jpg',
      description: 'Mountains, lakes, and wildlife.',
    ),
    FlipCard(
      title: 'Bali, Indonesia',
      imagePath: 'assets/bali.jpg',
      description: 'Bali is a beautiful place to visit.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Explore World",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ListView.separated(
          itemCount: cards.length,
          separatorBuilder: (context, index) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            return cards[index];
          },
        ),
      ),
    );
  }
}

class ParallaxGalleryPage extends StatefulWidget {
  const ParallaxGalleryPage({super.key});

  @override
  State<ParallaxGalleryPage> createState() => _ParallaxGalleryPageState();
}

class _ParallaxGalleryPageState extends State<ParallaxGalleryPage> {
  final List<Map<String, String>> destinations = [
    {
      'title': 'Santorini, Greece',
      'imagePath': 'assets/santorini.jpg',
      'description': 'Sunsets, sea breeze, and blue domes.',
    },
    {
      'title': 'Kyoto, Japan',
      'imagePath': 'assets/kyoto.jpg',
      'description': 'Temples, blossoms, and peace.',
    },
    {
      'title': 'Cappadocia, Turkey',
      'imagePath': 'assets/cappadocia.jpg',
      'description': 'Hot air balloon rides, cave hotels, and fairy chimneys.',
    },
    {
      'title': 'Banff, Canada',
      'imagePath': 'assets/banff.jpg',
      'description': 'Mountains, lakes, and wildlife.',
    },
    {
      'title': 'Bali, Indonesia',
      'imagePath': 'assets/bali.jpg',
      'description': 'Bali is a beautiful place to visit.',
    },
  ];

  final PageController _pageController = PageController();
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Parallax Gallery",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: destinations.length,
        itemBuilder: (context, index) {
          // Calculate parallax effect
          final parallaxFactor = (index - _currentPage).abs();
          final parallaxValue = 1 - min(parallaxFactor, 1);

          return Transform.scale(
            scale: 0.8 + (parallaxValue * 0.2),
            child: Opacity(
              opacity: 0.5 + (parallaxValue * 0.5),
              child: ParallaxCard(
                title: destinations[index]['title']!,
                imagePath: destinations[index]['imagePath']!,
                description: destinations[index]['description']!,
              ),
            ),
          );
        },
      ),
    );
  }
}

class ParallaxCard extends StatelessWidget {
  final String title, imagePath, description;

  const ParallaxCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          imagePath,
          fit: BoxFit.cover,
          height: double.infinity,
          width: double.infinity,
        ),
        Container(color: Colors.black.withOpacity(0.4)),
        Center(
          child: Transform.translate(
            offset: const Offset(0, -40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 34,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: const TextStyle(fontSize: 18, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class FlipCard extends StatefulWidget {
  final String title, imagePath, description;

  const FlipCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.description,
  });

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void _flipCard() {
    if (_controller.isCompleted || _controller.velocity > 0) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final isFront = _animation.value < pi / 2;
          return Transform(
            alignment: Alignment.center,
            transform:
                Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(_animation.value),
            child:
                isFront
                    ? _buildCard(widget.title, imagePath: widget.imagePath)
                    : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(pi),
                      child: _buildCard(widget.description, back: true),
                    ),
          );
        },
      ),
    );
  }

  Widget _buildCard(String text, {String? imagePath, bool back = false}) {
    return Container(
      height: 400,
      width: 300,
      decoration: BoxDecoration(
        color: back ? Colors.white : Colors.black,
        image:
            imagePath != null
                ? DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                )
                : null,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.4)),
        ],
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(20),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 24,
          color: back ? Colors.black : Colors.white,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class Fantasy3DPage extends StatefulWidget {
  const Fantasy3DPage({super.key});

  @override
  State<Fantasy3DPage> createState() => _Fantasy3DPageState();
}

class _Fantasy3DPageState extends State<Fantasy3DPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Destination> _destinations;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 15000),
      vsync: this,
    )..repeat();

    _destinations = [
      Destination(
        title: 'Enchanted Forest',
        imagePath: 'assets/santorini.jpg', // Use same images for now
        description: 'Mystical trees with glowing flora and magical creatures.',
      ),
      Destination(
        title: 'Crystal Caves',
        imagePath: 'assets/kyoto.jpg',
        description:
            'Sparkling gemstones illuminate vast underground chambers.',
      ),
      Destination(
        title: 'Floating Islands',
        imagePath: 'assets/cappadocia.jpg',
        description:
            'Majestic landmasses suspended in the clouds with waterfalls cascading into the void.',
      ),
      Destination(
        title: 'Dragon\'s Lair',
        imagePath: 'assets/banff.jpg',
        description: 'Ancient volcanic fortress home to mighty dragons.',
      ),
      Destination(
        title: 'Starlight Oasis',
        imagePath: 'assets/bali.jpg',
        description: 'Desert haven where the night sky meets the earth.',
      ),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextDestination() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _destinations.length;
    });
  }

  void _previousDestination() {
    setState(() {
      _currentIndex =
          (_currentIndex - 1 + _destinations.length) % _destinations.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Fantasy Worlds",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return RotatingCube(
                    rotation: _controller.value * 2 * pi,
                    destination: _destinations[_currentIndex],
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: "prev",
                  onPressed: _previousDestination,
                  child: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 20),
                FloatingActionButton(
                  heroTag: "next",
                  onPressed: _nextDestination,
                  child: const Icon(Icons.arrow_forward),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Destination {
  final String title;
  final String imagePath;
  final String description;

  Destination({
    required this.title,
    required this.imagePath,
    required this.description,
  });
}

class RotatingCube extends StatelessWidget {
  final double rotation;
  final Destination destination;

  const RotatingCube({
    super.key,
    required this.rotation,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Front face
        Transform(
          alignment: Alignment.center,
          transform:
              Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(rotation),
          child: _buildCubeFace(
            title: destination.title,
            imagePath: destination.imagePath,
            size: 250,
          ),
        ),
        // Right face
        Transform(
          alignment: Alignment.center,
          transform:
              Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(rotation + pi / 2),
          child: _buildCubeFace(
            title: "Fantasy",
            description: destination.description,
            size: 250,
            textColor: Colors.amber,
          ),
        ),
        // Back face
        Transform(
          alignment: Alignment.center,
          transform:
              Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(rotation + pi),
          child: _buildCubeFace(
            title: "Discover",
            imagePath: destination.imagePath,
            size: 250,
            overlay: Colors.purple.withOpacity(0.5),
          ),
        ),
        // Left face
        Transform(
          alignment: Alignment.center,
          transform:
              Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(rotation + 3 * pi / 2),
          child: _buildCubeFace(
            title: "Explore",
            description: "Tap arrows to navigate worlds",
            size: 250,
            textColor: Colors.cyan,
          ),
        ),
      ],
    );
  }

  Widget _buildCubeFace({
    required String title,
    String? description,
    String? imagePath,
    double size = 200,
    Color? overlay,
    Color textColor = Colors.white,
  }) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: Colors.black,
        image:
            imagePath != null
                ? DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    overlay ?? Colors.black.withOpacity(0.3),
                    BlendMode.srcOver,
                  ),
                )
                : null,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.5),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.7), width: 2),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              color: textColor,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(color: Colors.black.withOpacity(0.7), blurRadius: 10),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          if (description != null) ...[
            const SizedBox(height: 10),
            Text(
              description,
              style: TextStyle(
                fontSize: 16,
                color: textColor.withOpacity(0.8),
                shadows: [
                  Shadow(color: Colors.black.withOpacity(0.7), blurRadius: 5),
                ],
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
