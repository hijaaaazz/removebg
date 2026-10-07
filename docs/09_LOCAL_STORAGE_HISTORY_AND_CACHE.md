# 09. Local Storage, History & Cache Architecture

To ensure instant responsiveness, offline capability, and low network bandwidth consumption, **RemoveIt** implements an **Offline-First Storage Architecture** combining Drift SQLite, device file caching, and secure token storage.

---

## 1. Storage Tiers & Responsibilities

| Tier | Technology | Data Stored | Security & Retention |
| :--- | :--- | :--- | :--- |
| **Secure Keyring** | `FlutterSecureStorage` | JWT Access/Refresh tokens, Device UUID, RevenueCat User ID | AES-256 encrypted, persistent across app updates |
| **Relational Database** | `Drift` (SQLite) | Processed Job History, Cloud Sync flags, Metadata | Persistent local DB, indexed queries |
| **Key-Value Store** | `SharedPreferences` | Theme mode (Dark/Light), Onboarding completed, Ad cooldowns | Plaintext key-value pairs |
| **Disk Image Cache** | `cached_network_image` + App Cache | Segmented preview thumbnails, downloaded clean masters | Auto-evicted on cache size limits (>250MB) |

---

## 2. Drift SQLite Schema (`lib/core/database/`)

Drift provides compile-time safe SQL tables, reactive Dart streams, and migration support:

```dart
// lib/core/database/tables/job_history_table.dart
import 'package:drift/drift.dart';

class JobHistoryTable extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get originalLocalPath => text().nullable()();
  TextColumn get previewRemoteUrl => text()();
  TextColumn get cleanRemoteUrl => text().nullable()();
  IntColumn get width => integer()();
  IntColumn get height => integer()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isPro => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
```

### Database Access Object (DAO) Pattern
```dart
// lib/features/history/data/datasources/history_local_data_source.dart
import 'package:drift/drift.dart';
import 'package:removeit_app/core/database/app_database.dart';

abstract class HistoryLocalDataSource {
  Stream<List<JobHistoryTableData>> watchHistory();
  Future<void> insertOrUpdateJob(JobHistoryTableCompanion job);
  Future<void> deleteJob(String id);
  Future<void> bulkDeleteJobs(List<String> ids);
  Future<void> clearAllHistory();
}

class HistoryLocalDataSourceImpl implements HistoryLocalDataSource {
  final AppDatabase db;

  HistoryLocalDataSourceImpl(this.db);

  @override
  Stream<List<JobHistoryTableData>> watchHistory() {
    return (db.select(db.jobHistoryTable)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  @override
  Future<void> insertOrUpdateJob(JobHistoryTableCompanion job) {
    return db.into(db.jobHistoryTable).insertOnConflictUpdate(job);
  }

  @override
  Future<void> deleteJob(String id) {
    return (db.delete(db.jobHistoryTable)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> bulkDeleteJobs(List<String> ids) {
    return (db.delete(db.jobHistoryTable)..where((t) => t.id.isIn(ids))).go();
  }

  @override
  Future<void> clearAllHistory() {
    return db.delete(db.jobHistoryTable).go();
  }
}
```

---

## 3. Remote Cloud Synchronization Flow

When an authenticated user opens the History tab:
1. **Instant Local Load:** The UI immediately renders local SQLite records via Drift's reactive `Stream`.
2. **Background Delta Sync:** The repository calls `GET /api/v1/history/`.
3. **Reconciliation:** New cloud records are inserted locally; records deleted remotely or expired on the server (after 7 days for Free / 30 days for Pro) are pruned from local SQLite.
4. **Offline Queue:** If a user deletes an item while offline, the item is soft-deleted locally and tagged for remote deletion upon network reconnect.

---

## 4. Cache Eviction & Disk Housekeeping

Unchecked image caches can consume gigabytes of device storage, leading users to uninstall the app.

### Housekeeping Protocol:
1. **Temporary Upload Artifacts:** Intermediate downscaled JPEG files created by `ImagePreprocessor` are deleted immediately after the upload request completes.
2. **Cap on Thumbnail Disk Cache:** The `cached_network_image` cache manager is configured with a strict ceiling:
   - `maxNrOfObjects: 100`
   - `stalePeriod: const Duration(days: 7)`
3. **User-Initiated Cache Clean:** The Settings screen provides a **"Clear Temporary Cache"** button displaying the current cache size (e.g., `42.8 MB`) and freeing disk space in one tap.
