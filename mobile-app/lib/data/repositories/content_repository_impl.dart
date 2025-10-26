import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/network_info.dart';
import '../models/content_model.dart';
// Removed missing import; an abstract ContentRemoteDataSource is defined below as a placeholder.
import '../datasources/local/cache_datasource.dart';

abstract class ContentRepository {
  Future<Either<Failure, List<ContentModel>>> getArticles({int page = 1, int limit = 20});
  Future<Either<Failure, List<ContentModel>>> getVideos({int page = 1, int limit = 20});
  Future<Either<Failure, ContentModel>> getContentById(String id);
  Future<Either<Failure, List<ContentModel>>> searchContent(String query);
  Future<Either<Failure, void>> incrementViewCount(String contentId);
}

class ContentRepositoryImpl implements ContentRepository {
  final ContentRemoteDataSource remoteDataSource;
  final CacheDataSource cacheDataSource;
  final NetworkInfo networkInfo;

  ContentRepositoryImpl({
    required this.remoteDataSource,
    required this.cacheDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<ContentModel>>> getArticles({int page = 1, int limit = 20}) async {
    try {
      if (await networkInfo.isConnected) {
        final articles = await remoteDataSource.getArticles(page: page, limit: limit);
        
        // Cache the articles
        for (final article in articles) {
          await cacheDataSource.cacheContent(article);
        }
        
        return Right(articles);
      } else {
        // If no internet, get from cache
        final cachedArticles = await cacheDataSource.getCachedContent(ContentType.article);
        return Right(cachedArticles);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ContentModel>>> getVideos({int page = 1, int limit = 20}) async {
    try {
      if (await networkInfo.isConnected) {
        final videos = await remoteDataSource.getVideos(page: page, limit: limit);
        
        // Cache the videos
        for (final video in videos) {
          await cacheDataSource.cacheContent(video);
        }
        
        return Right(videos);
      } else {
        // If no internet, get from cache
        final cachedVideos = await cacheDataSource.getCachedContent(ContentType.video);
        return Right(cachedVideos);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ContentModel>> getContentById(String id) async {
    try {
      if (await networkInfo.isConnected) {
        final content = await remoteDataSource.getContentById(id);
        
        // Cache the content
        await cacheDataSource.cacheContent(content);
        
        return Right(content);
      } else {
        // If no internet, get from cache
        final cachedContent = await cacheDataSource.getCachedContentById(id);
        if (cachedContent != null) {
          return Right(cachedContent);
        } else {
          return const Left(CacheFailure('Content not found in cache'));
        }
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ContentModel>>> searchContent(String query) async {
    try {
      if (await networkInfo.isConnected) {
        final results = await remoteDataSource.searchContent(query);
        
        // Cache the results
        for (final content in results) {
          await cacheDataSource.cacheContent(content);
        }
        
        return Right(results);
      } else {
        // If no internet, search in cache
        final cachedResults = await cacheDataSource.searchCachedContent(query);
        return Right(cachedResults);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> incrementViewCount(String contentId) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.incrementViewCount(contentId);
        return const Right(null);
      } else {
        // Store view count increment for later sync
        await cacheDataSource.cachePendingViewIncrement(contentId);
        return const Right(null);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}

// Note: ContentRemoteDataSource needs to be created
abstract class ContentRemoteDataSource {
  Future<List<ContentModel>> getArticles({int page = 1, int limit = 20});
  Future<List<ContentModel>> getVideos({int page = 1, int limit = 20});
  Future<ContentModel> getContentById(String id);
  Future<List<ContentModel>> searchContent(String query);
  Future<void> incrementViewCount(String contentId);
}