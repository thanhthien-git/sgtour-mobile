// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'SGTour';

  @override
  String get common_cancel => 'Отмена';

  @override
  String get common_confirm => 'Подтвердить';

  @override
  String get common_save => 'Сохранить';

  @override
  String get common_delete => 'Удалить';

  @override
  String get common_edit => 'Редактировать';

  @override
  String get common_search => 'Поиск';

  @override
  String get common_loading => 'Загрузка...';

  @override
  String get common_error => 'Ошибка';

  @override
  String get common_success => 'Успешно';

  @override
  String get common_retry => 'Повторить';

  @override
  String get common_next => 'Далее';

  @override
  String get common_back => 'Назад';

  @override
  String get common_done => 'Готово';

  @override
  String get common_skip => 'Пропустить';

  @override
  String get common_or => 'или';

  @override
  String get common_other => 'Другие';

  @override
  String get onboarding_title1 => 'Добро пожаловать в SGTour';

  @override
  String get onboarding_desc1 =>
      'Откройте для себя удивительные места и создайте незабываемые впечатления от путешествия.';

  @override
  String get onboarding_title2 => 'Умные рекомендации';

  @override
  String get onboarding_desc2 =>
      'Получайте персонализированные рекомендации в зависимости от ваших предпочтений и местоположения.';

  @override
  String get onboarding_title3 => 'Путешествуйте с ИИ';

  @override
  String get onboarding_desc3 =>
      'Позвольте нашему ассистенту с искусственным интеллектом помочь вам спланировать идеальное путешествие.';

  @override
  String get onboarding_getStarted => 'Начать';

  @override
  String get auth_login => 'Вход';

  @override
  String get auth_register => 'Регистрация';

  @override
  String get auth_logout => 'Выход';

  @override
  String get auth_email => 'Электронная почта или номер телефона';

  @override
  String get auth_password => 'Пароль';

  @override
  String get auth_confirmPassword => 'Подтвердить пароль';

  @override
  String get auth_fullName => 'Полное имя';

  @override
  String get auth_forgotPassword => 'Забыли пароль?';

  @override
  String get auth_noAccount => 'У вас нет аккаунта?';

  @override
  String get auth_hasAccount => 'У вас уже есть аккаунт?';

  @override
  String get auth_createAccount => 'Создать аккаунт';

  @override
  String get auth_loginNow => 'Войти сейчас';

  @override
  String get auth_welcomeBack => 'С возвращением';

  @override
  String get auth_createAccountToStart => 'Создайте аккаунт для начала работы';

  @override
  String get auth_loginSuccess => 'Вход успешен!';

  @override
  String get auth_loginFailed => 'Ошибка входа. Попробуйте еще раз.';

  @override
  String get auth_registerSuccess => 'Регистрация успешна!';

  @override
  String get auth_registerFailed => 'Ошибка регистрации!';

  @override
  String get auth_loginWithGoogle => 'Продолжить с Google';

  @override
  String get validation_emailRequired =>
      'Электронная почта не может быть пустой';

  @override
  String get validation_passwordRequired => 'Пароль не может быть пустым';

  @override
  String get validation_passwordMinLength =>
      'Пароль должен содержать минимум 6 символов';

  @override
  String get validation_confirmPasswordRequired =>
      'Подтверждение пароля не может быть пустым';

  @override
  String get validation_passwordMismatch => 'Пароли не совпадают';

  @override
  String get validation_nameRequired => 'Имя не может быть пустым';

  @override
  String get location_enableTitle => 'Включите определение местоположения';

  @override
  String get location_enableDesc =>
      'Нам нужен доступ к вашему местоположению, чтобы предложить близлежащие туристические достопримечательности и обеспечить лучший опыт.';

  @override
  String get location_enableButton => 'Включить местоположение';

  @override
  String get location_feature1 => 'Откройте для себя места рядом с вами';

  @override
  String get location_feature2 => 'Получите точные направления';

  @override
  String get location_feature3 =>
      'Персонализированные предложения по местоположению';

  @override
  String get location_permissionRequired =>
      'Для использования приложения требуется разрешение на доступ к местоположению';

  @override
  String get location_serviceDisabled =>
      'Пожалуйста, включите сервис определения местоположения на вашем устройстве';

  @override
  String get location_permissionDeniedTitle =>
      'Требуется разрешение на доступ к местоположению';

  @override
  String get location_permissionDeniedDesc =>
      'Вы отклонили разрешение на доступ к местоположению. Пожалуйста, перейдите в Настройки, чтобы предоставить разрешение.';

  @override
  String get location_openSettings => 'Открыть Настройки';

  @override
  String get logout_confirm => 'Вы уверены, что хотите выйти?';

  @override
  String get home_exploreNearby => 'Исследуйте места рядом с вами';

  @override
  String get home_categories => 'Категории';

  @override
  String get home_seeAll => 'Показать все';

  @override
  String get category_food => 'Еда';

  @override
  String get category_culture => 'Культура';

  @override
  String get category_shopping => 'Покупки';

  @override
  String get category_entertainment => 'Развлечения';

  @override
  String get nav_explore => 'Исследовать';

  @override
  String get nav_map => 'Карта';

  @override
  String get nav_profile => 'Профиль';

  @override
  String get map_title => 'Карта';

  @override
  String get map_comingSoon => 'Функция скоро появится';

  @override
  String get map_search_hint => 'Поиск места...';

  @override
  String get profile_title => 'Профиль';

  @override
  String get profile_comingSoon => 'Функция скоро появится';

  @override
  String get profile_name => 'Имя';

  @override
  String get profile_email => 'Электронная почта';

  @override
  String get profile_changePassword => 'Изменить пароль';

  @override
  String get profile_gender => 'Пол';

  @override
  String get profile_genderMale => 'Мужской';

  @override
  String get profile_genderFemale => 'Женский';

  @override
  String get profile_genderOther => 'Другое';

  @override
  String get profile_birthDate => 'Дата рождения';

  @override
  String get profile_phone => 'Номер телефона';

  @override
  String get profile_save => 'Сохранить';

  @override
  String get profile_editAvatar => 'Изменить фото';

  @override
  String get nav_settings => 'Настройки';

  @override
  String get settings_language => 'Язык';

  @override
  String get settings_languageEnglish => 'Английский';

  @override
  String get settings_languageVietnamese => 'Вьетнамский';

  @override
  String get settings_darkMode => 'Темный режим';

  @override
  String get settings_contact => 'Связаться с поддержкой';

  @override
  String get settings_privacy => 'Политика конфиденциальности';

  @override
  String get settings_terms => 'Условия обслуживания';

  @override
  String get contact_support_description =>
      'Свяжитесь с нашей командой поддержки';

  @override
  String get ai_greeting =>
      'Привет! Я ваш виртуальный гид SGTour. Куда бы вы хотели отправиться сегодня?';

  @override
  String get ai_error => 'Извините, у меня проблемы с подключением.';

  @override
  String get ai_mode_chat => 'Чат';

  @override
  String get ai_mode_video => 'Видео';

  @override
  String get ai_listening => 'Я слушаю...';

  @override
  String get ai_input_hint => 'Спросите SGTour о месте...';

  @override
  String search_result_for(String query) {
    return 'Результаты поиска по \"$query\"';
  }

  @override
  String get biometric_login_face => 'Face ID';

  @override
  String get biometric_login_fingerprint => 'Отпечаток пальца';

  @override
  String get biometric_login_with_face => 'Вход с Face ID';

  @override
  String get biometric_login_with_fingerprint => 'Вход по отпечатку пальца';

  @override
  String get biometric_enable_title => 'Включить биометрический вход';

  @override
  String get biometric_enable_desc =>
      'Вам будет предложено аутентифицироваться. Ваши биометрические данные будут сохранены в безопасности.';

  @override
  String get biometric_enabled => 'Биометрический вход включен';

  @override
  String get biometric_disabled => 'Биометрический вход отключен';

  @override
  String get biometric_not_available =>
      'Биометрическая аутентификация недоступна';

  @override
  String get biometric_setup_failed =>
      'Не удалось настроить биометрическую аутентификацию';

  @override
  String get biometric_quick_login => 'Включить быстрый вход';

  @override
  String get common_close => 'Закрыть';

  @override
  String get ai_video_end_dialog_title => 'Завершить видеочат?';

  @override
  String get ai_video_end_dialog_message =>
      'Сеанс с Avatar завершится, если вы перейдете в режим чата.';

  @override
  String get ai_video_end_dialog_cancel => 'Отмена';

  @override
  String get ai_video_end_dialog_confirm => 'Завершить';

  @override
  String get ai_listening_action => 'Слушаю...';

  @override
  String get ai_hold_to_speak => 'Нажмите и говорите';

  @override
  String get place_readMore => 'Читать далее';

  @override
  String get place_readLess => 'Показать меньше';
}
