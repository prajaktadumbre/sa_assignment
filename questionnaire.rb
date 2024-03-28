require "pstore"

STORE_NAME = "tendable.pstore"
@store = PStore.new(STORE_NAME)

QUESTIONS = {
  "q1" => "Can you code in Ruby?",
  "q2" => "Can you code in JavaScript?",
  "q3" => "Can you code in Swift?",
  "q4" => "Can you code in Java?",
  "q5" => "Can you code in C#?"
}.freeze

# TODO: FULLY IMPLEMENT
def do_prompt
  answers = {}
  # Ask each question and get an answer from the user's input.
  QUESTIONS.each do |question_key, question|
    print "#{question} (Yes/No): "
    ans = gets.chomp.downcase
    until ["yes", "no", "y", "n"].include?(ans)
      print "Please answer Yes or No: "
      ans = gets.chomp.downcase
    end
    answers[question_key] = ans
  end
  @store.transaction do
    @store[:answers] = answers
  end
  answers
end

def calculate_rating(answers)
  yes_count = answers.count { |_key, value| ["yes", "y"].include?(value) }
  total_questions = QUESTIONS.size
  (yes_count.to_f / total_questions) * 100
end

def do_report
  answers = @store.transaction { @store[:answers] }
  rating = calculate_rating(answers)
  puts "Rating for this run: #{rating.round(2)}%"
  
  total_runs = @store.transaction { @store.roots.size }
  total_rating = @store.transaction { @store.roots.map { |key| calculate_rating(@store[key]) }.sum }
  average_rating = total_rating / total_runs
  puts "Average rating for all runs: #{average_rating.round(2)}%"
end

loop do
  do_prompt
  do_report
  print "Do you want to run the survey again? (Yes/No): "
  run_again = gets.chomp.downcase
  break unless ["yes", "y"].include?(run_again)
end