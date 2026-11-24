
import { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  ActivityIndicator,
  Pressable,
} from 'react-native';

// serves: REQ-003

const API_URL = 'https://aiasd-project-ddsi.onrender.com';

type OutfitData = {
  city: string;
  today: string[];
  tomorrow: string[];
};

export default function ExploreScreen() {
  const [outfits, setOutfits] = useState<OutfitData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  async function loadOutfits() {
    setLoading(true);
    setError('');

    try {
      const response = await fetch(`${API_URL}/api/outfits?city=Ankara`);

      if (!response.ok) {
        throw new Error('Could not load outfit recommendations.');
      }

      const data = await response.json();
      setOutfits(data);
    } catch (err) {
      setError('Could not connect to the server. Please try again.');
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadOutfits();
  }, []);

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <Text style={styles.logo}>Weatherly</Text>
      <Text style={styles.heading}>Outfit Recommendations</Text>
      <Text style={styles.subtitle}>Dress for the weather!</Text>

      {loading && (
        <ActivityIndicator size="large" color="#7354A5" />
      )}

      {error !== '' && (
        <View>
          <Text style={styles.error}>{error}</Text>
          <Pressable style={styles.button} onPress={loadOutfits}>
            <Text style={styles.buttonText}>Try again</Text>
          </Pressable>
        </View>
      )}

      {outfits && !loading && (
        <>
          <Text style={styles.city}>📍 {outfits.city}</Text>

          <View style={styles.card}>
            <Text style={styles.cardTitle}>☀️ Today's Outfit</Text>
            {outfits.today.map((item, index) => (
              <Text style={styles.item} key={index}>• {item}</Text>
            ))}
          </View>

          <View style={styles.card}>
            <Text style={styles.cardTitle}>🌧️ Tomorrow's Outfit</Text>
            {outfits.tomorrow.map((item, index) => (
              <Text style={styles.item} key={index}>• {item}</Text>
            ))}
          </View>

          <Pressable style={styles.button} onPress={loadOutfits}>
            <Text style={styles.buttonText}>Refresh recommendations</Text>
          </Pressable>
        </>
      )}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F4F0FA',
  },
  content: {
    padding: 25,
    paddingTop: 65,
  },
  logo: {
    fontSize: 30,
    fontWeight: 'bold',
    color: '#7354A5',
    marginBottom: 25,
  },
  heading: {
    fontSize: 25,
    fontWeight: 'bold',
    color: '#35264D',
  },
  subtitle: {
    fontSize: 15,
    color: '#777',
    marginTop: 8,
    marginBottom: 25,
  },
  city: {
    fontSize: 18,
    fontWeight: '600',
    color: '#7354A5',
    marginBottom: 18,
  },
  card: {
    backgroundColor: 'white',
    padding: 22,
    borderRadius: 16,
    marginBottom: 18,
  },
  cardTitle: {
    fontSize: 19,
    fontWeight: 'bold',
    color: '#35264D',
    marginBottom: 15,
  },
  item: {
    fontSize: 16,
    color: '#555',
    marginBottom: 10,
  },
  button: {
    backgroundColor: '#7354A5',
    padding: 16,
    borderRadius: 12,
    alignItems: 'center',
    marginTop: 10,
  },
  buttonText: {
    color: 'white',
    fontSize: 15,
    fontWeight: 'bold',
  },
  error: {
    color: '#B42318',
    fontSize: 15,
    marginBottom: 15,
  },
});
