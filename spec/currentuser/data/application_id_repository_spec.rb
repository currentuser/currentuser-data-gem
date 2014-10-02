require 'helper'

module Currentuser
  module Data

    describe ApplicationIdRepository do

      before do
        ApplicationIdRepository.class.instance_variable_get(:@application_id).must_be_nil
        RequestStore.exist?('currentuser-data-application_id').must_equal false
      end

      after do
        ApplicationIdRepository.class.instance_variable_set(:@application_id, nil)
        RequestStore.delete('currentuser-data-application_id')
      end

      describe '#request_store_available?' do
        it 'is true during gem tests' do
          ApplicationIdRepository.send(:request_store_available?).must_equal true
        end
      end

      describe '#ensure_request_store_available!' do
        it 'raises if RequestStore is not available' do
          ApplicationIdRepository.stub :request_store_available?, false do
            -> {ApplicationIdRepository.send(:ensure_request_store_available!)}
              .must_raise RuntimeError
          end
        end
        it 'does not raise if RequestStore is available' do
          ApplicationIdRepository.send(:request_store_available?).must_equal true
          ApplicationIdRepository.send(:ensure_request_store_available!)
        end
      end

      describe '#remove_application_id_for_request' do
        it 'removes value from request store' do
          RequestStore.store['currentuser-data-application_id'] = 'my_application_id'
          RequestStore.exist?('currentuser-data-application_id').must_equal true
          ApplicationIdRepository.send(:remove_application_id_for_request)
          RequestStore.exist?('currentuser-data-application_id').must_equal false
        end
      end

      describe '#reset_application_id_for_request' do
        it 'set value to nil' do
          RequestStore.exist?('currentuser-data-application_id').must_equal false
          ApplicationIdRepository.send(:reset_application_id_for_request)
          RequestStore.exist?('currentuser-data-application_id').must_equal true
          RequestStore.store['currentuser-data-application_id'].must_be_nil
        end
      end

      describe '#set_application_id_for_request' do
        it 'stores in request store' do
          ApplicationIdRepository.send(:set_application_id_for_request, 'my_application_id')
          RequestStore.store['currentuser-data-application_id'].must_equal 'my_application_id'
        end
      end

      describe '#request_safe?' do
        it 'returns true if value is set (even to nil)' do
          ApplicationIdRepository.send(:request_safe?).must_equal false
          RequestStore.store['currentuser-data-application_id'] = nil
          ApplicationIdRepository.send(:request_safe?).must_equal true
          RequestStore.store['currentuser-data-application_id'] = 'my_application_id'
          ApplicationIdRepository.send(:request_safe?).must_equal true
        end
        it 'returns false if request store not available' do
          ApplicationIdRepository.stub :request_store_available?, false do
            ApplicationIdRepository.send(:request_safe?).must_equal false
          end
        end
      end

      describe '#resolve_application_id' do
        it 'returns request store content if set' do
          ApplicationIdRepository.with_application_id 'my_application_id' do
            ApplicationIdRepository.application_id = 'other_application_id'
            ApplicationIdRepository.send(:resolve_application_id).must_equal 'my_application_id'
          end
        end
        it 'returns class value if no content in request store' do
          ApplicationIdRepository.application_id = 'other_application_id'
          ApplicationIdRepository.send(:resolve_application_id).must_equal 'other_application_id'
        end
      end

      describe '#with_application_id' do
        it 'sets and removes application id' do
          ApplicationIdRepository.send(:remove_application_id_for_request)
          ApplicationIdRepository.with_application_id('my_application_id') do
            RequestStore.store['currentuser-data-application_id'].must_equal 'my_application_id'
          end
          RequestStore.exist?('currentuser-data-application_id').must_equal false
        end
        it 'sets and resets application id' do
          ApplicationIdRepository.send(:reset_application_id_for_request)
          ApplicationIdRepository.with_application_id('my_application_id') do
            RequestStore.store['currentuser-data-application_id'].must_equal 'my_application_id'
          end
          RequestStore.store['currentuser-data-application_id'].must_be_nil
        end
        it 'resets application id even if exception' do
          begin
            ApplicationIdRepository.with_application_id('my_application_id') do
              RequestStore.store['currentuser-data-application_id'].must_equal 'my_application_id'
              raise
            end
          rescue StandardError
            RequestStore.exist?('currentuser-data-application_id').must_equal false
          end
        end
        it 'returns the result of the block' do
          result = ApplicationIdRepository.with_application_id('my_application_id') do
            next 'my result'
          end
          result.must_equal 'my result'
        end
      end

      describe '#request_safe!' do
        it 'raises if request store not available' do
          ApplicationIdRepository.stub :request_store_available?, false do
            -> {ApplicationIdRepository.request_safe! {}}
            .must_raise RuntimeError
          end
        end
        it 'yields with nil value' do
          RequestStore.exist?('currentuser-data-application_id').must_equal false
          ApplicationIdRepository.request_safe! do
            RequestStore.exist?('currentuser-data-application_id').must_equal true
            RequestStore.store['currentuser-data-application_id'].must_be_nil
          end
          RequestStore.exist?('currentuser-data-application_id').must_equal false
        end
        it 'removes value even if exception' do
          begin
            ApplicationIdRepository.request_safe! do
              RequestStore.exist?('currentuser-data-application_id').must_equal true
              raise
            end
          rescue StandardError
            RequestStore.exist?('currentuser-data-application_id').must_equal false
          end
        end
        # Integration test
        it 'force #with_application_id to use request store' do
          ApplicationIdRepository.application_id = 'other_application_id'
          ApplicationIdRepository.resolve_application_id.must_equal 'other_application_id'

          ApplicationIdRepository.request_safe! do
            ApplicationIdRepository.resolve_application_id.must_be_nil
            ApplicationIdRepository.with_application_id 'application_id' do
              ApplicationIdRepository.resolve_application_id.must_equal 'application_id'
            end
            ApplicationIdRepository.resolve_application_id.must_be_nil
          end

          ApplicationIdRepository.resolve_application_id.must_equal 'other_application_id'
        end
      end
    end
  end
end
