require 'sinatra'

# handle get request for prediction about a particular appointment
# if the prediction is available, return a json object of the form {'prediction': 1/0, 'probability': float, 'date': ISO 8610 format}
# if the prediction is not available but can be scheduled, schedule it and respond with an error and a message indicating that it has been scheduled
# if there is some other error, respond with an error and indicate such.
get 'prediction/practices/:practice_external_id/appointment_id/:appointment_external_id' do |practice_ext_id, appointment_ext_id|
	
end