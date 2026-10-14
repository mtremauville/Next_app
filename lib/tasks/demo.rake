namespace :demo do
  desc "Reset the shared guest account to its sample data"
  task reset: :environment do
    guest = User.guest
    Demo::Reset.new(guest).call
    puts "Compte de démonstration réinitialisé : #{guest.entries.count} titres, #{guest.playlists.count} playlists."
  end
end
