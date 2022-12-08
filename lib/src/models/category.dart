import 'media.dart';

class Category {
  String id;
  String name;
  Media? picture;

  Category(this.id, this.name);

  Category.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap['id']?.toString() ?? '',
        name = jsonMap['name'] ?? '',
        picture =
            jsonMap['has_media'] ? Media.fromJSON(jsonMap['media'][0]) : null;
}
