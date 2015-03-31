require 'mongo'
include Mongo

def setup_db_indexes
	db = MongoClient.new.db('test')
	db['appointments'].ensure_index({practice_external_id: 1, appointment_external_id: 1}, {unique: true})
end

def generate_test_data
	db = MongoClient.new.db('test')
	[1,2,3,4,5].each do |practice_ext_id|
		(0...1000).each do |appointment_ext_id|
			db['appointments'].insert({
				'practice_external_id' => practice_ext_id,
				'appointment_external_id' => appointment_ext_id
			})

			if appointment_ext_id < 700
				apt = db['appointments'].find_one({
					'practice_external_id' => practice_ext_id,
					'appointment_external_id' => appointment_ext_id
				})

				prob = rand()
				prediction = prob > 0.5
				date = Time.now.utc
				db['predictions'].insert({
					'appointment_id' => apt['_id'],
					'prediction' => prediction,
					'probability' => prob,
					'date' => date
				})
			end
		end
	end
end

setup_db_indexes
generate_test_data