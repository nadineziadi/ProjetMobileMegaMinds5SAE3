const nodemailer = require('nodemailer');

/**
 * Send order confirmation email using Gmail SMTP
 */
async function sendOrderConfirmationEmail(orderData) {
  const {
    customerEmail,
    customerName = 'Customer',
    supplementName,
    brand,
    type,
    description,
    quantity,
    price,
    purchaseTime,
    imageUrl,
  } = orderData;

  // Validate required fields
  if (!customerEmail) {
    throw new Error('Customer email is required');
  }

  const totalPrice = (price * quantity).toFixed(2);
  const formattedTime = new Date(purchaseTime).toLocaleString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  });

  // Create Gmail transporter
  const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: process.env.GMAIL_USER,
      pass: process.env.GMAIL_APP_PASSWORD,
    },
  });

  // Email HTML content
  const htmlContent = `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <style>
        body { 
          font-family: Arial, sans-serif; 
          line-height: 1.6; 
          color: #333; 
          margin: 0;
          padding: 0;
        }
        .container { 
          max-width: 600px; 
          margin: 0 auto; 
          padding: 20px; 
          background-color: #f9f9f9;
        }
        .header { 
          background-color: #C7F000; 
          padding: 20px; 
          text-align: center; 
          border-radius: 8px 8px 0 0;
        }
        .header h1 {
          margin: 0;
          color: #17191C;
          font-size: 24px;
        }
        .content { 
          padding: 30px; 
          background-color: white;
          border-radius: 0 0 8px 8px;
        }
        .order-details { 
          background-color: #f9f9f9; 
          padding: 20px; 
          margin: 20px 0; 
          border-radius: 5px;
          border-left: 4px solid #C7F000;
        }
        .order-details ul { 
          list-style: none; 
          padding: 0; 
          margin: 0;
        }
        .order-details li { 
          padding: 10px 0; 
          border-bottom: 1px solid #eee; 
        }
        .order-details li:last-child { 
          border-bottom: none; 
        }
        .order-details strong {
          color: #17191C;
          display: inline-block;
          min-width: 120px;
        }
        .product-image { 
          text-align: center; 
          margin: 30px 0; 
        }
        .product-image img { 
          max-width: 200px; 
          height: auto; 
          border-radius: 8px;
          box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .delivery-notice {
          background-color: #C7F000;
          color: #17191C;
          padding: 15px;
          border-radius: 5px;
          margin: 20px 0;
          text-align: center;
          font-weight: bold;
        }
        .footer { 
          text-align: center; 
          padding: 20px; 
          color: #666;
          font-size: 12px;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>Your Gymini Order Confirmation</h1>
        </div>
        <div class="content">
          <p>Hello ${customerName},</p>
          <p>Thank you for your purchase! Here are your order details:</p>
          
          <div class="order-details">
            <ul>
              <li><strong>Supplement Name:</strong> ${supplementName}</li>
              <li><strong>Brand:</strong> ${brand}</li>
              <li><strong>Type:</strong> ${type}</li>
              <li><strong>Description:</strong> ${description}</li>
              <li><strong>Quantity:</strong> ${quantity}</li>
              <li><strong>Price:</strong> $${totalPrice}</li>
              <li><strong>Purchased at:</strong> ${formattedTime}</li>
            </ul>
          </div>

          ${imageUrl ? `
            <div class="product-image">
              <img src="${imageUrl}" alt="${supplementName}" width="200">
            </div>
          ` : ''}

          <div class="delivery-notice">
            Your order will be delivered within 24–48 hours.
          </div>

          <p>Thank you for choosing Gymini!</p>
        </div>
        <div class="footer">
          <p>&copy; ${new Date().getFullYear()} Gymini. All rights reserved.</p>
        </div>
      </div>
    </body>
    </html>
  `;

  // Plain text version
  const textContent = `
Your Gymini Order Confirmation

Hello ${customerName},

Thank you for your purchase! Here are your order details:

- Supplement Name: ${supplementName}
- Brand: ${brand}
- Type: ${type}
- Description: ${description}
- Quantity: ${quantity}
- Price: $${totalPrice}
- Purchased at: ${formattedTime}

Your order will be delivered within 24–48 hours.

Thank you for choosing Gymini!
  `;

  const mailOptions = {
    from: process.env.GMAIL_USER, // Sender email
    to: customerEmail, // Recipient email from checkout
    subject: 'Your Gymini Order Confirmation',
    text: textContent,
    html: htmlContent,
  };

  try {
    const info = await transporter.sendMail(mailOptions);
    console.log('✅ Email sent successfully:', info.messageId);
    return { 
      success: true, 
      messageId: info.messageId,
      recipient: customerEmail 
    };
  } catch (error) {
    console.error('❌ Error sending email:', error);
    throw error;
  }
}

module.exports = {
  sendOrderConfirmationEmail,
};

