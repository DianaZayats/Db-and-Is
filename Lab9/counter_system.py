import redis
import threading
import time

class CounterSystem:
    def __init__(self):
        self.r = redis.Redis(host='localhost', port=6379, db=0)
        self.channel = 'event_channel'  # Канал для Pub/Sub
        self.stream_name = 'event_stream'  # Потік для зберігання подій

    def listen_for_events(self):
        """Функція для підписки на канал і отримання подій"""
        pubsub = self.r.pubsub()
        pubsub.subscribe(self.channel)

        print("Підписка на канал... Чекаю подій.")
        for message in pubsub.listen():
            if message['type'] == 'message':
                print(f"Нова подія: {message['data'].decode('utf-8')}")

    def add_event(self, event_name, count):
        """Функція для додавання події в канал і потік"""
        try:
            count = int(count)
        except ValueError:
            print("Кількість повинна бути числом!")
            return

        # Публікуємо подію в канал
        self.r.publish(self.channel, f"{event_name} - {count} new events")

        # Додаємо подію в потік, кодуємо значення в байти
        self.r.xadd(self.stream_name, {
            'event': event_name.encode('utf-8'),
            'count': str(count).encode('utf-8'),
            'timestamp': str(time.time()).encode('utf-8')
        })

    def show_event_history(self):
        """Функція для перегляду історії подій з потоку"""
        messages = self.r.xrange(self.stream_name, '-', '+')
        if not messages:
            print("Історія порожня.")
        else:
            print("\nІсторія подій:")
            for message in messages:
                message_id = message[0]  # перший елемент - ID події
                message_data = message[1]  # другий елемент - дані події
                # Перевірка наявності полів 'event' і 'count'
                event_name = message_data.get(b'event', b'Unknown').decode('utf-8')
                count = message_data.get(b'count', b'0').decode('utf-8')
                timestamp = message_data.get(b'timestamp', b'N/A').decode('utf-8')

                # Виведення події
                print(f"ID: {message_id.decode('utf-8')} | Подія: {event_name} | Кількість: {count} | Час: {timestamp}")

# Функція для запуску підписки в окремому потоці
def start_listening(counter_system):
    listener_thread = threading.Thread(target=counter_system.listen_for_events)
    listener_thread.daemon = True
    listener_thread.start()

# Основний блок
def main():
    counter_system = CounterSystem()

    # Запуск підписки на канал в окремому потоці
    start_listening(counter_system)

    while True:
        print("\n1. Додати подію")
        print("2. Переглянути історію подій")
        print("3. Вийти")

        choice = input("Виберіть опцію: ")

        if choice == '1':
            event_name = input("Введіть назву події: ")
            count = input("Введіть кількість нових подій: ")
            counter_system.add_event(event_name, count)
        elif choice == '2':
            counter_system.show_event_history()
        elif choice == '3':
            print("До побачення!")
            break
        else:
            print("Невірний вибір. Спробуйте ще раз.")

if __name__ == "__main__":
    main()
