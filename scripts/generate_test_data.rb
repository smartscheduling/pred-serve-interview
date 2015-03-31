require 'date'

def setup_db_indexes
	db = MongoClient.new.db('test')
	db['appointments'].ensure_index({practice_external_id: 1, appointment_external_id: 1}, {unique: true})
end

def generate_test_data
	db = MongoClient.new.db('test')
	[1,2,3,4,5].each do |practice_ext_id|
		[0...1000].to_a.each do |appointment_ext_id|
			apt = db['appointments'].find_and_modify(
				query: {
					'practice_external_id' => practice_ext_id,
					'appointment_external_id' => appointment_ext_id
				},
				upsert: true,
				:new => true
			)

			if appointment_ext_id < 700
				prob = rand()
				prediction = prob > 0.5
				date = Date.today
				db['predictions'].insert({
					'appointment_id' => apt['_id'],
					'prediction' => prediction,
					'probability' => prob,
					'date' => date
				})
		end
	end
end