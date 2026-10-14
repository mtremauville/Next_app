module LegalHelper
  PUBLISHER = {
    name: "MICKAEL TREMAUVILLE",
    contact: "mickael.tremauville@gmail.com",
    host: "Hostinger",
    log_retention: "14 jours"
  }.freeze

  UPDATED_ON = Date.new(2026, 10, 14)

  def legal_publisher = PUBLISHER

  def legal_updated_on = UPDATED_ON.strftime("%d/%m/%Y")
end
