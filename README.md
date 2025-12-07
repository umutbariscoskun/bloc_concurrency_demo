# Flutter Bloc Concurrency Demo

![Bloc Concurrency Kraken](assets/kraken.png)

A Flutter application designed to demonstrate and visualize the behavior of **Bloc Concurrency** event transformers.

This project serves as a practical guide to understanding how `concurrent`, `sequential`, `droppable`, and `restartable` transformers affect event processing in `flutter_bloc`.

## 🚀 Features

The app contains 4 tabs, each dedicated to a specific event transformer. You can trigger events and watch the real-time logs to see how they are handled.

### 1. Concurrent (Default)
Process events concurrently.
- **Behavior:** All events run simultaneously.
- **Observation:** Triggering multiple events results in multiple "Started" and "Completed" logs appearing in parallel.

### 2. Sequential
Process events sequentially.
- **Behavior:** Events wait for the previous one to finish before starting.
- **Observation:** Triggering multiple events results in a strict queue: Started #1 -> Completed #1 -> Started #2 -> Completed #2.

### 3. Droppable
Ignore any events added while an event is processing.
- **Behavior:** If the bloc is busy, new events are ignored (dropped).
- **Observation:** Triggering an event while one is running results in **no logs** for the subsequent clicks.

### 4. Restartable
Process only the latest event and cancel previous event handlers.
- **Behavior:** New events cancel the currently running event.
- **Observation:** Triggering a new event immediately stops the previous one (you won't see "Completed" for the first one) and starts the new one.

## 🛠️ Tech Stack

- [Flutter](https://flutter.dev/)
- [flutter_bloc](https://pub.dev/packages/flutter_bloc)
- [bloc_concurrency](https://pub.dev/packages/bloc_concurrency)
- [equatable](https://pub.dev/packages/equatable)

## 🏁 Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/bloc_concurrency_example.git
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📖 How to Use

1. Open the app.
2. Select a tab (e.g., **Sequential**).
3. Tap the **"Trigger Event"** button multiple times.
4. Observe the **Logs** area to see when events start and complete.
5. Use the **Reset** button to clear logs and start over.

## 📝 License

This project is open source and available under the [MIT License](LICENSE).
