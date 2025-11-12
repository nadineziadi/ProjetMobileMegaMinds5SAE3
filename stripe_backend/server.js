const express = require('express');
const cors = require('cors');
require('dotenv').config();

const productRoutes = require('./routes/productRoutes');
const paymentRoutes = require('./routes/paymentRoutes');
const emailController = require('./controllers/emailController');

const app = express();
app.use(cors());
app.use(express.json());

app.use('/products', productRoutes);
app.use('/payment', paymentRoutes);

// Email routes
app.post('/email/send-order-confirmation', emailController.sendOrderConfirmation);

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
