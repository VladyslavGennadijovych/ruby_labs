require 'json'
require 'yaml'

class EventOrganizer
  def initialize
    @events = {}
  end

  def run
    loop do
      puts "\n--- ОРГАНАЙЗЕР ПОДІЙ ---"
      puts "1. Додати подію"
      puts "2. Редагувати подію"
      puts "3. Видалити подію"
      puts "4. Пошук подій"
      puts "5. Показати всі події"
      puts "6. Зберегти у файл (JSON/YAML)"
      puts "7. Завантажити з файлу (JSON/YAML)"
      puts "0. Вихід"
      print "Ваш вибір: "
      choice = gets.chomp.to_i

      case choice
      when 1 then add_event
      when 2 then edit_event
      when 3 then delete_event
      when 4 then search_event
      when 5 then list_events
      when 6 then save_to_file
      when 7 then load_from_file
      when 0 then break
      else puts "Невідомий вибір. Спробуйте ще раз."
      end
    end
  end

  private

  def add_event
    print "Назва події: "
    name = gets.chomp
    return puts "Подія з такою назвою вже існує." if @events.key?(name)

    data = collect_event_data
    @events[name] = data
    puts "Подію додано!"
  end

  def edit_event
    print "Назва події для редагування: "
    name = gets.chomp
    return puts "Подію не знайдено." unless @events.key?(name)

    data = collect_event_data(@events[name])
    @events[name] = data
    puts "Подію оновлено!"
  end

  def delete_event
    print "Назва події для видалення: "
    name = gets.chomp
    if @events.delete(name)
      puts "Подію видалено!"
    else
      puts "Подію не знайдено."
    end
  end

  def search_event
    print "Введіть ключове слово: "
    keyword = gets.chomp.downcase
    results = @events.select do |name, data|
      name.downcase.include?(keyword) ||
      data[:description].to_s.downcase.include?(keyword) ||
      data[:participants].any? { |p| p.downcase.include?(keyword) } ||
      data[:locations].any? { |l| l.downcase.include?(keyword) }
    end

    if results.any?
      puts "--- Результати пошуку ---"
      results.each { |name, data| display_event(name, data) }
    else
      puts "Нічого не знайдено."
    end
  end

  def list_events
    if @events.empty?
      puts "Список подій порожній."
    else
      puts "--- Всі події ---"
      @events.each { |name, data| display_event(name, data) }
    end
  end

  def save_to_file
    print "Ім'я файлу (без розширення): "
    filename = gets.chomp
    print "Формат (json/yaml): "
    format = gets.chomp.downcase

    case format
    when "json"
      File.write("#{filename}.json", JSON.pretty_generate(@events))
      puts "Збережено у #{filename}.json"
    when "yaml"
      File.write("#{filename}.yaml", @events.to_yaml)
      puts "Збережено у #{filename}.yaml"
    else
      puts "Невідомий формат."
    end
  end

  def load_from_file
    print "Ім'я файлу (з розширенням): "
    filename = gets.chomp
    unless File.exist?(filename)
      puts "Файл не знайдено."
      return
    end

    begin
      case File.extname(filename)
      when ".json"
        @events = JSON.parse(File.read(filename), symbolize_names: true)
      when ".yaml", ".yml"
        @events = YAML.load_file(filename)
      else
        puts "Невідомий формат файлу."
        return
      end
      puts "Файл успішно завантажено."
    rescue => e
      puts "Помилка при завантаженні: #{e.message}"
    end
  end

  def collect_event_data(existing_data = {})
    print "Дата (напр. 2025-07-01) [#{existing_data[:date]}]: "
    date = gets.chomp
    date = existing_data[:date] if date.empty?

    print "Учасники (через кому) [#{existing_data[:participants]&.join(', ')}]: "
    participants_input = gets.chomp
    participants = participants_input.empty? ? existing_data[:participants] : participants_input.split(",").map(&:strip)

    print "Місця проведення (через кому) [#{existing_data[:locations]&.join(', ')}]: "
    locations_input = gets.chomp
    locations = locations_input.empty? ? existing_data[:locations] : locations_input.split(",").map(&:strip)

    print "Опис події [#{existing_data[:description]}]: "
    description = gets.chomp
    description = existing_data[:description] if description.empty?

    {
      date: date,
      participants: participants,
      locations: locations,
      description: description
    }
  end

  def display_event(name, data)
    puts "\nНазва: #{name}"
    puts "Дата: #{data[:date]}"
    puts "Учасники: #{data[:participants].join(', ')}"
    puts "Місця: #{data[:locations].join(', ')}"
    puts "Опис: #{data[:description]}"
  end
end

# Запуск програми
organizer = EventOrganizer.new
organizer.run
