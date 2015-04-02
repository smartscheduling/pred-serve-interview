require 'mongo'
include Mongo

class PredictionClient
	def initialize
		@db = MongoClient.new.db('test')
	end

	# add a document to the 'scheduled' collection in the db indicating the appointment id to predict and the time the prediction was requested
	def schedule_prediction(appointment_id)
		@db['scheduled'].insert({'appointment_id' => appointment_id, 'date' => Time.now.utc})
	end

	# return a hash containing keys :prediction => 0/1, :probability => float, :date => Date of prediction creation
	# or signal an error if no prediction is available
	def get_prediction(appointment_id)
		@db['predictions'].find_one({'appointment_id' => appointment_id}, sort: {date: :desc})
	end
end