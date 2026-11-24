
import { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  ActivityIndicator,
  Pressable,
} from 'react-native';

// serves: REQ-004

const API_URL = 'https://aiasd-project-ddsi.onrender.com';

type AvatarData = {
  hair: string;
  makeup: string;
  clothing: string;
};

export default function AvatarScreen() {
  const [avatar, setAvatar] = useState<AvatarData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  async function loadAvatar() {
    setLoading(true);
    setError('');

    try {
      const response = await fetch(
        `${API_URL}/api/avatar?hair=long&makeup=natural&clothing=casual`
      );

      if (!response.ok) {
        throw new Error('Could not load avatar.');
      }

      const data = await response.json();
      setAvatar(data);
    } catch {
      setError('Could not connect to the server. Please try again.');
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadAvatar();
  }, []);

  return (
    <ScrollView
      style={styles.container}
      contentContainerStyle={styles.content}>
      <Text style={styles.logo}>Weatherly</Text>
      <Text style={styles.heading}>My Avatar</Text>
      <Text style={styles.subtitle}>
        Your personal style at a glance!
      </Text>

      {loading && (
        <ActivityIndicator size="large" color="#7354A5" />
      )}

      {error !== '' && (
        <View>
          <Text style={styles.error}>{error}</Text>
          <Pressable style={styles.button} onPress={loadAvatar}>
            <Text style={styles.buttonText}>Try again</Text>
          </Pressable>
        </View>
      )}

      {avatar && !loading && (
        <>
          <View style={styles.avatarCircle}>
            <Text style={styles.avatarEmoji}>👩🏻</Text>
          </View>

          <View style={styles.card}>
            <Text style={styles.cardTitle}>Avatar Details</Text>

            <Text style={styles.item}>💇 Hair: {avatar.hair}</Text>
            <Text style={styles.item}>💄 Makeup: {avatar.makeup}</Text>
            <Text style={styles.item}>👗 Clothing: {avatar.clothing}</Text>
          </View>

          <Pressable style={styles.button} onPress={loadAvatar}>
            <Text style={styles.buttonText}>Refresh Avatar</Text>
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
    fontSize: 26,
    fontWeight: 'bold',
    color: '#35264D',
  },
  subtitle: {
    fontSize: 15,
    color: '#777',
    marginTop: 8,
    marginBottom: 25,
  },
  avatarCircle: {
    width: 150,
    height: 150,
    borderRadius: 75,
    backgroundColor: '#E6DDF3',
    justifyContent: 'center',
    alignItems: 'center',
    alignSelf: 'center',
    marginVertical: 20,
  },
  avatarEmoji: {
    fontSize: 85,
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
    marginBottom: 18,
  },
  item: {
    fontSize: 16,
    color: '#555',
    marginBottom: 14,
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

