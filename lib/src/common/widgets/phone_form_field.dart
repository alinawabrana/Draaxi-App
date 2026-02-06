import 'package:country_code_picker/country_code_picker.dart';
import 'package:draaxi/utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneFormField extends StatelessWidget {
  const PhoneFormField({
    super.key,
    this.phoneNumberController,
    this.phoneNumberValidator,
    this.onPhoneNumberChanged,
    this.selectedCountryCode,
    this.onCountryChanged,
    this.countryFilter,
  });

  final TextEditingController? phoneNumberController;
  final String? Function(String?)? phoneNumberValidator;
  final void Function(String)? onPhoneNumberChanged;
  final CountryCode? selectedCountryCode;
  final void Function(CountryCode)? onCountryChanged;
  final List<String>? countryFilter;

  @override
  Widget build(BuildContext context) {
    final isDark = AHelperFunction.isDarkMode(context);
    final textTheme = Theme.of(context).textTheme;
    final countryCode = selectedCountryCode ?? CountryCode.fromDialCode('+234');

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? const Color(0xFFB8B8B8) : const Color(0xFFB8B8B8),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Country flag dropdown area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CountryCodePicker(
                  onChanged: (CountryCode code) {
                    if (onCountryChanged != null) {
                      onCountryChanged!(code);
                    }
                  },
                  initialSelection: countryCode.code ?? 'NG',
                  favorite: countryFilter ?? const [],
                  countryFilter: countryFilter,
                  showCountryOnly: true,
                  showFlag: true,
                  showFlagMain: true,
                  showDropDownButton: false,
                  showFlagDialog: true,
                  hideMainText: true,
                  padding: EdgeInsets.zero,
                  flagWidth: 25,
                  textStyle: textTheme.bodyMedium,
                  dialogTextStyle: textTheme.bodyMedium,
                  dialogBackgroundColor: Theme.of(
                    context,
                  ).scaffoldBackgroundColor,
                  searchDecoration: InputDecoration(
                    hintText: 'Search country',
                    hintStyle: textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? const Color(0xFFD0D0D0)
                          : const Color(0xFF5A5A5A),
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 24,
                  color: isDark
                      ? const Color(0xFFD0D0D0)
                      : const Color(0xFF414141),
                ),
              ],
            ),
          ),
          // Vertical separator
          Container(
            width: 1,
            height: 40,
            color: isDark ? const Color(0xFFB8B8B8) : const Color(0xFFB8B8B8),
          ),
          // Country code display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              countryCode.dialCode ?? '+234',
              style: textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? const Color(0xFFD0D0D0)
                    : const Color(0xFFD0D0D0),
              ),
            ),
          ),
          // Phone number input field
          Expanded(
            child: TextFormField(
              controller: phoneNumberController,
              validator: phoneNumberValidator,
              onChanged: onPhoneNumberChanged,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Your mobile number',
                hintStyle: textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? const Color(0xFFD0D0D0)
                      : const Color(0xFFD0D0D0),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
