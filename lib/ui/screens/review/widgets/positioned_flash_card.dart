
import 'package:flash_card/flash_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/word.dart';
import '../../../../generated/assets.dart';
import '../../../commons/rounded_button.dart';
import '../../../commons/svg_button.dart';
import '../../vocabulary/bloc/vocabulary_bloc.dart';

part 'side_card.dart';

enum FlashCardStatus { checkBack, mastered }

class PositionedFlashCardController {
  late Future<void> Function() checkBack;
  late Future<void> Function() mastered;
}

class PositionedFlashCard extends StatefulWidget {
  final Word word;
  final PositionedFlashCardController? controller;

  const PositionedFlashCard({
    super.key,
    required this.word,
    this.controller,
  });
  static final _animateDuration = const Duration(milliseconds: 500);

  @override
  State<PositionedFlashCard> createState() => _PositionedFlashCardState();
}

class _PositionedFlashCardState extends State<PositionedFlashCard> {
  FlashCardStatus? _status;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final word = widget.word;
    double cardWidth = (size.width * 0.7) <= 600 ? (size.width * 0.7) : 600;
    final center = size.width / 2 - cardWidth / 2;
    return AnimatedPositioned(
      left: _status == FlashCardStatus.mastered ? null : (_status == FlashCardStatus.checkBack ? - size.width : center),
      right: _status == FlashCardStatus.checkBack ? null : (_status == FlashCardStatus.mastered ? - size.width : center),
      duration: PositionedFlashCard._animateDuration,
      curve: Curves.easeInOut,
      child: Container(
        color: Colors.red.withValues(alpha: 0),
        child: FlashCard(
          height: size.height * 0.4,
          width: cardWidth,
          frontWidget: () => SideCard(
            word: word,
            isFront: false,
            status: _status,
          ),
          backWidget: () => SideCard(
            word: word,
            isFront: true,
            status: _status,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      widget.controller!.checkBack = _checkBack;
      widget.controller!.mastered = _mastered;
    }
  }

  Future<void> _checkBack() async {
    setState(() {
      _status = FlashCardStatus.checkBack;
    });
    await Future.delayed(PositionedFlashCard._animateDuration);
    setState(() {
      _status = null;
    });
  }

  Future<void> _mastered() async {
    setState(() {
      _status = FlashCardStatus.mastered;
    });
    await Future.delayed(PositionedFlashCard._animateDuration);
    setState(() {
      _status = null;
    });
  }
}
