require 'helper'

module Currentuser
  module Data

    describe ProjectIdRepository do

      before do
        ProjectIdRepository.class.instance_variable_get(:@project_id).must_be_nil
        RequestStore.exist?('currentuser-data-project_id').must_equal false
      end

      after do
        ProjectIdRepository.class.instance_variable_set(:@project_id, nil)
        RequestStore.delete('currentuser-data-project_id')
      end

      describe '#request_store_available?' do
        it 'is true during gem tests' do
          ProjectIdRepository.send(:request_store_available?).must_equal true
        end
      end

      describe '#ensure_request_store_available!' do
        it 'raises if RequestStore is not available' do
          ProjectIdRepository.stub :request_store_available?, false do
            -> {ProjectIdRepository.send(:ensure_request_store_available!)}
              .must_raise RuntimeError
          end
        end
        it 'does not raise if RequestStore is available' do
          ProjectIdRepository.send(:request_store_available?).must_equal true
          ProjectIdRepository.send(:ensure_request_store_available!)
        end
      end

      describe '#remove_project_id_for_request' do
        it 'removes value from request store' do
          RequestStore.store['currentuser-data-project_id'] = 'my_project_id'
          RequestStore.exist?('currentuser-data-project_id').must_equal true
          ProjectIdRepository.send(:remove_project_id_for_request)
          RequestStore.exist?('currentuser-data-project_id').must_equal false
        end
      end

      describe '#reset_project_id_for_request' do
        it 'set value to nil' do
          RequestStore.exist?('currentuser-data-project_id').must_equal false
          ProjectIdRepository.send(:reset_project_id_for_request)
          RequestStore.exist?('currentuser-data-project_id').must_equal true
          RequestStore.store['currentuser-data-project_id'].must_be_nil
        end
      end

      describe '#set_project_id_for_request' do
        it 'stores in request store' do
          ProjectIdRepository.send(:set_project_id_for_request, 'my_project_id')
          RequestStore.store['currentuser-data-project_id'].must_equal 'my_project_id'
        end
      end

      describe '#request_safe?' do
        it 'returns true if value is set (even to nil)' do
          ProjectIdRepository.send(:request_safe?).must_equal false
          RequestStore.store['currentuser-data-project_id'] = nil
          ProjectIdRepository.send(:request_safe?).must_equal true
          RequestStore.store['currentuser-data-project_id'] = 'my_project_id'
          ProjectIdRepository.send(:request_safe?).must_equal true
        end
        it 'returns false if request store not available' do
          ProjectIdRepository.stub :request_store_available?, false do
            ProjectIdRepository.send(:request_safe?).must_equal false
          end
        end
      end

      describe '#resolve_project_id' do
        it 'returns request store content if set' do
          ProjectIdRepository.with_project_id 'my_project_id' do
            ProjectIdRepository.project_id = 'other_project_id'
            ProjectIdRepository.send(:resolve_project_id).must_equal 'my_project_id'
          end
        end
        it 'returns class value if no content in request store' do
          ProjectIdRepository.project_id = 'other_project_id'
          ProjectIdRepository.send(:resolve_project_id).must_equal 'other_project_id'
        end
      end

      describe '#with_project_id' do
        it 'sets and removes project id' do
          ProjectIdRepository.send(:remove_project_id_for_request)
          ProjectIdRepository.with_project_id('my_project_id') do
            RequestStore.store['currentuser-data-project_id'].must_equal 'my_project_id'
          end
          RequestStore.exist?('currentuser-data-project_id').must_equal false
        end
        it 'sets and resets project id' do
          ProjectIdRepository.send(:reset_project_id_for_request)
          ProjectIdRepository.with_project_id('my_project_id') do
            RequestStore.store['currentuser-data-project_id'].must_equal 'my_project_id'
          end
          RequestStore.store['currentuser-data-project_id'].must_be_nil
        end
        it 'restore existing project id' do
          ProjectIdRepository.send(:set_project_id_for_request, 'old_project_id')
          ProjectIdRepository.with_project_id('my_project_id') do
            RequestStore.store['currentuser-data-project_id'].must_equal 'my_project_id'
          end
          RequestStore.store['currentuser-data-project_id'].must_equal 'old_project_id'
        end
        it 'resets project id even if exception' do
          begin
            ProjectIdRepository.with_project_id('my_project_id') do
              RequestStore.store['currentuser-data-project_id'].must_equal 'my_project_id'
              raise
            end
          rescue StandardError
            RequestStore.exist?('currentuser-data-project_id').must_equal false
          end
        end
        it 'returns the result of the block' do
          result = ProjectIdRepository.with_project_id('my_project_id') do
            next 'my result'
          end
          result.must_equal 'my result'
        end
      end

      describe '#request_safe!' do
        it 'raises if request store not available' do
          ProjectIdRepository.stub :request_store_available?, false do
            -> {ProjectIdRepository.request_safe! {}}
            .must_raise RuntimeError
          end
        end
        it 'yields with nil value' do
          RequestStore.exist?('currentuser-data-project_id').must_equal false
          ProjectIdRepository.request_safe! do
            RequestStore.exist?('currentuser-data-project_id').must_equal true
            RequestStore.store['currentuser-data-project_id'].must_be_nil
          end
          RequestStore.exist?('currentuser-data-project_id').must_equal false
        end
        it 'removes value even if exception' do
          begin
            ProjectIdRepository.request_safe! do
              RequestStore.exist?('currentuser-data-project_id').must_equal true
              raise
            end
          rescue StandardError
            RequestStore.exist?('currentuser-data-project_id').must_equal false
          end
        end
        # Integration test
        it 'force #with_project_id to use request store' do
          ProjectIdRepository.project_id = 'other_project_id'
          ProjectIdRepository.resolve_project_id.must_equal 'other_project_id'

          ProjectIdRepository.request_safe! do
            ProjectIdRepository.resolve_project_id.must_be_nil
            ProjectIdRepository.with_project_id 'project_id' do
              ProjectIdRepository.resolve_project_id.must_equal 'project_id'
            end
            ProjectIdRepository.resolve_project_id.must_be_nil
          end

          ProjectIdRepository.resolve_project_id.must_equal 'other_project_id'
        end
      end
    end
  end
end
