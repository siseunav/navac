import { initializeApp } from "firebase/app";
// Import the functions you need from the SDKs you need
import {getAuth} from "firebase/auth";
import { getFirestore } from "firebase/firestore";
import { getStorage } from "firebase/storage";

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyC1_tnF6pG912O-yh6bo9Z7Jd-i3K-v_F0",
  authDomain: "shully-f95f5.firebaseapp.com",
  projectId: "shully-f95f5",
  storageBucket: "shully-f95f5.firebasestorage.app",
  messagingSenderId: "640978668394",
  appId: "1:640978668394:web:5acb2251e4f917022f7313"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
//app 인증 서비스에 대한 링크를 가져올 수 있다. 초간단하다고 한다. 
export const auth = getAuth(app);
//db 설정
export const storage = getStorage(app);
export const db = getFirestore(app);