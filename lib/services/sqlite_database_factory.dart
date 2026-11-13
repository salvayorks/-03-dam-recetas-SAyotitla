import 'sqlite_database_factory_stub.dart'
    if (dart.library.io) 'sqlite_database_factory_io.dart'
    as implementation;

Future<void> initializeSqliteDatabaseFactory() =>
    implementation.initializeSqliteDatabaseFactory();
