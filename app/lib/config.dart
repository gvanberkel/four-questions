/// Where the app's data lives and who may reach it.
abstract final class AppConfig {
  static const appName = 'Four Questions';
  static const version = '0.1.0';

  /// The Google Sheet that is the app's database.
  static const spreadsheetId = '196o_v9iuMYy5h91ovrL0kaGdz444bMcTfesXMf_gpaM';
  static final Uri spreadsheetUrl = Uri.parse(
    'https://docs.google.com/spreadsheets/d/$spreadsheetId/edit',
  );

  static const questionsSheet = 'Questions';
  static const answersSheet = 'Answers';
  static const peopleSheet = 'People';

  /// The OAuth 2.0 web client (Google Cloud project `four-questions-d1c19`)
  /// that signs people in. Overridable with
  /// `--dart-define=GOOGLE_CLIENT_ID=…` for a different project.
  static const googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: '',
  );

  /// `--dart-define=DEMO=true` runs against an in-memory sheet with a demo
  /// account, so the app can be tried without Google.
  static const demo = bool.fromEnvironment('DEMO');
}
