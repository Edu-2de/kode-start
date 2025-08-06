import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/character.dart';
import '../services/rick_and_morty_service.dart';
import 'character_detail_screen.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/character_card_modern.dart';
import '../widgets/character_card_classic.dart';
import '../providers/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<Character> characters = [];
  bool isLoading = true;
  bool hasError = false;
  int currentPage = 1;
  bool hasMore = true;
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
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
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
        // Limitar a apenas 10 personagens para melhor performance
        characters = response.results.take(10).toList();
        currentPage = 1;
        hasMore = false; // Desabilitar carregamento de mais personagens
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
    if (!hasMore || isLoading) return;

    try {
      setState(() {
        isLoading = true;
      });

      final response = await RickAndMortyService.getCharacters(
        page: currentPage + 1,
      );
      setState(() {
        characters.addAll(response.results);
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final style = themeProvider.currentStyle;

    return Scaffold(
      backgroundColor: style == AppStyle.modern
          ? const Color(0xFF18181B)
          : const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(style),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
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
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: hasError
                      ? _buildErrorWidget()
                      : isLoading && characters.isEmpty
                      ? _buildLoadingWidget()
                      : _buildCharactersList(style),
                ),
              ],
            ),
          ),
          if (isDrawerOpen) ...[
            DrawerOverlay(onTap: _toggleDrawer),
            SlideTransition(
              position: _slideAnimation,
              child: const CustomDrawer(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(AppStyle style) {
    return Container(
      color: style == AppStyle.modern
          ? const Color(0xFF18181B)
          : const Color(0xFF1A1A1A),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleDrawer,
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 24,
                height: 24,
                child: const Icon(Icons.menu, color: Colors.white, size: 24),
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: style == AppStyle.modern ? 80 : 60,
            height: style == AppStyle.modern ? 55 : 40,
            child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
          ),
          const Spacer(),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
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
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 5),
      itemCount: characters.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= characters.length) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
          );
        }

        final character = characters[index];

        return style == AppStyle.modern
            ? CharacterCardModern(
                character: character,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CharacterDetailScreen(character: character),
                    ),
                  );
                },
              )
            : CharacterCardClassic(
                character: character,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CharacterDetailScreen(character: character),
                    ),
                  );
                },
              );
      },
    );
  }
}
