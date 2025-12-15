part of readarr_commands;

/// Facilitates, encapsulates, and manages individual calls related to books within Readarr.
class ReadarrControllerBook {
  final Dio _client;

  ReadarrControllerBook(this._client);

  /// Handler for `GET /api/v1/book`.
  ///
  /// Returns books for a specific author.
  Future<List<ReadarrBook>> getByAuthor({required int authorId}) async =>
      _commandGetBooksByAuthor(_client, authorId: authorId);

  /// Handler for `GET /api/v1/book/{id}`.
  ///
  /// Returns the book with the matching ID.
  Future<ReadarrBook> get({required int bookId}) async =>
      _commandGetBook(_client, bookId: bookId);

  /// Handler for `PUT /api/v1/book`.
  ///
  /// Update an existing book.
  Future<ReadarrBook> update({required ReadarrBook book}) async =>
      _commandUpdateBook(_client, book: book);

  /// Handler for `PUT /api/v1/book/monitor`.
  ///
  /// Set monitored status for multiple books.
  Future<List<ReadarrBook>> setMonitored({
    required List<int> bookIds,
    required bool monitored,
  }) async =>
      _commandSetMonitored(
        _client,
        bookIds: bookIds,
        monitored: monitored,
      );
}
