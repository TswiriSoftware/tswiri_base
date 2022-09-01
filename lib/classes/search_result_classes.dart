import 'package:tswiri_database/tswiri_app_database/app_database.dart';

///Base Result class.
abstract class Result {
  Result({
    required this.containerUID,
    required this.textSimilarity,
  });

  ///The containerUID of this result.
  String containerUID;

  ///The textSimilarity. (string_similarity)
  ///Comparison of enteredKeyword to the result.
  double textSimilarity;

  @override
  String toString() {
    return 'Result: $textSimilarity, $containerUID\n';
  }
}

///Name Result.
class NameResult implements Result {
  NameResult({
    required this.containerUID,
    required this.textSimilarity,
    required this.name,
  });

  ///ContainerUID.
  @override
  String containerUID;

  ///Comparison between the enteredKeyword and the name.
  @override
  double textSimilarity;

  ///The name of the Cataloged Container.
  String name;

  @override
  String toString() {
    return 'Name Result, "$name", $textSimilarity, $containerUID\n';
  }
}

///Description Result.
class DescriptionResult implements Result {
  DescriptionResult({
    required this.containerUID,
    required this.textSimilarity,
    required this.description,
  });

  ///ContainerUID.
  @override
  String containerUID;

  ///Comparison between the enteredKeyword and the description.
  @override
  double textSimilarity;

  ///The description of the Cataloged Container.
  String description;

  @override
  String toString() {
    return 'Description Result, "$description", $textSimilarity, $containerUID\n';
  }
}

///ContainerTag Result.
class ContainerTagResult implements Result {
  ContainerTagResult({
    required this.containerUID,
    required this.textSimilarity,
    required this.tag,
  });

  ///ContainerUID.
  @override
  String containerUID;

  ///Comparison between the enteredKeyword and the description.
  @override
  double textSimilarity;

  ///The description of the Cataloged Container.
  String tag;

  @override
  String toString() {
    return 'Description Result, "$tag", $textSimilarity, $containerUID\n';
  }
}

///PhotoLabel Result.
class PhotoLabelResult implements Result {
  PhotoLabelResult({
    required this.containerUID,
    required this.textSimilarity,
    required this.photoLabel,
    required this.photo,
  });

  ///ContainerUID.
  @override
  String containerUID;

  ///Comparison between the enteredKeyword and the description.
  @override
  double textSimilarity;

  ///The photoLabel Text.
  String photoLabel;

  ///The Photo.
  Photo photo;

  @override
  String toString() {
    return 'Description Result, "$photoLabel", $textSimilarity, $containerUID\n';
  }
}

///ObjectLabel Result.
class ObjectLabelResult implements Result {
  ObjectLabelResult({
    required this.containerUID,
    required this.textSimilarity,
    required this.objectLabel,
    required this.mlObject,
    required this.photo,
  });

  ///ContainerUID.
  @override
  String containerUID;

  ///Comparison between the enteredKeyword and the description.
  @override
  double textSimilarity;

  ///The description of the Cataloged Container.
  String objectLabel;

  ///The mlObject (for cut-outs)
  MLObject mlObject;

  ///The Photo.
  Photo photo;

  @override
  String toString() {
    return 'Description Result, "$objectLabel", $textSimilarity, $containerUID\n';
  }
}

///MLPhotoLabel Result.
class MLPhotoLabelResult implements Result {
  MLPhotoLabelResult({
    required this.containerUID,
    required this.textSimilarity,
    required this.mlPhotoLabel,
    required this.photo,
  });

  ///ContainerUID.
  @override
  String containerUID;

  ///Comparison between the enteredKeyword and the description.
  @override
  double textSimilarity;

  ///The photoLabel Text.
  String mlPhotoLabel;

  ///The Photo.
  Photo photo;

  @override
  String toString() {
    return 'Description Result, "$mlPhotoLabel", $textSimilarity, $containerUID\n';
  }
}

///MLObjectLabel Result.
class MLObjectLabelResult implements Result {
  MLObjectLabelResult({
    required this.containerUID,
    required this.textSimilarity,
    required this.mlObjectLabel,
    required this.mlObject,
    required this.photo,
  });

  ///ContainerUID.
  @override
  String containerUID;

  ///Comparison between the enteredKeyword and the description.
  @override
  double textSimilarity;

  ///The description of the Cataloged Container.
  String mlObjectLabel;

  ///The mlObject (for cut-outs)
  MLObject mlObject;

  ///The Photo.
  Photo photo;

  @override
  String toString() {
    return 'Description Result, "$mlObjectLabel", $textSimilarity, $containerUID\n';
  }
}

///MLTextResult Result.
class MLTextResult implements Result {
  MLTextResult({
    required this.containerUID,
    required this.textSimilarity,
    required this.mlText,
    required this.mlTextElement,
    required this.photo,
  });

  ///ContainerUID.
  @override
  String containerUID;

  ///Comparison between the enteredKeyword and the description.
  @override
  double textSimilarity;

  ///The description of the Cataloged Container.
  String mlText;

  ///The mlObject (for cut-outs)
  MLTextElement mlTextElement;

  ///The Photo.
  Photo photo;

  @override
  String toString() {
    return 'Description Result, "$mlText", $textSimilarity, $containerUID\n';
  }
}
