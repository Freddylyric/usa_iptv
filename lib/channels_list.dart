import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:usa_tv/video_player_screen.dart';
import 'adapters/channels_model.dart';
// Assuming you have a Channels model

class ChannelsList extends StatefulWidget {
  @override
  _ChannelsListState createState() => _ChannelsListState();
}

class _ChannelsListState extends State<ChannelsList> {
  late Box<ChannelModel> channelsBox;

  late BannerAd bannerAdTop;
  late BannerAd bannerAdBottom;
  bool isLoadedTop = false;
  bool isLoadedBottom = false;

  var adUnitTop = "ca-app-pub-3940256099942544/6300978111"; // Change this to your top ad unit ID
  var adUnitBottom = "ca-app-pub-3940256099942544/6300978111"; // Change this to your bottom ad unit ID

  @override
  void initState() {
    super.initState();
    channelsBox = Hive.box<ChannelModel>('channels');
    _initChannels();
    initBannerAds();
  }

  initBannerAds() {
    bannerAdTop = BannerAd(
        adUnitId: adUnitTop,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
            onAdLoaded: (ad) {
              setState(() {
                isLoadedTop = true;
              });
            },
            onAdFailedToLoad: (ad, error) {
              ad.dispose();
              print("Failed to load top banner ad: ${error.message}");
            }));
    bannerAdTop.load();

    bannerAdBottom = BannerAd(
        adUnitId: adUnitBottom,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
            onAdLoaded: (ad) {
              setState(() {
                isLoadedBottom = true;
              });
            },
            onAdFailedToLoad: (ad, error) {
              ad.dispose();
              print("Failed to load bottom banner ad: ${error.message}");
            }));
    bannerAdBottom.load();
  }


  Future<void> _initChannels() async {
    // Check if Nigerian channels are already in the Hive box
    if (channelsBox.values.any((channel) => channel.country == 'Nigeria')) {
      return;
    }

    // If not, fetch Nigerian channels from Firebase and add them to the Hive box
    await fetchNigerianChannelsFirebase();
    setState(() {

    });
  }

  Future<List<ChannelModel>> fetchNigerianChannels() async {
    try {
      List<ChannelModel> nigerianChannels = [];

      // Iterate through the Hive box
      for (var i = 0; i < channelsBox.length; i++) {
        ChannelModel channel = channelsBox.getAt(i)!;
        if (channel.country == 'Nigeria') {
          nigerianChannels.add(channel);
        }
      }

      return nigerianChannels;
    } catch (e) {
      print("Error fetching channels: $e");
      return [];
    }
  }

  // ... Other methods ...

  Future<List<QueryDocumentSnapshot>> fetchNigerianChannelsFirebase() async {
    try {
      Box<ChannelModel> channelsBox = Hive.box<ChannelModel>('channels');

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('channels')
          .where('country', isEqualTo: 'Nigeria')
          .get();

      List<QueryDocumentSnapshot> documents = snapshot.docs;

      for (QueryDocumentSnapshot document in documents) {
        Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;

        if (data != null) {
          String channelId = data['id'] ?? '';
          String channelName = data['name'] ?? '';
          String channelCountry = data['country'] ?? '';
          String channelLogo = data['logo'] ?? '';
          String channelStreamingLink = data['streamingLink'] ?? '';

          // Save the data in the Hive channel box
          channelsBox.put(
            channelId,
            ChannelModel(
              id: channelId,
              name: channelName,
              country: channelCountry,
              logo: channelLogo,
              streamingLink: channelStreamingLink,
            ),
          );
        }
      }

      return documents;
    } catch (e) {
      print("Error fetching channels: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
        title: Text('USA TV'),
      ),
      body:
      Column(
          children: [

            isLoadedTop
                ? SizedBox(
              height: bannerAdTop.size.height.toDouble(),
              width: bannerAdTop.size.width.toDouble(),
              child: AdWidget(ad: bannerAdTop),
            )
                : SizedBox(),
            Container(
              height: size.height*0.8,

              child:
            FutureBuilder(
              future: fetchNigerianChannels(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading channels'));
                } else {
                  List<ChannelModel> nigerianChannels =
                  snapshot.data as List<ChannelModel>;
                  return ListView.builder(
                    itemCount: nigerianChannels.length,
                    itemBuilder: (context, index) {
                      ChannelModel channel = nigerianChannels[index];

                      return Card(
                        child: ListTile(
                          onTap: () async {
                            String streamingLink = channel.streamingLink;
                            if (streamingLink.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VideoPlayerScreen(
                                    url: streamingLink,
                                  ),
                                ),
                              );
                            }
                          },
                          leading: _buildLogoWidget(channel.logo),
                          title: Text(channel.name),
                          subtitle: Text(channel.id),
                        ),
                      );
                    },
                  );
                }
              },
            ),
            ),





            isLoadedBottom
                ? SizedBox(
              height: bannerAdBottom.size.height.toDouble(),
              width: bannerAdBottom.size.width.toDouble(),
              child: AdWidget(ad: bannerAdBottom),
            )
                : SizedBox(),
          ]),
    );
  }

  Widget _buildLogoWidget(String logoUrl) {
    if (logoUrl.isEmpty) {
      return CircularProgressIndicator();
    } else {
      return Container(
        width: 50,
        height: 50,
        child: Image.network(
          logoUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container();
          },
        ),
      );
    }
  }
}