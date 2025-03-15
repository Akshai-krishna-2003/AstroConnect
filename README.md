# **AstroConnect - Your Personalized Astrology Companion** 🔮✨

Welcome to **AstroConnect**, a sophisticated astrology application that provides personalized horoscope readings, partner compatibility insights, and past searches, all integrated with **AI-powered predictions** using **Hugging Face’s Falcon-7B model**.

This project is being developed collaboratively by two professionals:

- **Lead Software Engineer & System Architect:** Responsible for backend development, API integration, database management, and business logic implementation along with UI development.

---

## 🚀 **Project Overview**

AstroConnect is a **Flutter-based astrology application** that combines artificial intelligence with user inputs to generate **highly personalized astrological insights**. The app supports **multiple languages** and features an **aesthetic UI inspired by cosmic elements**.

It includes:  
✅ **Daily Horoscope & Astrology Predictions**  
✅ **Vedic Astrology-Based Partner Compatibility**  
✅ **History of Past Horoscope Searches**  
✅ **Google Sign-In & Firebase Authentication**  
✅ **Image Uploads for Profile Personalization**  
✅ **Dark-Themed, Cosmic UI for Enhanced Aesthetic**  
✅ **Multi-Language Support (English, Malayalam, Tamil, Hindi)**  
✅ **Optimized Performance & Secure Storage (SQLite, Firebase Firestore)**

---

## 📱 **Tech Stack & Tools Used**

### **Frontend (Mobile App - Flutter)**

- **Flutter** (Latest Stable Version)
- **Dart** (Core Programming Language)
- **Provider** (State Management)
- **Custom Theming & Animations** (For better UI experience)

### **Backend & APIs**

- **Firebase Authentication** (Email, Google Sign-In)
- **Firebase Firestore** (User Data Storage)
- **Firebase Storage** (Image Uploads & Retrieval)
- **Hugging Face API** (Falcon-7B AI Model for Astrology Predictions)

### **Database & Storage**

- **SQLite** (Local Storage for Past Searches)
- **SharedPreferences** (User Preferences & Language Selection)

### **Machine Learning Model Used**

- **Model:** [Falcon-7B Instruct](https://huggingface.co/tiiuae/falcon-7b-instruct)
- **Purpose:** Generates astrology-based insights using natural language processing (NLP).
- **API Integration:** Handled via HTTP requests in **huggingface_service.dart**

---

## 🛠 **Installation & Setup**

### **Step 1: Clone the Repository**

\`\`\`bash
git clone https://github.com/Akshai-krishna-2003/AstroConnect.git
cd astroconnect
\`\`\`

### **Step 2: Install Dependencies**

\`\`\`bash
flutter pub get
\`\`\`

### **Step 3: Set Up Firebase**

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/).
2. Enable **Authentication** (Email & Google Sign-In).
3. Enable **Cloud Firestore** & **Firebase Storage**.
4. Download and add \`google-services.json\` (for Android) and \`GoogleService-Info.plist\` (for iOS) to respective folders.

### **Step 4: Set Up API Keys**

1. Create a Hugging Face account.
2. Get your API key from [Hugging Face API](https://huggingface.co/settings/tokens).
3. Replace \`"xxx"\` with your API Key in \`huggingface_service.dart\`.

\`\`\`dart
final String \_apiKey = "xxx"; // Add your API key here 
\`\`\` 
Note: huggingface_service.dart and huggingface2_service.dart is not added to the repository for security purpose

### **Step 5: Run the App**

\`\`\`bash
flutter run
\`\`\`

---

## 🔥 **Key Features & Functionality**

### 🌟 **1. AI-Powered Astrology Insights**

- Users input their **name, date of birth, time of birth, and place of birth**.
- Data is sent to **Hugging Face Falcon-7B model**, which generates personalized astrology readings.
- Users can also upload an **image**, which is stored securely in **Firebase Storage**.

### 💑 **2. Partner Compatibility Check**

- Users input details for **Bride & Groom**.
- The app uses AI to generate **detailed compatibility reports based on Vedic astrology**.
- Results are stored in the user’s history for future reference.

### 📜 **3. Previous Searches & History**

- Users can view past horoscope readings & compatibility checks.
- **SQLite Database** stores offline search history.

### 🌍 **4. Multi-Language Support**

- **English, Malayalam, Tamil, and Hindi** language support.
- Language changes **every 20 seconds** dynamically on the home screen.
- JSON-based localization stored in \`lib/localization/\`.

### 🎨 **5. Aesthetic & Cosmic-Themed UI**

- **Dark theme with celestial backgrounds.**
- **Smooth animations & interactive elements.**
- **Custom fonts & gradient UI design.**

### 🔒 **6. Secure User Authentication**

- **Firebase Authentication** allows users to sign in with **Email & Google**.
- Forgot Password feature allows password reset via **email**.

---

## 🏗 **Folder Structure**

- **astroconnect/** *(Root Directory)*
  - **lib/** *(Main Flutter application code)*
    - **screens/** *(UI Screens - Login, Home, Astrology, etc.)*
      - `astrology_input_screen.dart`
      - `home_screen.dart`
      - `login_screen.dart`
      - `partner_compatibility_screen.dart`
      - `previous_searches_screen.dart`
    - **services/** *(API Calls, Firebase, Database Handling)*
      - `auth_service.dart`
      - `db_service.dart`
      - `firestore_service.dart`
      - `history_service.dart`
      - `huggingface_service.dart` *(excluded for security)*
      - `huggingface2_service.dart` *(excluded for security)*
      - `localization_service.dart`
      - `firebase_options.dart`
    - **localization/** *(Multi-Language JSON Files)*
      - `en.json`
      - `hi.json`
      - `ml.json`
      - `ta.json`
    - **assets/** *(Images, Icons, Backgrounds)*
    - **main.dart** *(Entry Point)*
  - **android/** *(Android-specific Configuration)*
  - **ios/** *(iOS-specific Configuration)*
  - **linux/** *(Linux-specific Configuration)*
  - **macos/** *(macOS-specific Configuration)*
  - **web/** *(Web-specific Configuration)*
  - **windows/** *(Windows-specific Configuration)*
  - **pubspec.yaml** *(Project Dependencies & Assets Configuration)*
  - **README.md** *(Project Documentation)*
  - **.gitignore** *(Ignore Unnecessary Files in Git)*

# Flutter dependencies

**/build/
**/pubspec.lock

# Firebase

**/android/app/google-services.json
**/ios/Runner/GoogleService-Info.plist

# Environment Variables

**/.env
**/config.dart

# MacOS & Windows Ignore

.DS*Store
*.iml
\_.log

# IDE Specific

.vscode/
.idea/
\`\`\`

---

## 🎯 **Future Enhancements**

🔹 **Daily Horoscope Feature**  
🔹 **More Languages & Regional Astrology**  
🔹 **Dark & Light Mode Switching**  
🔹 **User Profile Customization**  
🔹 **Integration with Panchang & Nakshatra Reports**

---

## ❤️ **Contributors**

| Role                                                   | Name               | Email                       | GitHub                                           | LinkedIn                                                                    |
| ------------------------------------------------------ | ------------------ | --------------------------- | ------------------------------------------------ | --------------------------------------------------------------------------- |
| **Lead Software Engineer & System Architect**          | _Akshai Krishna A_ | akshaykrishna1983@gmail.com | [Akshai](https://github.com/Akshai-krishna-2003) | [Akshai Krishna](https://www.linkedin.com/in/akshai-krishna-a-a5ab99224/)   |

📢 **Want to Contribute?** Feel free to fork this repository and submit a **pull request**.

---

## 📢 **License**

This project is licensed under the **MIT License**.

---

## 🌟 **Show Your Support**

If you like this project, don't forget to ⭐ **Star this repository** and **Share it with others**!

---

## 📲 **Upcoming Play Store Release**

We plan to **publish AstroConnect on the Google Play Store** soon! Stay tuned for updates. 🚀

🔮✨ _Explore your future with AstroConnect!_ ✨🔮
