import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:web_application/constants/colors.dart';
import 'package:web_application/constants/keys.dart';
import 'package:web_application/constants/links.dart';
import 'dart:js' as js;
import 'textfield.dart';
import 'package:http/http.dart' as http;

class Contactus extends StatefulWidget {
  const Contactus({super.key});

  @override
  State<Contactus> createState() => _ContactusState();
}

class _ContactusState extends State<Contactus> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  // Method to store data in Firestore
  Future<void> submitContactForm() async {
    if (formKey.currentState!.validate()) {
      try {
        // Add the contact information to Firestore
        await FirebaseFirestore.instance.collection('contacts').add({
          'subject': subjectController.text.trim(),
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'message': messageController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message sent successfully!'),
            // backgroundColor: Colors.green,
          ),
        );
        _sendEmail(messageController.text.trim(), nameController.text.trim(),
            emailController.text.trim(), subjectController.text.trim());

        // Clear the form fields
        nameController.clear();
        emailController.clear();
        messageController.clear();
        subjectController.clear();
      } catch (e) {
        // Show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  final serviceId = ServiceId;
  final templateId = TemplateId;
  final userId = UserId;

  Future<void> _sendEmail(
      String message, String name, String email, String subject) async {
    final url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "service_id": serviceId,
          "template_id": templateId,
          "user_id": userId,
          "template_params": {
            "user_name": name,
            "user_email": email,
            "user_message": message,
            "user_subject": subject,
          }
        }),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email Sent!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(' Failed to Send Email: '),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error: "),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // New Contact Information Section
          Container(
            padding: const EdgeInsets.fromLTRB(25, 20, 25, 60),
            color: CustomColor.bgdark2,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Contact Information",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.blueAccent),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "123 Beauty Lane, Glamour City, BC 56789",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Icon(Icons.phone, color: Colors.green),
                      SizedBox(width: 10),
                      Text(
                        "+1 (234) 567-8901",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Icon(Icons.email, color: Colors.red),
                      SizedBox(width: 10),
                      Text(
                        "contact@beautyhaven.com",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          // Existing Get in Touch Container
          Container(
            padding: const EdgeInsets.fromLTRB(25, 20, 25, 60),
            color: CustomColor.bgdark2,
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  const Text(
                    "Get in Touch",
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: CustomTextField(
                      controller: subjectController,
                      hintText: "Subject",
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter the subject'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Row(
                      children: [
                        Flexible(
                          child: CustomTextField(
                            controller: nameController,
                            hintText: "Your Name",
                            validator: (value) => value == null || value.isEmpty
                                ? 'Enter your name'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Flexible(
                          child: CustomTextField(
                            controller: emailController,
                            hintText: "Your Email",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter your email';
                              }
                              final emailRegex = RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                              if (!emailRegex.hasMatch(value)) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: CustomTextField(
                      controller: messageController,
                      hintText: "Your Message",
                      maxline: 10,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter your message'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: SizedBox(
                      width: 250,
                      child: ElevatedButton(
                        onPressed: submitContactForm,
                        child: const Text("Get in Touch"),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: const Divider(),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          js.context.callMethod('open', [IconLinks.facebook]);
                        },
                        child: Image.asset("assets/Socials/facebook.png"),
                      ),
                      InkWell(
                        onTap: () {
                          js.context.callMethod('open', [IconLinks.instagram]);
                        },
                        child: Image.asset("assets/Socials/instagram.png"),
                      ),
                      InkWell(
                        onTap: () {
                          js.context.callMethod('open', [IconLinks.whatsapp]);
                        },
                        child: Image.asset("assets/Socials/whatsapp.png"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
