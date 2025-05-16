require 'json'
require 'yaml'

# Глобальний хеш подій
$events = {}

# Додати подію
def add_event(name, data)
  if $events.key?(name)
    puts "Помилка: Подія '#{name}' вже існує."
    return false
  end
  $events[name] = data
  puts "Подію '#{name}' додано."
  true
end

# Редагувати подію
def edit_event(name, data)
  unless $events.key?(name)
    puts "Помилка: Подію '#{name}' не знайдено."
    return false
  end
  $events[name] = data
  puts "Подію '#{name}' оновлено."
  true
end

# Видалити подію
def delete_event(name)
  if $events.delete(name)
    puts "Подію '#{name}' видалено."
    true
  else
    puts "Помилка: Подію '#{name}' не знайдено."
    false
  end
end

# Пошук подій за ключовим словом
def search_events(keyword)
  keyword_down = keyword.downcase
  results = $events.select do |name, data|
    name.downcase.include?(keyword_down) ||
    data[:description].to_s.downcase.include?(keyword_down) ||
    data[:participants].any? { |p| p.downcase.include?(keyword_down) } ||
    data[:locations].any? { |l| l.downcase.include?(keyword_down) }
  end

  if results.empty?
    puts "Подій з ключовим словом '#{keyword}' не знайдено."
  else
    puts "Знайдено #{results.size} подій за ключовим словом '#{keyword}':"
    results.each { |name, data| display_event(name, data) }
  end

  results
end

# Вивести всі події
def list_events
  if $events.empty?
    puts "Список подій порожній."
  else
    puts "Всі події:"
    $events.each { |name, data| display_event(name, data) }
  end
end

# Зберегти події у файл (json або yaml)
def save_to_file(filename, format)
  case format.downcase
  when 'json'
    File.write(filename, JSON.pretty_generate($events))
    puts "Дані збережено у файл '#{filename}' у форматі JSON."
  when 'yaml'
    File.write(filename, $events.to_yaml)
    puts "Дані збережено у файл '#{filename}' у форматі YAML."
  else
    puts "Помилка: Невідомий формат '#{format}'."
    false
  end
end

# Завантажити події з файлу (json або yaml)
def load_from_file(filename)
  unless File.exist?(filename)
    puts "Помилка: Файл '#{filename}' не знайдено."
    return false
  end

  case File.extname(filename)
  when '.json'
    $events = JSON.parse(File.read(filename), symbolize_names: true)
    puts "Дані завантажено з файлу '#{filename}' у форматі JSON."
  when '.yaml', '.yml'
    $events = YAML.load_file(filename)
    puts "Дані завантажено з файлу '#{filename}' у форматі YAML."
  else
    puts "Помилка: Невідомий формат файлу '#{filename}'."
    return false
  end
  true
end

# Допоміжна функція для виводу події
def display_event(name, data)
  puts "\nНазва: #{name}"
  puts "Дата: #{data[:date]}"
  puts "Учасники: #{data[:participants].join(', ')}"
  puts "Місця проведення: #{data[:locations].join(', ')}"
  puts "Опис: #{data[:description]}"
end

# ---- Приклад використання ----
add_event("Конференція", {
  date: "2025-09-10",
  participants: ["Анна", "Богдан"],
  locations: ["Київ", "Одеса"],
  description: "Тематична конференція з IT"
})

edit_event("Конференція", {
  date: "2025-09-11",
  participants: ["Анна", "Богдан", "Віктор"],
  locations: ["Київ"],
  description: "Оновлена дата конференції"
})

list_events

search_events("віктор")

save_to_file("events.yaml", "yaml")

load_from_file("events.yaml")

delete_event("Конференція")

list_events
