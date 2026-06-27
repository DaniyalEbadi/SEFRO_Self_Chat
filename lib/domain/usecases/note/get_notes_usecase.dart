import '../../entities/note_entity.dart';
import '../../repositories/note_repository.dart';

class GetNotesUseCase {
  final NoteRepository repository;
  GetNotesUseCase(this.repository);

  Future<List<NoteEntity>> call({String? query, bool? pinned}) {
    return repository.getNotes(query: query, pinned: pinned);
  }
}
