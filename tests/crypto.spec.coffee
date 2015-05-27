chai = require('chai')
expect = chai.expect
crypto = require('../lib/crypto')

describe 'Crypto:', ->

	describe '.generateUUID()', ->

		it 'should return a string', ->
			uuid = crypto.generateUUID()
			expect(uuid).to.be.a('string')

		it 'should have a length of 62 (31 bytes)', ->
			uuid = crypto.generateUUID()
			expect(uuid).to.have.length(62)

		it 'should generate different uuids each time', ->
			uuid1 = crypto.generateUUID()
			uuid2 = crypto.generateUUID()
			uuid3 = crypto.generateUUID()

			expect(uuid1).to.not.equal(uuid2)
			expect(uuid2).to.not.equal(uuid3)
			expect(uuid3).to.not.equal(uuid1)
