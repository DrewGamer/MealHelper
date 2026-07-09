# Authentication Setup Guide (Phase 3)

To upgrade anonymous accounts to permanent accounts so users don't lose their data, we are adding **Email/Password** and **Google Sign-In**. 

Because Firebase handles the backend security for this, there are a few manual configuration steps you need to perform in your Firebase and Google Cloud consoles.

---

## 1. Enable Email/Password Authentication
This is the easiest one to set up!

1. Go to the [Firebase Console](https://console.firebase.google.com/) and open your **MealHelper** project.
2. Click on **Authentication** in the left sidebar, then click the **Sign-in method** tab.
3. Click **Add new provider** and select **Email/Password**.
4. Toggle the **Enable** switch (you do not need to enable "Email link (passwordless sign-in)").
5. Click **Save**.

---

## 2. Enable Google Sign-In
Google Sign-In allows users to link their account with 1-tap, but it requires linking your Firebase project to Google's OAuth system.

### A. Enable the Provider in Firebase
1. On the same **Sign-in method** tab in Firebase Authentication, click **Add new provider** and select **Google**.
2. Toggle the **Enable** switch.
3. It will ask for a "Project support email". Select your email address from the dropdown.
4. Click **Save**.

### B. Add your SHA-1 to Firebase
For Google Sign-In to work on Android, Google needs to verify the app's cryptographic signature. We already generated this earlier!
1. In the Firebase Console, click the **Gear Icon** (Project settings) in the top left corner.
2. Scroll down to the **Your apps** section and make sure your Android app is selected.
3. Under the "SHA certificate fingerprints" section, click **Add fingerprint**.
4. Paste the SHA-1 fingerprint we generated earlier: 
   `AA:F7:09:1D:D7:CF:43:0A:75:90:73:BA:15:39:FB:83:EA:7F:E6:2D`
5. Click **Save**.

*(Note: When you eventually release this to the Google Play Store, the Play Store generates a NEW release SHA-1 fingerprint that you will also need to add here.)*

---

## 3. Configure the OAuth Consent Screen (Google Cloud)
When a user clicks "Sign in with Google", they see a popup asking for permission. You have to configure what that popup says.

1. Go to the [Google Cloud Console OAuth Consent Screen](https://console.cloud.google.com/apis/credentials/consent).
2. Make sure your **meal-helper-16fd5** project is selected at the top.
3. Choose **External** user type and click **Create**.
4. Fill out the required fields:
   * **App name:** MealHelper
   * **User support email:** (Your email)
   * **Developer contact info:** (Your email)
5. Click **Save and Continue** all the way to the end (you don't need to add specific scopes or test users for basic authentication).
6. On the final Summary page, click **Back to Dashboard**.
7. *Crucial step:* Click the **PUBLISH APP** button on the dashboard so it's moved out of "Testing" mode, otherwise only you can log in!

---

Once you've completed these steps, your backend is fully configured to accept permanent account links!
