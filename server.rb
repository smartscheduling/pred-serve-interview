require 'sinatra'
require 'byebug'
require 'json'

require_relative './lib/appointment_client'
require_relative './lib/prediction_client'

appointment_client = AppointmentClient.new
prediction_client = PredictionClient.new

# handle get request for prediction about a particular appointment
# if the prediction is available, return a json object of the form {'prediction': 1/0, 'probability': float, 'date': ISO 8610 format}
# if the prediction is not available but can be scheduled, schedule it and respond with an error and a message indicating that it has been scheduled
# if there is some other error, respond with an error and indicate such.
get '/practices/:practice_external_id/appointments/:appointment_external_id/prediction' do |practice_ext_id, appointment_ext_id|
	content_type :json
	
	practice_ext_id = practice_ext_id.to_i
	appointment_ext_id = appointment_ext_id.to_i
	apt = appointment_client.get_appointment(practice_ext_id, appointment_ext_id)

	if apt == nil
		return { 'error' => { 'title' => 'Appointment not found' } }.to_json
	end

	pred = prediction_client.get_prediction(apt['_id'])

	if pred == nil
		prediction_client.schedule_prediction(apt['_id'])
		return { 'error' => {'title' => 'Prediction scheduled' } }.to_json
	end
	
	{
		prediction: pred['prediction'],
		probability: pred['probability'],
		date: pred['date']
	}.to_json
end