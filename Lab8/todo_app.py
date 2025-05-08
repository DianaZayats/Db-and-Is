import redis

class TodoApp:
    def __init__(self):
        # Підключення до Redis
        self.r = redis.Redis(host='localhost', port=6379, db=0)
        self.key = 'tasks'  # Ключ для списку завдань у Redis

    def show_tasks(self):
        # Отримуємо всі завдання
        tasks = self.r.lrange(self.key, 0, -1)
        if tasks:
            print("\nВаші завдання:")
            for idx, task in enumerate(tasks, start=1):
                print(f"{idx}. {task.decode('utf-8')}")
        else:
            print("Список завдань порожній.")

    def add_task(self, task):
        # Додаємо нове завдання
        self.r.lpush(self.key, task)
        print(f"\nЗавдання '{task}' додано.")

    def delete_task(self, task_index):
        # Видаляємо завдання за індексом
        tasks = self.r.lrange(self.key, 0, -1)
        if 0 < task_index <= len(tasks):
            task_to_delete = tasks[task_index - 1]
            self.r.lrem(self.key, 1, task_to_delete)
            print(f"\nЗавдання '{task_to_delete.decode('utf-8')}' видалено.")
        else:
            print("\nНевірний індекс завдання.")

    def clear_tasks(self):
        # Очищаємо всі завдання
        self.r.delete(self.key)
        print("\nВсі завдання видалено.")

def main():
    app = TodoApp()
    while True:
        print("\nМеню:")
        print("1. Показати завдання")
        print("2. Додати завдання")
        print("3. Видалити завдання")
        print("4. Очистити список завдань")
        print("5. Вийти")

        choice = input("\nВиберіть опцію (1/2/3/4/5): ")

        if choice == '1':
            app.show_tasks()
        elif choice == '2':
            task = input("\nВведіть нове завдання: ")
            app.add_task(task)
        elif choice == '3':
            task_index = int(input("\nВведіть номер завдання для видалення: "))
            app.delete_task(task_index)
        elif choice == '4':
            app.clear_tasks()
        elif choice == '5':
            print("\nДо побачення!")
            break
        else:
            print("\nНевірна опція. Спробуйте знову.")

if __name__ == "__main__":
    main()
