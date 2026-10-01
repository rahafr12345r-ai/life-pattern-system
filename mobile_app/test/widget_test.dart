import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:life_pattern_mobile/features/authentication/sign_in_screen.dart';

void main() {
  testWidgets('Life Pattern app starts at sign in', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignInScreen()));

    expect(find.text('Sign in to your account'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
