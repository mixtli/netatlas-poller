module NetAtlas::Renderer
  class Table
    include CommandLineReporter

    def initialize(data, *args)
      @data = data
      @headers = args.map do |arg|
        if arg.kind_of?(Hash)
          arg[:label] ||= arg[:field].to_s
          arg
        else
          {:field => arg, :label => arg.to_s}
        end
      end
    end

    def render
      suppress_output
      table(:border => true ) do
        row :header => true do
          @headers.each do |h|
            h[:width] ||= 80 / @headers.size
            column h[:label], h.slice(:width, :padding, :align, :bold, :underline, :reversed)
          end
        end
        @data.each do |record|
          row do
            @headers.each do |h|
              column record[h[:field]]
            end
          end
        end
      end
      return capture_output
    end
  end
end