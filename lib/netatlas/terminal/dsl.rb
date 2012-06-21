require 'delegate'
require 'rbcurse/core/widgets/rmenu'
module NetAtlas::Terminal
  @@views = {}
  def self.views; @@views; end

  module DSL
    def init
      VER::start_ncurses
    end
    def window(options = {},  &blk)
      $log.debug "in window"
      if blk
        @@window = Window.new(options, &blk) 
      else
        $log.debug "got here #{@@window.inspect}"
        @@window
      end
      @@window
    end

    def views
      NetAtlas::Terminal.views
    end

    def table_view(name = nil, options = {}, &blk)
      if name.kind_of?(Hash)
        options = name
        name = nil
      end
      TableView.new(options)
    end

    def view(name = nil, options = {}, &blk)
      if name.kind_of?(Hash)
        options = name
        name = nil
      end
      v = View.new(nil, name, options)
      NetAtlas::Terminal.views[name] = v if name
    end

    def run
      @form = RubyCurses::Form.new @@window
      @form.repaint
      @@window.wrefresh
      Ncurses.update_panels
      break_key = ?\C-q.getbyte(0)
      loop do
        catch :close do
          while((ch = @@window.getchar()) != 999) 
            if ch == break_key
              break
            end
            #begin
              @form.handle_key ch
            #rescue => e
            #  textdialog [e.to_s, *e.backtrace], :title => "Exception"
            #end
          end
        end
        stopping = @@window.fire_close_handler
        @@window.wrefresh
        break if stopping
      end
    end
  end

  class Window < DelegateClass(VER::Window)
    attr_reader :root_view
    def initialize(options = {}, &blk)
      @options = options
      super(VER::Window.root_window)
      instance_eval(&blk)
    end
    def menubar(&blk)
      require 'rbcurse/core/widgets/rmenu'
      @menubar = MenuBar.new(&blk)
    end


    def root_view=(v)
      @root_view = v
    end
  end

  class View < SimpleDelegator
    def initialize(delegate = nil, name = nil, options = {}, &blk)
      if name.kind_of?(Hash)
        options = name
        name = nil
      end
      delegate ||= RubyCurses::Widget.new(options)
      super(delegate)
      NetAtlas::Terminal.views[name] = self if name
      instance_eval(&blk)
    end
  end

  class TableView < View
    def initialize(name = nil, options = {}, &blk)
      super(RubyCurses::TabularWidget(nil, options), name, options)
    end
  end

  class MenuBar < View
    def initialize(&blk)
      super(RubyCurses::MenuBar.new(&blk))
    end
  end

end