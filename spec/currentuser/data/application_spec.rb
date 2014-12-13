require 'helper'

module Currentuser
  module Data

    describe Project do

      if ENV['CURRENTUSER_PROJECT_ID_FOR_TESTS']

        before do
          BaseResource.project_id = ENV['CURRENTUSER_PROJECT_ID_FOR_TESTS']
        end

        after do
          BaseResource.project_id = nil
        end

        describe '#current' do

          it 'retrieves data' do
            project = Project.current

            project.id.must_equal ENV['CURRENTUSER_PROJECT_ID_FOR_TESTS']
            project.name.wont_be_nil
            project.url.wont_be_nil
            project.test.must_equal true
            project.is_sign_up_allowed.must_equal true
          end
        end

        describe '#users' do

          it 'raises UnauthorizedAccess if no secret key' do
            project = Project.current
            assert_raises ActiveResource::UnauthorizedAccess do
              project.users(nil)
            end
          end

          it 'raises UnauthorizedAccess if wrong secret key' do
            project = Project.current
            assert_raises ActiveResource::UnauthorizedAccess do
              project.users('wrong secret key')
            end
          end

          if ENV['CURRENTUSER_SECRET_KEY_FOR_TESTS']

            it 'returns an empty collection if no user' do
              project = Project.current
              assert_equal [], project.users(ENV['CURRENTUSER_SECRET_KEY_FOR_TESTS']).to_a
            end

            describe 'with users' do

              after do
                User.delete(:clear)
              end

              it 'returns a collection of users' do
                user_1 = User.create(email: 'email1@test.com', password: 'pass1')
                user_2 = User.create(email: 'email2@test.com', password: 'pass1')

                users = Project.current.users(ENV['CURRENTUSER_SECRET_KEY_FOR_TESTS'])

                assert_equal %w(email1@test.com email2@test.com), users.map(&:email)
                assert_equal [user_1.id, user_2.id], users.map(&:id)
              end
            end
          end
        end

      end
    end
  end
end
