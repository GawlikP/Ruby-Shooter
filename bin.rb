require "Gosu"
class Player
    attr_accessor :x, :y, :w, :h, :speed,:attack_speed,:attack_timer
    attr_reader :is_shooting
    def initialize x,y
        @x = x;
        @y = y;
        @w = 32.0;
        @h = 32.0;
        @vx = 0.0;
        @speed = 1.0;
        @attack_speed = 10.0;
        @attack_timer = 0.0;
        @is_shooting = false
    end

    def moving id
        if Gosu.button_down? Gosu::KB_LEFT
            @vx = -@speed;
        elsif Gosu.button_down? Gosu::KB_RIGHT
            @vx = @speed;
        else
            @vx = 0.0;
        end
        if Gosu.button_down? Gosu::KB_SPACE
            @is_shooting = true
        else 
            @is_shooting = false
        end
    end

    def update dt
        
        @x += @vx * dt;
    end

    def show
        Gosu.draw_rect(@x,@y,@w,@h,0xff_ff0000);
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
        @direction = d;
        @from = f;
    end

    def update dt
        @x += @speed *dt if direction == 'r'
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
    @@Count_of = 0.0;
    def initialize
        @bullet = [];
    end

    def add_bullet x, y, s, d, f
        @bullet.push(Bullet.new(x,y,s,d,f));
        @@Count_of +=1;
    end

    def show
        @bullet.each do |x|
            x.show
        end
    end

    def update dt 
        @bullet.delete_if do |x|
             if x.y < 0
                @@Count_of -=1;
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
    def initialize x,y
        @x = x;
        @y = y;
        @w = 32;
        @h = 32;
    end

    def update(dt)
    end

    def is_hit(b)
        if @x > b.x + b.w or @y > b.y + b.h or @x + @w < b.x or @y + @h < b.y  
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
        @enemy = []
    end
    def add_enemy x,y
        @enemy.push(Enemy.new x, y);
    end
    def update dt
        @enemy.each do |x|
            
        end
    end
    def hit_check bullets
       @enemy.delete_if do |x|
            bullets.each do |y|
                if x.hit(y) 
                    true
                end
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
        super 1024, 720
        self.caption = "Game"
        @player = Player.new 1024/2, 720-32
        @bullets = Bullets.new
        @enemies = Enemies.new 
            @enemies.add_enemy(10,10)
            @enemies.add_enemy(40,10)
        @now = 0.0
        @last = Gosu.milliseconds();
        @dt = 0.0
    end
    def update
        self.caption = "Bullets: #{Bullets.Count_of}";
        @now = Gosu.milliseconds();
        @dt = @now - @last
        @last = Gosu.milliseconds();
        @player.moving nil
        @player.update(@dt)

        @bullets.update(@dt)
        if @player.is_shooting
            @bullets.add_bullet(@player.x,@player.y,0.5,'u','p');
        end

        @enemies.hit_check @bullets.bullet

    end

    def draw
        @player.show
        @bullets.show
        @enemies.show
    end

    def button_down(id)
        if id == Gosu::KB_ESCAPE
            close
        end
    end
end

test = Window.new.show