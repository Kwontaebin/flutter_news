import 'package:json_annotation/json_annotation.dart';

part 'newsModel.g.dart';

@JsonSerializable()
class News {
  final String title;
  final String url;

  News({required this.title, required this.url});

  // JSON -> DTO
  factory News.fromJson(Map<String, dynamic> json) => _$NewsFromJson(json);

  // DTO -> JSON
  Map<String, dynamic> toJson() => _$NewsToJson(this);
}
