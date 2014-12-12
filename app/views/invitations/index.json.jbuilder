json.array!(@invitations) do |invitation|
  json.extract! invitation, :id, :invitee_email, :invitee_name, :invitation_sent_at, :status, :users_id
  json.url invitation_url(invitation, format: :json)
end
