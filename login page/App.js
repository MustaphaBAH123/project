import React from 'react';
import { View, Text, TextInput, TouchableOpacity, StyleSheet, Image } from 'react-native';
import logo from './assets/logo.png';
// Then use: source={logo}
export default function App() {
  const [username, setUsername] = React.useState('محمد إسلام 06');
  const [password, setPassword] = React.useState('');

  // Use one of these options for your logo:
   
  // OR for local asset: import logo from './assets/logo.png';

  return (
    <View style={styles.container}>
      {/* Logo Section */}
      <View style={styles.logoContainer}>
        <Image 
          source={logo}
          style={styles.logoImage}
        />
      </View>

      <Text style={styles.header}>مرحبا بك من جديد تسجيل الدخول</Text>
      
      <View style={styles.inputContainer}>
        <Text style={styles.label}>إسم المستخدم</Text>
        <TextInput
          style={styles.input}
          value={username}
          onChangeText={setUsername}
        />
      </View>
      
      <View style={styles.inputContainer}>
        <Text style={styles.label}>كلمة المرور</Text>
        <TextInput
          style={styles.input}
          secureTextEntry
          value={password}
          onChangeText={setPassword}
        />
      </View>
      
      <TouchableOpacity style={styles.button}>
        <Text style={styles.buttonText}>تسجيل الدخول</Text>
      </TouchableOpacity>
      
      <Text style={styles.footer}>ليس لدى حساب إنشاء حساب</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 32,
    justifyContent: 'center',
    backgroundColor: '#fff',
  },
  logoContainer: {
    alignItems: 'center',
    marginBottom: 24,
  },
  logoImage: {
    width: 120,
    height: 120,
    resizeMode: 'contain',
  },
  header: {
    fontSize: 24,
    marginBottom: 32,
    textAlign: 'center',
    color: '#333',
  },
  inputContainer: {
    marginBottom: 20,
  },
  label: {
    fontSize: 16,
    marginBottom: 8,
    color: '#555',
    textAlign: 'right',
  },
  input: {
    height: 50,
    backgroundColor: '#f9f9f9',
    borderWidth: 1,
    borderColor: '#e0e0e0',
    borderRadius: 8,
    paddingHorizontal: 16,
    textAlign: 'right',
  },
  button: {
    height: 50,
    backgroundColor: '#2196F3',
    borderRadius: 8,
    justifyContent: 'center',
    alignItems: 'center',
    marginTop: 16,
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
  },
  footer: {
    color: '#2196F3',
    textAlign: 'center',
    marginTop: 24,
  },
});