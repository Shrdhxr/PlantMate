# 🌱 PlantMate – Plant Care Reminder & Health Tracker

PlantMate is a Flutter app that helps you organize your plant collection and track care routines like **watering**, **fertilizing**, and **repotting**. Add custom photos, log care history, and browse a clean, image-first list of your plants. Data is stored locally using JSON with lightweight preferences via `shared_preferences`.

---

## ✨ Features

- 📋 **Plant Management** — Add, edit, delete plants (name, species, tags, photo).
- 💧 **Care Tracking** — Log watering, fertilizing, repotting with notes.
- 🕒 **Frequencies & Status** — Store care frequencies per plant and see which ones are due.
- 🖼️ **Custom Photos** — Pick from gallery or camera to personalize each plant.
- 🔍 **Search & Filters** — Find plants by name, species, or tags.
- 🌗 **Theme Toggle** — Light/Dark mode with saved preference.
- 📊 **Stats (basic)** — View simple charts for plant count and care activity.
- 💾 **Local Storage** — JSON for plant data + `shared_preferences` for settings.

---

## 📸 Screenshots

> Add images to `/assets/screenshots/` and link them here.

<!--
![Home](assets/screenshots/home.png)
![Details](assets/screenshots/details.png)
![Add Plant](assets/screenshots/add.png)
-->

---

## 🛠 Tech Stack

- **Framework:** Flutter (Dart)
- **State Management:** Riverpod or Cubit/BLoC
- **Storage:** Local JSON files + `shared_preferences`
- **Media:** `image_picker`
- **Charts:** `fl_chart`
- **Paths:** `path_provider`

---

## 📂 Project Structure

