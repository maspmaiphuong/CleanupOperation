#encoding: utf-8
require 'rubygems'
require 'gosu'

#constants for screen width and height
$width = 1280
$height = 800

#determins layers of things placed on screen
#background is the lowest layer, user interface is the highest layer
module ZOrder
    BACKGROUND, OBJECT, PLAYER, UI = *0..3
end

class Soap
    attr_accessor :score, :image, :squee, :clean

    def initialize()
        @score = 0
        @image = Gosu::Image.new("media/soap.png")
        @squee = Gosu::Sample.new("media/squee.mp3")
        @clean = 100
    end
end 

class Dirt
    attr_accessor :x, :y, :type, :image, :level, :loc, :immune

    def initialize(image, type, loc)
        @type = type;
        @image = Gosu::Image.new(image)
        @loc = loc
        @immune = 0
        @level = 1
        case loc.to_i
        when 0
            @x = $width.to_f/3-@image.width+120
            @y = $height.to_f/3-@image.height
        when 1
            @x = $width.to_f/3-@image.width+120
            @y = ($height.to_f/3)*2-@image.height
        when 2
            @x = ($width.to_f/3)*2-@image.width+120
            @y = ($height.to_f/3)-@image.height
        when 3
            @x = ($width.to_f/3)*3-@image.width
            @y = ($height.to_f/3)*3-@image.height
        when 4
            @x = $width.to_f/3*(2)-@image.width+120
            @y = $height.to_f/3*3-@image.height
        when 5
            @x = ($width.to_f/4)*(3)-@image.width
            @y = ($height.to_f/4)*(2)-@image.height
        end
        if (@x<0) 
            @x = @x*(-1)
        end
        if (@y<0) 
            @y = @y*(-1)
        end
    end
end

def draw_dirt dirt
    dirt.image.draw(dirt.x, dirt.y, ZOrder::OBJECT)
end

def update_level dirt
    case dirt.type
    when :dirt1
        if dirt.level == 2 
            dirt.image = Gosu::Image.new("media/dirt-1-lv2.png")
        elsif dirt.level >= 3
            dirt.image = Gosu::Image.new("media/dirt-1-lv3.png")
        end
    when :dirt2
        if dirt.level == 2 
            dirt.image = Gosu::Image.new("media/dirt-2-lv2.png")
        elsif dirt.level >= 3
            dirt.image = Gosu::Image.new("media/dirt-2-lv3.png")
        end
    when :dirt3
        if dirt.level == 2 
            dirt.image = Gosu::Image.new("media/dirt-3-lv2.png")
        elsif dirt.level >= 3
            dirt.image = Gosu::Image.new("media/dirt-3-lv3.png")
        end
    when :dirt4
        if dirt.level == 2 
            dirt.image = Gosu::Image.new("media/dirt-4-lv2.png")
        elsif dirt.level >= 3
            dirt.image = Gosu::Image.new("media/dirt-4-lv3.png")
        end
    end
end

class Bonus
    attr_accessor :image, :type, :x, :y, :vel_x, :vel_y, :blink, :poose, :splash

    def initialize(image, type)
        @type = type
        @image = Gosu::Image.new(image)
        @vel_x = rand(-4..4)
        @vel_y = rand(-4..4)
        @x = rand*($width)
        @y = rand*($height)
        @blink = Gosu::Sample.new("media/blink.mp3")
        @poose = Gosu::Sample.new("media/poose.mp3")
        @splash = Gosu::Sample.new("media/splash.mp3")
    end
end

def generate_bonus
    case rand(7)
    when 0
        Bonus.new("media/bonus.png", :bonus)
    when 1
        Bonus.new("media/poo.png", :poo)
    when 2
        Bonus.new("media/water.png", :water)
    when 3
        Bonus.new("media/bonus.png", :bonus)
    when 4
        Bonus.new("media/bonus.png", :bonus)
    when 5
        Bonus.new("media/bonus.png", :bonus)
    when 6
        Bonus.new("media/poo.png", :poo)
    end
end

def move_bonus bonus
    bonus.x += bonus.vel_x
    bonus.y += bonus.vel_y
end

def change_direction bonus
    if rand(200) == 25
        bonus.vel_x = rand(-4...4)
        bonus.vel_y = rand(-4...4)
    end
end

def draw_bonus bonus
    bonus.image.draw(bonus.x, bonus.y, ZOrder::OBJECT)
end

def collect_bonus(all_bonus, soap, all_dirt)
    all_bonus.reject! do |bonus|
        if Gosu.distance(mouse_x, mouse_y, bonus.x, bonus.y) < 80
            case bonus.type
            when :bonus
                soap.clean += 20 
                bonus.blink.play
            when :poo
                soap.clean -= 20
                bonus.poose.play
            when :water
                all_dirt.reject! do |dirt|
                    @locq << dirt.loc
                    true
                end
                bonus.splash.play
            end
            true
        else
            false
        end
    end
end

class Meter
    attr_accessor :point, :base, :meter

    def initialize
        @point = 100
        @base = Gosu::Image.new("media/meter-base.png")
        @meter = Gosu::Image.new("media/meter.png")
    end
end

def clean_dirt(all_dirt, soap)
    all_dirt.reject! do |dirt|
        if (dirt.immune <= 0)
            if (dirt.level > 3)
                @locq << dirt.loc
                soap.score += 10
                soap.clean -= 10
                soap.squee.play
                true
            elsif (Gosu.distance(mouse_x-141, mouse_y-141, dirt.x, dirt.y) < 80) and (dirt.level <= 3)
                soap.score += 1
                soap.clean -= 1
                dirt.level += 1
                dirt.immune = 10
                false
            else
                false
            end
        end
    end
end

def update_meter(soap, meter)
    if soap.clean > 75
        meter.meter = Gosu::Image.new("media/meter.png")
        soap.image = Gosu::Image.new("media/soap.png")
    elsif soap.clean > 50
        meter.meter = Gosu::Image.new("media/meter-75.png")
        soap.image = Gosu::Image.new("media/soap.png")
    elsif soap.clean > 25 
        meter.meter = Gosu::Image.new("media/meter-50.png")
        soap.image = Gosu::Image.new("media/soap-dirty.png")
    elsif soap.clean > 5
        meter.meter = Gosu::Image.new("media/meter-25.png")
    elsif soap.clean > 0 
        meter.meter = Gosu::Image.new("media/meter-05.png")
    else 
        meter.meter = Gosu::Image.new("media/meter-00.png")
    end
end

class CleanupOperationGame < Gosu::Window
    def initialize

        super($width,$height)
        self.caption = "Cleanup Operation Game"

        @background_image = Gosu::Image.new("media/game-background.png")
        @all_dirt = Array.new
        @all_bonus = Array.new
        @locq = SizedQueue.new(6)
        @locq << 1
        @locq << 2
        @locq << 3
        @locq << 4
        @locq << 5
        @locq << 0
        @meter = Meter.new
        @player = Soap.new
        @font = Gosu::Font.new(30)
        @playing = true
        @start_time = 0
    end

    def draw
        @background_image.draw(0, 0, ZOrder::BACKGROUND)
        @player.image.draw(mouse_x-141,mouse_y-141,ZOrder::PLAYER)
        @meter.base.draw(10,60,ZOrder::OBJECT)
        @meter.meter.draw(10,60,ZOrder::OBJECT)
        @all_dirt.each { |dirt| draw_dirt dirt }
        @all_bonus.each { |bonus| draw_bonus bonus }
        @font.draw("Score: #{@player.score}", 10, 10, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
        @font.draw(@time_left.to_s, 200, 10, 2)

        unless @playing
            @font.draw('Game Over', 300, 300, 3)
            @font.draw('Press the Space Bar to Play Again', 175, 350, 3)
         end
    end

    def update
        if @playing 
            @time_left = (30 - ((Gosu.milliseconds - @start_time) / 1000))
            @playing = false if @time_left < 0
            @playing = false if @player.clean < 0
            update_meter(@player, @meter)

            @all_dirt.each do |dirt|
                if dirt.level > 1
                    update_level dirt
                end

                if dirt.immune > 0
                    dirt.immune -= 1
                end
            end

            @all_bonus.each do |bonus|
                if (bonus.vel_x == 0)
                    bonus.vel_x = rand(-2...2)
                end
                if (bonus.vel_y == 0)
                    bonus.vel_y = rand(-2...2)
                end

                move_bonus bonus
                change_direction bonus
            end

            self.remove_bonus

            if button_down?(Gosu::MsLeft)   
                clean_dirt(@all_dirt, @player)
                collect_bonus(@all_bonus, @player, @all_dirt)
            end

            if rand(100) < 2 and @all_dirt.size < 6
                @all_dirt.push(generate_dirt)
            end

            if rand(100) < 2 and @all_bonus.size < 2
                @all_bonus.push(generate_bonus)
            end
        end
    end

    def generate_dirt
        case rand(4)
        when 0
            Dirt.new("media/dirt-1.png",:dirt1,@locq.pop)
        when 1
            Dirt.new("media/dirt-2.png",:dirt2,@locq.pop)
        when 2
            Dirt.new("media/dirt-3.png",:dirt3,@locq.pop)
        when 3
            Dirt.new("media/dirt-4.png",:dirt4,@locq.pop)
        end
    end

    #remove the bonus that go out of the screen
    def remove_bonus
        @all_bonus.reject! do |bonus|
            puts bonus.image.width
            if (bonus.x+bonus.image.width/2 > $width) or (bonus.y+bonus.image.height/2 > $height) or (bonus.x - bonus.image.width/2 < 0) or (bonus.y-bonus.image.height/2 < 0)
                true
            else
                false
            end
        end
    end

    def button_down(id)
        if id == Gosu::KB_ESCAPE
            close
        end

        if (id == Gosu::KB_SPACE)
            @playing = true
            @start_time = Gosu.milliseconds
            @player.clean = 100
            @player.score = 0
        end

    end
end

CleanupOperationGame.new.show if __FILE__ == $0
