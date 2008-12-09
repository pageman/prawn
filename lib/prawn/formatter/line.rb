module Prawn
  class Formatter

    class Line
      attr_reader :instructions

      def initialize(instructions, hard_break)
        @instructions = instructions
        @instructions.pop while @instructions.last && @instructions.last.discardable?

        @hard_break = hard_break

        @spaces = @instructions.inject(0) { |sum, instruction| sum + instruction.spaces }
        @spaces = [1, @spaces].max
      end

      def hard_break?
        @hard_break
      end

      def width
        instructions.inject(0) { |sum, instruction| sum + instruction.width }
      end

      def height(include_blank=false)
        instructions.map { |instruction| instruction.height(include_blank) }.max
      end

      def draw_on(document, state, options={})
        return if instructions.empty?

        case(options[:align]) 
        when :left
          state[:x] = 0
        when :center
          state[:x] = (state[:width] - width) / 2.0
        when :right
          state[:x] = state[:width] - width
        when :justify
          state[:x] = 0
          state[:padding] = hard_break? ? 0 : (state[:width] - width) / @spaces
          state[:text].word_space(state[:padding])
        end

        state[:y] -= height + (options[:spacing] || 0)

        relative_x = state[:x] - state[:last_x]
        state[:last_x] = state[:x]
        state[:text].move(relative_x, -(height + (options[:spacing] || 0)))

        LinkStartInstruction.resume(document, state)
        state[:accumulator] = nil

        instructions.each { |instruction| instruction.draw(document, state, options) }

        LinkEndInstruction.pause(instructions.last.state, document, state, options)

#new_x = state[:width] + 10
#relative_x = new_x - state[:last_x]
#state[:last_x] = new_x
#state[:text].move(relative_x, 0)
#state[:text].show(self[:badness].to_s)
      end
    end

  end
end