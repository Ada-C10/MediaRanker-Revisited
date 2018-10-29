require 'csv'
media_file = Rails.root.join('db', 'media_seeds.csv')

User.create(provider: "github", uid: 99999, username: "seed_user", name: "Seed Person")

CSV.foreach(media_file, headers: true, header_converters: :symbol, converters: :all) do |row|
  data = Hash[row.headers.zip(row.fields)]
  puts data
  Work.create!(data)
end
