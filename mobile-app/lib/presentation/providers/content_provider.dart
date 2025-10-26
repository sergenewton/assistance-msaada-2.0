import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/content_model.dart';

// State classes
class ContentState {
  final List<ContentModel> articles;
  final List<ContentModel> videos;
  final List<ContentModel> searchResults;
  final bool isLoading;
  final bool isSearching;
  final String? error;
  final ContentModel? selectedContent;
  final String searchQuery;

  const ContentState({
    this.articles = const [],
    this.videos = const [],
    this.searchResults = const [],
    this.isLoading = false,
    this.isSearching = false,
    this.error,
    this.selectedContent,
    this.searchQuery = '',
  });

  ContentState copyWith({
    List<ContentModel>? articles,
    List<ContentModel>? videos,
    List<ContentModel>? searchResults,
    bool? isLoading,
    bool? isSearching,
    String? error,
    ContentModel? selectedContent,
    String? searchQuery,
  }) {
    return ContentState(
      articles: articles ?? this.articles,
      videos: videos ?? this.videos,
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      error: error,
      selectedContent: selectedContent ?? this.selectedContent,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// Content provider
class ContentNotifier extends StateNotifier<ContentState> {
  ContentNotifier() : super(const ContentState());

  Future<void> loadArticles() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // This would call the actual use case
      await Future.delayed(const Duration(seconds: 1)); // Simulate loading
      
      // Mock data for now
      final articles = <ContentModel>[
        ContentModel(
          id: '1',
          title: 'Comment reconnaître les signes de violence',
          description: 'Guide complet pour identifier les différents types de violence',
          type: ContentType.article,
          content: 'Contenu de l\'article...',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        ContentModel(
          id: '2',
          title: 'Ressources d\'aide disponibles',
          description: 'Liste des organisations et services d\'assistance',
          type: ContentType.article,
          content: 'Contenu de l\'article...',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];
      
      state = state.copyWith(
        isLoading: false,
        articles: articles,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadVideos() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // This would call the actual use case
      await Future.delayed(const Duration(seconds: 1)); // Simulate loading
      
      // Mock data for now
      final videos = <ContentModel>[
        ContentModel(
          id: '3',
          title: 'Témoignage: Sortir de la violence',
          description: 'Témoignage inspirant d\'une survivante',
          type: ContentType.video,
          content: 'URL de la vidéo...',
          videoUrl: 'https://example.com/video1',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        ContentModel(
          id: '4',
          title: 'Techniques de gestion du stress',
          description: 'Exercices pratiques pour gérer l\'anxiété',
          type: ContentType.video,
          content: 'URL de la vidéo...',
          videoUrl: 'https://example.com/video2',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ];
      
      state = state.copyWith(
        isLoading: false,
        videos: videos,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> searchContent(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(
        searchResults: [],
        searchQuery: '',
        isSearching: false,
      );
      return;
    }

    state = state.copyWith(isSearching: true, error: null, searchQuery: query);
    
    try {
      // This would call the actual search use case
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate search
      
      // Mock search results
      final allContent = [...state.articles, ...state.videos];
      final searchResults = allContent.where((content) {
        return content.title.toLowerCase().contains(query.toLowerCase()) ||
               content.description.toLowerCase().contains(query.toLowerCase());
      }).toList();
      
      state = state.copyWith(
        isSearching: false,
        searchResults: searchResults,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isSearching: false,
        error: e.toString(),
      );
    }
  }

  void selectContent(ContentModel content) {
    state = state.copyWith(selectedContent: content);
  }

  void clearSelectedContent() {
    state = state.copyWith(selectedContent: null);
  }

  void clearSearch() {
    state = state.copyWith(
      searchResults: [],
      searchQuery: '',
      isSearching: false,
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider instances
final contentProvider = StateNotifierProvider<ContentNotifier, ContentState>((ref) {
  return ContentNotifier();
});

// Individual providers for specific data
final articlesProvider = Provider<List<ContentModel>>((ref) {
  return ref.watch(contentProvider).articles;
});

final videosProvider = Provider<List<ContentModel>>((ref) {
  return ref.watch(contentProvider).videos;
});

final searchResultsProvider = Provider<List<ContentModel>>((ref) {
  return ref.watch(contentProvider).searchResults;
});

final contentLoadingProvider = Provider<bool>((ref) {
  return ref.watch(contentProvider).isLoading;
});

final contentSearchingProvider = Provider<bool>((ref) {
  return ref.watch(contentProvider).isSearching;
});

final contentErrorProvider = Provider<String?>((ref) {
  return ref.watch(contentProvider).error;
});

final selectedContentProvider = Provider<ContentModel?>((ref) {
  return ref.watch(contentProvider).selectedContent;
});

final searchQueryProvider = Provider<String>((ref) {
  return ref.watch(contentProvider).searchQuery;
});

// Derived providers
final hasSearchResultsProvider = Provider<bool>((ref) {
  return ref.watch(searchResultsProvider).isNotEmpty;
});

final isSearchActiveProvider = Provider<bool>((ref) {
  return ref.watch(searchQueryProvider).isNotEmpty;
});

final recentContentProvider = Provider<List<ContentModel>>((ref) {
  final articles = ref.watch(articlesProvider);
  final videos = ref.watch(videosProvider);
  final allContent = [...articles, ...videos];
  
  // Sort by creation date and take the 5 most recent
  allContent.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return allContent.take(5).toList();
});