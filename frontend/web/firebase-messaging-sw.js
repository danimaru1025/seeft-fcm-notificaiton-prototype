importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyCKvyPDk1hYZh1HNC9HO0moed6r0aCyUrs",
  authDomain: "seeft-prototype.firebaseapp.com",
  projectId: "seeft-prototype",
  storageBucket: "seeft-prototype.firebasestorage.app",
  messagingSenderId: "961238276657",
  appId: "1:961238276657:web:041f24167eb0db8b841310"
});

const messaging = firebase.messaging();

// バックグラウンド通知の処理
messaging.onBackgroundMessage((payload) => {
  console.log('バックグラウンド通知受信:', payload);
  
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});