import 'package:flutter/material.dart';

class ProductCard extends StatefulWidget {
  final String productId;
  final String img;
  final String title;
  final Map<String, String> prices;
  final String category;
  final Function(Map<String, String>) onAddToCart;
  final Function(String productId, String imageUrl, String category) onDelete;
  final Function(
      String productId,
      String currentName,
      double currentPrice,
      String category,
      Map<String, String> prices,
      String selectedInch,
      Function(String, double) onUpdatePrice) onEdit;
  final double currentPrice;

  const ProductCard({
    required this.productId,
    required this.img,
    required this.title,
    required this.prices,
    required this.category,
    required this.onAddToCart,
    required this.onDelete,
    required this.onEdit,
    required this.currentPrice,
    Key? key,
  }) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  String? _selectedInch;
  String _price = "";

  @override
  void initState() {
    super.initState();
    if (widget.prices.isNotEmpty) {
      _selectedInch = widget.prices.keys.first;
      _price = widget.prices[_selectedInch]!;
    }
  }

  @override
  void didUpdateWidget(ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.prices.isNotEmpty) {
      _selectedInch = widget.prices.keys.first;
      _price = widget.prices[_selectedInch]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 40),
      clipBehavior: Clip.antiAlias,
      height: 400,
      width: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[800],
      ),
      child: Column(
        children: [
          Image.network(
            widget.img,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 250,
                height: 200,
                color: Colors.grey,
                child: const Icon(Icons.error),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          ),
          const SizedBox(height: 5),
          Text(
            widget.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '\$$_price',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Material(
            child: DropdownButton<String>(
              isExpanded: true,
              value: widget.prices.containsKey(_selectedInch)
                  ? _selectedInch
                  : null,
              hint: const Text('Select Size'),
              items: widget.prices.keys.map((String val) {
                return DropdownMenuItem<String>(
                  value: val,
                  child: Text('$val"'),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedInch = newValue;
                    _price = widget.prices[newValue]!;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  widget.onEdit(
                    widget.productId,
                    widget.title,
                    double.parse(_price),
                    widget.category,
                    widget.prices,
                    _selectedInch!,
                    (String updatedInch, double updatedPrice) {
                      setState(() {
                        _selectedInch = updatedInch;
                        _price = updatedPrice.toString();
                      });
                    },
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  widget.onDelete(
                    widget.productId,
                    widget.img,
                    widget.category,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
