#!/usr/bin/env node

const BASE_URL = 'http://localhost:8000/api/v1';

async function testShopPurchase() {
  console.log('🛒 Testing Shop Purchase Functionality...\n');

  // Step 1: ゲストログインして認証トークンを取得
  console.log('1. Setting up guest authentication...');
  const deviceId = `test_shop_${Date.now()}`;
  let accessToken;

  try {
    const response = await fetch(`${BASE_URL}/auth/guest-login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        device_id: deviceId,
        device_info: { platform: 'test', model: 'test' }
      })
    });
    const data = await response.json();
    
    if (data.success) {
      accessToken = data.data.access_token;
      console.log('✅ Authentication successful');
      console.log(`   Player: ${data.data.username}`);
    } else {
      throw new Error(data.message || 'Authentication failed');
    }
  } catch (error) {
    console.log('❌ Authentication failed:', error.message);
    return;
  }

  // Step 2: プレイヤー情報を確認
  console.log('\n2. Checking player info...');
  let playerGold;
  try {
    const response = await fetch(`${BASE_URL}/players/me`, {
      headers: { 'Authorization': `Bearer ${accessToken}` }
    });
    const data = await response.json();
    
    if (data.success) {
      playerGold = data.data.gold;
      console.log('✅ Player info retrieved');
      console.log(`   Gold: ${playerGold}G`);
      console.log(`   Shop Level: ${data.data.shop_level || 'N/A'}`);
      console.log(`   Full data:`, JSON.stringify(data.data, null, 2));
    } else {
      throw new Error(data.message || 'Failed to get player info');
    }
  } catch (error) {
    console.log('❌ Failed to get player info:', error.message);
  }

  // Step 3: 利用可能な武器を確認
  console.log('\n3. Checking available weapons...');
  let availableWeapon;
  try {
    const response = await fetch(`${BASE_URL}/weapons?page=1&limit=5`, {
      headers: { 'Authorization': `Bearer ${accessToken}` }
    });
    const data = await response.json();
    
    if (data.success && data.data && data.data.length > 0) {
      availableWeapon = data.data[0];
      console.log('✅ Weapons available');
      console.log(`   First weapon: ${availableWeapon.name}`);
      console.log(`   Price: ${availableWeapon.calculated_price || availableWeapon.base_price}G`);
      console.log(`   Required Level: ${availableWeapon.required_level}`);
    } else {
      console.log('❌ No weapons available');
      console.log('   Data:', JSON.stringify(data, null, 2));
      return;
    }
  } catch (error) {
    console.log('❌ Failed to get weapons:', error.message);
    return;
  }

  // Step 4: 武器購入を試行
  console.log('\n4. Attempting weapon purchase...');
  try {
    const response = await fetch(`${BASE_URL}/shop/purchase`, {
      method: 'POST',
      headers: { 
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        weapon_id: availableWeapon.id.toString()
      })
    });
    
    const responseText = await response.text();
    console.log(`   Response status: ${response.status}`);
    console.log(`   Response: ${responseText}`);
    
    if (response.ok) {
      const data = JSON.parse(responseText);
      if (data.success) {
        console.log('✅ Purchase successful');
        console.log(`   Weapon: ${data.data.weapon_name}`);
        console.log(`   Gold spent: ${data.data.gold_spent}G`);
        console.log(`   Remaining gold: ${data.data.remaining_gold}G`);
      } else {
        console.log('❌ Purchase failed');
        console.log(`   Error: ${data.message}`);
      }
    } else {
      console.log('❌ HTTP Error');
      console.log(`   Status: ${response.status}`);
      console.log(`   Response: ${responseText}`);
    }
  } catch (error) {
    console.log('❌ Purchase request failed:', error.message);
  }

  console.log('\n🔍 Shop Purchase Testing Complete!');
}

testShopPurchase().catch(console.error);