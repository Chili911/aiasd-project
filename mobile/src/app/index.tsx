
import { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  Pressable,
  StyleSheet,
  Alert,
  ActivityIndicator,
  ScrollView,
} from 'react-native';
import { router } from 'expo-router';
import { setAuthToken } from '../constants/auth';

const API_URL = 'https://aiasd-project-ddsi.onrender.com';

// serves: REQ-001
// serves: REQ-002

type WeatherData = {
  city: string;
  today: {
    temperature: number;
    condition: string;
    precipitation: string;
  };
  tomorrow: {
    temperature: number;
    condition: string;
    precipitation: string;
  };
};

export default function HomeScreen() {
  const [email, setEmail] = useState('');
  const [code, setCode] = useState('');
  const [loggedInEmail, setLoggedInEmail] = useState('');
  const [step, setStep] = useState<'email' | 'code' | 'dashboard'>('email');
  const [loading, setLoading] = useState(false);
  const [weather, setWeather] = useState<WeatherData | null>(null);

  async function requestCode() {
    if (!email.trim()) {
      Alert.alert('Error', 'Please enter your email.');
      return;
    }

    setLoading(true);

    try {
      const response = await fetch(`${API_URL}/auth/code`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: email.trim() }),
      });

      if (!response.ok) {
        throw new Error('Could not send code.');
      }

      setStep('code');
      Alert.alert('Code sent', 'Check your email for the 4-digit code.');
    } catch (error) {
      Alert.alert('Connection error', 'Could not connect to the server.');
    } finally {
      setLoading(false);
    }
  }

  async function login() {
    setLoading(true);

    try {
      const response = await fetch(`${API_URL}/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          email: email.trim(),
          code: code.trim(),
        }),
      });

      if (!response.ok) {
        throw new Error('Incorrect email or code.');
      }

      const data = await response.json();

      // Save the login token for the chatbot.
      setAuthToken(data.token);

      const userResponse = await fetch(`${API_URL}/auth/me`, {
        headers: { Authorization: `Bearer ${data.token}` },
      });

      if (!userResponse.ok) {
        throw new Error('Could not verify login.');
      }

      const user = await userResponse.json();
      setLoggedInEmail(user.email);

      const weatherResponse = await fetch(
        `${API_URL}/api/weather?city=Istanbul`
      );

      if (!weatherResponse.ok) {
        throw new Error('Could not load weather.');
      }

      const weatherData = await weatherResponse.json();

      setWeather(weatherData);
      setStep('dashboard');
    } catch (error) {
      Alert.alert(
        'Login failed',
        'Please check your code and try again.'
      );
    } finally {
      setLoading(false);
    }
  }

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <Text style={styles.logo}>Weatherly</Text>
      <Text style={styles.subtitle}>Your weather, your style.</Text>

      {step === 'email' && (
        <>
          <Text style={styles.heading}>Welcome!</Text>
          <Text style={styles.description}>
            Enter your email to get started.
          </Text>

          <TextInput
            style={styles.input}
            placeholder="Email address"
            keyboardType="email-address"
            autoCapitalize="none"
            value={email}
            onChangeText={setEmail}
          />

          <Pressable
            style={styles.button}
            onPress={requestCode}
            disabled={loading}
          >
            {loading ? (
              <ActivityIndicator color="white" />
            ) : (
              <Text style={styles.buttonText}>Send code</Text>
            )}
          </Pressable>
        </>
      )}

      {step === 'code' && (
        <>
          <Text style={styles.heading}>Verify your email</Text>
          <Text style={styles.description}>
            Enter the 4-digit code sent to {email}.
          </Text>

          <TextInput
            style={styles.input}
            placeholder="4-digit code"
            keyboardType="number-pad"
            maxLength={4}
            value={code}
            onChangeText={setCode}
          />

          <Pressable
            style={styles.button}
            onPress={login}
            disabled={loading}
          >
            {loading ? (
              <ActivityIndicator color="white" />
            ) : (
              <Text style={styles.buttonText}>Verify and login</Text>
            )}
          </Pressable>
        </>
      )}

      {step === 'dashboard' && weather && (
        <>
          <Text style={styles.heading}>Hello!</Text>
          <Text style={styles.description}>{loggedInEmail}</Text>
          <Text style={styles.city}>📍 {weather.city}</Text>

          <View style={styles.card}>
            <Text style={styles.cardTitle}>Today's Weather ☀️</Text>
            <Text style={styles.temperature}>
              {weather.today.temperature}°C
            </Text>
            <Text style={styles.weatherText}>
              {weather.today.condition}
            </Text>
            <Text style={styles.weatherText}>
              Precipitation: {weather.today.precipitation}
            </Text>
          </View>

          <View style={styles.card}>
            <Text style={styles.cardTitle}>Tomorrow's Weather 🌧️</Text>
            <Text style={styles.temperature}>
              {weather.tomorrow.temperature}°C
            </Text>
            <Text style={styles.weatherText}>
              {weather.tomorrow.condition}
            </Text>
            <Text style={styles.weatherText}>
              Precipitation: {weather.tomorrow.precipitation}
            </Text>
          </View>

          {/* Open chatbot */}
          <Pressable
            style={styles.button}
            onPress={() => router.push('/chat')}
          >
            <Text style={styles.buttonText}>
              Open Weatherly Chat 💬
            </Text>
          </Pressable>

          <Pressable
            style={styles.button}
            onPress={() => {
              setAuthToken('');
              setStep('email');
              setEmail('');
              setCode('');
              setLoggedInEmail('');
              setWeather(null);
            }}
          >
            <Text style={styles.buttonText}>Log out</Text>
          </Pressable>
        </>
      )}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flexGrow: 1,
    backgroundColor: '#F4F0FA',
    justifyContent: 'center',
    padding: 28,
  },
  logo: {
    fontSize: 38,
    fontWeight: 'bold',
    color: '#7354A5',
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 16,
    color: '#777',
    textAlign: 'center',
    marginBottom: 35,
  },
  heading: {
    fontSize: 27,
    fontWeight: 'bold',
    color: '#35264D',
    marginBottom: 12,
  },
  description: {
    fontSize: 15,
    color: '#666',
    marginBottom: 20,
  },
  city: {
    fontSize: 19,
    fontWeight: 'bold',
    color: '#7354A5',
    marginBottom: 15,
  },
  input: {
    backgroundColor: 'white',
    borderRadius: 12,
    padding: 16,
    fontSize: 16,
    marginBottom: 18,
    borderWidth: 1,
    borderColor: '#DDD3EA',
  },
  button: {
    backgroundColor: '#7354A5',
    padding: 17,
    borderRadius: 12,
    alignItems: 'center',
    marginTop: 12,
  },
  buttonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: 'bold',
  },
  card: {
    backgroundColor: 'white',
    padding: 20,
    borderRadius: 16,
    marginBottom: 16,
  },
  cardTitle: {
    fontSize: 19,
    fontWeight: 'bold',
    color: '#35264D',
    marginBottom: 12,
  },
  temperature: {
    fontSize: 34,
    fontWeight: 'bold',
    color: '#7354A5',
  },
  weatherText: {
    fontSize: 16,
    color: '#666',
    marginTop: 6,
  },
});
