import 'package:flutter/material.dart';
import 'base_page.dart';

/// Example page demonstrating how to use BasePage
class ExamplePage extends BasePage {
  const ExamplePage({super.key}) : super(title: 'Example Page');

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends BasePageState<ExamplePage> {
  int _counter = 0;

  @override
  void onInitState() {
    // Custom initialization logic
    print('ExamplePage initialized');
  }

  @override
  void onDispose() {
    // Custom cleanup logic
    print('ExamplePage disposed');
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });

    if (_counter > 5) {
      showSuccess('Counter is greater than 5!');
    }
  }

  void _showErrorExample() {
    showError('This is an example error message');
  }

  void _showLoadingExample() async {
    showLoading();

    // Simulate some async operation
    await Future.delayed(const Duration(seconds: 2));

    hideLoading();
    showSuccess('Loading completed!');
  }

  void _showConfirmationExample() async {
    final confirmed = await showConfirmationDialog(
      title: 'Confirmation',
      content: 'Are you sure you want to reset the counter?',
    );

    if (confirmed) {
      setState(() {
        _counter = 0;
      });
      showSuccess('Counter reset!');
    }
  }

  @override
  Widget buildBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('You have pushed the button this many times:'),
        Text('$_counter', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _incrementCounter,
          child: const Text('Increment Counter'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _showErrorExample,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Show Error'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _showLoadingExample,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: const Text('Show Loading'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _showConfirmationExample,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: const Text('Show Confirmation'),
        ),
      ],
    );
  }
}
