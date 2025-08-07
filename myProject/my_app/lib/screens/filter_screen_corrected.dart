import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/character.dart';
import '../services/rick_and_morty_service.dart';
import 'character_detail_screen.dart';
import '../widgets/custom_drawer.dart';
import '../providers/theme_provider.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen>
    with TickerProviderStateMixin {
  List<Character> filteredCharacters = [];
  bool isLoading = false;
  bool hasFiltered = false;
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

  void _toggleFilterCollapse() {
    setState(() {
      isFilterCollapsed = !isFilterCollapsed;
    });
  }

  Future<void> _applyFilters() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      hasFiltered = true;
    });

    try {
      List<Character> allCharacters = [];
      int page = 1;
      bool hasMore = true;

      while (hasMore && page <= 5) {
        final response = await RickAndMortyService.getCharacters(page: page);
        allCharacters.addAll(response.results);
        hasMore = response.info.next != null;
        page++;
      }

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
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        filteredCharacters = [];
        isLoading = false;
        errorMessage = 'Error loading characters';
      });
    }
  }

  void _clearFilters() {
    setState(() {
      selectedStatus = null;
      selectedGender = null;
      selectedSpecies = null;
      filteredCharacters = [];
      hasFiltered = false;
      errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final style = themeProvider.currentStyle;
        final backgroundColor = style == AppStyle.modern
            ? const Color(0xFF0F0F0F)
            : const Color(0xFF1A1A1A);
        final headerColor = style == AppStyle.modern
            ? const Color(0xFF1F1F1F)
            : const Color(0xFF1A1A1A);

        return Scaffold(
          backgroundColor: backgroundColor,
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    // Header
                    Container(
                      color: headerColor,
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
                            width: style == AppStyle.modern ? 85 : 60,
                            height: style == AppStyle.modern ? 60 : 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const Spacer(),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {},
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.grey[700]!,
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Title
                    Container(
                      color: headerColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
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

                    const SizedBox(height: 30),

                    // Content area
                    Expanded(
                      child: Container(
                        color: backgroundColor,
                        child: Column(
                          children: [
                            // Filter controls
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2A2A),
                                borderRadius: BorderRadius.circular(12),
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
                                      onChanged: (value) => setState(
                                        () => selectedStatus = value,
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    _buildFilterDropdown(
                                      label: 'Gender',
                                      value: selectedGender,
                                      items: genderOptions,
                                      onChanged: (value) => setState(
                                        () => selectedGender = value,
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    _buildFilterDropdown(
                                      label: 'Species',
                                      value: selectedSpecies,
                                      items: speciesOptions,
                                      onChanged: (value) => setState(
                                        () => selectedSpecies = value,
                                      ),
                                    ),

                                    const SizedBox(height: 24),

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
                                              'Clear',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: _applyFilters,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
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
                                              'Apply',
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

                            Expanded(child: _buildResults()),
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
                  child: const CustomDrawer(),
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
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[700]!),
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

  Widget _buildResults() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
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
              onPressed: _applyFilters,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (!hasFiltered) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.filter_list, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Select filters and tap Apply to see results',
              style: TextStyle(color: Colors.grey, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (filteredCharacters.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No characters found with the selected filters',
              style: TextStyle(color: Colors.grey, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filteredCharacters.length,
      itemBuilder: (context, index) {
        final character = filteredCharacters[index];
        return _buildCharacterCard(character);
      },
    );
  }

  Widget _buildCharacterCard(Character character) {
    Color statusColor;
    switch (character.status.toLowerCase()) {
      case 'alive':
        statusColor = Colors.green;
        break;
      case 'dead':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CharacterDetailScreen(character: character),
            ),
          );
        },
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: character.image,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[800],
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[800],
                      child: const Icon(Icons.error, color: Colors.white),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        character.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${character.status} - ${character.species}',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Last known location:',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            character.location.name,
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
