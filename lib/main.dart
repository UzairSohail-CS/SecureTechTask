import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() async {
    final response = await http.post(
      Uri.parse('https://fakestoreapi.com/auth/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": _usernameController.text,
        "password": _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProductListPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductListPage extends StatefulWidget {
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<dynamic> productList = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final response =
        await http.get(Uri.parse('https://fakestoreapi.com/products'));
    if (response.statusCode == 200) {
      setState(() {
        productList = jsonDecode(response.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product List')),
      body: ListView.builder(
        itemCount: productList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ProductDetailsPage(product: productList[index])),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 5,
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProductDetailsPage(
                                  product: productList[index])),
                        );
                      },
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(15)),
                            child: Image.network(
                              productList[index]['image'],
                              width: double.infinity,
                              height: 150,
                              // fit: BoxFit.fill,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              color: Colors.black.withOpacity(0.6),
                              padding: EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 8),
                              child: Text(
                                'Rating: ${productList[index]['rating']['rate']}',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Text(
                            productList[index]['title'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(productList[index]['description']),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProductDetailsPage extends StatefulWidget {
  final dynamic product;

  ProductDetailsPage({required this.product});

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  bool isCardExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product Details')),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: Image.network(widget.product['image']),
                        );
                      },
                    );
                  },
                  child: Image.network(widget.product['image'],
                      height: 300, width: double.infinity, fit: BoxFit.cover),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius:
                    BorderRadius.only(bottomLeft: Radius.circular(20)),
              ),
              child: Text(
                widget.product['title'],
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: isCardExpanded
                  ? MediaQuery.of(context).size.height * 0.6
                  : 120,
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey, offset: Offset(0, -2), blurRadius: 5)
                ],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isCardExpanded = !isCardExpanded;
                      });
                    },
                    child: Icon(
                      isCardExpanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_up,
                      size: 36,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${widget.product['price']}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24)),
                      ElevatedButton(
                        onPressed: () {
                          // Handle purchase button tap
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.purple,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('Purchase',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  if (isCardExpanded) ...[
                    SizedBox(height: 16),
                    Text(widget.product['description'],
                        style: TextStyle(fontSize: 16)),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.yellow),
                        SizedBox(width: 4),
                        Text(
                            '${widget.product['rating']['rate']} (${widget.product['rating']['count']} reviews)'),
                      ],
                    ),
                    SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 1; i <= 5; i++)
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.yellow),
                              SizedBox(width: 4),
                              Text('$i stars'),
                            ],
                          ),
                        SizedBox(height: 16),
                        for (int i = 0; i < 3; i++)
                          ListTile(
                            title: Text('Random Comment ${i + 1}'),
                            subtitle: Text('This is a random comment.'),
                          ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
