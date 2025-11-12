const emailService = require('../services/emailService');

/**
 * Send order confirmation email
 * POST /email/send-order-confirmation
 */
exports.sendOrderConfirmation = async (req, res) => {
  try {
    const {
      customerEmail,
      customerName,
      supplementName,
      brand,
      type,
      description,
      quantity,
      price,
      purchaseTime,
      imageUrl,
    } = req.body;

    // Validate required fields
    if (!customerEmail) {
      return res.status(400).json({
        success: false,
        error: 'customerEmail is required',
      });
    }

    if (!supplementName || !price) {
      return res.status(400).json({
        success: false,
        error: 'supplementName and price are required',
      });
    }

    const orderData = {
      customerEmail,
      customerName: customerName || 'Customer',
      supplementName,
      brand: brand || 'N/A',
      type: type || 'N/A',
      description: description || 'N/A',
      quantity: quantity || 1,
      price: parseFloat(price),
      purchaseTime: purchaseTime || new Date().toISOString(),
      imageUrl: imageUrl || '',
    };

    // Send email
    const result = await emailService.sendOrderConfirmationEmail(orderData);

    res.json({
      success: true,
      message: 'Order confirmation email sent successfully',
      messageId: result.messageId,
      recipient: result.recipient,
    });
  } catch (error) {
    // Log error but return success for payment (email is secondary)
    console.error('Error in sendOrderConfirmation:', error);
    res.status(200).json({
      success: false,
      message: 'Payment successful but email failed to send',
      error: error.message,
    });
  }
};

