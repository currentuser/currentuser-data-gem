require 'helper'

module Currentuser
  module Data

    describe ApplicationIdRepository do

      before do
        ApplicationIdRepository.class.instance_variable_get(:@application_id).must_be_nil
        RequestStore.store['currentuser-data-application_id'].must_be_nil
      end

      after do
        ApplicationIdRepository.class.instance_variable_set(:@application_id, nil)
        RequestStore.store['currentuser-data-application_id'] = nil
      end

      describe '#request_store_available?' do
        it 'is true during gem tests' do
          ApplicationIdRepository.send(:request_store_available?).must_equal true
        end
      end

      describe '#set_application_id_for_request' do
        it 'raises if RequestStore is not available' do
          ApplicationIdRepository.stub :request_store_available?, false do
            -> {ApplicationIdRepository.set_application_id_for_request 'my_application_id'}
              .must_raise RuntimeError
          end
        end
        it 'stores in request store (if available)' do
          ApplicationIdRepository.set_application_id_for_request 'my_application_id'
          RequestStore.store['currentuser-data-application_id'].must_equal 'my_application_id'
        end
      end

      describe '#get_application_id_for_request' do
        it 'returns nil if RequestStore is not available' do
          ApplicationIdRepository.set_application_id_for_request 'my_application_id'
          ApplicationIdRepository.stub :request_store_available?, false do
            ApplicationIdRepository.send(:get_application_id_for_request).must_be_nil
          end
        end
        it 'returns stored application id (if RequestStore available)' do
          ApplicationIdRepository.set_application_id_for_request 'my_application_id'
          ApplicationIdRepository.send(:get_application_id_for_request).must_equal 'my_application_id'
        end
      end

      describe '#resolve_application_id' do
        it 'returns request store content if set' do
          ApplicationIdRepository.set_application_id_for_request 'my_application_id'
          ApplicationIdRepository.application_id = 'other_application_id'
          ApplicationIdRepository.send(:resolve_application_id).must_equal 'my_application_id'
        end
        it 'returns class value if no content in request store' do
          ApplicationIdRepository.application_id = 'other_application_id'
          ApplicationIdRepository.send(:resolve_application_id).must_equal 'other_application_id'
        end
      end

    end
  end
end
