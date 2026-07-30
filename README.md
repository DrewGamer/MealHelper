# Meal Helper

Meal Helper is a Flutter application built to help with weekly meal planning and management. It was originally created to solve the ever-present problem of deciding what to have for dinner every week. While anyone can use it to plan any type of meal, please note that it currently only supports scheduling one meal per day.

## Features

- **Meal Database:** Keep a database of meals. Add, edit, and organize meals with specific details (name/description/main protein/other ingredients).
- **Ingredient Manager:** Track the ingredients into 2 categories: main protein sources or other ingredients.
- **Smart Meal Planning:** Automatically generate meal plans while applying custom rules (which currently includes):
  - Trying to avoid selecting recent meals.
  - Varying protein sources from day to day.
  - Avoiding overlapping meals.
  - Excluding specific meals (toggled within the meal details itself)
- **Collaboration & Workspaces:** Share your meal plans and coordinate others using collaborative workspaces.
- **User Authentication:** Use the app anonymously or link your account (via email or Google account) to sync data across devices.

## Installation

### For Android Users (Installing on your phone)

Since Meal Helper is not available on the Google Play Store, you will need to install it directly from our GitHub Releases page. If you have never installed an app from outside the Play Store, here is how you can do it:

1. **Download the App:**
   - Open your phone's web browser and navigate to the **Releases** section of this GitHub repository.
   - Download the latest `.apk` file (e.g., `app-release.apk`) to your phone.

2. **Allow Installation from Unknown Sources:**
   - When the download is complete, tap the `.apk` file to open it.
   - Your phone will likely block the installation and display a security warning stating that your phone is not allowed to install unknown apps from this source.
   - Tap **Settings** on that prompt.
   - Find your web browser (or the "My Files" app) in the list and toggle **Allow from this source** to **ON**.

3. **Install the App:**
   - Tap the back button to return to the installation screen.
   - Tap **Install**.
   - Once it finishes installing, you can open Meal Helper from your app drawer!

### For Developers (Running locally)

To get started with Meal Helper development, make sure you have [Flutter](https://flutter.dev/) installed on your machine.

1. Clone the repository and navigate to the project directory.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## Resources

- [Flutter Documentation](https://docs.flutter.dev/) - Official documentation for Flutter development.
