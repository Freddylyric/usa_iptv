import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String url;


  VideoPlayerScreen({required this.url, });

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController? _chewieController;
  bool _isFullScreen = false;
  var interstitialAdUnit = "ca-app-pub-9354755118881714/8787204120";
  InterstitialAd? _interstitialAd;
  bool _adShown = false;


  @override
  void initState() {
    super.initState();
    _createInterstitialAd();
    _videoPlayerController = VideoPlayerController.network(widget.url);
  }


  @override
  void dispose() {
    _interstitialAd?.dispose();
    _chewieController?.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }




  void _createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnit,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          // Show the ad as soon as it is loaded.
          if (!_adShown) {
            _showInterstitialAd(widget.url);
          }
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            print('Ad failed to load: $error');
          }
        },
      ),
    );
  }

  void _showInterstitialAd(url) async {
    if (_interstitialAd == null) {
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        if (_adShown) {
          Navigator. of(context).pop();

          // here call vi

        } else {
          setState(() {
            _adShown = true;
          });
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        if (kDebugMode) {
          print('$ad onAdFailedToShowFullScreenContent: $error');
        }
        //here call vid
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null;
  }


  void _enterFullScreen() {
    setState(() {
      _isFullScreen = true;
    });

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _exitFullScreen() {
    setState(() {
      _isFullScreen = false;
    });

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Enjoy Watching", style: GoogleFonts.poppins(fontSize: 20, color: Colors.black, ),),
      ),
      body: FutureBuilder(
        future: _videoPlayerController.initialize(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            _chewieController = ChewieController(
              videoPlayerController: _videoPlayerController,
              autoPlay: true,
              looping: true,
              showControls: true,
              allowFullScreen: true,
            );
            return _buildVideoPlayer();
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Chewie(
      controller: _chewieController!,
    );
  }
}