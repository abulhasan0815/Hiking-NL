import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hiking_app/models/trail.dart';
import 'package:hiking_app/services/trail_service.dart';
import 'package:hiking_app/services/sample_data_service.dart';
import 'package:hiking_app/widgets/trail_card.dart';
import 'package:hiking_app/config/app_theme.dart';

class TrailDiscoveryScreen extends StatefulWidget {
  const TrailDiscoveryScreen({super.key});

  @override
  State<TrailDiscoveryScreen> createState() => _TrailDiscoveryScreenState();
}

class _TrailDiscoveryScreenState extends State<TrailDiscoveryScreen> {
  String? selectedDifficulty;
  String? selectedLocation;
  String sortBy = 'name';
  bool _isLoading = false;
  List<String> locations = [];
  List<String> difficulties = [];

  @override
  void initState() {
    super.initState();
    _loadFilterOptions();
    _checkAndAddSampleData();
  }

  Future<void> _loadFilterOptions() async {
    final trailService = Provider.of<TrailService>(context, listen: false);
    final locationList = await trailService.getTrailLocations();
    final difficultyList = await trailService.getTrailDifficulties();
    setState(() {
      locations = locationList;
      difficulties = difficultyList;
    });
  }

  Future<void> _checkAndAddSampleData() async {
    final sampleDataService = SampleDataService();
    final trailsExist = await sampleDataService.checkIfTrailsExist();
    
    if (!trailsExist) {
      setState(() {
        _isLoading = true;
      });
      await sampleDataService.addSampleTrails();
      setState(() {
        _isLoading = false;
      });
      // Reload filter options after adding sample data
      _loadFilterOptions();
    }
  }

  void _clearFilters() {
    setState(() {
      selectedDifficulty = null;
      selectedLocation = null;
      sortBy = 'name';
    });
  }

  // Apply filters and sorting to the trail list
  List<Trail> _applyFilters(List<Trail> trails) {
    List<Trail> filteredTrails = List.from(trails);

    // Apply difficulty filter
    if (selectedDifficulty != null && selectedDifficulty != 'All') {
      filteredTrails = filteredTrails.where((trail) => trail.difficulty == selectedDifficulty).toList();
    }

    // Apply location filter
    if (selectedLocation != null && selectedLocation != 'All') {
      filteredTrails = filteredTrails.where((trail) => trail.location == selectedLocation).toList();
    }

    // Apply sorting
    switch (sortBy) {
      case 'name':
        filteredTrails.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'length_asc':
        filteredTrails.sort((a, b) => a.length.compareTo(b.length));
        break;
      case 'length_desc':
        filteredTrails.sort((a, b) => b.length.compareTo(a.length));
        break;
      case 'difficulty':
        // Custom sort by difficulty: Easy -> Moderate -> Hard
        final difficultyOrder = {'Easy': 1, 'Moderate': 2, 'Hard': 3};
        filteredTrails.sort((a, b) {
          final aOrder = difficultyOrder[a.difficulty] ?? 0;
          final bOrder = difficultyOrder[b.difficulty] ?? 0;
          return aOrder.compareTo(bOrder);
        });
        break;
      default:
        filteredTrails.sort((a, b) => a.name.compareTo(b.name));
    }

    return filteredTrails;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Trails'),
        elevation: 0,
        centerTitle: true,
        actions: [
          Tooltip(
            message: 'Clear Filters',
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _clearFilters,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Animated Filter Section
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryGreen.withOpacity(0.05),
                  AppTheme.accentGreen.withOpacity(0.02),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.borderGrey,
                  width: 1,
                ),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Difficulty Filter
                DropdownButtonFormField<String>(
                  value: selectedDifficulty,
                  decoration: InputDecoration(
                    labelText: 'Difficulty',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Difficulties')),
                    ...difficulties.map((difficulty) => 
                      DropdownMenuItem(value: difficulty, child: Text(difficulty))
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedDifficulty = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Location and Sort Row
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedLocation,
                        decoration: InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All')),
                          ...locations.map((location) => 
                            DropdownMenuItem(value: location, child: Text(location))
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedLocation = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: sortBy,
                        decoration: InputDecoration(
                          labelText: 'Sort',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'name', child: Text('Name')),
                          DropdownMenuItem(value: 'length_asc', child: Text('Shortest')),
                          DropdownMenuItem(value: 'length_desc', child: Text('Longest')),
                          DropdownMenuItem(value: 'difficulty', child: Text('Difficulty')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            sortBy = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                // Active Filters Display
                if (selectedDifficulty != null || selectedLocation != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.lightGreen,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppTheme.accentGreen.withOpacity(0.3),
                        ),
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (selectedDifficulty != null)
                            Chip(
                              label: Text(
                                'Difficulty: $selectedDifficulty',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              backgroundColor: AppTheme.primaryGreen,
                              labelStyle: const TextStyle(color: AppTheme.white),
                              onDeleted: () {
                                setState(() {
                                  selectedDifficulty = null;
                                });
                              },
                            ),
                          if (selectedLocation != null)
                            Chip(
                              label: Text(
                                'Location: $selectedLocation',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              backgroundColor: AppTheme.accentGreen,
                              labelStyle: const TextStyle(color: AppTheme.white),
                              onDeleted: () {
                                setState(() {
                                  selectedLocation = null;
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Trail List
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: AppTheme.primaryGreen,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading trails...',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : StreamBuilder<List<Trail>>(
                    stream: Provider.of<TrailService>(context).getTrails(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryGreen,
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 64, color: AppTheme.hardRed),
                              const SizedBox(height: 16),
                              Text(
                                'Error loading trails',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                                onPressed: _checkAndAddSampleData,
                              ),
                            ],
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.landscape, size: 64, color: AppTheme.lightText),
                              const SizedBox(height: 16),
                              Text(
                                'No trails available',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.add),
                                label: const Text('Load Sample Trails'),
                                onPressed: _checkAndAddSampleData,
                              ),
                            ],
                          ),
                        );
                      }

                      final allTrails = snapshot.data!;
                      final filteredTrails = _applyFilters(allTrails);

                      if (filteredTrails.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 64, color: AppTheme.lightText),
                              const SizedBox(height: 16),
                              Text(
                                'No trails match your filters',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.clear_all),
                                label: const Text('Clear Filters'),
                                onPressed: _clearFilters,
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: filteredTrails.length,
                        itemBuilder: (context, index) {
                          final trail = filteredTrails[index];
                          return TrailCard(trail: trail);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}