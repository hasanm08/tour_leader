import 'package:tour_leader/data/models/destination.dart';

class DestinationService {
  static final DestinationService _instance = DestinationService._internal();
  factory DestinationService() => _instance;
  DestinationService._internal();

  List<Destination> _destinations = [];

  Future<void> initialize() async {
    if (_destinations.isEmpty) {
      _destinations = _generateMockDestinations();
    }
  }

  List<Destination> _generateMockDestinations() {
    final now = DateTime.now();
    return [
      // Existing destinations
      Destination(
        id: '1',
        name: 'Santorini',
        description: 'Beautiful Greek island with stunning sunsets',
        longDescription:
            'Santorini is a Greek island in the southern Aegean Sea, about 200 km southeast of Greece.',
        country: 'Greece',
        city: 'Santorini',
        latitude: 36.3932,
        longitude: 25.4615,
        imageUrls: ['assets/images/santorini.jpg'],
        rating: 4.8,
        reviewCount: 1245,
        attractions: [
          'Oia Sunset',
          'Red Beach',
          'Akrotiri Archaeological Site',
          'Fira Town',
        ],
        categories: ['Beach', 'Culture', 'Romance', 'Photography'],
        price: 1299.99,
        isPopular: true,
        isFeatured: true,
        bestTimeToVisit: 'May to October',
        activities: [
          'Sunset Viewing',
          'Wine Tasting',
          'Beach Activities',
          'Photography',
        ],
        createdAt: now,
        updatedAt: now,
      ),

      Destination(
        id: '2',
        name: 'Kyoto',
        description: 'Ancient capital of Japan with temples and tradition',
        longDescription:
            'Kyoto, once the capital of Japan, is a city on the island of Honshu.',
        country: 'Japan',
        city: 'Kyoto',
        latitude: 35.0116,
        longitude: 135.7681,
        imageUrls: ['assets/images/kyoto.jpg'],
        rating: 4.7,
        reviewCount: 987,
        attractions: [
          'Fushimi Inari Shrine',
          'Kinkaku-ji Temple',
          'Arashiyama Bamboo Grove',
        ],
        categories: ['Culture', 'History', 'Temples', 'Traditional'],
        price: 1899.99,
        isPopular: true,
        isFeatured: true,
        bestTimeToVisit: 'March to May, September to November',
        activities: ['Temple Visits', 'Cherry Blossom Viewing', 'Tea Ceremony'],
        createdAt: now,
        updatedAt: now,
      ),

      // Shiraz places
      Destination(
        id: '6',
        name: 'Hafez Tomb',
        description: 'Tomb of the great Persian poet Hafez',
        longDescription:
            'The Tomb of Hafez, known locally as Hafezieh, is a memorial hall and tomb of the celebrated Persian poet Hafez.',
        country: 'Iran',
        city: 'Shiraz',
        latitude: 29.6255,
        longitude: 52.5504,
        imageUrls: ['assets/images/santorini.jpg'], // Placeholder
        rating: 4.7,
        reviewCount: 892,
        attractions: ['Hafez Mausoleum', 'Musalla Gardens'],
        categories: ['Culture', 'Poetry', 'History', 'Literature'],
        price: 299.99,
        isPopular: true,
        isFeatured: true,
        bestTimeToVisit: 'March to May, September to November',
        activities: ['Poetry Reading', 'Cultural Tours', 'Photography'],
        createdAt: now,
        updatedAt: now,
      ),

      Destination(
        id: '7',
        name: 'Persepolis',
        description: 'Magnificent ruins of the ancient Persian capital',
        longDescription:
            'Persepolis was the ceremonial capital of the Achaemenid Empire.',
        country: 'Iran',
        city: 'Marvdasht',
        latitude: 29.9357,
        longitude: 52.8916,
        imageUrls: ['assets/images/cappadocia.jpg'], // Placeholder
        rating: 4.9,
        reviewCount: 1234,
        attractions: ['Apadana Palace', 'Throne Hall', 'Gate of All Nations'],
        categories: ['History', 'Ancient', 'UNESCO', 'Archaeological'],
        price: 499.99,
        isPopular: true,
        isFeatured: true,
        bestTimeToVisit: 'October to April',
        activities: [
          'Historical Tours',
          'Archaeological Exploration',
          'Photography',
        ],
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  Future<List<Destination>> getAllDestinations() async {
    await initialize();
    return _destinations;
  }

  Future<List<Destination>> getFeaturedDestinations() async {
    await initialize();
    return _destinations.where((d) => d.isFeatured).toList();
  }

  Future<List<Destination>> getPopularDestinations() async {
    await initialize();
    return _destinations.where((d) => d.isPopular).toList();
  }

  Future<List<Destination>> getDestinationsByCategory(String category) async {
    await initialize();
    return _destinations.where((d) => d.categories.contains(category)).toList();
  }

  Future<List<Destination>> getDestinationsByCountry(String country) async {
    await initialize();
    return _destinations.where((d) => d.country == country).toList();
  }

  Future<Destination?> getDestinationById(String id) async {
    await initialize();
    try {
      return _destinations.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<String>> getCategories() async {
    await initialize();
    final categories = <String>{};
    for (final destination in _destinations) {
      categories.addAll(destination.categories);
    }
    return categories.toList()..sort();
  }

  Future<List<String>> getCountries() async {
    await initialize();
    final countries = <String>{};
    for (final destination in _destinations) {
      countries.add(destination.country);
    }
    return countries.toList()..sort();
  }
}
