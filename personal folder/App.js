import React, { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, StyleSheet, ScrollView } from 'react-native';
import { Checkbox } from 'react-native-paper'; // Expo-compatible checkbox

export default function ProfileCreation() {
  const [lastName, setLastName] = useState('أولاً دائرة، عرض نسخة...');
  const [firstName, setFirstName] = useState('محمد عبد الله...');
  const [birthDate, setBirthDate] = useState('1995/05/13');
  const [phoneNumber, setPhoneNumber] = useState('0 111 222 333');
  const [trafficCollege, setTrafficCollege] = useState('++++++++++');
  const [termsAccepted, setTermsAccepted] = useState(false);
  const [accountCreated, setAccountCreated] = useState(false);

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <Text style={styles.header}>أنشئ ملفك الشخصي</Text>
      
      <Text style={styles.sectionTitle}>اللقب</Text>
      <TextInput
        style={styles.input}
        value={lastName}
        onChangeText={setLastName}
      />
      
      <Text style={styles.sectionTitle}>الإسم</Text>
      <TextInput
        style={styles.input}
        value={firstName}
        onChangeText={setFirstName}
      />
      
      <Text style={styles.sectionTitle}>تاريخ الميلاد</Text>
      <TextInput
        style={styles.input}
        value={birthDate}
        onChangeText={setBirthDate}
      />
      
      <Text style={styles.sectionTitle}>رقم الهاتف</Text>
      <TextInput
        style={styles.input}
        value={phoneNumber}
        onChangeText={setPhoneNumber}
        keyboardType="phone-pad"
      />
      
      <Text style={styles.sectionTitle}>كلية المرور</Text>
      <TextInput
        style={styles.input}
        value={trafficCollege}
        onChangeText={setTrafficCollege}
      />
      
      <View style={styles.checkboxContainer}>
        <Checkbox.Android
          status={termsAccepted ? 'checked' : 'unchecked'}
          onPress={() => setTermsAccepted(!termsAccepted)}
          color="#2196F3"
        />
        <Text style={styles.checkboxLabel}>أوافق على الشروط و الأحكام.</Text>
      </View>
      
      <View style={styles.checkboxContainer}>
        <Checkbox.Android
          status={accountCreated ? 'checked' : 'unchecked'}
          onPress={() => setAccountCreated(!accountCreated)}
          color="#2196F3"
        />
        <Text style={styles.checkboxLabel}>إنشاء حساب</Text>
      </View>
      
      <TouchableOpacity style={styles.loginLink}>
        <Text style={styles.loginText}>لدي حساب بالفعل تسجيل الدخول</Text>
      </TouchableOpacity>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    padding: 20,
    backgroundColor: '#fff',
  },
  header: {
    fontSize: 24,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 30,
    color: '#333',
  },
  sectionTitle: {
    fontSize: 16,
    marginBottom: 8,
    color: '#555',
    textAlign: 'right',
  },
  input: {
    height: 50,
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    paddingHorizontal: 15,
    marginBottom: 20,
    textAlign: 'right',
    backgroundColor: '#f9f9f9',
  },
  checkboxContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 15,
    justifyContent: 'flex-end',
  },
  checkboxLabel: {
    fontSize: 16,
    color: '#333',
    textAlign: 'right',
    marginRight: 10,
  },
  loginLink: {
    marginTop: 20,
    alignItems: 'center',
  },
  loginText: {
    color: '#2196F3',
    fontSize: 16,
    textDecorationLine: 'underline',
  },
});