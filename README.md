# Somali Speech-to-Text (somali_stt)

Real-time Somali speech recognition app for iPhone using Groq's Whisper API.

## Features

- Record Somali speech (5 seconds)
- Send audio to Groq Whisper API
- Display Somali text transcription
- Secure API key storage with `.env`
- Works offline (recording only, API needs internet)

## Tech Stack

| Component | Technology |
|-----------|------------|
| Mobile Framework | Flutter |
| Speech Recognition | Groq Whisper API |
| Audio Recording | flutter_sound |
| State Management | Flutter StatefulWidget |
| Platform | iOS / Android |

## Prerequisites

- Flutter SDK
- Groq API key
- iOS device or simulator
- Xcode (for iOS development)

## Installation

1. Clone the repository:
```bash
git clone https://github.com/nuredev/somali-stt.git
cd somali-stt
