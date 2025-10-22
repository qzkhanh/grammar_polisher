import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../data/models/word.dart';
import '../../../../data/models/word_status.dart';
import '../../../../data/repositories/oxford_words_repository.dart';

part 'vocabulary_event.dart';

part 'vocabulary_state.dart';

part 'generated/vocabulary_bloc.freezed.dart';

class VocabularyBloc extends Bloc<VocabularyEvent, VocabularyState> {
  final OxfordWordsRepository _oxfordWordsRepository;

  VocabularyBloc({
    required OxfordWordsRepository oxfordWordsRepository,
  })  : _oxfordWordsRepository = oxfordWordsRepository,
        super(const VocabularyState()) {
    on<VocabularyEvent>((event, emit) async {
      await event.map(
        getAllOxfordWords: (event) => _onGetAllOxfordWords(event, emit),
        changeStatus: (event) => _onChangeStatus(event, emit),
        editDefinition: (event) => _onEditDefinition(event, emit),
        addWordRandomly: (event) => _onAddWordRandomly(event, emit),
      );
    });
  }

  _onGetAllOxfordWords(_GetAllOxfordWords event, Emitter<VocabularyState> emit) {
    debugPrint('VocabularyBloc: getAllOxfordWords');
    if (state.words.isNotEmpty) {
      debugPrint('VocabularyBloc: words is not empty - skip');
      return;
    }
    final words = _oxfordWordsRepository.getAllOxfordWords();
    debugPrint('VocabularyBloc: getAllOxfordWords - success - words ${words.length}');
    emit(state.copyWith(words: words));
  }

  _onChangeStatus(_ChangeStatus event, Emitter<VocabularyState> emit) {
    debugPrint('VocabularyBloc: changeStatus - word ${event.word.status} - status ${event.status}');
    final newWord = event.word.copyWith(status: event.status);
    final words = state.words.map((word) {
      if (word == event.word) {
        return newWord;
      }
      return word;
    }).toList();
    _oxfordWordsRepository.saveWord(newWord);
    emit(state.copyWith(words: words));
  }

  _onEditDefinition(_EditDefinition event, Emitter<VocabularyState> emit) {
    debugPrint('VocabularyBloc: editDefinition - word ${event.word.word} - newDefinition ${event.newDefinition}');
    final word = event.word;
    final newWord = Word(
      status: word.status,
      word: word.word,
      senses: word.senses,
      phoneticAm: word.phoneticAm,
      phoneticText: word.phoneticText,
      phonetic: word.phonetic,
      pos: word.pos,
      index: word.index,
      phoneticAmText: word.phoneticAmText,
      userDefinition: event.newDefinition,
    );
    final words = state.words.map((word) {
      if (word == event.word) {
        return newWord;
      }
      return word;
    }).toList();
    _oxfordWordsRepository.saveWord(newWord);
    emit(state.copyWith(words: words));
  }

  _onAddWordRandomly(_AddWordRandomly event, Emitter<VocabularyState> emit) {
    debugPrint('VocabularyBloc: addWordRandomly');
    final unknownWords = state.words.where((word) => word.status == WordStatus.unknown).toList()..shuffle();
    final randomWords = unknownWords.take(10);
    for (final word in randomWords) {
      final newWord = word.copyWith(status: WordStatus.star);
      _oxfordWordsRepository.saveWord(newWord);
    }
    emit(state.copyWith(words: state.words.map((word) {
      if (randomWords.contains(word)) {
        return word.copyWith(status: WordStatus.star);
      }
      return word;
    }).toList()));
  }
}
