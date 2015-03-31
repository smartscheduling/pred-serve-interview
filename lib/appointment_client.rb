require 'mongo'
include Mongo

class AppointmentClient
	def initialize
		@db = MongoClient.new.db('test')
	end

	def get_appointment(practice_ext_id, appointment_ext_id)
		return @db['appointments'].find_one({
			'practice_external_id' => practice_ext_id,
			'appointment_external_id' => appointment_ext_id
		})
	end
end