import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FirePlay',
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xFF121212)),
      home: const SplashScreen(),
    );
  }
}

// 1. নতুন SPLASH SCREEN WITH FIRE ANIMATION
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    // 3 সেকেন্ড পর HomePage এ যাবে
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
    });
  }
  @override void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // আগুনের আইকন এনিমেশন
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.9, end: 1.1),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Transform.scale(scale: value, child: child);
                  },
                  onEnd: () {},
                  child: Container(
                    width: 130, height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(colors: [Color(0xFFFF5722), Color(0xFFD32F2F), Colors.black]),
                      boxShadow: [BoxShadow(color: Colors.redAccent.withOpacity(0.6), blurRadius: 40, spreadRadius: 10)],
                    ),
                    child: const Icon(Icons.local_fire_department, size: 80, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 30),
                const Text("FirePlay", style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 2)),
                const Text("I Love Movies", style: TextStyle(color: Colors.white70, fontSize: 16, letterSpacing: 4)),
                const SizedBox(height: 50),
                const CircularProgressIndicator(color: Colors.redAccent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 2. বাকি সব আগের মতোই
class ApiService {
  final String apiKey = 'a8d1127acd0f8cbc708c6a0e220869c1';
  Future<List> searchMovies(String q) async {
    final url = Uri.parse('https://api.themoviedb.org/3/search/movie?api_key=$apiKey&query=$q&include_adult=false&language=en-US');
    final res = await http.get(url);
    if (res.statusCode == 200) return jsonDecode(res.body)['results'];
    return [];
  }
  Future<Map> getDetails(int id) async {
    final url = Uri.parse('https://api.themoviedb.org/3/movie/$id?api_key=$apiKey&append_to_response=videos,watch/providers&language=en-US');
    final res = await http.get(url);
    return jsonDecode(res.body);
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  ApiService api = ApiService();
  List movies = [];
  bool loading = false;
  TextEditingController ctrl = TextEditingController(text: "Aynabaji");
  void doSearch() async {
    setState(() => loading = true);
    var r = await api.searchMovies(ctrl.text);
    setState(() { movies = r; loading = false; });
  }
  @override void initState() { super.initState(); doSearch(); }
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🔥 FirePlay"), centerTitle: true, backgroundColor: Colors.redAccent),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(12), child: TextField(controller: ctrl, style: const TextStyle(color: Colors.white), onSubmitted: (v)=>doSearch(), decoration: InputDecoration(hintText: "Priyotoma, Hawa...", hintStyle: const TextStyle(color: Colors.white54), filled: true, fillColor: Colors.white10, suffixIcon: IconButton(icon: const Icon(Icons.search, color: Colors.red), onPressed: doSearch), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))))),
        if(loading) const LinearProgressIndicator(color: Colors.red),
        Expanded(child: ListView.builder(itemCount: movies.length, itemBuilder: (c,i){
          var m = movies[i];
          return Card(color: Colors.white10, margin: const EdgeInsets.symmetric(horizontal:12, vertical:6), child: ListTile(leading: m['poster_path']!=null? CachedNetworkImage(imageUrl: "https://image.tmdb.org/t/p/w92${m['poster_path']}", width: 50, fit: BoxFit.cover) : const Icon(Icons.movie, color: Colors.white), title: Text(m['title']??"", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), subtitle: Text("${m['release_date']??''} ⭐ ${m['vote_average']}", style: const TextStyle(color: Colors.white70)), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailsPage(movieId: m['id']))),));
        })),
      ]),
    );
  }
}

class DetailsPage extends StatefulWidget {
  final int movieId;
  const DetailsPage({super.key, required this.movieId});
  @override State<DetailsPage> createState() => _DetailsPageState();
}
class _DetailsPageState extends State<DetailsPage> {
  ApiService api = ApiService();
  Map? data;
  @override void initState(){ super.initState(); load(); }
  void load() async { var d = await api.getDetails(widget.movieId); setState(()=>data=d); }
  @override Widget build(BuildContext context) {
    if(data==null) return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator(color: Colors.red)));
    String? trailerKey;
    try{ var videos = data!['videos']['results'] as List; var t = videos.firstWhere((v)=>v['type']=='Trailer', orElse: ()=> videos.isNotEmpty? videos[0] : null); if(t!=null) trailerKey = t['key']; }catch(e){}
    var providers = [];
    try{ var all = data!['watch/providers']['results']; providers = all['BD']?['flatrate']?? all['IN']?['flatrate']?? all['US']?['flatrate']?? []; }catch(e){}
    return Scaffold(backgroundColor: Colors.black, appBar: AppBar(backgroundColor: Colors.transparent, title: Text(data!['title'])), body: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if(data!['backdrop_path']!=null) CachedNetworkImage(imageUrl: "https://image.tmdb.org/t/p/w500${data!['backdrop_path']}", width: double.infinity, height: 220, fit: BoxFit.cover),
      Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(data!['title'], style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height:8),
        Text(data!['overview']??"No description", style: const TextStyle(color: Colors.white70)), const SizedBox(height:20),
        const Text("কোথায় দেখা যাবে?", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height:10),
        if(providers.isEmpty) Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)), child: const Text("এই মুহূর্তে লিগ্যাল OTT লিস্ট পাওয়া যায়নি। Chorki / Bongo / Hoichoi তে সার্চ করুন।", style: TextStyle(color: Colors.yellowAccent))),
        Wrap(spacing: 10, children: providers.map<Widget>((p)=>Chip(avatar: CachedNetworkImage(imageUrl: "https://image.tmdb.org/t/p/w45${p['logo_path']}", width: 25), label: Text(p['provider_name'], style: const TextStyle(color: Colors.white)), backgroundColor: Colors.white24,)).toList()),
        const SizedBox(height:20),
        if(trailerKey!=null) ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size(double.infinity, 50)), onPressed: (){ Navigator.push(context, MaterialPageRoute(builder: (_) => TrailerPage(keyId: trailerKey!))); }, icon: const Icon(Icons.play_arrow), label: const Text("ট্রেলার দেখুন")),
      ])),
    ])));
  }
}
class TrailerPage extends StatelessWidget {
  final String keyId;
  const TrailerPage({super.key, required this.keyId});
  @override Widget build(BuildContext context) {
    var controller = YoutubePlayerController(initialVideoId: keyId, flags: const YoutubePlayerFlags(autoPlay: true));
    return Scaffold(backgroundColor: Colors.black, appBar: AppBar(backgroundColor: Colors.black), body: YoutubePlayer(controller: controller));
  }
}
