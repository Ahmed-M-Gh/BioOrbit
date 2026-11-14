class EndPoints {
  // الرابط الأساسي للسيرفر الذي يستضيف الـ 11 Endpoint الموجودة في BioOrbit_4.json
  static const String backendBaseUrl = 'https://bioorbit-q1kb.onrender.com';
  static const String aiWeeklyReportUrl =
      'https://bioorbit-0yay.onrender.com/api/v1/health/weekly-report';
  static const String imgbbAlbumUrl = 'https://ibb.co/album/nPFBWq';

  // المعرفات المرجعية كما وردت حرفياً في BioOrbit_4.json
  static const String defaultRecordId = '6af7b2f91d64b08c0813a2be';
  static const String defaultAstronautId = '6af76cba28fa0cba6ce16113';

  // 1. register (POST /register)
  static const String register = '$backendBaseUrl/register';

  // 2. Login (POST /login)
  static const String login = '$backendBaseUrl/login';

  // 3. Get Current User (GET /me)
  static const String me = '$backendBaseUrl/me';

  // 4. Create Health Record (POST /health-records)
  static const String healthRecords = '$backendBaseUrl/health-records';

  // 5. Get My Health Records (GET /health-records/me)
  static const String myHealthRecords = '$backendBaseUrl/health-records/me';

  // 6. Upload Image In Health Records (PATCH /health-records/:recordId/image)
  static String uploadRecordImage(String recordId) =>
      '$backendBaseUrl/health-records/$recordId/image';

  // 7. Image To AI (GET /health-records/:recordId/ai/image)
  static String imageToAi(String recordId) =>
      '$backendBaseUrl/health-records/$recordId/ai/image';

  // 8. Metrics To AI (GET /health-records/:recordId/ai/metrics)
  static String metricsToAi(String recordId) =>
      '$backendBaseUrl/health-records/$recordId/ai/metrics';

  // 9. 7 Records To AI (Weekly) (GET /health-records/ai/weekly)
  static const String weeklyRecordsToAi =
      '$backendBaseUrl/health-records/ai/weekly';

  // 10. Receive Weekly AI Reports (POST /weekly-reports/receive)
  static const String receiveWeeklyReports =
      '$backendBaseUrl/weekly-reports/receive';

  // 11. Get My Weekly Reports (GET /weekly-reports/me)
  static const String myWeeklyReports = '$backendBaseUrl/weekly-reports/me';
}
