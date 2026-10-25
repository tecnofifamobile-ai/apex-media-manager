// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_channel.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFavoriteChannelCollection on Isar {
  IsarCollection<FavoriteChannel> get favoriteChannels => this.collection();
}

const FavoriteChannelSchema = CollectionSchema(
  name: r'FavoriteChannel',
  id: 4381004366873818810,
  properties: {
    r'addedAt': PropertySchema(
      id: 0,
      name: r'addedAt',
      type: IsarType.dateTime,
    ),
    r'category': PropertySchema(
      id: 1,
      name: r'category',
      type: IsarType.string,
    ),
    r'cleanName': PropertySchema(
      id: 2,
      name: r'cleanName',
      type: IsarType.string,
    ),
    r'preferredName': PropertySchema(
      id: 3,
      name: r'preferredName',
      type: IsarType.string,
    ),
    r'preferredUrl': PropertySchema(
      id: 4,
      name: r'preferredUrl',
      type: IsarType.string,
    )
  },
  estimateSize: _favoriteChannelEstimateSize,
  serialize: _favoriteChannelSerialize,
  deserialize: _favoriteChannelDeserialize,
  deserializeProp: _favoriteChannelDeserializeProp,
  idName: r'id',
  indexes: {
    r'cleanName': IndexSchema(
      id: 5663364087405931711,
      name: r'cleanName',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'cleanName',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _favoriteChannelGetId,
  getLinks: _favoriteChannelGetLinks,
  attach: _favoriteChannelAttach,
  version: '3.1.0+1',
);

int _favoriteChannelEstimateSize(
  FavoriteChannel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.category.length * 3;
  bytesCount += 3 + object.cleanName.length * 3;
  {
    final value = object.preferredName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.preferredUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _favoriteChannelSerialize(
  FavoriteChannel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.addedAt);
  writer.writeString(offsets[1], object.category);
  writer.writeString(offsets[2], object.cleanName);
  writer.writeString(offsets[3], object.preferredName);
  writer.writeString(offsets[4], object.preferredUrl);
}

FavoriteChannel _favoriteChannelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FavoriteChannel();
  object.addedAt = reader.readDateTime(offsets[0]);
  object.category = reader.readString(offsets[1]);
  object.cleanName = reader.readString(offsets[2]);
  object.id = id;
  object.preferredName = reader.readStringOrNull(offsets[3]);
  object.preferredUrl = reader.readStringOrNull(offsets[4]);
  return object;
}

P _favoriteChannelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _favoriteChannelGetId(FavoriteChannel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _favoriteChannelGetLinks(FavoriteChannel object) {
  return [];
}

void _favoriteChannelAttach(
    IsarCollection<dynamic> col, Id id, FavoriteChannel object) {
  object.id = id;
}

extension FavoriteChannelByIndex on IsarCollection<FavoriteChannel> {
  Future<FavoriteChannel?> getByCleanName(String cleanName) {
    return getByIndex(r'cleanName', [cleanName]);
  }

  FavoriteChannel? getByCleanNameSync(String cleanName) {
    return getByIndexSync(r'cleanName', [cleanName]);
  }

  Future<bool> deleteByCleanName(String cleanName) {
    return deleteByIndex(r'cleanName', [cleanName]);
  }

  bool deleteByCleanNameSync(String cleanName) {
    return deleteByIndexSync(r'cleanName', [cleanName]);
  }

  Future<List<FavoriteChannel?>> getAllByCleanName(
      List<String> cleanNameValues) {
    final values = cleanNameValues.map((e) => [e]).toList();
    return getAllByIndex(r'cleanName', values);
  }

  List<FavoriteChannel?> getAllByCleanNameSync(List<String> cleanNameValues) {
    final values = cleanNameValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'cleanName', values);
  }

  Future<int> deleteAllByCleanName(List<String> cleanNameValues) {
    final values = cleanNameValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'cleanName', values);
  }

  int deleteAllByCleanNameSync(List<String> cleanNameValues) {
    final values = cleanNameValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'cleanName', values);
  }

  Future<Id> putByCleanName(FavoriteChannel object) {
    return putByIndex(r'cleanName', object);
  }

  Id putByCleanNameSync(FavoriteChannel object, {bool saveLinks = true}) {
    return putByIndexSync(r'cleanName', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCleanName(List<FavoriteChannel> objects) {
    return putAllByIndex(r'cleanName', objects);
  }

  List<Id> putAllByCleanNameSync(List<FavoriteChannel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'cleanName', objects, saveLinks: saveLinks);
  }
}

extension FavoriteChannelQueryWhereSort
    on QueryBuilder<FavoriteChannel, FavoriteChannel, QWhere> {
  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FavoriteChannelQueryWhere
    on QueryBuilder<FavoriteChannel, FavoriteChannel, QWhereClause> {
  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterWhereClause> idBetween(
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

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterWhereClause>
      cleanNameEqualTo(String cleanName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'cleanName',
        value: [cleanName],
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterWhereClause>
      cleanNameNotEqualTo(String cleanName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cleanName',
              lower: [],
              upper: [cleanName],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cleanName',
              lower: [cleanName],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cleanName',
              lower: [cleanName],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cleanName',
              lower: [],
              upper: [cleanName],
              includeUpper: false,
            ));
      }
    });
  }
}

extension FavoriteChannelQueryFilter
    on QueryBuilder<FavoriteChannel, FavoriteChannel, QFilterCondition> {
  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      addedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'addedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      addedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'addedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      addedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'addedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      addedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'addedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      categoryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      categoryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      categoryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      categoryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'category',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      categoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      categoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      categoryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      categoryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'category',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      categoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      categoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      cleanNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cleanName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      cleanNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cleanName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      cleanNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cleanName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      cleanNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cleanName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      cleanNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cleanName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      cleanNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cleanName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      cleanNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cleanName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      cleanNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cleanName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      cleanNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cleanName',
        value: '',
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      cleanNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cleanName',
        value: '',
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      preferredNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'preferredName',
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      preferredNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'preferredName',
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      preferredNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'preferredName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      preferredNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'preferredName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      preferredNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'preferredName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      preferredNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'preferredName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      preferredNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'preferredName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      preferredNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'preferredName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      preferredNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'preferredName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      preferredNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'preferredName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      preferredNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'preferredName',
        value: '',
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      preferredNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'preferredName',
        value: '',
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      preferredUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'preferredUrl',
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      preferredUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'preferredUrl',
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      preferredUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'preferredUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      preferredUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'preferredUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      preferredUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'preferredUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      preferredUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'preferredUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      preferredUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'preferredUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      preferredUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'preferredUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      preferredUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'preferredUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      preferredUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'preferredUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      preferredUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'preferredUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterFilterCondition>
      preferredUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'preferredUrl',
        value: '',
      ));
    });
  }
}

extension FavoriteChannelQueryObject
    on QueryBuilder<FavoriteChannel, FavoriteChannel, QFilterCondition> {}

extension FavoriteChannelQueryLinks
    on QueryBuilder<FavoriteChannel, FavoriteChannel, QFilterCondition> {}

extension FavoriteChannelQuerySortBy
    on QueryBuilder<FavoriteChannel, FavoriteChannel, QSortBy> {
  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterSortBy> sortByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.asc);
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterSortBy>
      sortByAddedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.desc);
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterSortBy>
      sortByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterSortBy>
      sortByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterSortBy>
      sortByCleanName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cleanName', Sort.asc);
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterSortBy>
      sortByCleanNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cleanName', Sort.desc);
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterSortBy>
      sortByPreferredName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preferredName', Sort.asc);
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterSortBy>
      sortByPreferredNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preferredName', Sort.desc);
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterSortBy>
      sortByPreferredUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preferredUrl', Sort.asc);
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterSortBy>
      sortByPreferredUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preferredUrl', Sort.desc);
    });
  }
}

extension FavoriteChannelQuerySortThenBy
    on QueryBuilder<FavoriteChannel, FavoriteChannel, QSortThenBy> {
  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterSortBy> thenByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.asc);
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterSortBy>
      thenByAddedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.desc);
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterSortBy>
      thenByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterSortBy>
      thenByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterSortBy>
      thenByCleanName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cleanName', Sort.asc);
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterSortBy>
      thenByCleanNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cleanName', Sort.desc);
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterSortBy>
      thenByPreferredName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preferredName', Sort.asc);
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterSortBy>
      thenByPreferredNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preferredName', Sort.desc);
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterSortBy>
      thenByPreferredUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preferredUrl', Sort.asc);
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QAfterSortBy>
      thenByPreferredUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preferredUrl', Sort.desc);
    });
  }
}

extension FavoriteChannelQueryWhereDistinct
    on QueryBuilder<FavoriteChannel, FavoriteChannel, QDistinct> {
  QueryBuilder<FavoriteChannel, FavoriteChannel, QDistinct>
      distinctByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'addedAt');
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QDistinct> distinctByCategory(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'category', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QDistinct> distinctByCleanName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cleanName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QDistinct>
      distinctByPreferredName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'preferredName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FavoriteChannel, FavoriteChannel, QDistinct>
      distinctByPreferredUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'preferredUrl', caseSensitive: caseSensitive);
    });
  }
}

extension FavoriteChannelQueryProperty
    on QueryBuilder<FavoriteChannel, FavoriteChannel, QQueryProperty> {
  QueryBuilder<FavoriteChannel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FavoriteChannel, DateTime, QQueryOperations> addedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'addedAt');
    });
  }

  QueryBuilder<FavoriteChannel, String, QQueryOperations> categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'category');
    });
  }

  QueryBuilder<FavoriteChannel, String, QQueryOperations> cleanNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cleanName');
    });
  }

  QueryBuilder<FavoriteChannel, String?, QQueryOperations>
      preferredNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'preferredName');
    });
  }

  QueryBuilder<FavoriteChannel, String?, QQueryOperations>
      preferredUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'preferredUrl');
    });
  }
}
