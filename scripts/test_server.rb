require 'byebug'
require 'rest_client'
require 'json'

require 'mongo'
include Mongo

require_relative '../lib/appointment_client'

def request_prediction(practice_ext_id, appointment_ext_id)
	JSON.parse(RestClient.get "localhost:4567/practices/#{practice_ext_id}/appointments/#{appointment_ext_id}/prediction")
end
	
def test_prediction_matches_response(practice_ext_id, appointment_ext_id)
	appointment_client = AppointmentClient.new
	db = MongoClient.new.db('test')

	apt = appointment_client.get_appointment(practice_ext_id, appointment_ext_id)
	pred = db['predictions'].find_one({'appointment_id' => apt['_id']}, sort: {date: :desc})

	begin
		resp = request_prediction(practice_ext_id, appointment_ext_id)
		if Time.parse(resp['date']).to_i == pred['date'].to_i && resp['probability'] == pred['probability']
			puts "PASSED"
		else
			puts "FAILED: returned data was in correct format but incorrect values"
		end
	rescue
		puts "FAILED: received unexpected response from server"
	end
end

puts "testing basic prediction requests"
test_prediction_matches_response(1,300)
test_prediction_matches_response(2,500)
test_prediction_matches_response(4,600)

puts "testing for appointments with more than one prediction"
test_prediction_matches_response(1,100)
test_prediction_matches_response(3,150)


def test_prediction_is_scheduled(practice_ext_id, appointment_ext_id)
	appointment_client = AppointmentClient.new
	db = MongoClient.new.db('test')

	apt = appointment_client.get_appointment(practice_ext_id, appointment_ext_id)
	
	begin
		scheduled_len = db['scheduled'].find({'appointment_id' => apt['_id']}).to_a.size
		resp = request_prediction(practice_ext_id, appointment_ext_id)
		if not resp['error']
			puts 'FAILED: no error was returned for an appointment without a prediction'
		end

		new_scheduled_len = db['scheduled'].find({'appointment_id' => apt['_id']}).to_a.size

		if new_scheduled_len <= scheduled_len
			puts 'FAILED: new prediction was not scheduled'
		end

		puts 'PASSED'
	rescue
		puts 'FAILED: received unexpected response from server'
	end
end

puts "testing for appointments without predictions"
test_prediction_is_scheduled(1, 800)
test_prediction_is_scheduled(1, 900)

def test_appointment_invalid(practice_ext_id, appointment_ext_id)
	begin
		resp = request_prediction(practice_ext_id, appointment_ext_id)
		if resp['error']
			puts 'PASSED'
		else
			puts 'FAILED: no error was returned for an invalid appointment'
		end
	rescue
		puts "FAILED: received unexpected response from server"
	end
end

puts "testing for invalid appointments"
test_appointment_invalid(3, 2000)
test_appointment_invalid(8, 200)