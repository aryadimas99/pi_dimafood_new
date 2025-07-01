const functions = require("firebase-functions");
const midtransClient = require("midtrans-client");
require("dotenv").config(); // Untuk baca file .env
const cors = require("cors")({ origin: true });

const snap = new midtransClient.Snap({
  isProduction: false,
  serverKey: process.env.MIDTRANS_SERVER_KEY,
  clientKey: process.env.MIDTRANS_CLIENT_KEY,
});

// Fungsi Firebase: createTransaction
exports.createTransaction = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      const { orderId, grossAmount, fullName, email, phone } = req.body;

      const parameter = {
        transaction_details: {
          order_id: orderId,
          gross_amount: grossAmount,
        },
        customer_details: {
          first_name: fullName,
          email: email,
          phone: phone,
        },
      };

      const transaction = await snap.createTransaction(parameter);
      res.status(200).send({
        snapToken: transaction.token,
      });
    } catch (error) {
      console.error("Midtrans error:", error);
      res.status(500).send("Failed to create transaction.");
    }
  });
});
