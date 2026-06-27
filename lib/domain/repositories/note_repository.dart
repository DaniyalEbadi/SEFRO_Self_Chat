import '../entities/note_entity.dart';

abstract class NoteRepository {
  Future<List<NoteEntity>> getNotes({String? query, bool? pinned});
  Future<NoteEntity> getNote(String id);
  Future<NoteEntity> createNote(NoteEntity note);
  Future<NoteEntity> updateNote(NoteEntity note);
  Future<void> deleteNote(String id);
  Future<NoteEntity> togglePin(String id);
}
