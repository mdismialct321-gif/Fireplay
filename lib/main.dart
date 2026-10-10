import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

void main() => runApp(MaterialApp(home: FirePlay(), debugShowCheckedModeBanner: false));

class FirePlay extends StatefulWidget { @override _FirePlayState createState() => _FirePlayState(); }

class _FirePlayState extends State<FirePlay> {
  List videos = [
    {'videoId': 'qXAvZUnMkm4', 'title': 'O Priyotoma - Shakib Khan - Full Song', 'author': 'Tiger Media'},
    {'videoId': '6iaJ08pY4ss', 'title': 'Hawa - Sada Sada Kala Kala - 4K', 'author': 'Chorki'},
    {'videoId': 'zqGW8TcG_0A', 'title': 'Poran - Cholo Niralay Song', 'author': 'Live Tech'},
    {'videoId': 'J0y6y_rj0lA', 'title': 'Priyotoma LoFi Version', 'author': 'LoFi BD'},
    {'videoId': 'u3rHdpj3_z0', 'title': 'Rajkumar - Barood Song - Shakib Khan', 'author': 'Bongo'},
    {'videoId': '9bZkp7q19f0', 'title': 'Bangla New Natok 2025 Apurba', 'author': 'CMV'},
    {'videoId': 'kJQP7kiw5Fk', 'title': 'Azhari Waz 2025 New', 'author': 'Azhari TV'},
    {'videoId': 'RgKAFK5djSk', 'title': 'Shakib Khan Hit Movie', 'author': 'Eagle'},
  ];
  TextEditingController ctrl = TextEditingController();
  bool loading = false;

  Future<void> search(String q) async {
    setState(() => loading = true);
    try {
      final res = await http.get(Uri.parse('https://pipedapi.kavin.rocks/search?q=$q')).timeout(Duration(seconds: 8));
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        var items = data['items'] as List;
        var list = items.where((v) => v['type'] == 'stream').map((v){
          String url = v['url']?? '';
          String id = url.contains('=')? url.split('=').last : url.split('/').last;
          return {'videoId': id, 'title': v['title'], 'author': v['uploaderName']};
        }).toList();
        if(list.isNotEmpty) setState(() => videos = list);
      }
    } catch(e) {}
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.red, title: Text("🔥 FirePlay - ${videos.length} Videos", style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true),
      body: Column(children: [
        Padding(padding: EdgeInsets.all(10), child: TextField(controller: ctrl, style: TextStyle(color: Colors.white), onSubmitted: (v)=> search(v), decoration: InputDecoration(hintText: "Search Priyotoma, Natok, Waz...", hintStyle: TextStyle(color: Colors.white54), filled: true, fillColor: Color(0xFF222222), border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none), suffixIcon: IconButton(icon: Icon(Icons.search, color: Colors.red), onPressed: ()=> search(ctrl.text))))),
        if(loading) LinearProgressIndicator(color: Colors.red),
        Expanded(child: GridView.builder(padding: EdgeInsets.all(8), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 8, mainAxisSpacing: 8), itemCount: videos.length, itemBuilder: (c,i){
          var v = videos[i];
          return GestureDetector(onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> PlayPage(id: v['videoId'], title: v['title']))), child: Container(decoration: BoxDecoration(color: Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)), child: Column(children: [ClipRRect(borderRadius: BorderRadius.vertical(top: Radius.circular(12)), child: Image.network("https://i.ytimg.com/vi/${v['videoId']}/hqdefault.jpg", height: 120, width: double.infinity, fit: BoxFit.cover)), Padding(padding: EdgeInsets.all(6), child: Text(v['title'], style: TextStyle(color: Colors.white, fontSize: 12), maxLines: 2))])));
        }))
      ]),
    );
  }
}

class PlayPage extends StatelessWidget {
  final String id, title;
  PlayPage({required this.id, required this.title});
  @override
  Widget build(BuildContext context) {
    var ctr = YoutubePlayerController(initialVideoId: id, flags: YoutubePlayerFlags(autoPlay: true));
    return Scaffold(backgroundColor: Colors.black, appBar: AppBar(backgroundColor: Colors.red, title: Text(title, maxLines: 1, style: TextStyle(fontSize: 14))), body: YoutubePlayer(controller: ctr, showVideoProgressIndicator: true));
  }
}
