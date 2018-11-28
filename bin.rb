require "Gosu"
class Player
    attr_accessor :x, :y, :w, :h, :speed,:attack_speed,:attack_timer    # Accessors to variables of object
    attr_reader :is_shooting
    def initialize x,y
        @x = x;
        @y = y;             # coordinates of obj
        @w = 32.0;
        @h = 32.0;
        @vx = 0.0;          # vertical speed in x direction
        @speed = 1.0;
        @attack_speed = 10.0;   # for attack blocking
        @attack_timer = 0.0;    # not using yet
        @is_shooting = false
    end

    def moving id
        if Gosu.button_down? Gosu::KB_LEFT      # Moving
            @vx = -@speed;  
        elsif Gosu.button_down? Gosu::KB_RIGHT  # left and right
            @vx = @speed;
        else
            @vx = 0.0;
        end
        if Gosu.button_down? Gosu::KB_SPACE     # Key for shooting
            @is_shooting = true
        else 
            @is_shooting = false
        end
    end

    def update dt
        
        @x += @vx * dt;     # Metod updateing over time
    end

    def show
        Gosu.draw_rect(@x,@y,@w,@h,0xff_ff0000);    # Primitive drawing metod, just for test
    end
end

class Bullet
    attr_accessor :x,:y,:w,:h,:speed,:direction,:from
    def initialize x,y,s,d,f
        @x = x;
        @y = y;
        @w = 16;
        @h = 16;
        @speed = s;
        @direction = d; # for making bulelets fly in different directions
        @from = f;      # for checking who will take damage
    end

    def update dt
        @x += @speed *dt if direction == 'r'    # for different direction we need to change another coordinate
        @x -= @speed *dt if direction == 'l'    
        @y -= @speed *dt if direction == 'u'
        @y += @speed *dt if direction == 'd'
    end

    def show
        Gosu.draw_rect(@x,@y,@w,@h,0xff_ffff00)
    end
end
class Bullets 
    attr_accessor :bullet
    @@Count_of = 0.0; # just for test
    def initialize
        @bullet = [];   # array for storing bullets data
    end

    def add_bullet x, y, s, d, f
        @bullet.push(Bullet.new(x,y,s,d,f));    # adding new bullet to array 
        @@Count_of +=1;
    end

    def show
        @bullet.each do |x|
            x.show
        end
    end

    def update dt 
        @bullet.delete_if do |x|
             if x.y < 0             # if bullet flow out of window
                @@Count_of -=1;     # then we need to delet it
                true
             end
        end
        @bullet.each do |x|
            x.update dt
        end
    end

    def self.Count_of
        return @@Count_of
    end
end
class Enemy 
    attr_accessor :x, :y, :w, :h
    def initialize x,y          # basic eneemy class, it will be an super class in future
        @x = x;
        @y = y;
        @w = 32;
        @h = 32;
    end

    def update(dt)
            # empty for now
    end

    def is_hit(b)
        if @x > b.x + b.w or @y > b.y + b.h or @x + @w < b.x or @y + @h < b.y  # collision checking algorithm
            return false 
        else
            return true
        end
    end

    def show
        Gosu.draw_rect @x, @y, @w, @h, 0xff_00ffff
    end
end 
class Enemies
    attr_accessor :enemy
    @@Count_of = 0;
    def initialize
        @enemy = []     # array for storing enemies
    end
    def add_enemy x,y
        @enemy.push(Enemy.new x, y);
    end
    def update dt
        @enemy.each do |x|
            
        end
    end
    def hit_check bullets
        bullets.each do |y|
            @enemy.delete_if do |x|    # if bullet hit enemy we need to delete it
                x.is_hit(y) 
            end
        end    
    end

    def show
        @enemy.each do |x|
            x.show
        end
    end
end

class Window < Gosu::Window
    def initialize
        super 1024, 720     # Creating window
        self.caption = "Game"       # Default caption for window 
        @player = Player.new 1024/2, 720-32 # Default position for player
        @bullets = Bullets.new  # Creating bullets menager
        @enemies = Enemies.new  # the same for Enemies
            @enemies.add_enemy(10,10)   # add few enemies for test
            @enemies.add_enemy(40,10)
        @now = 0.0              # for delta time checking
        @last = Gosu.milliseconds();
        @dt = 0.0
    end
    def update
        self.caption = "Bullets: #{Bullets.Count_of}";
        @now = Gosu.milliseconds(); 
        @dt = @now - @last      # geting time delta
        @last = Gosu.milliseconds();
        @player.moving nil      # player methods 
        @player.update(@dt)

        @bullets.update(@dt)
        if @player.is_shooting  # enable to shoot
            @bullets.add_bullet(@player.x,@player.y,0.5,'u','p');
        end

        @enemies.hit_check @bullets.bullet

    end

    def draw
        @player.show
        @bullets.show       # drawing methods
        @enemies.show
    end

    def button_down(id)
        if id == Gosu::KB_ESCAPE
            close       # to close window with escape key
        end
    end
end

test = Window.new.show  # creating game object