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

  static Future<ShFolder> getShObjects(shObjectId) async {
    var shFolders = new List<ShFolder>();
    var shPosts = new List<ShPost>();
    String username = 'admin';
    String password = 'admin';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    print(basicAuth);
    var url = baseUrl + "/object/" + shObjectId + "/list";
    final response = await http
        .get(url, headers: {HttpHeaders.authorizationHeader: basicAuth});
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON.
      var shFolder = new ShFolder();
      Iterable folders = json.decode(response.body)["shFolders"];
      if (folders != null) {
        shFolders = folders.map((model) => ShFolder.fromJson(model)).toList();
      }
      Iterable posts = json.decode(response.body)["shPosts"];
      if (posts != null) {
        shPosts = posts.map((model) => ShPost.fromJson(model)).toList();
      }
      shFolder.shPosts = shPosts;
      shFolder.shFolders = shFolders;
      return shFolder;
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }
}

Future<ShPost> fetchPost() async {
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
    return ShPost.fromJson(json.decode(response.body));
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

class ShPost {
  final String owner;
  final String id;
  final String title;
  final String summary;

  ShPost({this.owner, this.id, this.title, this.summary});

  factory ShPost.fromJson(Map<String, dynamic> json) {
    return ShPost(
      owner: json['owner'],
      id: json['id'],
      title: json['title'],
      summary: json['summary'],
    );
  }
}

class ShFolder {
  List<ShFolder> shFolders = [];
  List<ShPost> shPosts = [];
  final String owner;
  final String id;
  final String name;

  ShFolder({this.owner, this.id, this.name, shFolders, shPosts});

  factory ShFolder.fromJson(Map<String, dynamic> json) {
    return ShFolder(
      owner: json['owner'],
      id: json['id'],
      name: json['name'],
      shFolders: json['shFolders'],
      shPosts: json['shPosts'],
    );
  }
}

class ShObject {
  final String owner;
  final String id;
  final String name;
  final String description;

  ShObject({this.owner, this.id, this.name, this.description});

  factory ShObject.fromJson(Map<String, dynamic> json) {
    return ShObject(
      owner: json['owner'],
      id: json['id'],
      name: json['name'],
      description: json['description'],
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
                return ListView.separated(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    Site site = snapshot.data[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.pages),
                        title: Text(site.name),
                        subtitle: Text(site.description), //
                        trailing: Icon(Icons.keyboard_arrow_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Folders(
                                    shFolder: API.getShObjects(site.id), title: site.name)),
                          );
                        },
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider();
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

class Folders extends StatelessWidget {
  final Future<ShFolder> shFolder;
  final String title;
  Folders({Key key, this.shFolder, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: FutureBuilder<ShFolder>(
          future: shFolder,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.separated(
                itemCount: snapshot.data.shFolders.length +
                    snapshot.data.shPosts.length,
                itemBuilder: (context, index) {
                  if (index < snapshot.data.shFolders.length) {
                    ShFolder shFolder = snapshot.data.shFolders[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.folder),
                        title: Text(shFolder.name),
                        subtitle: Text("Folder"),
                        trailing: Icon(Icons.keyboard_arrow_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Folders(
                                    shFolder: API.getShObjects(shFolder.id), title: shFolder.name)),
                          );
                        },
                      ),
                    );
                  } else {
                    ShPost shPost = snapshot
                        .data.shPosts[index - snapshot.data.shFolders.length];
                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.receipt),
                        title: Text(shPost.title),
                        subtitle:
                            Text(shPost.summary != null ? shPost.summary : ""),
                        trailing: Icon(Icons.keyboard_arrow_right),
                        onTap: () {
                         
                        },
                      ),
                    );
                  }
                },
                separatorBuilder: (context, index) {
                  return Divider();
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
    );
  }
}
