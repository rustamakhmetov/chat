# Whitelist locales available for the application
I18n.available_locales = [:en, :ru]

# Set default locale to something other than :en
I18n.default_locale = :en

I18n::Backend::Simple.include(I18n::Backend::Pluralization)
I18n.backend.store_translations :ru, i18n: { plural: { rule: lambda { |n| [0, 1].include?(n) ? :one : :other } } }