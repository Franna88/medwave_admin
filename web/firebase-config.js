// Firebase configuration for MedWave Admin Panel (Web)
// This connects to the medx.ai Firebase project

// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
import { getFirestore } from "firebase/firestore";
import { getAuth } from "firebase/auth";
import { getStorage } from "firebase/storage";

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyC_medx_ai_web_api_key", // Replace with actual medx.ai web API key
  authDomain: "medx-ai.firebaseapp.com",
  projectId: "medx-ai",
  storageBucket: "medx-ai.firebasestorage.app",
  messagingSenderId: "987654321", // Replace with actual medx.ai messaging sender ID
  appId: "1:987654321:web:medx_ai_web_app_id", // Replace with actual medx.ai web app ID
  measurementId: "G-MEDX_AI_MEASUREMENT_ID" // Replace with actual medx.ai measurement ID
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Initialize Firebase services
const analytics = getAnalytics(app);
const db = getFirestore(app);
const auth = getAuth(app);
const storage = getStorage(app);

export { db, auth, storage, analytics };
