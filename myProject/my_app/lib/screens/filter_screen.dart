import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/character.dart';
import '../services/rick_and_morty_service.dart';
import 'character_detail_screen.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/character_card_modern.dart';
import '../widgets/character_card_classic.dart';
import '../providers/theme_provider.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  List<Character> allCharacters = [];
  List<Character> filteredCharacters = [];
  bool isLoading = false;
  bool hasMore = true;
  int currentPage = 1;
  String? errorMessage;
  bool isDrawerOpen = false;
  bool isFilterCollapsed = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  // Filtros
  String? selectedStatus;
  String? selectedGender;
  String? selectedSpecies;

  final List<String> statusOptions = ['alive', 'dead', 'unknown'];
  final List<String> genderOptions = [
    'female',
    'male',
    'genderless',
    'unknown',
  ];
  final List<String> speciesOptions = [
    'human',
    'alien',
    'humanoid',
    'robot',
    'animal',
    'disease',
    'mythological creature',
  ];

  @override
  void initState() {
    super.initState();
    _loadAllCharacters();
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

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (hasMore && !isLoading) {
        _loadMore();
      }
    }
  }

  Future<void> _loadAllCharacters() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await RickAndMortyService.getCharacters(page: 1);
      setState(() {
        allCharacters = response.results;
        filteredCharacters = response.results;
        currentPage = 1;
        hasMore = response.info.next != null;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error loading characters';
      });
    }
  }

  Future<void> _loadMore() async {
    if (!hasMore || isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await RickAndMortyService.getCharacters(
        page: currentPage + 1,
      );
      setState(() {
        allCharacters.addAll(response.results);
        currentPage++;
        hasMore = response.info.next != null;
        isLoading = false;
        _applyFiltersToAllCharacters();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _applyFiltersToAllCharacters() {
    List<Character> filtered = allCharacters.where((character) {
      bool matchesStatus =
          selectedStatus == null ||
          character.status.toLowerCase() == selectedStatus!.toLowerCase();

      bool matchesGender =
          selectedGender == null ||
          character.gender.toLowerCase() == selectedGender!.toLowerCase();

      bool matchesSpecies =
          selectedSpecies == null ||
          character.species.toLowerCase() == selectedSpecies!.toLowerCase();

      return matchesStatus && matchesGender && matchesSpecies;
    }).toList();

    setState(() {
      filteredCharacters = filtered;
    });
  }

  void _onFilterChanged() {
    _applyFiltersToAllCharacters();
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

  void _toggleFilterCollapse() {
    setState(() {
      isFilterCollapsed = !isFilterCollapsed;
    });
  }

  void _clearFilters() {
    setState(() {
      selectedStatus = null;
      selectedGender = null;
      selectedSpecies = null;
    });
    _applyFiltersToAllCharacters();
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
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/icon.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
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
                            'FILTER CHARACTERS',
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

                    // Content area
                    Expanded(
                      child: Container(
                        color: style == AppStyle.modern
                            ? const Color(0xFF0F0F0F)
                            : const Color(0xFF1A1A1A),
                        child: Column(
                          children: [
                            // Filter controls
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: style == AppStyle.modern
                                    ? const Color(0xFF2A2A2A)
                                    : const Color(0xFF2D2D30),
                                borderRadius: BorderRadius.circular(12),
                                border: style == AppStyle.classic
                                    ? Border.all(
                                        color: Colors.white.withOpacity(0.1),
                                        width: 1,
                                      )
                                    : null,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Filters',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: _toggleFilterCollapse,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            child: Icon(
                                              isFilterCollapsed
                                                  ? Icons.expand_more
                                                  : Icons.expand_less,
                                              color: Colors.grey[400],
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  if (!isFilterCollapsed) ...[
                                    const SizedBox(height: 20),

                                    _buildFilterDropdown(
                                      label: 'Status',
                                      value: selectedStatus,
                                      items: statusOptions,
                                      onChanged: (value) {
                                        setState(() => selectedStatus = value);
                                        _onFilterChanged();
                                      },
                                      style: style,
                                    ),

                                    const SizedBox(height: 16),

                                    _buildFilterDropdown(
                                      label: 'Gender',
                                      value: selectedGender,
                                      items: genderOptions,
                                      onChanged: (value) {
                                        setState(() => selectedGender = value);
                                        _onFilterChanged();
                                      },
                                      style: style,
                                    ),

                                    const SizedBox(height: 16),

                                    _buildFilterDropdown(
                                      label: 'Species',
                                      value: selectedSpecies,
                                      items: speciesOptions,
                                      onChanged: (value) {
                                        setState(() => selectedSpecies = value);
                                        _onFilterChanged();
                                      },
                                      style: style,
                                    ),

                                    const SizedBox(height: 24),

                                    // Apenas botão Clear
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: _clearFilters,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.grey[700],
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text(
                                              'Clear All Filters',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            Expanded(child: _buildResults(style)),
                          ],
                        ),
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

  Widget _buildFilterDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required AppStyle style,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: style == AppStyle.modern
                ? const Color(0xFF1A1A1A)
                : const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: style == AppStyle.modern
                  ? Colors.grey[700]!
                  : Colors.purple.withOpacity(0.3),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(
                'Select $label',
                style: TextStyle(color: Colors.grey[500]),
              ),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              dropdownColor: const Color(0xFF2A2A2A),
              style: const TextStyle(color: Colors.white),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item.toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResults(AppStyle style) {
    if (isLoading && filteredCharacters.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            style == AppStyle.modern ? Colors.blue : Colors.purple,
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAllCharacters,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (filteredCharacters.isEmpty) {
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
              'No characters found with the selected filters',
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
        // Loading indicator para carregamento de mais personagens
        if (isLoading && filteredCharacters.isNotEmpty)
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
                  'Loading more characters...',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),

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
                filteredCharacters.length + (hasMore && !isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= filteredCharacters.length) {
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

              final character = filteredCharacters[index];

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
