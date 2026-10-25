import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:esptv_player/core/widgets/remote_action.dart';
import 'package:esptv_player/core/widgets/remote_text_field.dart';
import 'package:esptv_player/core/utils/device_capabilities.dart';

void main() {
  testWidgets('TV fields open the keyboard only after OK, then return to navigation', (tester) async {
    DeviceCapabilities.isTv = true;
    addTearDown(() => DeviceCapabilities.isTv = false);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: Column(children: [
      RemoteAction(autofocus: true, onTap: () {}, child: const Text('Start')),
      const RemoteTextField(decoration: InputDecoration(hintText: 'TV input')),
    ]))));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(tester.testTextInput.isVisible, isFalse);
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pump();
    expect(tester.testTextInput.isVisible, isTrue);
    await tester.enterText(find.byType(TextField), 'TV text');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(tester.testTextInput.isVisible, isFalse);
  });
  testWidgets('D-pad moves focus and select activates only the selected card', (
    tester,
  ) async {
    var first = 0, second = 0, options = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              RemoteAction(
                autofocus: true,
                onTap: () => first++,
                child: const SizedBox(
                  width: 100,
                  height: 100,
                  child: Text('First'),
                ),
              ),
              RemoteAction(
                onTap: () => second++,
                onLongPress: () => options++,
                child: const SizedBox(
                  width: 100,
                  height: 100,
                  child: Text('Second'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    expect(first, 1);
    expect(second, 0);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    expect(first, 1);
    expect(second, 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.contextMenu);
    expect(options, 1);
  });
}
