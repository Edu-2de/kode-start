import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/character.dart';
import '../services/rick_and_morty_service.dart';
import 'character_detail_screen.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/character_card_modern.dart';
import '../widgets/character_card_classic.dart';
import '../widgets/profile_menu_new.dart';
import '../providers/theme_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Character> searchResults = [];
  bool isLoading = false;
  bool hasSearched = false;
  bool hasMore = false;
  int currentPage = 1;
  String? errorMessage;
  bool isDrawerOpen = false;
  String lastQuery = '';
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
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

    // Listen for text changes with debounce
    _searchController.addListener(() {
      final query = _searchController.text.trim();
      if (query != lastQuery) {
        lastQuery = query;
        if (query.isNotEmpty) {
          _debounceSearch(query);
        } else {
          _clearSearch();
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _debounceSearch(String query) {
    // Cancel any existing timer
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_searchController.text.trim() == query && mounted) {
        _searchCharacters(query, isNewSearch: true);
      }
    });
  }

  void _clearSearch() {
    setState(() {
      searchResults = [];
      hasSearched = false;
      hasMore = false;
      errorMessage = null;
      currentPage = 1;
    });
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
      if (hasMore && !isLoading && lastQuery.isNotEmpty) {
        _searchCharacters(lastQuery, isNewSearch: false);
      }
    }
  }

  Future<void> _searchCharacters(
    String query, {
    required bool isNewSearch,
  }) async {
    if (query.trim().isEmpty) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
      if (isNewSearch) {
        hasSearched = true;
        searchResults = [];
        currentPage = 1;
      }
    });

    try {
      final response = await RickAndMortyService.searchCharacters(
        query.trim(),
        page: isNewSearch ? 1 : currentPage + 1,
      );

      setState(() {
        if (isNewSearch) {
          searchResults = response.results;
          currentPage = 1;
        } else {
          searchResults.addAll(response.results);
          currentPage++;
        }
        hasMore = response.info.next != null;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        if (isNewSearch) {
          searchResults = [];
        }
        isLoading = false;
        errorMessage = 'No character found with that name';
        hasMore = false;
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
              ? const Color(0xFF0F0F0F)
              : const Color(0xFF1A1A1A),
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    // Header igual à home
                    Container(
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
                                decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                child: const Icon(
                                  Icons.menu,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: style == AppStyle.modern ? 120 : 60,
                            height: style == AppStyle.modern ? 72 : 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const Spacer(),
                          // Profile Menu
                          const ProfileMenu(),
                        ],
                      ),
                    ),
                    // Title
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
                            'SEARCH CHARACTERS',
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
                    const SizedBox(height: 20),

                    // Search field
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: style == AppStyle.modern
                            ? const Color(0xFF2A2A2A)
                            : const Color(0xFF2D2D30),
                        borderRadius: BorderRadius.circular(12),
                        border: style == AppStyle.classic
                            ? Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                                width: 1,
                              )
                            : null,
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Type to search characters...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Results
                    Expanded(child: _buildSearchResults(style)),
                  ],
                ),
              ),

              // Drawer
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

  Widget _buildSearchResults(AppStyle style) {
    if (!hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: style == AppStyle.modern ? Colors.grey[600] : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Type a character name to search',
              style: TextStyle(
                color: style == AppStyle.modern
                    ? Colors.grey[400]
                    : Colors.grey,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (isLoading && searchResults.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            style == AppStyle.modern ? Colors.blue : Colors.purple,
          ),
        ),
      );
    }

    if (errorMessage != null && searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: style == AppStyle.modern ? Colors.grey[600] : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: TextStyle(
                color: style == AppStyle.modern
                    ? Colors.grey[400]
                    : Colors.grey,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              mainAxisSpacing: style == AppStyle.modern ? 12 : 8,
              childAspectRatio: style == AppStyle.modern ? 1.8 : 4.0,
            ),
            itemCount: searchResults.length + (hasMore && isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= searchResults.length) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        style == AppStyle.modern ? Colors.blue : Colors.purple,
                      ),
                    ),
                  ),
                );
              }

              final character = searchResults[index];

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
