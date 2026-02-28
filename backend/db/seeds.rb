require "faker"

puts "🌱 Seeding database..."

# ---------------------------------------------------------------------------
# Demo user
# ---------------------------------------------------------------------------
puts "\n→ Creating demo user..."

demo_user = User.find_or_create_by!(email: "demo@theflock.com") do |user|
  user.username     = "demo_flock"
  user.display_name = "Demo User"
  user.password     = "demo1234"
  user.bio          = "This is the demo account for The Flock. Welcome!"
  user.avatar_url   = "https://api.dicebear.com/7.x/identicon/svg?seed=demo_flock"
end

puts "  ✓ #{demo_user.username} (#{demo_user.email})"

# ---------------------------------------------------------------------------
# Regular users
# ---------------------------------------------------------------------------
puts "\n→ Creating 10 users..."

SEED_USERS = [
  { username: "alice_codes",   display_name: "Alice Nakamura",   bio: "Ruby dev by day, baker by night. 🍞" },
  { username: "brentonius",    display_name: "Brent Okafor",     bio: "Probably thinking about databases right now." },
  { username: "cleo_writes",   display_name: "Cleo Martínez",    bio: "Words, coffee, and the occasional bug fix." },
  { username: "dan_the_dev",   display_name: "Daniel Osei",      bio: "Full-stack engineer. I ship things." },
  { username: "emi_builds",    display_name: "Emiko Tanaka",     bio: "Frontend forever. CSS is my cardio." },
  { username: "ferris_codes",  display_name: "Ferris Huang",     bio: "Backend purist. REST or die." },
  { username: "greta_rx",      display_name: "Greta Andersen",   bio: "Rails, React, running. In that order." },
  { username: "hector_dev",    display_name: "Héctor Romero",    bio: "Open source contributor. DMs open." },
  { username: "ines_io",       display_name: "Inès Dupont",      bio: "TypeScript nerd. Strict mode only." },
  { username: "juan_backend",  display_name: "Juan Villarreal",  bio: "PostgreSQL whisperer. Indexing everything." },
].freeze

regular_users = SEED_USERS.map do |attrs|
  user = User.find_or_create_by!(email: "#{attrs[:username]}@theflock.com") do |u|
    u.username     = attrs[:username]
    u.display_name = attrs[:display_name]
    u.password     = "Password1!"
    u.bio          = attrs[:bio]
    u.avatar_url   = "https://api.dicebear.com/7.x/identicon/svg?seed=#{attrs[:username]}"
  end
  puts "  ✓ #{user.username}"
  user
end

all_users = [demo_user] + regular_users

# ---------------------------------------------------------------------------
# Tweets
# ---------------------------------------------------------------------------
puts "\n→ Creating tweets (5–15 per user)..."

TWEET_TEMPLATES = [
  "Just shipped a feature that took way too long. Worth it. 🚀",
  "Hot take: %{lang} is actually great once you stop fighting it.",
  "Debugging this for 3 hours. The bug was a missing semicolon.",
  "Finally refactored that service object. Future me will be grateful.",
  "Code review culture matters more than the tech stack.",
  "Pair programming is underrated. Change my mind.",
  "That moment when the tests pass on the first try. Rare but beautiful.",
  "Reminder: naming things is still the hardest problem in CS.",
  "Today I learned something obvious that I should have known 2 years ago.",
  "My git history is a crime scene. Please don't look.",
  "Wrote more tests today than code. This is the way.",
  "The best code is the code you don't have to write.",
  "Just discovered a gem that does exactly what I built last week.",
  "N+1 queries are the silent killer of Rails apps. Profile everything.",
  "Working on something exciting. Can't say what yet. 👀",
  "PostgreSQL full-text search > Elasticsearch for 90% of use cases.",
  "Just remembered I never removed those debug puts statements. Deploying anyway.",
  "The docs lied. Stack Overflow saved me. Classic.",
  "Coffee → code → repeat. This is the loop I live in.",
  "Typed the same variable name wrong three times in a row. I'm fine.",
].freeze

LANGUAGES = %w[Ruby Rails TypeScript React PostgreSQL Elixir Go Rust].freeze

all_users.each do |user|
  if user.tweets.exists?
    puts "  · #{user.username} — skipped (already has #{user.tweets.count} tweets)"
    next
  end

  tweet_count = rand(5..15)
  tweet_count.times do
    content = TWEET_TEMPLATES.sample.gsub("%{lang}", LANGUAGES.sample)
    Tweet.create!(user: user, content: content)
  end
  puts "  ✓ #{user.username} — #{tweet_count} tweets"
end

# ---------------------------------------------------------------------------
# Follows: each user follows 3–6 others, no self-follows
# ---------------------------------------------------------------------------
puts "\n→ Creating follow relationships..."

all_users.each do |follower|
  if follower.active_follows.exists?
    puts "  · #{follower.username} — skipped (already following #{follower.following.count})"
    next
  end

  candidates = all_users.reject { |u| u.id == follower.id }
  targets    = candidates.sample(rand(3..6))

  targets.each { |followed| Follow.create!(follower: follower, followed: followed) }

  puts "  ✓ #{follower.username} follows #{targets.map(&:username).join(', ')}"
end

# ---------------------------------------------------------------------------
# Demo user guaranteed followers: at least 5
# ---------------------------------------------------------------------------
puts "\n→ Ensuring demo user has at least 5 followers..."

current_follower_count = demo_user.followers.count
needed                 = [0, 5 - current_follower_count].max

if needed > 0
  candidates = regular_users.reject { |u| u.following?(demo_user) }
  candidates.first(needed).each do |user|
    Follow.find_or_create_by!(follower: user, followed: demo_user)
  end
end

puts "  ✓ demo_flock has #{demo_user.reload.followers.count} followers"

# ---------------------------------------------------------------------------
# Likes: 0–8 likes per tweet
# ---------------------------------------------------------------------------
puts "\n→ Creating likes..."

total_likes = 0

if Like.exists?
  puts "  · skipped (likes already seeded)"
else
  Tweet.find_each do |tweet|
    likers = all_users.reject { |u| u.id == tweet.user_id }.sample(rand(0..8))
    likers.each do |liker|
      Like.create!(user: liker, tweet: tweet)
      total_likes += 1
    end
  end
end

puts "  ✓ #{total_likes} likes distributed across #{Tweet.count} tweets"

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
puts "\n✅ Seed complete!"
puts "   Users:   #{User.count}"
puts "   Tweets:  #{Tweet.count}"
puts "   Follows: #{Follow.count}"
puts "   Likes:   #{Like.count}"
puts "\n   Demo login → email: demo@theflock.com / password: demo1234"
