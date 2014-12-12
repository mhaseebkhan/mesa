json.array!(@missions) do |mission|
  json.extract! mission, :id, :title, :brief, :shared_motivation, :build_intent, :from_date, :to_date, :time, :place, :status, :is_authorized
  json.url mission_url(mission, format: :json)
end
