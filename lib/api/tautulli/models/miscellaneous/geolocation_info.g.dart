// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geolocation_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliGeolocationInfo _$TautulliGeolocationInfoFromJson(
        Map<String, dynamic> json) =>
    TautulliGeolocationInfo(
      code: TautulliUtilities.ensureStringFromJson(json['code']),
      country: TautulliUtilities.ensureStringFromJson(json['country']),
      region: TautulliUtilities.ensureStringFromJson(json['region']),
      city: TautulliUtilities.ensureStringFromJson(json['city']),
      postalCode: TautulliUtilities.ensureStringFromJson(json['postal_code']),
      timezone: TautulliUtilities.ensureStringFromJson(json['timezone']),
      latitude: TautulliUtilities.ensureDoubleFromJson(json['latitude']),
      longitude: TautulliUtilities.ensureDoubleFromJson(json['longitude']),
      accuracy: TautulliUtilities.ensureDoubleFromJson(json['accuracy']),
      continent: TautulliUtilities.ensureStringFromJson(json['continent']),
    );

Map<String, dynamic> _$TautulliGeolocationInfoToJson(
    TautulliGeolocationInfo instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('code', instance.code);
  writeNotNull('country', instance.country);
  writeNotNull('region', instance.region);
  writeNotNull('city', instance.city);
  writeNotNull('postal_code', instance.postalCode);
  writeNotNull('timezone', instance.timezone);
  writeNotNull('latitude', instance.latitude);
  writeNotNull('longitude', instance.longitude);
  writeNotNull('accuracy', instance.accuracy);
  writeNotNull('continent', instance.continent);
  return val;
}
