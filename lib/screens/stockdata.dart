import 'package:flutter/material.dart';
import '../main.dart';
import '../helper/global.dart' as global;
import 'package:url_launcher/url_launcher.dart';
import '../widgets/news.dart';
import '../widgets/drawer.dart';
import '../widgets/quote.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../helper/add.dart';
import '../database_helper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';

var months = [
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "June",
  "July",
  "Aug",
  "Sept",
  "Oct",
  "Nov",
  "Dec"
];
double icondiff;
bool icondisplay = true;
bool loadImage = false;
bool checkExist, showchkbox;

String txt = '';
Future<void> findConfig() async {
  int a = await dbHelper.getOneData(stockquote[0]['symbol']);
  // print('value of a = $a');
  //initial value of checkExist is set to 0
  checkExist = (a == 0) ? false : true;
  // print('value of check = $checkExist');
  showchkbox = false;
}

class Stockdata extends StatefulWidget {
  @override
  _StockdataState createState() => _StockdataState();
}

class _StockdataState extends State<Stockdata> {
  final _costtextfield = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String tmpcount = "", tmpcost = "";
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          endDrawer: Container(
            width: (MediaQuery.of(context).size.width / 100) * 80,
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: (MediaQuery.of(context).size.width / 100) * 75,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white, Colors.white],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: (MediaQuery.of(context).size.height / 100) * 10,
                  bottom: 0,
                  child: Container(
                    child: showchkbox
                        ? Center(
                            child: Container(
                            padding: EdgeInsets.fromLTRB(0, 60.0, 0, 0),
                            child: SpinKitWave(
                                color: Color.fromRGBO(54, 54, 64, 1.0),
                                size: 25.0),
                          ))
                        : Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  child: Padding(
                                    padding: const EdgeInsets.all(18),
                                    child: ListTile(
                                      title: Text(
                                        'Add to WatchList',
                                        textScaleFactor: 1.3,
                                        style: GoogleFonts.lato(
                                          color:
                                              Color.fromRGBO(54, 54, 64, 1.0),
                                        ),
                                      ),
                                      trailing: Checkbox(
                                          checkColor: Colors.white,
                                          activeColor:
                                              Color.fromRGBO(54, 54, 64, 1.0),
                                          value: checkExist,
                                          onChanged: (newValue) {
                                            Fluttertoast.showToast(
                                                msg: (checkExist == false)
                                                    ? stockinfo[0]['symbol'] +
                                                        " added to watchlist"
                                                    : stockinfo[0]['symbol'] +
                                                        " removed from watchlist",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor: Color.fromRGBO(
                                                    54, 54, 64, 1.0),
                                                textColor: Colors.white,
                                                fontSize: 16.0);
                                            setState(() {
                                              checkExist = newValue;
                                            });
                                            if (checkExist) {
                                              _insert(stockquote[0]['symbol']);
                                            } else {
                                              _delete(stockquote[0]['symbol']);
                                            }
                                          }),
                                      selected: true,
                                      onTap: () {},
                                    ),
                                  ),
                                ),
                              ),
                              TextButton(
                                child: Text("Add to portfolio",
                                    style: GoogleFonts.lato(
                                        color: Colors.white, fontSize: 17)),
                                style: ButtonStyle(
                                    padding: MaterialStateProperty.all<EdgeInsets>(
                                        EdgeInsets.fromLTRB(25, 15, 25, 15)),
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Color.fromRGBO(54, 54, 64, 1.0)),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Color.fromRGBO(54, 54, 64, 1.0)),
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(25.0),
                                            side: BorderSide(color: Color.fromRGBO(54, 54, 64, 1.0))))),
                                onPressed: () async {
                                  await _asyncInputDialog(context);
                                },
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: Color.fromRGBO(54, 54, 64, 1.0),
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: Color.fromRGBO(54, 54, 64, 1.0)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              stockquote[0]['exchange'] + ": " + stockquote[0]['symbol'],
              style: GoogleFonts.lato(
                  color: Color.fromRGBO(54, 54, 64, 1.0),
                  fontWeight: FontWeight.w600),
            ),
            iconTheme: IconThemeData(color: Color.fromRGBO(54, 54, 64, 1.0)),
            bottom: TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Color.fromRGBO(54, 54, 64, 1.0),
              indicatorSize: TabBarIndicatorSize.label,
              indicator: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                  color: Color.fromRGBO(54, 54, 64, 1.0)),
              tabs: [
                Tab(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text("Stats"),
                  ),
                ),
                Tab(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text("News"),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.white,
          ),
          body: TabBarView(
            children: [
              QuoteScreen(),
              NewsScreen(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    showchkbox = true;
    super.initState();
    findConfig();
    Future.delayed(const Duration(milliseconds: 2000), () {
      setState(() {
        showchkbox = false;
      });
    });
    setState(() {
      if (stockquote != null) {
        global.arrow = (stockquote[0]['change'] >= 0.0)
            ? "assets/green_up.png"
            : "assets/red_down.png";
      }
      _costtextfield.text = stockquote[0]['price'].toString();
      tmpcost = stockquote[0]['price'].toString();
    });
  }

  @override
  void dispose() {
    // other dispose methods
    _costtextfield.dispose();
    super.dispose();
  }

  void _insert(String name) async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnName: name,
      DatabaseHelper.columnAge: 1
    };
    final id = await dbHelper.insert(row);
  }

  void _insertStock(int count, num cost) async {
    Map<String, dynamic> row = {
      DatabaseHelper.stockName: stockquote[0]['symbol'],
      DatabaseHelper.stockCount: count,
      DatabaseHelper.stockCost: cost
    };
    final result = await dbHelper.queryFindStock(stockquote[0]['symbol']);
    if (result.length == 0) {
      final id = await dbHelper.insertStock(row);
    } else {
      final count = await dbHelper.updateStock(row);
    }
  }

  void _delete(String name) async {
    final rowsDeleted = await dbHelper.delete(name);
  }

  void _deleteStock() async {
    final id = await dbHelper.queryRowCountStock();
    final rowsDeleted = await dbHelper.deleteStockId(id);
  }

  Future _asyncInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Form(
            key: _formKey,
            child: AlertDialog(
              title: Text('Enter info'),
              content: new Row(
                children: [
                  new Expanded(
                      child: new TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: new InputDecoration(labelText: 'No. of shares'),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          double.parse(value) <= 0) {
                        return 'Enter valid no. of shares';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      tmpcount = value;
                    },
                  )),
                  Container(
                    child: Text('\t\t'),
                  ),
                  new Expanded(
                      child: new TextFormField(
                    controller: _costtextfield,
                    keyboardType: TextInputType.number,
                    decoration:
                        new InputDecoration(labelText: 'Price(' + r'$' + ')'),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          double.parse(value) <= 0) {
                        return 'Enter cost';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      tmpcost = value;
                    },
                  ))
                ],
              ),
              actions: [
                FlatButton(
                  child: Text('Add'),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      count = int.parse(tmpcount);
                      cost = num.parse(tmpcost);
                      _insertStock(count, cost);
                      Navigator.of(context).pop();
                      Fluttertoast.showToast(
                          msg: stockinfo[0]['symbol'] + " added to portfolio",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Color.fromRGBO(54, 54, 64, 1.0),
                          textColor: Colors.white,
                          fontSize: 16.0);
                    }
                  },
                ),
              ],
            ));
      },
    );
  }
}

launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
