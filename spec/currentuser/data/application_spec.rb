require 'helper'

module Currentuser
  module Data

    describe Application do

      if ENV['CURRENTUSER_APPLICATION_ID_FOR_TESTS']

        before do
          Application.application_id = ENV['CURRENTUSER_APPLICATION_ID_FOR_TESTS']
        end

        after do
          Application.application_id = nil
        end

        describe '#current' do

          it 'retrieves data' do
            application = Application.current

            application.id.must_equal ENV['CURRENTUSER_APPLICATION_ID_FOR_TESTS']
            application.name.wont_be_nil
            application.url.wont_be_nil
            application.test.must_equal true
          end
        end
      end
    end
  end
end
