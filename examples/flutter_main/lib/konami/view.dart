part of 'konami.dart';

class KonamiPage extends StatefulWidget {
  const KonamiPage({super.key});

  @override
  State<KonamiPage> createState() => _KonamiPageState();
}

class _KonamiPageState extends State<KonamiPage> {
  late final Controller controller;

  late final fNode = FocusNode(
    onKey: (node, e) {
      controller.keys.set(e.data.logicalKey.keyLabel, force: true);
      return KeyEventResult.handled;
    },
  );

  static const checker = IterableEquality();

  @override
  void initState() {
    controller = Controller();

    controller.last10.subscribe((codes) {
      if (codes.isEmpty) return;
      final won = checker.equals(codes, konamiCodes);

      if (won) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Congratulations!'),
              content: const Text('KONAMI! You won!'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Keep trying!'),
            duration: Duration(seconds: 2),
            padding: EdgeInsets.all(20),
          ),
        );
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    fNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: controller,
      child: KeyboardListener(
        autofocus: true,
        focusNode: fNode,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text('Enter the Konamic Codes', style: k32Text),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    KeyText('^'),
                    KeyText('^'),
                    KeyText('v'),
                    KeyText('v'),
                    KeyText('<'),
                    KeyText('>'),
                    KeyText('<'),
                    KeyText('>'),
                    KeyText('B'),
                    KeyText('A'),
                  ],
                ),
              ],
            ),
            ResetButton(),
            LastKey(),
          ],
        ),
      ),
    );
  }
}

class LastKey extends StatelessWidget {
  const LastKey({super.key});

  @override
  Widget build(BuildContext context) {
    final last10 = context.read<Controller>().last10;
    final keys = last10.currentBuffer.watch(context);
    final lastKey = keys.lastOrNull;

    if (lastKey != null) {
      return Text('$lastKey (${keys.length})', style: k32Text);
    }
    return const Text('start typing...', style: k32Text);
  }
}

class KeyText extends StatelessWidget {
  const KeyText(this.char, {super.key});

  final String char;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(3),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.onSurface),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        char,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ResetButton extends StatelessWidget {
  const ResetButton({super.key});

  @override
  Widget build(BuildContext context) {
    final last10 = context.read<Controller>().last10;
    final keys = context.read<Controller>().keys;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          foregroundColor: Theme.of(context).colorScheme.onTertiary,
          textStyle: k24Text,
          minimumSize: const Size(100, 100)),
      onPressed: () {
        keys.reset();
        last10.reset();
      },
      child: const Text('Reset'),
    );
  }
}