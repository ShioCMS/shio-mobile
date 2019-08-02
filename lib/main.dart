import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const baseUrl = "https://cloud.shiohara.org/api/v2";

class API {
  static Future<List<Site>> getSites() async {
    var sites = new List<Site>();
    String username = 'admin';
    String password = 'admin';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    print(basicAuth);
    var url = baseUrl + "/site";
    final response = await http
        .get(url, headers: {HttpHeaders.authorizationHeader: basicAuth});
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON.
      Iterable list = json.decode(response.body);
      sites = list.map((model) => Site.fromJson(model)).toList();
      return sites;
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }
}

Future<Post> fetchPost() async {
  String username = 'admin';
  String password = 'admin';
  String basicAuth =
      'Basic ' + base64Encode(utf8.encode('$username:$password'));
  print(basicAuth);
  final response = await http.get(
    'https://cloud.shiohara.org/api/v2/post/25ca7d45-4a7d-42cb-93f6-d2f5adca48d4',
    headers: {HttpHeaders.authorizationHeader: basicAuth},
  );
  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON.
    return Post.fromJson(json.decode(response.body));
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}

class Site {
  final String owner;
  final String id;
  final String name;
  final String description;

  Site({this.owner, this.id, this.name, this.description});

  factory Site.fromJson(Map<String, dynamic> json) {
    return Site(
      owner: json['owner'],
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}

class Post {
  final String owner;
  final String id;
  final String title;
  final String summary;

  Post({this.owner, this.id, this.title, this.summary});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      owner: json['owner'],
      id: json['id'],
      title: json['title'],
      summary: json['summary'],
    );
  }
}

void main() => runApp(MyApp(sites: API.getSites()));

class MyApp extends StatelessWidget {
  final Future<List<Site>> sites;

  MyApp({Key key, this.sites}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shiohara CMS',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Shiohara CMS'),
        ),
        body: Center(
          child: FutureBuilder<List<Site>>(
            future: sites,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    Site site = snapshot.data[index];
                    return  ListTile(title: Text(site.name));
                  },
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              // By default, show a loading spinner.
              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
