
import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  Pressable,
  ScrollView,
  StyleSheet,
  ActivityIndicator
} from 'react-native';
import { authToken } from '../constants/auth';

// serves: REQ-010

const API_URL = 'http://192.168.1.8:8000';

export default function ChatScreen() {
  const [message, setMessage] = useState('');
  const [answers, setAnswers] = useState<string[]>([]);
  const [loading, setLoading] = useState(false);

  async function sendMessage() {
    if (!message.trim() || loading) return;

    const userMessage = message.trim();
    setMessage('');
    setLoading(true);

    try {
      const response = await fetch(`${API_URL}/chat`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${authToken}`
        },
        body: JSON.stringify({ message: userMessage })
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.detail || 'Chat request failed.');
      }

      const answer =
        data.response || data.reply || data.answer ||
        JSON.stringify(data);

      setAnswers(previous => [...previous, answer]);
    } catch (error: any) {
      setAnswers(previous => [
        ...previous,
        error.message || 'Could not connect to Weatherly.'
      ]);
    } finally {
      setLoading(false);
    }
  }

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Weatherly Chat</Text>
      <Text style={styles.subtitle}>
        Ask me about weather and outfit suggestions!
      </Text>

      <ScrollView style={styles.messages}>
        {answers.map((answer, index) => (
          <View key={index} style={styles.answerBox}>
            <Text style={styles.answerLabel}>AI answer</Text>
            <Text style={styles.answer}>{answer}</Text>
          </View>
        ))}

        {loading && <ActivityIndicator color="#B76E79" />}
      </ScrollView>

      <TextInput
        style={styles.input}
        placeholder="Ask a weather question..."
        value={message}
        onChangeText={setMessage}
        multiline
      />

      <Pressable style={styles.button} onPress={sendMessage}>
        <Text style={styles.buttonText}>Send</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FFF8F5',
    padding: 20,
    paddingTop: 60
  },
  title: {
    fontSize: 27,
    fontWeight: 'bold',
    color: '#B76E79'
  },
  subtitle: {
    color: '#777',
    marginTop: 8
  },
  messages: {
    flex: 1,
    marginVertical: 20
  },
  answerBox: {
    backgroundColor: '#F5E5E5',
    padding: 16,
    borderRadius: 14,
    marginBottom: 12
  },
  answerLabel: {
    fontWeight: 'bold',
    color: '#B76E79',
    marginBottom: 8
  },
  answer: {
    color: '#333'
  },
  input: {
    backgroundColor: 'white',
    borderWidth: 1,
    borderColor: '#E5C7C7',
    borderRadius: 12,
    padding: 14,
    minHeight: 55
  },
  button: {
    backgroundColor: '#B76E79',
    padding: 16,
    borderRadius: 12,
    alignItems: 'center',
    marginTop: 12
  },
  buttonText: {
    color: 'white',
    fontWeight: 'bold'
  }
});
