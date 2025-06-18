const functions = require("firebase-functions");
const admin = require("firebase-admin");
const stripe = require("stripe")("sk_test_51RbIzfD0rT16v2dTy8Cu4uJToZufA3dBNFtCUGJ5O9it5BOQPu1ZiRcy5dN7qY17YmVrUC3Tcnd7WHpFZFhtH3J100tiuqfc9G");

admin.initializeApp();

exports.createPaymentIntent = functions.https.onRequest(async (req, res) => {
  const { amount, currency } = req.body;

  if (!amount || !currency) {
    return res.status(400).send("Faltan datos");
  }

  try {
    const paymentIntent = await stripe.paymentIntents.create({
      amount,
      currency,
    });

    return res.status(200).send({
      clientSecret: paymentIntent.client_secret,
    });
  } catch (error) {
    console.error("Stripe error:", error);
    return res.status(500).send("Error al crear el PaymentIntent");
  }
});
