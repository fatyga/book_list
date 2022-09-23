import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map> books = [];

  Future<List> getBooks() async {
    try {
      Response response =
          await get(Uri.parse('https://www.dbooks.org/api/recent'));

      if (response.statusCode == 200) {
        Map data = jsonDecode(response.body);
        return data['books'];
      } else {
        throw 'HTTP request error.';
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  initState() {
    getBooks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Suggested books'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: getBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Text('${snapshot.error} occured',
                    style: TextStyle(fontSize: 18.0)),
              );
            } else if (snapshot.hasData) {
              final data = snapshot.data as List;

              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                      child: Card(
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    Details(data: data[index]),
                              ),
                            );
                          },
                          title: Text(data[index]['title']),
                        ),
                      ));
                },
              );
            }
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

class Details extends StatefulWidget {
  final data;
  Details({Key? key, required this.data}) : super(key: key);

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Book details'),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Image.network(widget.data['image'],
                      width: 250, height: 250)),
              SizedBox(height: 20),
              Text('Title:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 3),
              Text(widget.data['title']),
              SizedBox(height: 15),
              Text('Authors:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 3),
              Text(widget.data['authors']),
              SizedBox(height: 15),
            ],
          ),
        ));
  }
}
