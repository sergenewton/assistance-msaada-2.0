import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:vbg_platform_mobile/core/errors/failures.dart';
import 'package:vbg_platform_mobile/features/auth/domain/entities/user.dart';
import 'package:vbg_platform_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:vbg_platform_mobile/features/auth/domain/usecases/login_user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUser usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = LoginUser(mockAuthRepository);
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

  test(
    'should get user from the repository when login is successful',
    () async {
      // arrange
      when(() => mockAuthRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const Right(tUser));

      // act
      final result = await usecase(LoginUserParams(
        email: tEmail,
        password: tPassword,
      ));

      // assert
      expect(result, const Right(tUser));
      verify(() => mockAuthRepository.login(
            email: tEmail,
            password: tPassword,
          ));
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );

  test(
    'should return authentication failure when login fails with wrong credentials',
    () async {
      // arrange
      when(() => mockAuthRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const Left(AuthenticationFailure('Invalid credentials')));

      // act
      final result = await usecase(LoginUserParams(
        email: tEmail,
        password: 'wrong_password',
      ));

      // assert
      expect(result, const Left(AuthenticationFailure('Invalid credentials')));
      verify(() => mockAuthRepository.login(
            email: tEmail,
            password: 'wrong_password',
          ));
    },
  );
}