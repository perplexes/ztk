################################################################################
#
#      Author: Zachary Patten <zachary@jovelabs.net>
#   Copyright: Copyright (c) Jove Labs
#     License: Apache License, Version 2.0
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
################################################################################
module ZTK

  # ZTK::RescueRetry Error Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class RescueRetryError < Error; end

  # RescueRetry Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class RescueRetry

    class << self

      def try(options={}, &block)
        options = Base.build_config({
          :tries => 1,
          :on => Exception,
          :delay => 1
        }.merge(options))
        options.logger.debug { "options=#{options.send(:table).inspect}" }

        !block_given? and Base.log_and_raise(options.logger, RescueRetryError, "You must supply a block!")

        begin
          return block.call
        rescue options.on => e
          if ((options.tries -= 1) > 0)
            options.logger.warn { "Caught #{e.inspect}, we will give it #{options.tries} more tr#{options.tries > 1 ? 'ies' : 'y'}." }
            sleep(options.delay)
            retry
          else
            options.logger.fatal { "Caught #{e.inspect} and we have no more tries left, sorry, we have to give up now." }
            raise e
          end
        end

      end

    end

  end

end
