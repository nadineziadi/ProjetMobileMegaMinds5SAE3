const products = require('../models/productModel');

exports.getAllProducts = (req, res) => {
  res.json(products);
};
