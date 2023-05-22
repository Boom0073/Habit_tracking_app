import 'package:flutter_svg/flutter_svg.dart';

//In order to load SVGs inside the flutter app, we need to use
//flutter_svg packager.We will write hard code the path to the
//assets that we need inside our widgets, however this is quite
//error prone.So what I'va done instead is to define all these
//assets as constant string that we can reference by name
class AppAssets {
  //System UI
  static const check = 'assets/check.svg';
  static const plus = 'assets/plus.svg';
  static const threeDots = 'assets/three-dots.svg';
  static const delete = 'assets/delete.svg';
  static const navigationClose = 'assets/navigation-close.svg';
  static const navigationBack = 'assets/navigation-back.svg';

  //tasks
  static const basketball = 'assets/basketball-ball.svg';
  static const beer = 'assets/beer.svg';
  static const bike = 'assets/bike.svg';
  static const book = 'assets/book.svg';
  static const carrot = 'assets/carrot.svg';
  static const chef = 'assets/chef.svg';
  static const dentalFloss = 'assets/dental-floss.svg';
  static const dog = 'assets/dog.svg';
  static const dumbell = 'assets/dumbell.svg';
  static const guitar = 'assets/guitar.svg';
  static const homework = 'assets/homework.svg';
  static const html = 'assets/html-coding.svg';
  static const karate = 'assets/karate.svg';
  static const mask = 'assets/mask.svg';
  static const meditation = 'assets/meditation.svg';
  static const painting = 'assets/paint-board-and-brush.svg';
  static const phone = 'assets/phone.svg';
  static const pushups = 'assets/pushups-man.svg';
  static const rest = 'assets/rest.svg';
  static const run = 'assets/run.svg';
  static const smoking = 'assets/smoking.svg';
  static const stretching = 'assets/stretching-exercises.svg';
  static const sun = 'assets/sun.svg';
  static const swimmer = 'assets/swimmer.svg';
  static const toothbrush = 'assets/toothbrush.svg';
  static const vitamins = 'assets/vitamins.svg';
  static const washHands = 'assets/wash-hands.svg';
  static const water = 'assets/water.svg';

  static const allTaskIcons = [
    basketball,
    beer,
    bike,
    book,
    carrot,
    chef,
    dentalFloss,
    dog,
    dumbell,
    guitar,
    homework,
    html,
    karate,
    mask,
    meditation,
    painting,
    phone,
    pushups,
    rest,
    run,
    smoking,
    stretching,
    sun,
    swimmer,
    toothbrush,
    vitamins,
    washHands,
    water,
  ];
  //This preloadSVGs() method use to preload SVGs file.Because
  //SVGs need to be precached so that they show immediately when used
  static Future<void> preloadSVGs() async {
    final assets = [
      //system UI
      check, plus, threeDots, delete, navigationClose, navigationBack,
      //tasks
      ...allTaskIcons,
    ];
    for (final asset in assets) {
      //this method is used to preload each assets in main function
      //before render UI.It allows us to precach all the assets by calling
      //this precachePicture function when our application starts.
      //This is something that we need to do when we work with SVG files in Flutter.
      await precachePicture(
        ExactAssetPicture(SvgPicture.svgStringDecoderBuilder, asset),
        null,
      );
    }
  }
}
