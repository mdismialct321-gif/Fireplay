import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

void main() => runApp(MaterialApp(home: FirePlay(), debugShowCheckedModeBanner: false));

class FirePlay extends StatefulWidget { @override _FirePlayState createState() => _FirePlayState(); }

class _FirePlayState extends State<FirePlay> {
  TextEditingController ctrl = TextEditingController(text: "Priyotoma");
  List videos = [];
  bool loading = false;

  Future<void> search(String q) async {
    setState(() => loading = true);
    try {
      // Using Invidious API - no key needed
      final url = Uri.parse('https://vid.puffyan.us/api/v1/search?q=$q');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        setState(() {
          videos = data.where((v) => v['type'] == 'video').toList();
          loading = false;
        });
      } else { setState(() => loading = false); }
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  void initState() { super.initState(); search("Priyotoma Bangla Song"); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.redAccent, title: Text("🔥 FirePlay", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), centerTitle: true),
      body: Column(children: [
        Padding(
          padding: EdgeInsets.all(10),
          child: TextField(
            controller: ctrl,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Priyotoma, Hawa...",
              hintStyle: TextStyle(color: Colors.white54),
              filled: true, fillColor: Color(0xFF222222),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              suffixIcon: IconButton(icon: Icon(Icons.search, color: Colors.red), onPressed: ()=> search(ctrl.text))
            ),
            onSubmitted: (v)=> search(v),
          ),
        ),
        if(loading) LinearProgressIndicator(color: Colors.red),
        Expanded(
          child: videos.isEmpty ? Center(child: Text(loading ? "Loading..." : "No video, Search again", style: TextStyle(color: Colors.white))) :
          ListView.builder(
            itemCount: videos.length,
            itemBuilder: (c,i){
              var v = videos[i];
              return ListTile(
                leading: CachedNetworkImage(imageUrl: "https://i.ytimg.com/vi/${v['videoId']}/mqdefault.jpg", width: 100, fit: BoxFit.cover),
                
