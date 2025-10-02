import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../models/barcode_model.dart';

class DriveRemote {
  final GoogleSignIn googleSignIn;
  final http.Client httpClient;

  DriveRemote({required this.googleSignIn, required this.httpClient});

  Future<drive.DriveApi> _api() async {
    final account = await googleSignIn.signInSilently();
    final user = account ?? await googleSignIn.signIn();
    final authHeaders = await user!.authHeaders;
    final authClient = _GoogleAuthClient(authHeaders);
    return drive.DriveApi(authClient);
  }

  Future<void> uploadCsv(List<BarcodeModel> items) async {
    final api = await _api();

    const folderName = 'BarcodeSyncApp';
    final folderList = await api.files.list(
      q: "mimeType = 'application/vnd.google-apps.folder' and name = '$folderName' and trashed = false",
      $fields: 'files(id, name)',
    );
    String folderId;
    if (folderList.files == null || folderList.files!.isEmpty) {
      final folder = drive.File()
        ..name = folderName
        ..mimeType = 'application/vnd.google-apps.folder';
      final created = await api.files.create(folder);
      folderId = created.id!;
    } else {
      folderId = folderList.files!.first.id!;
    }

    final dir = await getTemporaryDirectory();
    final csvPath = '${dir.path}/barcodes.csv';
    final file = File(csvPath)..writeAsStringSync(_toCsv(items));

    final existing = await api.files.list(
      q: "'$folderId' in parents and name = 'barcodes.csv' and trashed = false",
      $fields: 'files(id, name)',
    );

    final media = drive.Media(file.openRead(), await file.length());
    final meta = drive.File()
      ..name = 'barcodes.csv'
      ..parents = [folderId];

    if (existing.files == null || existing.files!.isEmpty) {
      await api.files.create(meta, uploadMedia: media);
    } else {
      final id = existing.files!.first.id!;
      await api.files.update(drive.File(), id, uploadMedia: media);
    }
  }

  String _toCsv(List<BarcodeModel> items) {
    final b = StringBuffer('transport,code,created_at\n');
    for (final it in items) {
      b.writeln('"${_esc(it.transport)}","${_esc(it.code)}",${it.createdAt.toIso8601String()}');
    }
    return b.toString();
  }

  String _esc(String v) => v.replaceAll('"', '""');
}

class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();
  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}
