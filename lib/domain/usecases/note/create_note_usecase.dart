import '../../entities/note_entity.dart';
import '../../repositories/note_repository.dart';

class CreateNoteUseCase {
  final NoteRepository repository;
  CreateNoteUseCase(this.repository);

  Future<NoteEntity> call(NoteEntity note) => repository.createNote(note);
}
