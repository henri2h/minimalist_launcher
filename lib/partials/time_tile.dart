import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeTile extends StatefulWidget {
  const TimeTile({super.key});

  @override
  State<TimeTile> createState() => _TimeTileState();
}

class _TimeTileState extends State<TimeTile> {
  late Timer t;
  @override
  void initState() {
    super.initState();
    t = Timer.periodic(
        const Duration(seconds: 30), (Timer t) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.now();
    final text = DateFormat.yMMMMd().format(date);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(
            "${date.hour}:${date.minute.toString().padLeft(2, '0')}",
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 22)))
        ],
      ),
    );
  }
}
