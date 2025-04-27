#  Event Planner - Final Project (Individual Part)

This project is part of the group final project.  
This specific section is developed individually by Janani Gokeda: the Event Planner Page.
Only the files listed below are part of my work.
No code from group members was copied or reused.
This part of the project is completed independently following academic integrity guidelines.
The Event Planner app allows users to add, view, update, and delete events, following all project specifications.

## Features Implemented
- Add a new event with:
- Name, Date, Time,Location,Description.
- Form validation ensures all fields are completed before saving.
- Store and display events using a local Floor database.
- ListView to show all events.
- Select an event to open it for updating or deleting.
- Use EncryptedSharedPreferences to:
- Save the last event created.
- Give the user a choice to copy previous event details when adding a new one.
- Snackbar notifications and AlertDialogs for:
- Event save, update, delete confirmations.
- Instructions on how to use the page.
- Multilingual support:Telugu and English (user can select language).
- Professional UI layout and responsive design:
- On phones: full screen event detail view.
- On tablets/desktops: event list and details side-by-side.
- Dartdoc documentation included under `/dartdoc/` folder.

## Technologies Used

- Flutter Framework
- Dart Language
- Floor Database (local storage)
- EncryptedSharedPreferences
- Material Design components
- Git & GitHub for version control

## Project Structure (Individual Part)

- /lib 
- event_planner_item.dart
- event_planner_page.dart
- event_planner_dao.dart
- Main.dart
- database.dart
- database.g.dart
- encrypted_storage.dart
- pubspec.yaml
- dartdoc

## Developer

Name:Janani Gokeda  
GitHub:https://github.com/jananigokeda/Event-Planner-App

