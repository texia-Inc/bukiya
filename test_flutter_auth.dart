#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';

// Simple test to verify the Flutter app can connect to the backend
void main() async {
  const baseUrl = 'http://localhost:8000';
  
  print('Testing connection to backend...');
  
  // Test health endpoint
  try {
    final healthResponse = await HttpClient()
        .getUrl(Uri.parse('$baseUrl/health'))
        .then((request) => request.close());
    
    if (healthResponse.statusCode == 200) {
      print('✓ Backend health check passed');
    } else {
      print('✗ Backend health check failed: ${healthResponse.statusCode}');
      return;
    }
  } catch (e) {
    print('✗ Backend connection failed: $e');
    return;
  }
  
  // Test login endpoint
  try {
    final client = HttpClient();
    final request = await client.postUrl(Uri.parse('$baseUrl/api/v1/auth/login'));
    request.headers.set('Content-Type', 'application/json');
    
    final loginData = {
      'email': 'shoptest@example.com',
      'password': 'shoptest123'
    };
    
    request.write(jsonEncode(loginData));
    final response = await request.close();
    
    if (response.statusCode == 200) {
      print('✓ Login test passed');
      
      final responseBody = await response.transform(utf8.decoder).join();
      final loginResponse = jsonDecode(responseBody);
      
      if (loginResponse['success'] == true && loginResponse['data']['access_token'] != null) {
        final token = loginResponse['data']['access_token'];
        print('✓ Access token received');
        
        // Test player profile endpoint
        final profileRequest = await client.getUrl(Uri.parse('$baseUrl/api/v1/players/me'));
        profileRequest.headers.set('Authorization', 'Bearer $token');
        final profileResponse = await profileRequest.close();
        
        if (profileResponse.statusCode == 200) {
          print('✓ Player profile test passed');
          final profileBody = await profileResponse.transform(utf8.decoder).join();
          final profileData = jsonDecode(profileBody);
          
          if (profileData['success'] == true && profileData['data']['player'] != null) {
            print('✓ Player data structure is correct');
            print('Player: ${profileData['data']['player']['username']}');
            print('Gold: ${profileData['data']['player']['gold']}');
            print('Shop Level: ${profileData['data']['player']['shop_level']}');
          } else {
            print('✗ Invalid player data structure');
          }
        } else {
          print('✗ Player profile test failed: ${profileResponse.statusCode}');
        }
      } else {
        print('✗ Invalid login response structure');
      }
    } else {
      print('✗ Login test failed: ${response.statusCode}');
    }
    
    client.close();
  } catch (e) {
    print('✗ Authentication test failed: $e');
  }
  
  print('\nTest completed. If all tests passed, the backend API is working correctly.');
  print('The issue might be in the Flutter app configuration or network connectivity.');
}