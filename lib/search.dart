import 'package:flutter/material.dart';
import 'main.dart';
import 'option.dart';
import 'drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database_helper.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'stockdata.dart';
import 'dart:convert';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AutoComplete extends StatefulWidget {
  AutoComplete() : super();

  final String title = "AutoComplete Demo";

  @override
  _AutoCompleteState createState() => _AutoCompleteState();
}

class _AutoCompleteState extends State<AutoComplete> {
  String _searchText = "";
  final myController = TextEditingController();
  // bool loadingInfo = true;
  // bool loadingQuote = true;
  // bool loadingNews = true;

  final dbHelper = DatabaseHelper.instance;
  String name = "";

  List<Option> _getSuggestions(String query) {
    List<Option> matches = [];
    if (query == "") {
      matches = [];
      return matches;
    }
    for (Option opt in options) {
      if (opt.name != null) matches.add(opt);
    }
    // matches.addAll(options);
    matches
        .retainWhere((s) => s.name.toLowerCase().contains(query.toLowerCase()));
    return matches;
  }

  @override
  void initState() {
    super.initState();
    myController.addListener(() {
      setState(() {
        _searchText = myController.text;
      });
    });
    // print('loadingFinal from search page');
    // print(loadingFinal);
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  Widget row(Option option) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          option.name.substring(
              0, (option.name.length > 15) ? 15 : option.name.length),
          style: TextStyle(fontSize: 16.0),
        ),
        SizedBox(
          width: 10.0,
        ),
        Text(
          option.symbol,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: Color.fromRGBO(54, 54, 64,
                  1.0), //This will change the drawer background to blue.
              //other styles
            ),
            child: CallDrawer()),
        backgroundColor: Color.fromRGBO(54, 54, 64, 1.0),
        appBar: AppBar(
          // automaticallyImplyLeading: false,
          title: Text("Financigram",
              style: GoogleFonts.lato(
                  color: Color.fromRGBO(54, 54, 64, 1.0),
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600)),
          iconTheme: IconThemeData(color: Color.fromRGBO(54, 54, 64, 1.0)),
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
            child: Column(
          children: <Widget>[
            (false)
                ? Dialog(
                    backgroundColor: Color.fromRGBO(54, 54, 64, 1.0),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                          Text(
                            "\t\t\t\t\tLoading",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  )
                : Form(
                    child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      children: <Widget>[
                        TypeAheadField(
                          noItemsFoundBuilder: (value) {
                            return Container(
                                decoration: new BoxDecoration(
                                  color: Color.fromRGBO(54, 54, 64, 1.0),
                                ),
                                child: ListTile(
                                  title: Text(
                                    'No Matches Found',
                                    style: GoogleFonts.lato(
                                        color: Colors.white,
                                        fontSize: 18.5,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    'Make sure you have entered a valid company name or check your connection and reload the app',
                                    style: GoogleFonts.lato(
                                        color: Colors.white,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ));
                          },
                          textFieldConfiguration: TextFieldConfiguration(
                              controller: myController,
                              autocorrect: true,
                              maxLines: 3,
                              minLines: 1,
                              autofocus: false,
                              style: DefaultTextStyle.of(context)
                                  .style
                                  .copyWith(
                                      fontStyle: FontStyle.normal,
                                      color: Colors.white,
                                      fontSize: 18.5,
                                      fontWeight: FontWeight.w200,
                                      decoration: TextDecoration.none,
                                      decorationStyle:
                                          TextDecorationStyle.dotted),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Enter company here',
                                suffixIcon: _searchText.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.clear,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            myController.clear();
                                          });
                                        },
                                      )
                                    : null,
                                hintStyle: GoogleFonts.lato(
                                    fontSize: 18.5, color: Colors.white),
                              )),
                          suggestionsCallback: (pattern) async {
                            return _getSuggestions(pattern);
                          },
                          itemBuilder: (context, suggestion) {
                            return Container(
                                decoration: new BoxDecoration(
                                  color: Color.fromRGBO(54, 54, 64, 1.0),
                                ),
                                child: ListTile(
                                  title: Text(
                                    '${suggestion.name}',
                                    style: GoogleFonts.lato(
                                        color: Colors.white,
                                        fontSize: 18.5,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    '${suggestion.exchangeShortName}: ${suggestion.symbol}',
                                    style: GoogleFonts.lato(
                                        color: Colors.white,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ));
                          },
                          onSuggestionSelected: (suggestion) {
                            stockquote = null;
                            stockinfo = null;
                            stocknews = null;
                            myController.text = suggestion.name;
                            _loadquote(suggestion.symbol);
                            _loadnews(suggestion.symbol);
                            _loadinfo(suggestion.symbol);
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return SpinKitWave(
                                    color: Colors.white, size: 25.0);
                              },
                            );
                            new Future.delayed(new Duration(seconds: 5), () {
                              myController.text = "";
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          Stockdata()));
                            });
                          },
                        )
                      ],
                    ),
                  )),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
              child: Container(
                child: Text(
                  "Search for latest quotes and news of stocks listed on NYSE and NASDAQ",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 21.0),
                ),
              ),
            ),
            ElevatedButton(
              // color:Colors.green;
              child: Text(
                'query',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () {
                _query();
              },
            ),
            ElevatedButton(
              // color:Colors.green;
              child: Text(
                'queryStock',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () {
                _queryStock();
              },
            ),
            ElevatedButton(
              child: Text(
                'delete',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () {
                _delete('AAN');
              },
            ),
          ],
        )));
  }

  void _delete(String name) async {
    // Assuming that the number of rows is the id for the last row.
    final rowsDeleted = await dbHelper.delete(name);
    print('deleted $rowsDeleted row(s): row $name');
  }

  void _query() async {
    final allRows = await dbHelper.queryAllRows();
    print('query all rows:');
    allRows.forEach((row) => print(row));
  }

  void _queryStock() async {
    final allRows = await dbHelper.queryAllRowsStock();
    print('query all rows stock:');
    allRows.forEach((row) => print(row));
  }

  void _loadquote(stockname) {
    http
        .get("https://fmpcloud.io/api/v3/quote/" + stockname + '?' + apikey)
        .then((result) {
      stockquote = json.decode(result.body);
      // setState(() {
      //   loadingQuote = false;
      // });
      // print(stockquote);
    });
  }

  void _loadnews(stockname) {
    http
        .get("https://fmpcloud.io/api/v3/stock_news?tickers=" +
            stockname +
            "&limit=5&" +
            apikey)
        .then((result) {
      // setState(() {
      //   loadingNews = false;
      // });
      stocknews = json.decode(result.body);
      // print(stocknews);
    });
  }

  void _loadinfo(stockname) {
    http
        .get("https://fmpcloud.io/api/v3/profile/" + stockname + "?" + apikey)
        .then((result) {
      stockinfo = json.decode(result.body);
      // (stockinfo[0]['website'] == "") ? print('yes') : print('no');
      // setState(() {
      //   loadingNews = false;
      // });
    });
  }
}
