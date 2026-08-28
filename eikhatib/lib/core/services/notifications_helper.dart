import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

class NotificationService {
  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "eikhatib",
      "private_key_id": "781e60168a26a31fa4fb0c22a5f65ef18785221e",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQC0LQFntgTJUXEx\nR+XPImOggdPs3ps980hnjvMHA/3KNPxQOekpxfiokEPkZFPJTUcuw3rrihcoSbXK\nv3b0Ujd4zPTypYcwdC250Cia21B0Xk14tjPElUYBYlqQklxxibFoeG6/jSMFRMI+\nBmoQdSgZC/+xUp/U4vJEGqQRBjvaEkKl+x3Jytr1sCIqiAYEyTAAO4UanH/j6VOs\nRomt/IWVu19B0ah/S5jWyClq2Q4TeZhAbXDaqAXzAUU10bEX95wfydDSDfSWkMCB\niSH5z7y125YC7Ectx3MYiFitjVZ6qVfApiPKSKIIrPXJgEI4fjTMzPJ5cPXI7uT/\nGb2NbFgjAgMBAAECggEAAYqxDGLxjFd23hkWmlZZy+UDtaJiA0tMDB011ZJVkmyW\ncolMUxMvZ+6nTHkFtOwR9xB59ZhrTxwlj7D7vGauGtaGJUPNWFjMjpGwoNw0YAqL\nVyqxkekR5Ekj+HPukcbzDnwy8AJHkaMsL/B8gw+KYrLh/HGpWt6ZfB1OPucMWnbx\n1+5Ff+1Q8nI5OLERFUk4PW6G1CasIUv6ip3FPEv/dHNwocD2Yf/mjWo/7MTAZ85j\nZv6Ese+Fm77URgmUt/NpJorxCBea58+HxGpUU2R7Wasb/mQlemkmPz1/2YAgFEN5\nGUbNb1yry3R1U2t78xT9zx3usxqgJsmI/zvMhfhHwQKBgQDtBTITluR/MbqWAanz\nW+/BdfKk8wYLYsvrFS0F4Xolqf18Uvp/4pceIFVfeAxIGz9HkDt9XzytYbWP+rI+\ntwt2CgCSQb3IQHLqfM6hCgnB6FmyUs7/lPhrmHkSvaUGfUaRTujc/6a0qPWDoVKl\ntHAPNHu+QSU+7Yj8ooTTwhiiGwKBgQDCmoZJeBi4ogJ7ICdllHFivT6IBDWM/IAV\nmj53iMA0n45IRtq/i5gbhvju6nT00yngrGWVyRs2NW7B+3aQuIJ4dQ8wwyZEtK9g\nFgfzjSr7SC9T2PO1FTxJbBb+FeYhbszKHoVChEjXCiVgru39lMot8ehLe/tYuQfJ\nVaUXu0HCmQKBgQCYh5JtVtqfHCKGLHXxPYXySvQmwJpwM1klZNA/i5XurRGKs1+v\ncuNrKMWoFXpZ4Ob9J82Q5fwHW+zaxit0/pjqko9Bj/sQ5qDNVBopOmuDFQK8Jlw9\nz+F6ZHnt3ItZvL7v/gcPSZo/gsfUuLmWF6NRtaW4jvXoJDbW1cOC/tKZZwKBgQCa\nYiyWrIgwMZb2RxP6KkGpq6ioD27MYqTafnuAKSUSmmIuRMfVndEWRYXHRIl0kPFw\nJFSS9/B2mP09N1lghoA7P+LFNIxvhUh8Wf4E4cFviFzDkCIHTsl9FhtHh+gCLfyZ\nfI0LsBZ5QrtUcHKt8hRTTs6S09EbGe9rcl5+7TfGQQKBgQDoiLGcDGxZGLwDm0jh\nEfVP3eS9g5q9KV9C1B04XbW/1fh3M0qImJwWb3C+RLYsquB0ptpjF9cabKPJMiSx\n5tESEu+jRJh2spE8n3c9i20o2OBkLs44Cbo6aiAVhN6D3opMYVUkdwDEyI4Vh8HF\nXodr96VMv+IitiOX3w3gfkXp6Q==\n-----END PRIVATE KEY-----\n",
      "client_email": "notification-eikhatib@eikhatib.iam.gserviceaccount.com",
      "client_id": "111827922566228670671",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/notification-eikhatib%40eikhatib.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com",
    };
    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging",
    ];
    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );
    auth.AccessCredentials credentials = await auth
        .obtainAccessCredentialsViaServiceAccount(
          auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
          scopes,
          client,
        );
    client.close();
    return credentials.accessToken.data;
  }

  static Future<void> sendNotification(
    String deviceToken,
    String title,
    String body,
  ) async {
    final String accessToken = await getAccessToken();
    String endpointFCM =
        'https://fcm.googleapis.com/v1/projects/servicesapp2024/messages:send';
    final Map<String, dynamic> message = {
      "message": {
        "token": deviceToken,
        "notification": {"title": title, "body": body},
        "data": {"route": "serviceScreen"},
      },
    };

    final http.Response response = await http.post(
      Uri.parse(endpointFCM),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      debugPrint('Notification sent successfully');
    } else {
      debugPrint('Failed to send notification');
    }
  }
}
