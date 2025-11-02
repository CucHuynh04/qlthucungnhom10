

import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'vi': {
      'app_title': 'Ứng dụng Quản lý Thú Cưng',
      'my_pets': 'Thú Cưng Của Tôi',
      'add_data': 'Thêm Dữ Liệu',
      'schedule': 'Lịch Hẹn',
      'statistics': 'Thống Kê',
      'care_log': 'Nhật Ký Chăm Sóc',
      'gallery': 'Bộ Sưu Tập',
      'export_share': 'Xuất/Chia Sẻ',
      'account': 'Tài Khoản',
      'profile': 'Hồ Sơ',
      'pet_manager': 'Pet Manager',
      'language': 'Ngôn ngữ',
      'vietnamese': 'Tiếng Việt',
      'english': 'English',
      'dark_mode': 'Chế độ tối',
      'statistics_title': 'Thống Kê',
      'care_log_title': 'Nhật Ký',
      'gallery_title': 'Bộ Sưu Tập',
      'export_title': 'Xuất & Chia Sẻ',
      'account_title': 'Tài Khoản',
      
      // Login
      'welcome_back': 'Chào mừng trở lại!',
      'email': 'Email',
      'password': 'Mật khẩu',
      'login': 'Đăng nhập',
      'login_with_google': 'Đăng nhập bằng Google',
      'login_anonymously': 'Đăng nhập Ẩn danh',
      'register': 'Đăng ký',
      'no_account': 'Chưa có tài khoản?',
      
      // Add Data
      'weight': 'Cân nặng',
      'care': 'Chăm sóc',
      'vaccination': 'Tiêm chủng',
      'accessories': 'Phụ kiện',
      'food': 'Thức ăn',
      'back_to_pet_selection': 'Quay lại chọn thú cưng',
      'weight_kg': 'Cân nặng (kg)',
      'date': 'Ngày',
      'notes': 'Ghi chú',
      'optional': 'tùy chọn',
      'add_weight_data': 'Thêm dữ liệu cân nặng',
      'care_type': 'Loại chăm sóc',
      'cost': 'Chi phí',
      'add_care_data': 'Thêm dữ liệu chăm sóc',
      'vaccine_name': 'Tên vaccine',
      'next_due_date': 'Ngày tiêm tiếp theo',
      'add_vaccination_data': 'Thêm dữ liệu tiêm chủng',
      'accessory_name': 'Tên phụ kiện',
      'accessory_type': 'Loại phụ kiện',
      'add_accessory_data': 'Thêm dữ liệu phụ kiện',
      'food_name': 'Tên thức ăn',
      'food_type': 'Loại thức ăn',
      'add_food_data': 'Thêm dữ liệu thức ăn',
      'select_date': 'Chọn ngày',
      'default_today': 'mặc định: hôm nay',
      
      // Schedule
      'add_schedule': 'Thêm lịch hẹn',
      'schedule_type': 'Loại lịch hẹn',
      'routine_checkup': 'Khám định kỳ',
      'vaccination': 'Tiêm chủng',
      'play_time': 'Đi chơi',
      'pet': 'Thú cưng',
      'title': 'Tiêu đề',
      'time': 'Thời gian',
      'no_schedule': 'Không có lịch hẹn nào',
      'tap_to_add': 'Nhấn nút + để thêm lịch hẹn mới',
      'select_pet_first': 'Vui lòng chọn thú cưng trước',
      'add': 'Thêm',
      'cancel': 'Hủy',
      'delete': 'Xóa',
      
      // Care Log
      'add_log': 'Thêm nhật ký',
      'log_type': 'Loại nhật ký',
      
      // Gallery
      'add_media': 'Thêm ảnh/video',
      'take_photo': 'Chụp ảnh',
      'select_from_gallery': 'Chọn ảnh từ thư viện',
      'record_video': 'Quay video',
      'select_video': 'Chọn video từ thư viện',
      
      // Export
      'back_to_pet': 'Quay lại chọn thú cưng',
      'gender': 'Giới tính',
      'birth_date': 'Ngày sinh',
      'stats': 'Thống kê',
      'times': 'lần ghi nhận',
      'export_pdf_profile': 'Xuất hồ sơ PDF',
      'export_profile_desc': 'Tạo file PDF chứa thông tin chi tiết về thú cưng',
      'export_vaccination_pdf': 'Xuất lịch tiêm chủng PDF',
      'export_vaccination_desc': 'Tạo file PDF chứa lịch sử tiêm chủng',
      'share_info': 'Chia sẻ thông tin',
      
      // Account
      'user': 'Người dùng',
      'personal_info': 'Thông tin cá nhân',
      'logout': 'Đăng xuất',
      
      // Pet
      'species': 'Loài',
      'breed': 'Giống',
      'male': 'Đực',
      'female': 'Cái',
      'add_pet': 'Thêm thú cưng mới',
      'pet_name': 'Tên thú cưng',
      'save': 'Lưu',
      
      // Statistics
      'weight_stats': 'Cân nặng',
      'cost_stats': 'Chi phí',
      
      // Common
      'select': 'Chọn',
      'date_format': 'DD/MM/YYYY',
      'all': 'Tất cả',
      'photos': 'Ảnh',
      'videos': 'Video',
      'go_back': 'Quay lại',
      'no_pets_yet': 'Bạn chưa có thú cưng nào',
      'search': 'Tìm kiếm',
      'please_select_pet': 'Vui lòng chọn thú cưng trước',
      'search_pets': 'Tìm kiếm thú cưng',
      'example': 'Ví dụ',
      'vnd': 'VNĐ',
    },
    'en': {
      'app_title': 'Pet Management App',
      'my_pets': 'My Pets',
      'add_data': 'Add Data',
      'schedule': 'Schedule',
      'statistics': 'Statistics',
      'care_log': 'Care Log',
      'gallery': 'Gallery',
      'export_share': 'Export & Share',
      'account': 'Account',
      'profile': 'Profile',
      'pet_manager': 'Pet Manager',
      'language': 'Language',
      'vietnamese': 'Tiếng Việt',
      'english': 'English',
      'dark_mode': 'Dark Mode',
      'statistics_title': 'Statistics',
      'care_log_title': 'Care Log',
      'gallery_title': 'Gallery',
      'export_title': 'Export & Share',
      'account_title': 'Account',
      
      // Login
      'welcome_back': 'Welcome back!',
      'email': 'Email',
      'password': 'Password',
      'login': 'Login',
      'login_with_google': 'Login with Google',
      'login_anonymously': 'Login Anonymously',
      'register': 'Register',
      'no_account': "Don't have an account?",
      
      // Add Data
      'weight': 'Weight',
      'care': 'Care',
      'vaccination': 'Vaccination',
      'accessories': 'Accessories',
      'food': 'Food',
      'back_to_pet_selection': 'Back to pet selection',
      'weight_kg': 'Weight (kg)',
      'date': 'Date',
      'notes': 'Notes',
      'optional': 'optional',
      'add_weight_data': 'Add weight data',
      'care_type': 'Care type',
      'cost': 'Cost',
      'add_care_data': 'Add care data',
      'vaccine_name': 'Vaccine name',
      'next_due_date': 'Next due date',
      'add_vaccination_data': 'Add vaccination data',
      'accessory_name': 'Accessory name',
      'accessory_type': 'Accessory type',
      'add_accessory_data': 'Add accessory data',
      'food_name': 'Food name',
      'food_type': 'Food type',
      'add_food_data': 'Add food data',
      'select_date': 'Select date',
      'default_today': 'default: today',
      
      // Schedule
      'add_schedule': 'Add schedule',
      'schedule_type': 'Schedule type',
      'routine_checkup': 'Routine checkup',
      'vaccination': 'Vaccination',
      'play_time': 'Play time',
      'pet': 'Pet',
      'title': 'Title',
      'time': 'Time',
      'no_schedule': 'No schedule',
      'tap_to_add': 'Press the + button to add a new appointment',
      'select_pet_first': 'Please select a pet first',
      'add': 'Add',
      'cancel': 'Cancel',
      'delete': 'Delete',
      
      // Care Log
      'add_log': 'Add log',
      'log_type': 'Log type',
      
      // Gallery
      'add_media': 'Add image/video',
      'take_photo': 'Take photo',
      'select_from_gallery': 'Select from gallery',
      'record_video': 'Record video',
      'select_video': 'Select video',
      
      // Export
      'back_to_pet': 'Back to pet selection',
      'gender': 'Gender',
      'birth_date': 'Birth date',
      'stats': 'Statistics',
      'times': 'records',
      'export_pdf_profile': 'Export PDF profile',
      'export_profile_desc': 'Create PDF file containing detailed pet information',
      'export_vaccination_pdf': 'Export vaccination schedule PDF',
      'export_vaccination_desc': 'Create PDF file containing vaccination history',
      'share_info': 'Share information',
      
      // Account
      'user': 'User',
      'personal_info': 'Personal information',
      'logout': 'Logout',
      
      // Pet
      'species': 'Species',
      'breed': 'Breed',
      'male': 'Male',
      'female': 'Female',
      'add_pet': 'Add new pet',
      'pet_name': 'Pet name',
      'save': 'Save',
      
      // Statistics
      'weight_stats': 'Weight',
      'cost_stats': 'Cost',
      
      // Common
      'select': 'Select',
      'date_format': 'DD/MM/YYYY',
      'all': 'All',
      'photos': 'Photos',
      'videos': 'Videos',
      'go_back': 'Go back',
      'no_pets_yet': 'You have no pets yet',
      'search': 'Search',
      'please_select_pet': 'Please select a pet first',
      'search_pets': 'Search Pets',
      'example': 'Example',
      'vnd': 'VND',
    },
  };

  String get appTitle => _localizedValues[locale.languageCode]!['app_title']!;
  String get myPets => _localizedValues[locale.languageCode]!['my_pets']!;
  String get addData => _localizedValues[locale.languageCode]!['add_data']!;
  String get schedule => _localizedValues[locale.languageCode]!['schedule']!;
  String get statistics => _localizedValues[locale.languageCode]!['statistics']!;
  String get careLog => _localizedValues[locale.languageCode]!['care_log']!;
  String get gallery => _localizedValues[locale.languageCode]!['gallery']!;
  String get exportShare => _localizedValues[locale.languageCode]!['export_share']!;
  String get account => _localizedValues[locale.languageCode]!['account']!;
  String get profile => _localizedValues[locale.languageCode]!['profile']!;
  String get petManager => _localizedValues[locale.languageCode]!['pet_manager']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get vietnamese => _localizedValues[locale.languageCode]!['vietnamese']!;
  String get english => _localizedValues[locale.languageCode]!['english']!;
  String get darkMode => _localizedValues[locale.languageCode]!['dark_mode']!;
  String get statisticsTitle => _localizedValues[locale.languageCode]!['statistics_title']!;
  String get careLogTitle => _localizedValues[locale.languageCode]!['care_log_title']!;
  String get galleryTitle => _localizedValues[locale.languageCode]!['gallery_title']!;
  String get exportTitle => _localizedValues[locale.languageCode]!['export_title']!;
  String get accountTitle => _localizedValues[locale.languageCode]!['account_title']!;
  
  // Login
  String get welcomeBack => _localizedValues[locale.languageCode]!['welcome_back']!;
  String get email => _localizedValues[locale.languageCode]!['email']!;
  String get password => _localizedValues[locale.languageCode]!['password']!;
  String get login => _localizedValues[locale.languageCode]!['login']!;
  String get loginWithGoogle => _localizedValues[locale.languageCode]!['login_with_google']!;
  String get loginAnonymously => _localizedValues[locale.languageCode]!['login_anonymously']!;
  String get register => _localizedValues[locale.languageCode]!['register']!;
  String get noAccount => _localizedValues[locale.languageCode]!['no_account']!;
  
  // Add Data
  String get weight => _localizedValues[locale.languageCode]!['weight']!;
  String get care => _localizedValues[locale.languageCode]!['care']!;
  String get vaccination => _localizedValues[locale.languageCode]!['vaccination']!;
  String get accessories => _localizedValues[locale.languageCode]!['accessories']!;
  String get food => _localizedValues[locale.languageCode]!['food']!;
  String get backToPetSelection => _localizedValues[locale.languageCode]!['back_to_pet_selection']!;
  String get weightKg => _localizedValues[locale.languageCode]!['weight_kg']!;
  String get date => _localizedValues[locale.languageCode]!['date']!;
  String get notes => _localizedValues[locale.languageCode]!['notes']!;
  String get optional => _localizedValues[locale.languageCode]!['optional']!;
  String get addWeightData => _localizedValues[locale.languageCode]!['add_weight_data']!;
  String get careType => _localizedValues[locale.languageCode]!['care_type']!;
  String get cost => _localizedValues[locale.languageCode]!['cost']!;
  String get addCareData => _localizedValues[locale.languageCode]!['add_care_data']!;
  String get vaccineName => _localizedValues[locale.languageCode]!['vaccine_name']!;
  String get nextDueDate => _localizedValues[locale.languageCode]!['next_due_date']!;
  String get addVaccinationData => _localizedValues[locale.languageCode]!['add_vaccination_data']!;
  String get accessoryName => _localizedValues[locale.languageCode]!['accessory_name']!;
  String get accessoryType => _localizedValues[locale.languageCode]!['accessory_type']!;
  String get addAccessoryData => _localizedValues[locale.languageCode]!['add_accessory_data']!;
  String get foodName => _localizedValues[locale.languageCode]!['food_name']!;
  String get foodType => _localizedValues[locale.languageCode]!['food_type']!;
  String get addFoodData => _localizedValues[locale.languageCode]!['add_food_data']!;
  String get selectDate => _localizedValues[locale.languageCode]!['select_date']!;
  String get defaultToday => _localizedValues[locale.languageCode]!['default_today']!;
  
  // Schedule
  String get addSchedule => _localizedValues[locale.languageCode]!['add_schedule']!;
  String get scheduleType => _localizedValues[locale.languageCode]!['schedule_type']!;
  String get routineCheckup => _localizedValues[locale.languageCode]!['routine_checkup']!;
  String get playTime => _localizedValues[locale.languageCode]!['play_time']!;
  String get pet => _localizedValues[locale.languageCode]!['pet']!;
  String get title => _localizedValues[locale.languageCode]!['title']!;
  String get time => _localizedValues[locale.languageCode]!['time']!;
  String get noSchedule => _localizedValues[locale.languageCode]!['no_schedule']!;
  String get tapToAdd => _localizedValues[locale.languageCode]!['tap_to_add']!;
  String get selectPetFirst => _localizedValues[locale.languageCode]!['select_pet_first']!;
  String get add => _localizedValues[locale.languageCode]!['add']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get deleteStr => _localizedValues[locale.languageCode]!['delete']!;
  
  // Care Log
  String get addLog => _localizedValues[locale.languageCode]!['add_log']!;
  String get logType => _localizedValues[locale.languageCode]!['log_type']!;
  
  // Gallery
  String get addMedia => _localizedValues[locale.languageCode]!['add_media']!;
  String get takePhoto => _localizedValues[locale.languageCode]!['take_photo']!;
  String get selectFromGallery => _localizedValues[locale.languageCode]!['select_from_gallery']!;
  String get recordVideo => _localizedValues[locale.languageCode]!['record_video']!;
  String get selectVideo => _localizedValues[locale.languageCode]!['select_video']!;
  
  // Export
  String get backToPet => _localizedValues[locale.languageCode]!['back_to_pet']!;
  String get gender => _localizedValues[locale.languageCode]!['gender']!;
  String get birthDate => _localizedValues[locale.languageCode]!['birth_date']!;
  String get stats => _localizedValues[locale.languageCode]!['stats']!;
  String get times => _localizedValues[locale.languageCode]!['times']!;
  String get exportPdfProfile => _localizedValues[locale.languageCode]!['export_pdf_profile']!;
  String get exportProfileDesc => _localizedValues[locale.languageCode]!['export_profile_desc']!;
  String get exportVaccinationPdf => _localizedValues[locale.languageCode]!['export_vaccination_pdf']!;
  String get exportVaccinationDesc => _localizedValues[locale.languageCode]!['export_vaccination_desc']!;
  String get shareInfo => _localizedValues[locale.languageCode]!['share_info']!;
  
  // Account
  String get user => _localizedValues[locale.languageCode]!['user']!;
  String get personalInfo => _localizedValues[locale.languageCode]!['personal_info']!;
  String get logout => _localizedValues[locale.languageCode]!['logout']!;
  
  // Pet
  String get species => _localizedValues[locale.languageCode]!['species']!;
  String get breed => _localizedValues[locale.languageCode]!['breed']!;
  String get male => _localizedValues[locale.languageCode]!['male']!;
  String get female => _localizedValues[locale.languageCode]!['female']!;
  String get addPet => _localizedValues[locale.languageCode]!['add_pet']!;
  String get petName => _localizedValues[locale.languageCode]!['pet_name']!;
  String get save => _localizedValues[locale.languageCode]!['save']!;
  
  // Statistics
  String get weightStats => _localizedValues[locale.languageCode]!['weight_stats']!;
  String get costStats => _localizedValues[locale.languageCode]!['cost_stats']!;
  
  // Common
  String get select => _localizedValues[locale.languageCode]!['select']!;
  String get dateFormat => _localizedValues[locale.languageCode]!['date_format']!;
  String get all => _localizedValues[locale.languageCode]!['all']!;
  String get photos => _localizedValues[locale.languageCode]!['photos']!;
  String get videos => _localizedValues[locale.languageCode]!['videos']!;
  String get goBack => _localizedValues[locale.languageCode]!['go_back']!;
  String get noPetsYet => _localizedValues[locale.languageCode]!['no_pets_yet']!;
  String get search => _localizedValues[locale.languageCode]!['search']!;
  String get pleaseSelectPet => _localizedValues[locale.languageCode]!['please_select_pet']!;
  String get searchPets => _localizedValues[locale.languageCode]!['search_pets']!;
  String get example => _localizedValues[locale.languageCode]!['example']!;
  String get vnd => _localizedValues[locale.languageCode]!['vnd']!;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['vi', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}





