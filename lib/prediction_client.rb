require 'mongo'
include Mongo

class PredictionClient
	def initialize
		@db = MongoClient.new.db('test')
	end

	# add a document to the 'scheduled' collection in the db indicating the appointment id to predict and the time the prediction was requested
	def schedule_prediction(appointment_id)
	end

	# return a hash containing keys :prediction => 0/1, :probability => float, :date => Date of prediction creation
	# or signal an error if no prediction is available
	def get_prediction(appointment_id)
	end
end