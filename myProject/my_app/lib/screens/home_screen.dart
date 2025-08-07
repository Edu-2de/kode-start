import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/character.dart';
import '../services/rick_and_morty_service.dart';
import 'character_detail_screen.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/character_card_modern.dart';
import '../widgets/character_card_classic.dart';
import '../widgets/profile_menu.dart';
import '../providers/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<Character> characters = [];
  List<Character> allCharacters = [];
  bool isLoading = true;
  bool hasError = false;
  int currentPage = 1;
  bool hasMore = true;
  bool isThemeChanging = false; // Flag to indicate theme is changing
  final ScrollController _scrollController = ScrollController();
  bool isDrawerOpen = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadCharacters();
    _scrollController.addListener(_onScroll);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    // Listen for theme changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<ThemeProvider>(
          context,
          listen: false,
        ).addListener(_onThemeChanged);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();

    // Remove theme listener
    if (mounted) {
      try {
        Provider.of<ThemeProvider>(
          context,
          listen: false,
        ).removeListener(_onThemeChanged);
      } catch (e) {
        // Ignore error if provider was already removed
      }
    }

    super.dispose();
  }

  void _onThemeChanged() {
    if (!mounted) return;

    setState(() {
      isThemeChanging = true;
      // During theme change, show only first 5 characters
      if (allCharacters.isNotEmpty) {
        characters = allCharacters.take(5).toList();
      }
    });

    // After a small delay, restore all characters gradually
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _restoreAllCharactersGradually();
      }
    });
  }

  void _restoreAllCharactersGradually() async {
    if (!mounted || allCharacters.isEmpty) return;

    setState(() {
      isThemeChanging = false;
    });

    // Restore characters in batches of 5, with delay between each batch
    for (int i = 5; i < allCharacters.length; i += 5) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted) break;

      setState(() {
        characters = allCharacters.take(i + 5).toList();
      });
    }
  }

  void _toggleDrawer() {
    setState(() {
      isDrawerOpen = !isDrawerOpen;
    });

    if (isDrawerOpen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (hasMore && !isLoading) {
        _loadMore();
      }
    }
  }

  Future<void> _loadCharacters() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });

      final response = await RickAndMortyService.getCharacters(page: 1);
      setState(() {
        // Store all characters
        allCharacters = response.results;
        // Show all initially (will only limit during theme change)
        characters = response.results;
        currentPage = 1;
        hasMore = response.info.next != null;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (!hasMore || isLoading || isThemeChanging) return;

    try {
      setState(() {
        isLoading = true;
      });

      final response = await RickAndMortyService.getCharacters(
        page: currentPage + 1,
      );
      setState(() {
        // Add new characters to complete list
        allCharacters.addAll(response.results);

        // If not changing theme, show all
        if (!isThemeChanging) {
          characters.addAll(response.results);
        }

        currentPage++;
        hasMore = response.info.next != null;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final style = themeProvider.currentStyle;

        return Scaffold(
          backgroundColor: style == AppStyle.modern
              ? const Color(0xFF0F0F0F) // Darker background for card area
              : const Color(0xFF1A1A1A),
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(style),
                    Container(
                      color: style == AppStyle.modern
                          ? const Color(0xFF1C1B20)
                          : const Color(0xFF1A1A1A),
                      padding: EdgeInsets.fromLTRB(
                        20,
                        style == AppStyle.modern ? 2 : 10,
                        20,
                        style == AppStyle.modern ? 16 : 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'RICK AND MORTY API',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: style == AppStyle.modern
                                  ? FontWeight.w400
                                  : FontWeight.w600,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Container(
                        color: style == AppStyle.modern
                            ? const Color(
                                0xFF0F0F0F,
                              ) // Darker background for cards
                            : const Color(0xFF1A1A1A),
                        child: hasError
                            ? _buildErrorWidget()
                            : isLoading && characters.isEmpty
                            ? _buildLoadingWidget()
                            : _buildCharactersList(style),
                      ),
                    ),
                  ],
                ),
              ),
              if (isDrawerOpen) ...[
                DrawerOverlay(onTap: _toggleDrawer),
                SlideTransition(
                  position: _slideAnimation,
                  child: CustomDrawer(onClose: _toggleDrawer),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(AppStyle style) {
    return Container(
      color: style == AppStyle.modern
          ? const Color(0xFF1C1B20)
          : const Color(0xFF1A1A1A),
      padding: EdgeInsets.fromLTRB(
        20,
        style == AppStyle.modern ? 4 : 20,
        20,
        style == AppStyle.modern ? 4 : 10,
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleDrawer,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(color: Colors.transparent),
                child: const Icon(Icons.menu, color: Colors.white, size: 24),
              ),
            ),
          ),
          const Spacer(),
          Container(
            width: style == AppStyle.modern ? 120 : 60,
            height: style == AppStyle.modern ? 72 : 40,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
          ),
          const Spacer(),
          const ProfileMenu(),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Error loading characters',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadCharacters,
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      ),
    );
  }

  Widget _buildCharactersList(AppStyle style) {
    if (characters.isEmpty) {
      return Center(
        child: Text(
          'No characters loaded',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Column(
      children: [
        // Theme change indicator
        if (isThemeChanging)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      style == AppStyle.modern ? Colors.blue : Colors.purple,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Applying theme...',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),

        // Character list
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              mainAxisSpacing: style == AppStyle.modern ? 12 : 8,
              childAspectRatio: style == AppStyle.modern ? 1.8 : 4.0,
            ),
            itemCount:
                characters.length + (hasMore && !isThemeChanging ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= characters.length) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                );
              }

              final character = characters[index];

              if (style == AppStyle.modern) {
                return CharacterCardModern(
                  character: character,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CharacterDetailScreen(character: character),
                    ),
                  ),
                );
              } else {
                return CharacterCardClassic(
                  character: character,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CharacterDetailScreen(character: character),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
