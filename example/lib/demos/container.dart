import 'package:flutter/cupertino.dart';
import 'package:cupertino_native/cupertino_native.dart';

class ContainerDemoPage extends StatelessWidget {
  const ContainerDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Container Demo')),
      child: SafeArea(
        child: Center(
          child: CNContainer(
            width: 100,
            height: 100,
            isInteractive: true,
            style: GlassStyle.regular,
          ),
        ),
      ),
    );
  }
}
