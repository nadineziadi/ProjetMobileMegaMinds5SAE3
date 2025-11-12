const Stripe = require('stripe');
const stripe = Stripe(process.env.STRIPE_SECRET_KEY);

exports.createPaymentIntent = async (req, res) => {
  const { amount, currency = 'usd', description = '', quantity = 1 } = req.body;
  
  try {
    // Calculate total amount (amount per item * quantity)
    const totalAmount = amount * quantity;
    
    const paymentIntent = await stripe.paymentIntents.create({
      amount: totalAmount,
      currency: currency,
      payment_method_types: ['card'],
      description: description || undefined,
      metadata: {
        quantity: quantity.toString(),
        unit_amount: amount.toString(),
      },
    });
    
    res.json({ clientSecret: paymentIntent.client_secret });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
