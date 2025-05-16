require 'json'
require 'yaml'

# Клас окремої події
class Event
  attr_accessor :name, :date, :participants, :locations, :description

  def initialize(name:, date:, participants:, locations:, description:)
    @name = name
    @date = date
    @participants = participants
    @locations = locations
    @description = description
  end

  def to_h
    {
      date: @date,
      participants: @participants,
      locations: @locations,
      description: @description
    }
  end

  def self.from_h(name, hash)
    Event.new(
      name: name,
      date: hash[:date] || hash["date"],
      participants: hash[:participants] || hash["participants"],
      locations: hash[:locations] || hash["locations"],
      description: hash[:description] || hash["description"]
    )
  end

  def matches?(keyword)
    keyword = keyword.downcase
    @name.downcase.include?(keyword) ||
      @description.downcase.include?(keyword) ||
      @participants.any? { |p| p.downcase.include?(keyword) } ||
      @locations.any? { |l| l.downcase.include?(keyword) }
  end

  def display
    puts "\nНазва: #{@name}"
    puts "Дата: #{@date}"
    puts "Учасники: #{@participants.join(', ')}"
    puts "Місця: #{@locations.join(', ')}"
    puts "Опис: #{@description}"
  end
end

# Клас колекції подій
class EventManager
  def initialize
    @events = {}
  end

  def add(event)
    return false if @events.key?(event.name)
    @events[event.name] = event
    true
  end

  def edit(name, new_event)
    return false unless @events.key?(name)
    @events[name] = new_event
    true
  end

  def delete(name)
    !!@events.delete(name)
  end

  def search(keyword)
    @events.values.select { |event| event.matches?(keyword) }
  end

  def all
    @events.values
  end

  def save(filename, format)
    data = @events.transform_values(&:to_h)
    case format
    when "json"
      File.write("#{filename}.json", JSON.pretty_generate(data))
    when "yaml"
      File.write("#{filename}.yaml", data.to_yaml)
    else
      raise "Невідомий формат: #{format}"
    end
  end

  def load(filename)
    data = case File.extname(filename)
           when ".json"
             JSON.parse(File.read(filename))
           when ".yaml", ".yml"
             YAML.load_file(filename)
           else
             raise "Невідомий формат файлу."
           end

    @events = data.map { |name, info| [name, Event.from_h(name, info)] }.to_h
  end

  def find(name)
    @events[name]
  end
end

# Клас консольної взаємодії
class ConsoleApp
  def initialize
    @manager = EventManager.new
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
      puts "7. Завантажити з файлу"
      puts "0. Вихід"
      print "Ваш вибір: "
      case gets.chomp
      when "1" then add_event
      when "2" then edit_event
      when "3" then delete_event
      when "4" then search_event
      when "5" then list_events
      when "6" then save_events
      when "7" then load_events
      when "0" then break
      else puts "Невідомий вибір."
      end
    end
  end

  private

  def prompt_event_data(name = nil, existing_event = nil)
    name ||= ask("Назва події")

    print "Дата [#{existing_event&.date}]: "
    date = gets.chomp
    date = existing_event&.date if date.empty?

    print "Учасники (через кому) [#{existing_event&.participants&.join(', ')}]: "
    participants_input = gets.chomp
    participants = if participants_input.empty?
                     existing_event&.participants || []
                   else
                     participants_input.split(',').map(&:strip)
                   end

    print "Місця (через кому) [#{existing_event&.locations&.join(', ')}]: "
    locations_input = gets.chomp
    locations = if locations_input.empty?
                  existing_event&.locations || []
                else
                  locations_input.split(',').map(&:strip)
                end

    print "Опис [#{existing_event&.description}]: "
    description = gets.chomp
    description = existing_event&.description if description.empty?

    Event.new(
      name: name,
      date: date,
      participants: participants,
      locations: locations,
      description: description
    )
  end

  def ask(prompt)
    print "#{prompt}: "
    gets.chomp
  end

  def add_event
    name = ask("Назва події")
    if @manager.add(prompt_event_data(name))
      puts "Подія додана."
    else
      puts "Подія з такою назвою вже існує."
    end
  end

  def edit_event
    name = ask("Назва події для редагування")
    existing = @manager.find(name)
    if existing
      updated = prompt_event_data(name, existing)
      @manager.edit(name, updated)
      puts "Подію оновлено."
    else
      puts "Подія не знайдена."
    end
  end

  def delete_event
    name = ask("Назва події для видалення")
    if @manager.delete(name)
      puts "Подію видалено."
    else
      puts "Подія не знайдена."
    end
  end

  def search_event
    keyword = ask("Ключове слово")
    results = @manager.search(keyword)
    if results.any?
      results.each(&:display)
    else
      puts "Нічого не знайдено."
    end
  end

  def list_events
    events = @manager.all
    if events.empty?
      puts "Список подій порожній."
    else
      events.each(&:display)
    end
  end

  def save_events
    filename = ask("Ім'я файлу (без розширення)")
    format = ask("Формат (json/yaml)").downcase
    begin
      @manager.save(filename, format)
      puts "Файл збережено."
    rescue => e
      puts "Помилка: #{e.message}"
    end
  end

  def load_events
    filename = ask("Ім'я файлу (з розширенням)")
    begin
      @manager.load(filename)
      puts "Файл завантажено."
    rescue => e
      puts "Помилка: #{e.message}"
    end
  end
end

# Запуск програми
ConsoleApp.new.run
