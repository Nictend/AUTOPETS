// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pet_feeder/main.dart';

void main() {
  testWidgets('renders the pet feeder dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const PetFeederApp());

    expect(find.text('PetFeeder'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Alimentar agora'),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Alimentar agora'), findsOneWidget);
  });

  testWidgets('navigates through all feeder areas', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PetFeederApp());

    await tester.tap(find.text('Ração'));
    await tester.pumpAndSettle();
    expect(find.text('PORÇÃO MANUAL'), findsOneWidget);

    await tester.tap(find.text('Água'));
    await tester.pumpAndSettle();
    expect(find.text('VOLUME MANUAL'), findsOneWidget);

    await tester.tap(find.text('Horários'));
    await tester.pumpAndSettle();
    expect(find.text('Novo horário'), findsOneWidget);

    await tester.tap(find.text('Histórico'));
    await tester.pumpAndSettle();
    expect(find.text('Refeições recentes'), findsOneWidget);

    await tester.tap(find.text('Ajustes'));
    await tester.pumpAndSettle();
    expect(find.text('Conexão da máquina'), findsOneWidget);
  });

  testWidgets('closes and saves name, breed, age and species safely', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PetFeederApp());
    await tester.tap(find.text('Ajustes'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('Thor'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Luna');
    await tester.enterText(find.byType(TextField).at(1), 'Border Collie');
    await tester.enterText(find.byType(TextField).at(2), '4');
    await tester.tap(find.text('Gato'));
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Luna'), findsOneWidget);
    expect(
      find.textContaining('Gato · Border Collie · 4 anos'),
      findsOneWidget,
    );
    expect(find.text('🐱'), findsOneWidget);
  });

  testWidgets('releases water and updates the reservoir level', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PetFeederApp());
    await tester.tap(find.text('Água'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Liberar 250 ml'),
      300,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.text('Liberar 250 ml'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();

    await tester.drag(find.byType(Scrollable), const Offset(0, 900));
    await tester.pumpAndSettle();
    expect(find.text('70% · 1,4 L disponível'), findsOneWidget);
  });
}
