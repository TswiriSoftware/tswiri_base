import 'package:string_similarity/string_similarity.dart';
import 'package:tswiri_base/models/search/search_result_models.dart';
import 'package:tswiri_database/tswiri_app_database/app_database.dart';

class SearchController {
  SearchController({
    required this.filters,
  });

  ///A reference to the filterList.
  List<String> filters;

  List<Result> searchResults = [];

  void search({String? enteredKeyword}) {
    if (enteredKeyword != null && enteredKeyword.isNotEmpty) {
      //Normilize the enteredKeyword.
      String normilizedEnteredKeyword = enteredKeyword.trim().toLowerCase();

      //Clear the search results.
      searchResults.clear();

      if (filters.contains('Name')) {
        //Search on CatalogedContainer Name.
        searchResults.addAll(nameSearch(normilizedEnteredKeyword));
      }

      if (filters.contains('Description')) {
        //Search on CatalogedContainer Description.
        searchResults.addAll(descriptionSearch(enteredKeyword));
      }

      //Check if the TagText table search should be conducted.
      if (filters.contains('Tags') ||
          filters.contains('Photo Labels') ||
          filters.contains('Object Labels')) {
        //Search TagText Table.
        List<TagText> tagTexts = appIsar!.tagTexts
            .filter()
            .textContains(enteredKeyword, caseSensitive: false)
            .findAllSync();

        if (filters.contains('Tags')) {
          //Add Tag Results.
          searchResults.addAll(containerTagSearch(enteredKeyword, tagTexts));
        }
        if (filters.contains('Photo Labels')) {
          //Add Photo Label Results.
          searchResults.addAll(photoLabelSearch(enteredKeyword, tagTexts));
        }
        if (filters.contains('Object Labels')) {
          //Add Object Label Results.
          searchResults.addAll(objectLabelSearch(enteredKeyword, tagTexts));
        }
      }

      if (filters.contains('ML Labels')) {
        //Search on MLDetectedLabelText.
        List<MLDetectedLabelText> mlDetectedLabelTexts = appIsar!
            .mLDetectedLabelTexts
            .filter()
            .detectedLabelTextContains(enteredKeyword, caseSensitive: false)
            .findAllSync();

        //Add mlPhotoLabel results.
        searchResults
            .addAll(mlPhotoLabelSearch(enteredKeyword, mlDetectedLabelTexts));

        //Add mlObjectLabel results.
        searchResults
            .addAll(mlObjectLabelSearch(enteredKeyword, mlDetectedLabelTexts));
      }

      if (filters.contains('ML Text')) {
        List<MLDetectedElementText> mlDetectedElementTexts = appIsar!
            .mLDetectedElementTexts
            .filter()
            .detectedTextContains(enteredKeyword, caseSensitive: false)
            .findAllSync();

        //Add mlText results.
        searchResults
            .addAll(mlTextSearch(enteredKeyword, mlDetectedElementTexts));
      }

      //Sort results in decending order on TextSimilarity.
      searchResults
          .sort((a, b) => b.textSimilarity.compareTo(a.textSimilarity));
    } else {
      //Defaults.
      //Clear the search results.
      searchResults.clear();

      searchResults.addAll(nameSearch(''));
    }
  }

  //Search on containerNames.
  List<NameResult> nameSearch(String enteredKeyword) {
    //List of containers where name contains enteredKeyword.
    List<CatalogedContainer> containers = appIsar!.catalogedContainers
        .filter()
        .nameContains(enteredKeyword, caseSensitive: false)
        .findAllSync();

    return containers.map(
      (e) {
        return NameResult(
            uid: 'nr_${e.id}',
            containerUID: e.containerUID,
            textSimilarity: enteredKeyword.similarityTo(e.name),
            name: e.name ?? 'err');
      },
    ).toList();
  }

  //Search on containerDescriptions.
  List<DescriptionResult> descriptionSearch(String enteredKeyword) {
    //List of containers where name contains enteredKeyword.
    List<CatalogedContainer> containers = appIsar!.catalogedContainers
        .filter()
        .descriptionContains(enteredKeyword, caseSensitive: false)
        .findAllSync();

    return containers.map(
      (e) {
        return DescriptionResult(
            uid: '${e.id}_${e.barcodeUID}',
            containerUID: e.containerUID,
            textSimilarity: enteredKeyword.similarityTo(e.description),
            description: e.description ?? 'err');
      },
    ).toList();
  }

  //Search on containerTags.
  List<ContainerTagResult> containerTagSearch(
      String enteredKeyword, List<TagText> tagTexts) {
    List<ContainerTagResult> results = [];

    for (TagText tagText in tagTexts) {
      //Find relevant containerTags.
      List<ContainerTag> containerTags = appIsar!.containerTags
          .filter()
          .tagTextIDEqualTo(tagText.id)
          .findAllSync();

      for (ContainerTag containerTag in containerTags) {
        //Find relevant CatalogedContainer.
        CatalogedContainer? catalogedContainer = appIsar!.catalogedContainers
            .filter()
            .containerUIDMatches(containerTag.containerUID)
            .findFirstSync();

        if (catalogedContainer != null) {
          //Create ContainerTag Result.
          results.add(
            ContainerTagResult(
              uid: 'ct_${catalogedContainer.id}',
              containerUID: catalogedContainer.containerUID,
              textSimilarity: enteredKeyword.similarityTo(tagText.text),
              tag: tagText.text,
            ),
          );
        }
      }
    }
    return results;
  }

  //Search on photoLabels.
  List<PhotoLabelResult> photoLabelSearch(
      String enteredKeyword, List<TagText> tagTexts) {
    List<PhotoLabelResult> results = [];

    for (TagText tagText in tagTexts) {
      //Find relevant photoLabels.
      List<PhotoLabel> photoLabels = appIsar!.photoLabels
          .filter()
          .tagTextIDEqualTo(tagText.id)
          .findAllSync();

      for (PhotoLabel photoLabel in photoLabels) {
        Photo? photo = appIsar!.photos.getSync(photoLabel.photoID);
        if (photo != null) {
          results.add(PhotoLabelResult(
            uid: 'plr_${photoLabel.id}',
            containerUID: photo.containerUID!,
            textSimilarity: enteredKeyword.similarityTo(tagText.text),
            photoLabel: tagText.text,
            photo: photo,
          ));
        }
      }
    }

    return results;
  }

  //Search on objectLabels
  List<ObjectLabelResult> objectLabelSearch(
      String enteredKeyword, List<TagText> tagTexts) {
    //List of results.
    List<ObjectLabelResult> results = [];

    for (TagText tagText in tagTexts) {
      //Find relevant objectLabels.
      List<ObjectLabel> objectLabels = appIsar!.objectLabels
          .filter()
          .tagTextIDEqualTo(tagText.id)
          .findAllSync();

      for (ObjectLabel objectLabel in objectLabels) {
        //Find relevant mlObject.
        MLObject? mlObject = appIsar!.mLObjects.getSync(objectLabel.objectID);
        if (mlObject != null) {
          //Find relevant photo.
          Photo? photo = appIsar!.photos.getSync(mlObject.photoID);
          if (photo != null) {
            //Create ObjectLabelResult.
            results.add(
              ObjectLabelResult(
                uid: '${photo.containerUID!}_${objectLabel.id}',
                containerUID: photo.containerUID!,
                textSimilarity: enteredKeyword.similarityTo(tagText.text),
                objectLabel: tagText.text,
                mlObject: mlObject,
                photo: photo,
              ),
            );
          }
        }
      }
    }

    return results;
  }

  List<MLPhotoLabelResult> mlPhotoLabelSearch(
      String enteredKeyword, List<MLDetectedLabelText> mlDetectedLabelTexts) {
    //List of results.
    List<MLPhotoLabelResult> results = [];

    for (MLDetectedLabelText mlDetectedLabel in mlDetectedLabelTexts) {
      //Find relevant mlPhotoLabels.
      List<MLPhotoLabel> mlPhotoLabels = appIsar!.mLPhotoLabels
          .filter()
          .detectedLabelTextIDEqualTo(mlDetectedLabel.id)
          .findAllSync();

      for (MLPhotoLabel mlPhotoLabel in mlPhotoLabels) {
        //Find relevant photo.
        Photo? photo = appIsar!.photos.getSync(mlPhotoLabel.photoID!);

        if (photo != null &&
            mlDetectedLabel.hidden == false &&
            mlPhotoLabel.userFeedback != false) {
          //Create MLPhotoLabelResult.
          results.add(
            MLPhotoLabelResult(
              uid: 'mlplr_${photo.id}_${mlPhotoLabel.id}',
              containerUID: photo.containerUID!,
              textSimilarity: enteredKeyword
                  .similarityTo(mlDetectedLabel.detectedLabelText),
              mlPhotoLabel: mlDetectedLabel.detectedLabelText,
              photo: photo,
            ),
          );
        }
      }
    }
    return results;
  }

  List<MLObjectLabelResult> mlObjectLabelSearch(
      String enteredKeyword, List<MLDetectedLabelText> mlDetectedLabelTexts) {
    //List of results.
    List<MLObjectLabelResult> results = [];
    for (MLDetectedLabelText mlDetectedLabel in mlDetectedLabelTexts) {
      //Find relevant mlObjectLabels.
      List<MLObjectLabel> mlObjectLabels = appIsar!.mLObjectLabels
          .filter()
          .detectedLabelTextIDEqualTo(mlDetectedLabel.id)
          .findAllSync();

      for (MLObjectLabel mlObjectLabel in mlObjectLabels) {
        //Find relevant MLObject.
        MLObject? mlObject = appIsar!.mLObjects.getSync(mlObjectLabel.objectID);
        if (mlObject != null) {
          //Find relevant photo.
          Photo? photo = appIsar!.photos.getSync(mlObject.photoID);
          if (photo != null && mlObjectLabel.userFeedback != false) {
            //Create MLObjectLabelResult.
            results.add(
              MLObjectLabelResult(
                uid: 'mlolr_${mlObjectLabel.id}',
                containerUID: photo.containerUID!,
                textSimilarity: enteredKeyword
                    .similarityTo(mlDetectedLabel.detectedLabelText),
                mlObjectLabel: mlDetectedLabel.detectedLabelText,
                mlObject: mlObject,
                photo: photo,
              ),
            );
          }
        }
      }
    }
    return results;
  }

  List<MLTextResult> mlTextSearch(String enteredKeyword,
      List<MLDetectedElementText> mlDetectedElementTexts) {
    List<MLTextResult> results = [];

    for (MLDetectedElementText mlDetectedElementText
        in mlDetectedElementTexts) {
      //Find relevant mlTextElements.
      List<MLTextElement> mlTextElements = appIsar!.mLTextElements
          .filter()
          .detectedElementTextIDEqualTo(mlDetectedElementText.id)
          .findAllSync();

      for (MLTextElement mlTextElement in mlTextElements) {
        //Find relevent photo.
        Photo? photo = appIsar!.photos.getSync(mlTextElement.photoID);
        if (photo != null) {
          results.add(
            MLTextResult(
              uid: 'mlter_${mlTextElement.id}',
              containerUID: photo.containerUID!,
              textSimilarity: enteredKeyword
                  .similarityTo(mlDetectedElementText.detectedText),
              mlText: mlDetectedElementText.detectedText,
              mlTextElement: mlTextElement,
              photo: photo,
            ),
          );
        }
      }
    }

    return results;
  }
}