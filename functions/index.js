/**
 * Import function triggers from their respective submodules:
 */
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const Stripe = require("stripe");
const cors = require("cors")({origin: true});

// Initialize Firebase Admin SDK
admin.initializeApp();
/* eslint-disable new-cap */
const SecretKey = "sk_test_51QfdfKJeXUs6PxpaISskjjdKw6BpeytIi82KMvnQ2SMNZNNgdWk9A0OKJ6w0UogzbxoCfWA0eMXGXSOqnJ22suMf00vZ7XNhiy";
/* eslint-enable new-cap */


// Initialize Stripe with your secret key
const stripe = Stripe(SecretKey); // Replace with your actual Stripe Secret Key

// Create a payment intent function
exports.createPaymentIntent = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    if (req.method !== "POST") {
      // Enforce POST request
      return res.status(405).send({error: "Only POST requests are allowed"});
    }

    try {
      const {amount, currency} = req.body;

      if (!amount || !currency) {
        // Validate input
        return res.status(400).send({error: "Missing required fields: amount or currency"});
      }

      // Create a payment intent in Stripe
      const paymentIntent = await stripe.paymentIntents.create({
        amount: Math.round(amount * 100), // Convert amount to cents
        currency: currency,
        payment_method_types: ["card"],
      });

      // Send the client secret to the frontend
      res.status(200).send({
        clientSecret: paymentIntent.client_secret,
      });
    } catch (error) {
      console.error("Error creating payment intent:", error);
      res.status(500).send({error: error.message});
    }
  });
});
