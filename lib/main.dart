import 'package:flutter/material.dart';
void main()=> runApp(MaterialApp(home: FirePlay(), debugShowCheckedModeBanner: false));
class FirePlay extends StatefulWidget{ @override _FirePlayState createState()=> _FirePlayState(); }
class _FirePlayState extends State<FirePlay>{
  List allVideos=[
    {'id':'qXAvZUnMkm4','t':'O Priyotoma - Shakib Khan Full Song 4K'},
    {'id':'6iaJ08pY4ss','t':'Hawa - Sada Sada Kala Kala - Full Song'},
    {'id':'zqGW8TcG_0A','t':'Poran - Cholo Niralay - Bangla Song'},
    {'id':'u3rHdpj3_z0','t':'Rajkumar - Barood - Shakib Khan New'},
    {'id':'9bZkp7q19f0','t':'Bangla Natok 2025 - Apurba & Tisha'},
    {'id':'kJQP7kiw5Fk','t':'Mizanur Rahman Azhari New Waz 2025'},
    {'id':'RgKAFK5djSk','t':'Shakib Khan Best Action Scene'},
    {'id':'J0y6y_rj0lA','t':'Priyotoma Lofi Version - Night Mood'},
    {'id':'CevxZvSJLk8','t':'Bangla Hit Gaan 2025 Mix'},
    {'id':'OPf0YbXqDm0','t':'Bangla New Movie Trailer 2025'},
    {'id':'hT_nvWreIhg','t':'One Love - Shorif Uddin Bangla Song'},
    {'id':'JGwWNGJdvx8','t':'Shape of You Bangla Cover - Ed Sheeran'},
  ];
  List filtered=[];
  TextEditingController c=TextEditingController();
  @override void initState(){super.initState(); filtered=allVideos;}
  void search(String q){setState(()=> filtered=allVideos.where((v)=> v['t']!.toLowerCase().contains(q.toLowerCase())).toList());}
  @override Widget build(BuildContext context){
    return Scaffold(backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.red, title: Text("🔥 FirePlay - ${filtered.length} Videos", style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true),
      body: Column(children:[
        Padding(padding: EdgeInsets.all(10), child: TextField(controller: c, style: TextStyle(color: Colors.white), onChanged: search, decoration: InputDecoration(hintText: "Search Priyotoma, Hawa, Waz...", hintStyle: TextStyle(color: Colors.white54), filled: true, fillColor: Color(0xFF222222), prefixIcon: Icon(Icons.search, color: Colors.white54), border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none)))),
        Expanded(child: GridView.builder(padding: EdgeInsets.all(8), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 8, mainAxisSpacing: 8), itemCount: filtered.length, itemBuilder: (ctx,i){
          var v=filtered[i];
          return Container(decoration: BoxDecoration(color: Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)), child: Column(children:[
            ClipRRect(borderRadius: BorderRadius.vertical(top: Radius.circular(12)), child: Stack(alignment: Alignment.center, children:[Image.network("https://i.ytimg.com/vi/${v['id']}/hqdefault.jpg", height: 120, width: double.infinity, fit: BoxFit.cover), Icon(Icons.play_circle_fill, color: Colors.white, size: 50)])),
            Padding(padding: EdgeInsets.all(8), child: Text(v['t']!, style: TextStyle(color: Colors.white, fontSize: 12), maxLines: 2)),
            Spacer(),
            Padding(padding: EdgeInsets.only(bottom: 6), child: Text("▶️ Tap to Play", style: TextStyle(color: Colors.redAccent, fontSize: 10))),
          ]));
        }))
      ]),
    );
  }
}
