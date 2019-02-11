module Laksa
  module Util
    class Unit
      ZIL = 'zil'
      LI = 'li'
      QA = 'qa'

      def self.from_qa(qa, unit, is_pack = false)
        ret = case unit
        when ZIL
          qa / 1000000000000.0
        when LI
          qa / 1000000.0
        when QA
          qa
        end

        if is_pack
          ret.round
        else
          ret
        end
      end

      def self.to_qa(qa, unit)
        case unit
        when ZIL
          qa * 1000000000000
        when LI
          qa * 1000000
        when QA
          qa
        end
      end
    end
  end
end