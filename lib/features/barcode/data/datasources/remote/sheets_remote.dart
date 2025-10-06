import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:http/http.dart' as http;
import '../../models/barcode_model.dart';

class SheetsRemote {
  final GoogleSignIn googleSignIn;
  final http.Client httpClient;

  SheetsRemote({required this.googleSignIn, required this.httpClient});

  Future<sheets.SheetsApi> _api() async {
    final acc = await googleSignIn.signInSilently();
    final user = acc ?? await googleSignIn.signIn();
    final headers = await user!.authHeaders;
    final authClient = _GoogleAuthClient(headers);
    return sheets.SheetsApi(authClient);
  }

  Future<void> appendBarcodes({
    required String spreadsheetId,
    required String sheetName,
    required List<BarcodeModel> items,
  }) async {
    final api = await _api();
    final values = items.map((e) => [e.transport, e.code]).toList();
    final valueRange = sheets.ValueRange.fromJson({'values': values});
    await api.spreadsheets.values.append(
      valueRange, spreadsheetId, '$sheetName!A:B',
      valueInputOption: 'RAW', insertDataOption: 'INSERT_ROWS',
    );
  }

  static String? extractSpreadsheetId(String url) {
    final re = RegExp(r'/spreadsheets/d/([a-zA-Z0-9-_]+)');
    final m = re.firstMatch(url);
    return m?.group(1);
  }
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