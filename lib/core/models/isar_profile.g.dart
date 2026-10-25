// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_profile.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarProfileCollection on Isar {
  IsarCollection<IsarProfile> get isarProfiles => this.collection();
}

const IsarProfileSchema = CollectionSchema(
  name: r'IsarProfile',
  id: -1036419008855777887,
  properties: {
    r'colorCode': PropertySchema(
      id: 0,
      name: r'colorCode',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'm3uUrl': PropertySchema(
      id: 2,
      name: r'm3uUrl',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 3,
      name: r'name',
      type: IsarType.string,
    ),
    r'syncId': PropertySchema(
      id: 4,
      name: r'syncId',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 5,
      name: r'type',
      type: IsarType.string,
    ),
    r'userId': PropertySchema(
      id: 6,
      name: r'userId',
      type: IsarType.string,
    ),
    r'xcPassword': PropertySchema(
      id: 7,
      name: r'xcPassword',
      type: IsarType.string,
    ),
    r'xcUrl': PropertySchema(
      id: 8,
      name: r'xcUrl',
      type: IsarType.string,
    ),
    r'xcUsername': PropertySchema(
      id: 9,
      name: r'xcUsername',
      type: IsarType.string,
    )
  },
  estimateSize: _isarProfileEstimateSize,
  serialize: _isarProfileSerialize,
  deserialize: _isarProfileDeserialize,
  deserializeProp: _isarProfileDeserializeProp,
  idName: r'id',
  indexes: {
    r'syncId': IndexSchema(
      id: 7538593479801827566,
      name: r'syncId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'syncId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _isarProfileGetId,
  getLinks: _isarProfileGetLinks,
  attach: _isarProfileAttach,
  version: '3.1.0+1',
);

int _isarProfileEstimateSize(
  IsarProfile object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.m3uUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.syncId.length * 3;
  bytesCount += 3 + object.type.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  {
    final value = object.xcPassword;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.xcUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.xcUsername;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _isarProfileSerialize(
  IsarProfile object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.colorCode);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.m3uUrl);
  writer.writeString(offsets[3], object.name);
  writer.writeString(offsets[4], object.syncId);
  writer.writeString(offsets[5], object.type);
  writer.writeString(offsets[6], object.userId);
  writer.writeString(offsets[7], object.xcPassword);
  writer.writeString(offsets[8], object.xcUrl);
  writer.writeString(offsets[9], object.xcUsername);
}

IsarProfile _isarProfileDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarProfile();
  object.colorCode = reader.readLong(offsets[0]);
  object.createdAt = reader.readDateTimeOrNull(offsets[1]);
  object.id = id;
  object.m3uUrl = reader.readStringOrNull(offsets[2]);
  object.name = reader.readString(offsets[3]);
  object.syncId = reader.readString(offsets[4]);
  object.type = reader.readString(offsets[5]);
  object.userId = reader.readString(offsets[6]);
  object.xcPassword = reader.readStringOrNull(offsets[7]);
  object.xcUrl = reader.readStringOrNull(offsets[8]);
  object.xcUsername = reader.readStringOrNull(offsets[9]);
  return object;
}

P _isarProfileDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarProfileGetId(IsarProfile object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarProfileGetLinks(IsarProfile object) {
  return [];
}

void _isarProfileAttach(
    IsarCollection<dynamic> col, Id id, IsarProfile object) {
  object.id = id;
}

extension IsarProfileByIndex on IsarCollection<IsarProfile> {
  Future<IsarProfile?> getBySyncId(String syncId) {
    return getByIndex(r'syncId', [syncId]);
  }

  IsarProfile? getBySyncIdSync(String syncId) {
    return getByIndexSync(r'syncId', [syncId]);
  }

  Future<bool> deleteBySyncId(String syncId) {
    return deleteByIndex(r'syncId', [syncId]);
  }

  bool deleteBySyncIdSync(String syncId) {
    return deleteByIndexSync(r'syncId', [syncId]);
  }

  Future<List<IsarProfile?>> getAllBySyncId(List<String> syncIdValues) {
    final values = syncIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'syncId', values);
  }

  List<IsarProfile?> getAllBySyncIdSync(List<String> syncIdValues) {
    final values = syncIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'syncId', values);
  }

  Future<int> deleteAllBySyncId(List<String> syncIdValues) {
    final values = syncIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'syncId', values);
  }

  int deleteAllBySyncIdSync(List<String> syncIdValues) {
    final values = syncIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'syncId', values);
  }

  Future<Id> putBySyncId(IsarProfile object) {
    return putByIndex(r'syncId', object);
  }

  Id putBySyncIdSync(IsarProfile object, {bool saveLinks = true}) {
    return putByIndexSync(r'syncId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySyncId(List<IsarProfile> objects) {
    return putAllByIndex(r'syncId', objects);
  }

  List<Id> putAllBySyncIdSync(List<IsarProfile> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'syncId', objects, saveLinks: saveLinks);
  }
}

extension IsarProfileQueryWhereSort
    on QueryBuilder<IsarProfile, IsarProfile, QWhere> {
  QueryBuilder<IsarProfile, IsarProfile, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarProfileQueryWhere
    on QueryBuilder<IsarProfile, IsarProfile, QWhereClause> {
  QueryBuilder<IsarProfile, IsarProfile, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterWhereClause> syncIdEqualTo(
      String syncId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'syncId',
        value: [syncId],
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterWhereClause> syncIdNotEqualTo(
      String syncId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncId',
              lower: [],
              upper: [syncId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncId',
              lower: [syncId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncId',
              lower: [syncId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncId',
              lower: [],
              upper: [syncId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension IsarProfileQueryFilter
    on QueryBuilder<IsarProfile, IsarProfile, QFilterCondition> {
  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      colorCodeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'colorCode',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      colorCodeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'colorCode',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      colorCodeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'colorCode',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      colorCodeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'colorCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      createdAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      createdAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      createdAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> m3uUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'm3uUrl',
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      m3uUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'm3uUrl',
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> m3uUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'm3uUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      m3uUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'm3uUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> m3uUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'm3uUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> m3uUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'm3uUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      m3uUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'm3uUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> m3uUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'm3uUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> m3uUrlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'm3uUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> m3uUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'm3uUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      m3uUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'm3uUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      m3uUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'm3uUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> syncIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      syncIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'syncId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> syncIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'syncId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> syncIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'syncId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      syncIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'syncId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> syncIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'syncId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> syncIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> syncIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syncId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      syncIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      syncIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> typeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> typeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> typeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> typeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> typeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> typeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> userIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      userIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> userIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> userIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      userIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> userIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> userIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> userIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      xcPasswordIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'xcPassword',
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      xcPasswordIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'xcPassword',
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      xcPasswordEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'xcPassword',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      xcPasswordGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'xcPassword',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      xcPasswordLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'xcPassword',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      xcPasswordBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'xcPassword',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      xcPasswordStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'xcPassword',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      xcPasswordEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'xcPassword',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      xcPasswordContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'xcPassword',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      xcPasswordMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'xcPassword',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      xcPasswordIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'xcPassword',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      xcPasswordIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'xcPassword',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> xcUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'xcUrl',
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      xcUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'xcUrl',
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> xcUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'xcUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      xcUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'xcUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> xcUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'xcUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> xcUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'xcUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> xcUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'xcUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> xcUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'xcUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> xcUrlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'xcUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> xcUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'xcUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition> xcUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'xcUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      xcUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'xcUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      xcUsernameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'xcUsername',
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      xcUsernameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'xcUsername',
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      xcUsernameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'xcUsername',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      xcUsernameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'xcUsername',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      xcUsernameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'xcUsername',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      xcUsernameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'xcUsername',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      xcUsernameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'xcUsername',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      xcUsernameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'xcUsername',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      xcUsernameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'xcUsername',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      xcUsernameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'xcUsername',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      xcUsernameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'xcUsername',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterFilterCondition>
      xcUsernameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'xcUsername',
        value: '',
      ));
    });
  }
}

extension IsarProfileQueryObject
    on QueryBuilder<IsarProfile, IsarProfile, QFilterCondition> {}

extension IsarProfileQueryLinks
    on QueryBuilder<IsarProfile, IsarProfile, QFilterCondition> {}

extension IsarProfileQuerySortBy
    on QueryBuilder<IsarProfile, IsarProfile, QSortBy> {
  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> sortByColorCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorCode', Sort.asc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> sortByColorCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorCode', Sort.desc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> sortByM3uUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'm3uUrl', Sort.asc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> sortByM3uUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'm3uUrl', Sort.desc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> sortBySyncId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncId', Sort.asc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> sortBySyncIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncId', Sort.desc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> sortByXcPassword() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xcPassword', Sort.asc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> sortByXcPasswordDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xcPassword', Sort.desc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> sortByXcUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xcUrl', Sort.asc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> sortByXcUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xcUrl', Sort.desc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> sortByXcUsername() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xcUsername', Sort.asc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> sortByXcUsernameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xcUsername', Sort.desc);
    });
  }
}

extension IsarProfileQuerySortThenBy
    on QueryBuilder<IsarProfile, IsarProfile, QSortThenBy> {
  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> thenByColorCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorCode', Sort.asc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> thenByColorCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorCode', Sort.desc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> thenByM3uUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'm3uUrl', Sort.asc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> thenByM3uUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'm3uUrl', Sort.desc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> thenBySyncId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncId', Sort.asc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> thenBySyncIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncId', Sort.desc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> thenByXcPassword() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xcPassword', Sort.asc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> thenByXcPasswordDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xcPassword', Sort.desc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> thenByXcUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xcUrl', Sort.asc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> thenByXcUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xcUrl', Sort.desc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> thenByXcUsername() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xcUsername', Sort.asc);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QAfterSortBy> thenByXcUsernameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xcUsername', Sort.desc);
    });
  }
}

extension IsarProfileQueryWhereDistinct
    on QueryBuilder<IsarProfile, IsarProfile, QDistinct> {
  QueryBuilder<IsarProfile, IsarProfile, QDistinct> distinctByColorCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'colorCode');
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QDistinct> distinctByM3uUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'm3uUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QDistinct> distinctBySyncId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QDistinct> distinctByType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QDistinct> distinctByUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QDistinct> distinctByXcPassword(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'xcPassword', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QDistinct> distinctByXcUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'xcUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarProfile, IsarProfile, QDistinct> distinctByXcUsername(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'xcUsername', caseSensitive: caseSensitive);
    });
  }
}

extension IsarProfileQueryProperty
    on QueryBuilder<IsarProfile, IsarProfile, QQueryProperty> {
  QueryBuilder<IsarProfile, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarProfile, int, QQueryOperations> colorCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'colorCode');
    });
  }

  QueryBuilder<IsarProfile, DateTime?, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<IsarProfile, String?, QQueryOperations> m3uUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'm3uUrl');
    });
  }

  QueryBuilder<IsarProfile, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<IsarProfile, String, QQueryOperations> syncIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncId');
    });
  }

  QueryBuilder<IsarProfile, String, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<IsarProfile, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }

  QueryBuilder<IsarProfile, String?, QQueryOperations> xcPasswordProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'xcPassword');
    });
  }

  QueryBuilder<IsarProfile, String?, QQueryOperations> xcUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'xcUrl');
    });
  }

  QueryBuilder<IsarProfile, String?, QQueryOperations> xcUsernameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'xcUsername');
    });
  }
}
