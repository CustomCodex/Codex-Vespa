Config = {}

-- Rental configuration
Config.RentalPrice = 500  -- Set rental price here
Config.RentalDuration = 600000  -- 10 minutes in milliseconds
Config.VehicleName = 'tmax'  -- Vespa model name

-- Rental marker coordinates
Config.RentalMarker = {
    x = -516.22662353516,
    y = -254.39208984375,
    z = 35.632659912109
}

-- Locales configuration
Config.Locales = {
    en = {
        rental_blip_name = "Vespa Rental Service",
        rent_vehicle = "Press ~INPUT_CONTEXT~ to rent a Vespa",
        rental_time_left_message = "Rental Time Left: %d seconds",
        thank_you_message = "Thank you for renting a Vespa! Enjoy your ride.",
        get_back_on_message = "Please get back on the Vespa or it will be removed in 10 seconds.",
        rental_expired = "Your rental time has expired. The Vespa has been removed."
    },
    nl = {
        rental_blip_name = "Vespa Verhuur Service",
        rent_vehicle = "Druk ~INPUT_CONTEXT~ om een Vespa te huren",
        rental_time_left_message = "Huur Tijd Over: %d seconden",
        thank_you_message = "Bedankt voor het huren van een Vespa! Geniet van je rit.",
        get_back_on_message = "Kom alstublieft terug op de Vespa of deze zal na 10 seconden worden verwijderd.",
        rental_expired = "Je huurperiode is verlopen. De Vespa is verwijderd."
    }
}

-- Set default locale
Config.Locale = 'en'  -- Change to 'nl' for Dutch
