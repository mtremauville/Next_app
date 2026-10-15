module LegalHelper
  PUBLISHER = {
    name: "MICKAEL TREMAUVILLE",
    contact: "mickael.tremauville@gmail.com",
    host: "Hostinger",
    log_retention_days: 14
  }.freeze

  UPDATED_ON = Date.new(2026, 10, 15)

    def legal_publisher = PUBLISHER

    def legal_updated_on = l(UPDATED_ON, format: :legal_date)

    def legal_log_retention = t("legal.days", count: PUBLISHER[:log_retention_days])
end
