# 🌱 PlantMate – Plant Care Reminder & Health Tracker

PlantMate is a Flutter app that helps you organize your plant collection and track care routines like **watering**, **fertilizing**, and **repotting**. Add custom photos, log care history, and browse a clean, image-first list of your plants.

---

## ✨ Features

- 📋 **Plant Management** — Add, edit, delete plants (name, species, tags, photo).
- 💧 **Care Tracking** — Log watering, fertilizing, repotting with notes.
- 🕒 **Frequencies & Status** — Store care frequencies per plant and see which ones are due.
- 🖼️ **Custom Photos** — Pick from gallery or camera to personalize each plant.
- 🔍 **Search & Filters** — Find plants by name, species, or tags.
- 📊 **Stats** — View simple charts for plant count and care activity.

---

## 📸 Images

### Screenshots
<img width="1131" height="549" alt="MA_SCREENS_1" src="https://github.com/user-attachments/assets/ed57455b-c95f-40d2-a2fb-b34d6e60b75d" />
<img width="1135" height="546" alt="MA_SCREENS_2" src="https://github.com/user-attachments/assets/9a4a9685-c659-4355-b242-18a01070719e" />

### Wireframes
<img width="1085" height="395" alt="MA_WireFrames" src="https://github.com/user-attachments/assets/e3453bbe-a442-484a-bc16-ac4a7e91c5ed" />

### Screen Flow
<img width="1389" height="829" alt="App_Flow_MA" src="https://github.com/user-attachments/assets/0576e9cd-c4ef-457b-b817-e6e7863a42a6" />

---

## 🛠 Tech Stack

- **Framework:** Flutter (Dart)

- **State Management:** Riverpod or Cubit/BLoC
- **Storage:** Local JSON files + `shared_preferences`
- **Media:** `image_picker`

- **Charts:** `fl_chart`
- **Paths:** `path_provider`

---

## 🚀 Getting Started

```bash
# 1) Clone
git clone https://github.com/<Shrdhxr>/plantmate.git
cd plantmate

# 2) Install dependencies
flutter pub get

# 3) Run
flutter run
