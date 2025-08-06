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
  List<Character> allCharacters = []; // Lista completa de todos os personagens
  bool isLoading = true;
  bool hasError = false;
  int currentPage = 1;
  bool hasMore = true;
  bool isThemeChanging = false; // Flag para indicar que o tema está mudando
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

    // Escutar mudanças de tema
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

    // Remover listener de tema
    if (mounted) {
      try {
        Provider.of<ThemeProvider>(
          context,
          listen: false,
        ).removeListener(_onThemeChanged);
      } catch (e) {
        // Ignorar erro se o provider já foi removido
      }
    }

    super.dispose();
  }

  void _onThemeChanged() {
    if (!mounted) return;

    setState(() {
      isThemeChanging = true;
      // Durante mudança de tema, mostrar apenas os primeiros 5 personagens
      if (allCharacters.isNotEmpty) {
        characters = allCharacters.take(5).toList();
      }
    });

    // Após um pequeno delay, restaurar todos os personagens gradualmente
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

    // Restaurar personagens em lotes de 5, com delay entre cada lote
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
        // Armazenar todos os personagens
        allCharacters = response.results;
        // Mostrar todos inicialmente (só limitará durante mudança de tema)
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
        // Adicionar novos personagens à lista completa
        allCharacters.addAll(response.results);

        // Se não estamos mudando tema, mostrar todos
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
            width: style == AppStyle.modern ? 80 : 60, // Logo maior no modern
            height: style == AppStyle.modern ? 55 : 40, // Logo maior no modern
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
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
        // Indicador de mudança de tema
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
                  'Aplicando tema...',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),

        // Lista de personagens
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 5),
            itemCount:
                characters.length + (hasMore && !isThemeChanging ? 1 : 0),
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
