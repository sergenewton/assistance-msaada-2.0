import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:vbg_platform_mobile/core/errors/failures.dart';
import 'package:vbg_platform_mobile/features/auth/domain/entities/user.dart';
import 'package:vbg_platform_mobile/features/auth/domain/usecases/login_user.dart';
import 'package:vbg_platform_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:vbg_platform_mobile/features/auth/presentation/providers/auth_state_provider.dart';

class MockLoginUser extends Mock implements LoginUser {}

void main() {
  late MockLoginUser mockLoginUser;
  late ProviderContainer container;

  setUp(() {
    mockLoginUser = MockLoginUser();
    container = ProviderContainer(
      overrides: [
        loginUserProvider.overrideWithValue(mockLoginUser),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  final tUser = User(
    id: '1',
    email: tEmail,
    name: 'Test User',
    createdAt: DateTime.now(),
    isVerified: true,
  );

  group('AuthNotifier', () {
    test('initial state should be correct', () {
      final notifier = container.read(authNotifierProvider.notifier);
      final state = container.read(authNotifierProvider);

      expect(state.user, isNull);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.isAuthenticated, false);
    });

    test('should emit loading then success when login is successful', () async {
      // arrange
      when(() => mockLoginUser(any()))
          .thenAnswer((_) async => const Right(tUser));

      // act
      final notifier = container.read(authNotifierProvider.notifier);
      
      // Listen to state changes
      final states = <AuthState>[];
      container.listen(
        authNotifierProvider,
        (previous, next) => states.add(next),
        fireImmediately: true,
      );

      await notifier.login(email: tEmail, password: tPassword);

      // assert
      expect(states.length, 3);
      expect(states[0].isLoading, false); // initial
      expect(states[1].isLoading, true);  // loading
      expect(states[2].isLoading, false); // success
      expect(states[2].user, tUser);
      expect(states[2].isAuthenticated, true);
      expect(states[2].error, isNull);
    });

    test('should emit loading then error when login fails', () async {
      // arrange
      when(() => mockLoginUser(any()))
          .thenAnswer((_) async => const Left(AuthenticationFailure('Invalid credentials')));

      // act
      final notifier = container.read(authNotifierProvider.notifier);
      
      final states = <AuthState>[];
      container.listen(
        authNotifierProvider,
        (previous, next) => states.add(next),
        fireImmediately: true,
      );

      await notifier.login(email: tEmail, password: tPassword);

      // assert
      expect(states.length, 3);
      expect(states[0].isLoading, false); // initial
      expect(states[1].isLoading, true);  // loading
      expect(states[2].isLoading, false); // error
      expect(states[2].user, isNull);
      expect(states[2].isAuthenticated, false);
      expect(states[2].error, 'Invalid credentials');
    });

    test('should clear state when logout is called', () {
      // arrange
      when(() => mockLoginUser(any()))
          .thenAnswer((_) async => const Right(tUser));

      final notifier = container.read(authNotifierProvider.notifier);

      // act - login first
      notifier.login(email: tEmail, password: tPassword);
      // then logout
      notifier.logout();

      final finalState = container.read(authNotifierProvider);

      // assert
      expect(finalState.user, isNull);
      expect(finalState.isLoading, false);
      expect(finalState.error, isNull);
      expect(finalState.isAuthenticated, false);
    });
  });
}