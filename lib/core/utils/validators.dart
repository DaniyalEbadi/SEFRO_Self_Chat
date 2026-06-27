class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'ایمیل را وارد کنید';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'ایمیل معتبر نیست';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'رمز عبور را وارد کنید';
    if (value.length < 6) return 'رمز عبور باید حداقل ۶ کاراکتر باشد';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'شماره موبایل را وارد کنید';
    final phoneRegex = RegExp(r'^(\+98|0)?9\d{9}$');
    if (!phoneRegex.hasMatch(value)) return 'شماره موبایل معتبر نیست';
    return null;
  }

  static String? required(String? value, [String field = '']) {
    if (value == null || value.trim().isEmpty) {
      return field.isEmpty ? 'این فیلد الزامی است' : '$field را وارد کنید';
    }
    return null;
  }

  static String? pin(String? value) {
    if (value == null || value.isEmpty) return 'پین را وارد کنید';
    if (value.length != 4) return 'پین باید ۴ رقم باشد';
    return null;
  }
}
