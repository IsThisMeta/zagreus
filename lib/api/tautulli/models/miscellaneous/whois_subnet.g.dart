// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'whois_subnet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliWHOISSubnet _$TautulliWHOISSubnetFromJson(Map<String, dynamic> json) =>
    TautulliWHOISSubnet(
      cidr: TautulliUtilities.ensureStringFromJson(json['cidr']),
      name: TautulliUtilities.ensureStringFromJson(json['name']),
      handle: TautulliUtilities.ensureStringFromJson(json['handle']),
      range: TautulliUtilities.ensureStringFromJson(json['range']),
      description: TautulliUtilities.ensureStringFromJson(json['description']),
      country: TautulliUtilities.ensureStringFromJson(json['country']),
      state: TautulliUtilities.ensureStringFromJson(json['state']),
      city: TautulliUtilities.ensureStringFromJson(json['city']),
      address: TautulliUtilities.ensureStringFromJson(json['address']),
      postalCode: TautulliUtilities.ensureStringFromJson(json['postal_code']),
      emails: TautulliUtilities.ensureStringListFromJson(json['emails']),
      created: TautulliUtilities.ensureStringFromJson(json['created']),
      updated: TautulliUtilities.ensureStringFromJson(json['updated']),
    );

Map<String, dynamic> _$TautulliWHOISSubnetToJson(TautulliWHOISSubnet instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('cidr', instance.cidr);
  writeNotNull('name', instance.name);
  writeNotNull('handle', instance.handle);
  writeNotNull('range', instance.range);
  writeNotNull('description', instance.description);
  writeNotNull('country', instance.country);
  writeNotNull('state', instance.state);
  writeNotNull('city', instance.city);
  writeNotNull('address', instance.address);
  writeNotNull('postal_code', instance.postalCode);
  writeNotNull('emails', instance.emails);
  writeNotNull('created', instance.created);
  writeNotNull('updated', instance.updated);
  return val;
}
